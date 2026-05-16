// Voyna Edge Function: award_badge
// 배지 획득 메인 진입점 — GPS 좌표 검증 + 등급별 분기 + XP 트리거
// 호출: POST { badge_id, user_lat, user_lng, accuracy_m?, confirmed? }
//      Authorization: Bearer <user_jwt> (필수)

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

// Haversine 거리 (m)
function haversine(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371000;
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    // 1. 사용자 인증
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    const jwt = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authErr } = await supabase.auth.getUser(jwt);
    if (authErr || !user) {
      return new Response(JSON.stringify({ error: "Invalid token" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. 페이로드 검증
    const p = await req.json();
    if (
      typeof p.badge_id !== "number" ||
      typeof p.user_lat !== "number" ||
      typeof p.user_lng !== "number"
    ) {
      return new Response(JSON.stringify({ error: "badge_id, user_lat, user_lng required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 3. 배지 + 명소 정보
    const { data: badge, error: bErr } = await supabase
      .from("badges")
      .select("id, name, grade, xp_reward, requires_confirmation, location_id, icon, image_url, locations(lat, lng, radius_m, name)")
      .eq("id", p.badge_id)
      .single();
    if (bErr || !badge) {
      return new Response(JSON.stringify({ error: "Badge not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 4. 확인형 배지인데 confirmed=false면 팝업 요청 응답
    if (badge.requires_confirmation && !p.confirmed) {
      return new Response(
        JSON.stringify({ requires_confirmation: true, badge }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // 5. 거리 검증
    const loc: any = badge.locations;
    if (!loc) {
      return new Response(JSON.stringify({ error: "Location data missing" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    const dist = haversine(p.user_lat, p.user_lng, loc.lat, loc.lng);
    if (dist > loc.radius_m) {
      return new Response(
        JSON.stringify({
          error: "Out of range",
          distance_m: Math.round(dist),
          allowed_m: loc.radius_m,
        }),
        { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // 6. GPS 정확도 검증 (50m 초과 시 거부)
    if (typeof p.accuracy_m === "number" && p.accuracy_m > 50) {
      return new Response(
        JSON.stringify({ error: "GPS accuracy too low", accuracy_m: p.accuracy_m }),
        { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // 7. 중복 획득 체크 + 삽입 (UNIQUE 제약 활용)
    const { error: insertErr } = await supabase
      .from("user_badges")
      .insert({
        user_id: user.id,
        badge_id: badge.id,
        lat: p.user_lat,
        lng: p.user_lng,
      });
    if (insertErr) {
      if (insertErr.code === "23505") {
        return new Response(JSON.stringify({ error: "Already obtained" }), {
          status: 409,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
      throw insertErr;
    }

    // 8. XP 적립 (award_xp 호출)
    const xpRes = await supabase.functions.invoke("award_xp", {
      body: {
        user_id: user.id,
        amount: badge.xp_reward,
        reason: "badge_obtained",
        ref_badge_id: badge.id,
      },
    });

    return new Response(
      JSON.stringify({
        success: true,
        badge,
        xp_gained: badge.xp_reward,
        new_level: xpRes.data?.new_level,
        current_xp: xpRes.data?.current_xp,
        next_level_xp: xpRes.data?.next_level_xp,
        level_up: xpRes.data?.level_up ?? false,
        levels_gained: xpRes.data?.levels_gained ?? [],
        new_titles: xpRes.data?.new_titles ?? [],
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (e) {
    console.error("award_badge error:", e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
