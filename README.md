# Voyna (보이나)

GPS 기반 여행 인증 배지 앱 — 발걸음이 기록이 되고, 기록이 추억이 된다.

## 프로젝트 구조

```
voyna-app/
├── supabase/           # 백엔드 (DB 스키마, Edge Functions, 시드 데이터)
│   ├── migrations/     # SQL 마이그레이션 (테이블, RLS, 트리거)
│   ├── seed/           # 30곳 명소 + 30 배지 시드 데이터
│   └── functions/      # Edge Functions (배지 획득 검증 등)
├── lib/                # Flutter 앱 코드 (Dart) — Phase 2부터 생성
├── assets/             # 배지 이미지, 사운드, 아이콘
├── docs/               # 개발 문서
├── scripts/            # 빌드·시드·테스트 자동화
└── .env.example        # 환경변수 템플릿
```

## 기술 스택

- **앱**: Flutter (Raw, no FlutterFlow) — Dart 3.x
- **백엔드**: Supabase (PostgreSQL + Auth + Edge Functions + Storage)
- **지도**: 카카오맵 (WebView)
- **인증**: 카카오 OAuth + Google OAuth (Supabase Auth)
- **iOS 빌드**: Codemagic (Mac 불필요, 클라우드 빌드)
- **분석**: Supabase Analytics (무료 플랜)

## 개발 진행

상세 계획: [기획서 v2.0](../기획서/) + [12주 구현 계획](../기획서/docs/superpowers/plans/2026-05-12-voyna-mvp-implementation.md)

### 현재 단계

- [x] 프로젝트 폴더 생성
- [ ] **Phase 0**: Supabase / 카카오 / Google 계정 (무료 가입)
- [ ] **Phase 1**: 백엔드 DB + Edge Functions
- [ ] **Phase 2**: 카카오·구글 로그인 (Flutter)
- [ ] **Phase 3**: 4탭 UI (홈/맵/배지/더보기)
- [ ] **Phase 4**: GPS + 자동/확인형 배지 획득
- [ ] **Phase 6**: 무료 AI 배지 디자인 30종
- [ ] **Phase 7**: 실기기 테스트
- [ ] **Phase 8**: TestFlight 베타 50명
- [ ] **Phase 10**: App Store 출시

## 환경변수 설정

```bash
cp .env.example .env
# .env 파일을 열어 실제 값 입력 (.gitignore로 보호됨)
```

## 라이선스

© 2026 Voyna. All rights reserved.
