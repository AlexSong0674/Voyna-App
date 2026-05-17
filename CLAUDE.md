# Voyna (보이나) — 앱 코드 저장소

> 알토대학원 벤처 스타트업 과제 — GPS 기반 여행 인증 배지 앱  
> 기획서 폴더: `../기획서/` (별도 git 저장소)  
> 이 저장소: https://github.com/AlexSong0674/Voyna-App  
> 최종 업데이트: 2026-05-12

---

## 한 줄 요약

**Voyna** — *Voyage + Navigation* + 한국어 "보이나"의 이중 의미.  
"발걸음이 기록이 되고, 기록이 추억이 된다."

---

## 디렉토리 구조

```
voyna-app/
├── CLAUDE.md                       ← 이 파일
├── README.md                       ← 프로젝트 소개
├── .env                            ← Supabase URL/key (gitignored)
├── .env.example                    ← 환경변수 템플릿
├── .gitignore
├── supabase/
│   ├── migrations/
│   │   ├── 0000_reset.sql          ← 초기 reset (재실행 가능)
│   │   ├── 0001_initial_schema.sql ← 8 테이블 + RLS + 트리거 + 4 RPC
│   │   └── 0002_seed_data.sql      ← 서울 30곳 + 30 배지
│   └── functions/
│       ├── check_titles/           ← 칭호 자동 부여
│       ├── award_xp/               ← XP 적립 + 레벨업
│       ├── get_nearby_badges/      ← 주변 배지 조회
│       └── award_badge/            ← 배지 획득 메인
├── lib/                            ← Flutter 코드 (Phase 2부터 생성)
├── assets/                         ← 배지 이미지·아이콘·사운드
├── docs/
│   ├── 01_supabase_setup_guide.md  ← Supabase 가입 가이드
│   ├── 02_edge_functions_deploy.md ← Edge Function 배포 가이드
│   └── decisions.md                ← 주요 결정사항 로그 ⭐
└── scripts/                        ← 빌드·배포 자동화
```

---

## 현재 상태 (2026-05-12 기준)

### ✅ 완료된 것
- **Supabase 백엔드 100%** — 8 테이블 + RLS + 4 Edge Function 모두 ACTIVE
- **시드 데이터** — 서울 30 명소 + 30 배지 입력 완료
- **로컬 → GitHub** push 완료

### 🔄 진행 중
- **Phase 2: 인증 시스템** — Kakao + Google OAuth 셋업 (V1.1에 Naver 추가 예정)

### 📋 다음 단계 (Phase 3+)
- Flutter 프로젝트 초기화
- 4탭 UI (홈/맵/배지/더보기)
- GPS + 배지 획득 로직
- AI 무료 도구로 배지 30종 디자인
- TestFlight 베타 → App Store 출시

---

## 기술 스택 (확정)

| 영역 | 도구 | 비용 |
|------|------|------|
| 앱 | **Flutter (Raw)** — Dart 직접 작성 | 무료 |
| 백엔드 | **Supabase** (PostgreSQL + Auth + Edge Functions + Storage) | Free 플랜 |
| 지도 | **카카오맵** (WebView) | 무료 (월 300만 호출) |
| 인증 | Kakao + Google (MVP), Naver (V1.1) | 무료 |
| iOS 빌드 | **Codemagic** (Mac 불필요) | 무료 500분/월 |
| Git | GitHub | 무료 |

### 사용 안 함 (결정 근거 → `docs/decisions.md`)
- ❌ FlutterFlow Pro ($30/월)
- ❌ FlutterFlow Free
- ❌ Firebase (데모용으로만 사용)
- ❌ 외주 디자이너 (V1.1 검토)

---

## Supabase 프로젝트

- **URL**: https://wucbvyxneegbpjvamhfo.supabase.co
- **Region**: ap-northeast-1 (Tokyo)
- **Dashboard**: https://supabase.com/dashboard/project/wucbvyxneegbpjvamhfo
- **anon key, service_role key**: `.env` 파일 참조 (gitignored)

### 배포된 Edge Functions
1. `check_titles` — 칭호 자동 부여 (7종)
2. `award_xp` — XP 적립 + 자동 레벨업
3. `get_nearby_badges` — 반경 N km 내 배지 조회
4. `award_badge` — 배지 획득 메인 (GPS 검증 포함)

---

## DB 스키마 한눈에

```
users           — auth.users와 1:1, 닉네임/레벨/XP/칭호
locations       — 명소 마스터 (좌표·반경·카테고리)
badges          — 명소별 배지 (등급·XP·확인형 여부)
user_badges     — 사용자별 획득 이력 (좌표·일자)
xp_log          — XP 적립 이력 (어뷰징 추적용)
subscriptions   — 구독 상태 (V1.2 도입 예정)
seasons, events — V1.1+ 미리 준비
```

---

## 주요 결정사항 (요약)

자세한 내용은 `docs/decisions.md` 참조.

| 날짜 | 결정 |
|------|------|
| 2026-05-12 | 인증: Kakao + Google MVP, **Naver는 V1.1** |
| 2026-05-12 | 백엔드: Supabase 단일화 |
| 2026-05-12 | 프레임워크: Raw Flutter (FlutterFlow 미사용) |
| 2026-05-12 | 명소: 50 → 30곳으로 축소 |
| 2026-05-12 | 디자인: 무료 AI 도구만 |

---

## 비용 추적

| 항목 | 결제 시점 | 비용 |
|------|----------|------|
| Supabase | 현재 | **무료** |
| 카카오·구글 OAuth | 현재 | **무료** |
| GitHub | 현재 | **무료** |
| Codemagic | W8 전후 | **무료** (500분/월) |
| Apple Developer | W8 (TestFlight 직전) | **$99/년 (약 14만원)** |
| 도메인 voyna.app + voyna.co.kr | W11 전후 | **약 5만원/년** |
| **합계 (출시 시점)** | | **약 19만원** |

---

## 다음 세션에서 이어가는 방법

1. 이 CLAUDE.md를 Claude에게 보여주기
2. `docs/decisions.md`로 결정사항 확인
3. `git log --oneline -20`으로 최근 변경 확인
4. 마지막 작업 단계가 어디인지 README 또는 채팅으로 확인
5. 이어서 진행

---

## 기획서와의 관계

- **기획서 폴더** (`../기획서/`): 서비스 기획, 마케팅, 사업 계획, 50곳 DB 원본
- **이 폴더** (`voyna-app/`): 실제 앱 코드, 백엔드, 배포
- 둘은 **별도 git 저장소** (기획서는 `AlexSong0674/test`, 앱은 `AlexSong0674/Voyna-App`)
