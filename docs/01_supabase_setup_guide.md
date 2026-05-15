# Step 1: Supabase 계정 생성 및 프로젝트 셋업

> 예상 소요 시간: **10분**  
> 비용: **무료** (MAU 5만까지 무료 플랜)

---

## 1️⃣ 가입 (3분)

1. 브라우저에서 **https://supabase.com** 접속
2. 우측 상단 **"Start your project"** 클릭
3. **"Continue with GitHub"** 권장 (기존 GitHub `AlexSong0674` 계정 사용)
   - GitHub 인증 페이지에서 **Authorize Supabase**
4. 대시보드 화면이 뜨면 가입 완료 ✅

---

## 2️⃣ 조직(Organization) 생성 (1분)

처음 로그인 시 자동으로 조직 생성 화면이 뜹니다.

```
Organization name: Voyna
Type: Personal
Plan: Free  ← 절대 Pro/Team 클릭 X
```

→ **Create organization** 클릭.

---

## 3️⃣ 새 프로젝트 생성 (3분)

조직 대시보드에서 **"New project"** 클릭.

```
┌───────────────────────────────────────────┐
│ Project name:     voyna-prod              │
│                                           │
│ Database Password:                        │
│   [20자 이상 강력한 비밀번호 생성]            │
│   ⚠️ 이 비밀번호는 1Password 또는 메모장에    │
│      반드시 따로 저장하세요!                  │
│                                           │
│ Region: Northeast Asia (Seoul)            │
│         ap-northeast-2                    │
│                                           │
│ Pricing Plan: Free                        │
└───────────────────────────────────────────┘
```

→ **Create new project** 클릭.

⏳ 약 2분 대기 (프로비저닝).

---

## 4️⃣ 핵심 키 3종 복사 (1분)

프로젝트 생성 후, 좌측 사이드바 → ⚙️ **Settings** → **API**:

다음 3가지를 복사해 메모장에 저장:

```
1. Project URL:
   https://xxxxxxxxxxxx.supabase.co

2. anon (public) key:
   eyJhbGci... (200자 정도)
   ← 클라이언트 앱에서 사용

3. service_role key:
   eyJhbGci... (200자 정도)
   ← 서버 측에서만 사용, 절대 앱에 노출 금지!
```

⚠️ **service_role 키는 절대 GitHub에 푸시하지 마세요.** Edge Function 환경변수로만 사용합니다.

---

## 5️⃣ 스키마 적용 (2분)

좌측 사이드바 → 🗄 **SQL Editor** → **+ New query**

1. `voyna-app/supabase/migrations/0001_initial_schema.sql` 파일을 메모장으로 열기
2. 전체 내용 복사
3. Supabase SQL Editor에 붙여넣기
4. 우측 하단 **Run** 클릭 (또는 Ctrl+Enter)

✅ 성공 시: 하단에 "Success. No rows returned" 메시지.

⚠️ 에러 시: 에러 메시지를 그대로 복사해 알려주세요.

---

## 6️⃣ 시드 데이터 적용 (1분)

같은 SQL Editor에서:

1. `voyna-app/supabase/migrations/0002_seed_data.sql` 파일 내용 복사
2. SQL Editor에 붙여넣기 (이전 쿼리 지우고)
3. **Run** 클릭

✅ 마지막 5줄에 다음 결과가 보이면 성공:

| table_name | count |
|------------|-------|
| locations | 30 |
| badges | 30 |
| badges_common | 19 |
| badges_rare | 8 |
| badges_special | 3 |

---

## 7️⃣ 확인 (선택)

좌측 🗄 **Table Editor**에서 다음 테이블들이 생성됐는지 확인:

- ✅ users (비어있음, 가입 시 자동 추가)
- ✅ locations (30행)
- ✅ badges (30행)
- ✅ user_badges (비어있음)
- ✅ xp_log (비어있음)
- ✅ subscriptions (비어있음)
- ✅ seasons, events (비어있음)

---

## ✅ 완료 후 알려주세요

다음 정보를 채팅으로 알려주시면 다음 단계로 진행합니다 (anon key는 공개되어도 안전합니다):

```
Project URL: https://_____________.supabase.co
anon key:    eyJhbGci...
```

⚠️ **service_role key는 절대 채팅에 입력하지 마세요.** 별도로 보관해두시면 됩니다.

---

## 🚨 문제 해결

| 증상 | 해결 |
|------|------|
| 가입 시 GitHub 인증 안 됨 | 시크릿 창에서 GitHub 로그아웃 후 재시도 |
| 프로젝트 생성 후 멈춤 (5분 이상) | 페이지 새로고침, 안 되면 다른 region 시도 |
| SQL Run 시 "extension cube does not exist" | 무시 가능 (CREATE EXTENSION IF NOT EXISTS가 처리) |
| RLS 에러 "permission denied" | 위 SQL이 모두 적용됐는지 확인, 안 됐으면 다시 Run |

---

## 다음 단계 (Step 2)

Supabase 셋업 완료 후 → **카카오 디벨로퍼스 + Google OAuth 가입** (소요 15분)
