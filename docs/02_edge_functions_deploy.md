# Step 2: Edge Functions 4종 배포 (Supabase Dashboard)

> 예상 소요 시간: **10분** (각 함수당 2분)  
> 비용: **무료** (Supabase Free 50만 호출/월)

---

## 🎯 배포 순서 (반드시 이 순서대로!)

함수 간 호출 관계가 있어 의존성 순서대로 배포해야 합니다:

```
1️⃣ check_titles      (의존 없음)
       ↓ 호출됨
2️⃣ award_xp          (check_titles 호출)
       ↓ 호출됨
3️⃣ get_nearby_badges (의존 없음)
4️⃣ award_badge       (award_xp 호출)
```

---

## ▶️ 시작: Edge Functions 메뉴 열기

브라우저에서 다음 링크 열기:

**👉 https://supabase.com/dashboard/project/wucbvyxneegbpjvamhfo/functions**

상단의 초록색 **"Deploy a new function"** 버튼 클릭 → **"Via Editor"** 선택.

---

## 1️⃣ check_titles 배포

### Step 1.1: 함수 생성

**Deploy a new function** → **Via Editor**:

```
Name: check_titles
```

### Step 1.2: 코드 붙여넣기

파일 위치:
```
voyna-app\supabase\functions\check_titles\index.ts
```

1. 이 파일을 **VS Code** 또는 **메모장**으로 열기
2. **Ctrl + A → Ctrl + C** (전체 복사)
3. Supabase 에디터에서 기본 템플릿 코드를 **모두 지우고** (Ctrl+A → Delete)
4. **Ctrl + V** 붙여넣기

### Step 1.3: 배포

우측 하단 **"Deploy function"** 버튼 클릭.

⏳ 약 30초 후 ✅ 초록색 "Deployed" 표시.

→ 좌측 사이드바 Functions 목록에 `check_titles`가 생성됨.

---

## 2️⃣ award_xp 배포

### Step 2.1: 새 함수

상단 **"Deploy a new function"** → **"Via Editor"**:

```
Name: award_xp
```

### Step 2.2: 코드 붙여넣기

파일 위치:
```
voyna-app\supabase\functions\award_xp\index.ts
```

→ 전체 복사 → 에디터 비우고 붙여넣기 → **Deploy function** ▶️

---

## 3️⃣ get_nearby_badges 배포

```
Name: get_nearby_badges
```

파일:
```
voyna-app\supabase\functions\get_nearby_badges\index.ts
```

→ 복사 → 붙여넣기 → **Deploy function** ▶️

---

## 4️⃣ award_badge 배포

```
Name: award_badge
```

파일:
```
voyna-app\supabase\functions\award_badge\index.ts
```

→ 복사 → 붙여넣기 → **Deploy function** ▶️

---

## ✅ 배포 완료 확인

Functions 목록에 4개가 모두 보이고 상태가 **Active (초록)** 면 완료:

```
✓ check_titles        Active
✓ award_xp            Active
✓ get_nearby_badges   Active
✓ award_badge         Active
```

---

## 🔧 환경변수 — 자동 설정됨

Supabase Edge Functions는 다음 환경변수를 **자동으로 제공**합니다:
- `SUPABASE_URL` ✅
- `SUPABASE_ANON_KEY` ✅
- `SUPABASE_SERVICE_ROLE_KEY` ✅

→ 별도 설정 필요 없음.

---

## 📥 완료 후 답변

다음 양식으로 알려주세요:

```
✅ check_titles 배포 완료
✅ award_xp 배포 완료
✅ get_nearby_badges 배포 완료
✅ award_badge 배포 완료
```

또는 **"4개 다 완료"** 라고 한 줄로 알려주셔도 됩니다.

→ 제가 즉시 API로 자동 테스트 후, **Phase 2 (카카오/구글 OAuth)** 로 진행합니다.

---

## 🚨 문제 해결

| 증상 | 해결 |
|------|------|
| Deploy 후 "Error: failed to compile" | 코드 복사 시 첫 줄이 잘못 붙음 — 첫 줄이 `// Voyna Edge Function:`로 시작하는지 확인 |
| "function name already exists" | 이미 같은 이름으로 만들어진 것 — 좌측에서 클릭 후 코드 수정 |
| "permission denied" | Free 플랜 최대 함수 수 초과? — 50개까지 무료, 문제될 일 없음 |
| Deploy 버튼이 회색 | 우측 상단 함수 이름이 비어있는지 확인 |

코드는 모두 **Deno 런타임**으로 실행되며 — `Deno.serve()` 패턴은 Supabase 권장 최신 방식입니다 (별도 import 불필요).
