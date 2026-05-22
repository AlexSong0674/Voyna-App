# Voyna 앱 개발 — 세션 핸드오프 (2026-05-22)

> 새 Claude 세션 시작 시 이 파일을 먼저 읽어주세요.
> 사용자(AlexSong0674)는 비전공 창업가, Windows 10 환경, Mac 없음.

---

## 🎯 한 줄 요약

GPS 기반 여행 인증 배지 앱 **Voyna**의 iOS MVP를 **12주 안에 App Store 출시** 목표.
백엔드 100% 완성, Flutter 앱 구조 + 인증 페이지까지 완료. **Google 로그인 동작 확인**.

---

## ✅ 완료된 작업

### 백엔드 (Supabase, 100% 완료)
- **프로젝트**: https://wucbvyxneegbpjvamhfo.supabase.co (Tokyo 리전)
- **8개 테이블** + RLS + 트리거 + 4 RPC 함수
- **시드 데이터**: 서울 30곳 명소 + 30 배지 (특별 3 / 희귀 8 / 일반 19)
- **4개 Edge Functions ACTIVE**:
  - `check_titles` (칭호 자동 부여)
  - `award_xp` (XP 적립 + 레벨업)
  - `get_nearby_badges` (주변 배지 조회)
  - `award_badge` (배지 획득 메인)
- **OAuth Provider**: Google ✅ 동작 확인, Kakao 등록됐으나 사용 보류 (아래 참조)
- **Site URL / Redirect URLs**: localhost:3000 등록됨

### Flutter 앱 (구조 + 인증)
- **Flutter 3.41.9 stable** 설치 (`C:\dev\flutter`)
- **Raw Flutter** 선택 (FlutterFlow 미사용, 비용 0)
- **프로젝트 위치**: `C:\Users\송 하 준\Documents\알토대학원\수업과제\벤처 스타트업\voyna-app`
- **141 패키지** 설치 완료 (supabase_flutter, geolocator, flutter_inappwebview 등)
- **lib/ 구조**:
  ```
  main.dart                       앱 진입 + Supabase 초기화
  core/env.dart                   .env 헬퍼
  core/theme.dart                 Voyna 브랜드 컬러
  core/router.dart                GoRouter + 인증 가드
  features/splash/                splash + auth_callback
  features/auth/login_page.dart   Google 로그인 (카카오는 "곧 출시" 상태)
  features/home/                  4탭 (홈/맵/배지/더보기)
  ```
- **빌드 검증**: `flutter run -d chrome --release --web-port=3000` 으로 동작 확인

### GitHub
- **저장소**: https://github.com/AlexSong0674/Voyna-App (앱 코드)
- **저장소**: https://github.com/AlexSong0674/test (기획서)

---

## ⚠️ 알려진 이슈 / 주의사항

### 1. Dev 모드 빌드 불안정 (release 모드 사용 권장)
- Flutter web의 dev 모드(DDC)는 1000+ 스크립트 로드 → 흰 화면 멈춤 자주 발생
- **해결**: `flutter run -d chrome --release --web-port=3000` 사용
- 단점: hot reload 불가, 코드 수정 시 재빌드 (2~3분)

### 2. 카카오 OAuth 블로커
- Supabase의 카카오 provider가 `account_email` 스코프를 하드코딩 요청
- 카카오 개인 앱은 `account_email` 동의항목 활성화 불가
- → KOE205 에러로 막힘
- **결정**: MVP에서 제외, V1.1에서 비즈 앱 인증 또는 커스텀 Edge Function으로 해결
- 자세한 내용: `docs/decisions.md` 참조

### 3. 디스크 공간 빠듯
- C 드라이브 여유 7~8 GB (정상 동작에 충분하지만 빠듯)
- Android Studio 설치 보류 (Phase 4 GPS 단계 전 정리 필요)

### 4. Mac 없음 → iOS 빌드 전략
- 개발 검증: Android Emulator (W7~) 또는 Chrome (현재)
- iOS 빌드: **Codemagic** (Mac 없이 클라우드 빌드) — W8 이후
- Apple Developer $99 결제는 TestFlight 시점(W8~9)에

---

## 📋 다음 단계 (Phase 3 진행)

새 세션에서 이어갈 작업:

### 1. 카카오 버튼 UI 수정 동작 확인
- 현재 코드는 "카카오로 시작 (곧 출시)" 상태로 변경됨
- 다시 빌드해서 Google만으로 정상 로그인 → 홈 진입까지 검증 필요

