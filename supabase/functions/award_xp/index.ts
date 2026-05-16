// Voyna Edge Function: award_xp
// XP 적립 + 자동 레벨업 처리 + 칭호 자동 체크
// 호출: POST { user_id, amount, reason, ref_badge_id? }

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

// 레벨 n에서 n+1로 가는 데 필요한 XP: 100 × n^1.6
function xpForLevel(n: number): number {
  return Math.floor(100 * Math.pow(n, 1.6));
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const p = await req.json();
    if (!p.user_id || typeof p.amount !== "number" || p.amount <= 0) {
      return new Response(JSON.stringify({ error: "user_id and positive amount required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 1. xp_log 기록
    await supabase.from("xp_log").insert({
      user_id: p.user_id,
      amount: p.amount,
      reason: p.reason ?? "badge_obtained",
      ref_badge_id: p.ref_badge_id ?? null,
    });

    // 2. 현재 사용자 정보 조회
    const { data: u, error: uErr } = await supabase
      .from("users")
      .select("level, xp")
      .eq("id", p.user_id)
      .single();
    if (uErr || !u) {
      return new Response(JSON.stringify({ error: "User not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 3. 레벨업 연쇄 계산
    let newXp = u.xp + p.amount;
    let newLevel = u.level;
    const leveledUp: number[] = [];

    while (newLevel < 99 && newXp >= xpForLevel(newLevel)) {
      newXp -= xpForLevel(newLevel);
      newLevel += 1;
      leveledUp.push(newLevel);
    }

    // 4. users 업데이트
    await supabase
      .from("users")
      .update({ level: newLevel, xp: newXp })
      .eq("id", p.user_id);

    // 5. 칭호 자동 체크
    const { data: titlesData } = await supabase.functions.invoke("check_titles", {
      body: { user_id: p.user_id },
    });

    return new Response(
      JSON.stringify({
        success: true,
        new_level: newLevel,
        level_up: leveledUp.length > 0,
        levels_gained: leveledUp,
        current_xp: newXp,
        next_level_xp: newLevel < 99 ? xpForLevel(newLevel) : null,
        new_titles: titlesData?.new_titles ?? [],
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (e) {
    console.error("award_xp error:", e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
