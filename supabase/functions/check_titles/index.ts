// Voyna Edge Function: check_titles
// 사용자의 현재 보유 배지·레벨·지역수를 보고 칭호 조건 충족 여부 체크,
// 처음 부여되는 칭호는 자동으로 user.title에 장착.

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

async function badgeCount(uid: string): Promise<number> {
  const { count } = await supabase
    .from("user_badges")
    .select("*", { count: "exact", head: true })
    .eq("user_id", uid);
  return count ?? 0;
}

async function userLevel(uid: string): Promise<number> {
  const { data } = await supabase.from("users").select("level").eq("id", uid).single();
  return data?.level ?? 0;
}

async function categoryCount(uid: string, cat: string): Promise<number> {
  const { data } = await supabase.rpc("count_category_badges", {
    p_user_id: uid,
    p_category: cat,
  });
  return Number(data ?? 0);
}

async function regionCount(uid: string): Promise<number> {
  const { data } = await supabase
    .from("user_badges")
    .select("badges!inner(locations!inner(region))")
    .eq("user_id", uid);
  if (!data) return 0;
  const regions = new Set<string>();
  for (const row of data as any[]) {
    const region = row.badges?.locations?.region;
    if (region) regions.add(region);
  }
  return regions.size;
}

// 칭호 정의 — 약한 조건부터 강한 조건 순서 (마지막이 가장 높은 등급)
const TITLES: { name: string; check: (uid: string) => Promise<boolean> }[] = [
  { name: "동네 탐험가",     check: async (u) => (await badgeCount(u)) >= 5 },
  { name: "국내 여행러",     check: async (u) => (await regionCount(u)) >= 3 },
  { name: "도시 헌터",       check: async (u) => (await categoryCount(u, "랜드마크")) >= 5 },
  { name: "산악인",          check: async (u) => (await categoryCount(u, "자연")) >= 5 },
  { name: "지도 마니아",     check: async (u) => (await badgeCount(u)) >= 30 },
  { name: "고수 여행자",     check: async (u) => (await userLevel(u)) >= 50 },
  { name: "전설의 여행자",   check: async (u) => (await userLevel(u)) >= 99 && (await badgeCount(u)) >= 200 },
];

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { user_id } = await req.json();
    if (!user_id) {
      return new Response(JSON.stringify({ error: "user_id required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const earned: string[] = [];
    for (const t of TITLES) {
      if (await t.check(user_id)) earned.push(t.name);
    }

    // 사용자가 아직 칭호가 없으면 가장 높은 등급으로 자동 장착
    if (earned.length > 0) {
      const { data: u } = await supabase
        .from("users")
        .select("title")
        .eq("id", user_id)
        .single();
      if (!u?.title) {
        await supabase
          .from("users")
          .update({ title: earned[earned.length - 1] })
          .eq("id", user_id);
      }
    }

    return new Response(JSON.stringify({ new_titles: earned }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("check_titles error:", e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
