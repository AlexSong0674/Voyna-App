// Voyna Edge Function: get_nearby_badges
// 현재 위치 기준 반경 N km 내 배지 조회 + 사용자별 획득 여부 표시
// 호출: GET ?lat=37.5663&lng=126.9779&radius_km=5
//      (옵션) Authorization: Bearer <jwt> → obtained 필드 정확히 반환

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
};

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const url = new URL(req.url);
    const lat = parseFloat(url.searchParams.get("lat") ?? "");
    const lng = parseFloat(url.searchParams.get("lng") ?? "");
    const radiusKm = parseFloat(url.searchParams.get("radius_km") ?? "5");

    if (isNaN(lat) || isNaN(lng)) {
      return new Response(JSON.stringify({ error: "lat and lng required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 로그인된 사용자면 ID 추출 (선택)
    let userId: string | null = null;
    const authHeader = req.headers.get("Authorization");
    if (authHeader) {
      const jwt = authHeader.replace("Bearer ", "");
      const { data } = await supabase.auth.getUser(jwt);
      userId = data.user?.id ?? null;
    }

    // 1. 반경 내 명소 ID 조회
    const { data: locations, error: locErr } = await supabase.rpc(
      "get_locations_within_radius",
      { p_lat: lat, p_lng: lng, p_radius_m: radiusKm * 1000 },
    );
    if (locErr) throw locErr;

    const locationIds = (locations ?? []).map((l: any) => l.id);
    if (locationIds.length === 0) {
      return new Response(JSON.stringify({ badges: [], count: 0 }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. 해당 명소들의 배지 정보 (locations join)
    const { data: badges, error: bErr } = await supabase
      .from("badges")
      .select("*, locations(id, name, lat, lng, radius_m, category, district, description)")
      .in("location_id", locationIds);
    if (bErr) throw bErr;

    // 3. 사용자의 획득 배지 ID 목록
    let obtainedIds: number[] = [];
    if (userId) {
      const { data: ub } = await supabase
        .from("user_badges")
        .select("badge_id")
        .eq("user_id", userId);
      obtainedIds = (ub ?? []).map((r: any) => r.badge_id);
    }

    // 4. obtained 플래그 추가
    const result = (badges ?? []).map((b: any) => ({
      ...b,
      obtained: obtainedIds.includes(b.id),
    }));

    return new Response(JSON.stringify({ badges: result, count: result.length }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("get_nearby_badges error:", e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