### 2. Phase 3 본격 진행 — 4탭 화면 완성
- 홈 페이지: 프로필 카드 + 최근 배지 + 다음 도전 (이미 작성됨, 데이터 확인 필요)
- 배지 컬렉션: 30종 그리드 표시 (이미 작성됨, 정상 동작 확인 필요)
- 더보기: 설정/로그아웃 (작성됨)
- 맵 탭: **다음 작업** — 카카오맵 WebView 통합 (Phase 4)

### 3. Phase 4 — GPS + 배지 획득 로직
- 위치 권한 요청 (geolocator + permission_handler 패키지 설치됨)
- 카카오맵 WebView (kakao_map.html 자산 작성 필요)
- 자동 배지 획득 vs 확인형 배지 분기 로직

### 4. Phase 6 — 배지 디자인 (병렬)
- 무료 AI 도구 (Microsoft Designer + Ideogram + Canva)
- 30종 배지 생성 → Supabase Storage 업로드
- `badges.image_url` 일괄 업데이트

---

## 🔑 환경변수 위치

실제 키 값은 **`voyna-app/.env` (로컬, gitignored)**에 보관되어 있습니다.

키 종류:
- `SUPABASE_URL` (공개 OK)
- `SUPABASE_ANON_KEY` (anon 키, 클라이언트 공개 가능)
- `KAKAO_REST_API_KEY` / `KAKAO_NATIVE_APP_KEY` / `KAKAO_JAVASCRIPT_KEY` / `KAKAO_CLIENT_SECRET`
- `GOOGLE_CLIENT_ID_WEB` / `GOOGLE_CLIENT_SECRET`

> ⚠️ 절대 채팅/git에 노출 금지. 사용자 PC의 .env 파일에서 직접 읽어주세요.
> 참고: `voyna-app/.env.example` 에 형식만 있음.

---

## 🛠 자주 쓰는 명령어

```powershell
# Flutter SDK PATH 설정
$env:Path = "C:\dev\flutter\bin;$env:Path"

# 프로젝트 디렉토리로 이동
cd "C:\Users\송 하 준\Documents\알토대학원\수업과제\벤처 스타트업\voyna-app"

# Release 모드로 실행 (안정적)
flutter run -d chrome --release --web-port=3000

# 빌드 로그 확인
Get-Content "C:\Temp\flutter_run.log" -Tail 30

# Flutter/dart 프로세스 정리
Get-Process | Where-Object { $_.ProcessName -match "^(dart|dartvm|dartaotruntime)$" } | Stop-Process -Force
```

```bash
# Supabase Management API (Edge Function 배포 등)
# PAT 발급: https://supabase.com/dashboard/account/tokens
# Project ref: wucbvyxneegbpjvamhfo
```

---

## 📚 참고 문서

| 문서 | 용도 |
|------|------|
| `voyna-app/CLAUDE.md` | 프로젝트 컨텍스트 (Claude 자동 로드) |
| `voyna-app/docs/decisions.md` | 모든 의사결정 시간순 기록 |
| `voyna-app/docs/01_supabase_setup_guide.md` | Supabase 셋업 가이드 (참고용) |
| `voyna-app/docs/02_edge_functions_deploy.md` | Edge Function 배포 |
| `voyna-app/docs/03_kakao_oauth_setup.md` | 카카오 OAuth (V1.1 참고) |
| `voyna-app/docs/04_google_oauth_setup.md` | 구글 OAuth 가이드 |
| `기획서/docs/superpowers/plans/2026-05-12-voyna-mvp-implementation.md` | 12주 구현 계획 |

---

## 💬 사용자 소통 스타일

- **언어**: 한국어
- **수준**: 비전공 창업가 (코딩 불가, 시각/실행 중심)
- **선호**: 단계별 명확한 안내, 화면 캡처 친화적
- **금지**: 너무 긴 설명, 가정 기반 추측
- **확인사항**: 결정 전 옵션 제시 + 추천 명확히

---

## 🚀 새 세션 시작 시 첫 메시지 예시

"이전 세션에서 Voyna 앱 개발 중. HANDOFF.md 참고하여 현재 상태 파악 완료.
다음 단계: Phase 3 — 4탭 화면 동작 검증 + Phase 4 (GPS) 준비.
어떤 작업부터 시작할까요?"
