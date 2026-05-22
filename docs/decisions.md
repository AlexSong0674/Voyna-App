# Voyna 주요 결정사항 (Decision Log)

> 개발 과정에서 내린 중요한 의사결정을 시간순으로 기록.  
> 나중에 "왜 그렇게 했지?" 싶을 때 돌아볼 수 있도록 작성.

---

## 2026-05-12: 인증 Provider 선정 — Kakao + Google만 MVP

### ✅ 결정
MVP는 **Kakao 로그인 + Google 로그인** 2종만 지원. **Naver 로그인은 V1.1으로 연기**.

### 🤔 검토한 옵션
| 옵션 | 장점 | 단점 | MVP 적합? |
|------|------|------|----------|
| A. Kakao + Google | Supabase 기본 지원, 15~25분 설정 | 네이버 사용자 일부 누락 | ✅ |
| B. Kakao + Google + Naver | 모든 한국 사용자 커버 | 네이버는 Supabase 미지원 → 커스텀 Edge Function 60~90분 추가 작업 | ❌ (시간) |
| C. Email + Password 만 | 모든 사용자 커버 | 가입 마찰 큼, 비밀번호 분실 처리 등 운영 부담 | ❌ |

### 📌 결정 근거
1. **시장 점유율**: 한국 모바일 앱에서 카카오 로그인 점유율이 네이버보다 높음
2. **MVP 일정**: 12주 안에 출시 목표 — 1~2일 일정 단축 가능
3. **출시 후 빠르게 보완 가능**: Naver는 Edge Function 1개 추가로 V1.1에 무리 없이 도입
4. **Supabase 기본 지원의 가치**: 보안·유지보수·문서 표준화

### 📅 V1.1 (출시 후 4~8주) 계획
- 네이버 디벨로퍼스 OAuth 앱 등록
- Edge Function `naver_oauth_callback` 작성 — Naver access token → Supabase JWT 발급
- 앱 로그인 화면에 네이버 버튼 추가
- 예상 작업: 2~3일

### 🔗 참고
- Supabase Auth Providers: https://supabase.com/docs/guides/auth/social-login
- Naver 디벨로퍼스: https://developers.naver.com/main/

---

## 2026-05-22: 카카오 OAuth — MVP에서 제외, V1.1로 연기

### ✅ 결정
**MVP는 Google 로그인만 지원**. 카카오 로그인은 **V1.1**에 도입.

### 🤔 발견된 기술적 블로커
- 카카오 OAuth는 **`account_email` 동의항목**이 필요 → 개인 앱은 활성화 불가 (KOE205 에러)
- Supabase Auth의 카카오 provider는 `account_email` 스코프를 **하드코딩**해서 요청 (Management API로 override 불가)
- `external_kakao_email_optional=true` 설정은 OAuth 후처리에만 영향, OAuth 요청 자체엔 영향 X
- Flutter 클라이언트의 `scopes` 파라미터는 기본 스코프에 **추가**만 가능, **대체** 불가

### 📅 V1.1 카카오 도입 방안 (둘 중 선택)
1. **카카오 비즈 앱 인증** (사업자등록증 필요, 심사 1~3일)
   - 승인 후 `account_email` 동의항목 활성화 가능
   - Supabase 내장 카카오 provider 그대로 사용 가능
2. **커스텀 Edge Function OAuth** (개발 1~2일)
   - 사업자 등록 없이 가능
   - Supabase signInWithIdToken으로 우회

### 📌 V1.1 시점에 베타 피드백 보고 결정
- 베타 사용자 다수가 카카오 요구 → 옵션 1 (비즈 인증)
- 빠른 출시 후 점진 보완 → 옵션 2 (커스텀 Edge Function)

### 🔗 참고
- 이 문제 발견까지 ~2일 시도 (시간 사용)
- Google 로그인은 정상 동작 확인됨
- 베타 출시 시 로그인 버튼은 **"Google로 시작하기"만 노출**, 카카오는 "곧 출시 예정" 표시

---

## 2026-05-12: 이메일/비밀번호 로그인 — V1.5+로 연기

### ✅ 결정
MVP는 **소셜 로그인(Kakao + Google)만 지원**. 이메일/비밀번호 가입은 V1.5 또는 V2로 연기.

### 🤔 검토한 옵션
| 옵션 | MVP 적합? | 이유 |
|------|----------|------|
| A. 소셜 로그인만 (Kakao + Google) | ✅ | 한국 사용자 99% 커버, 가입 5초 |
| B. 소셜 + 이메일/비밀번호 병행 | ❌ | 비밀번호 분실 처리·이메일 인증 등 운영 부담, 가입 마찰 30~50% 증가 |
| C. 이메일/비밀번호만 | ❌ | 한국에서 가입 전환율 매우 낮음 |

### 📌 결정 근거
1. **가입 전환율**: 소셜 로그인이 이메일 방식 대비 약 2배
2. **운영 부담 절감**: 비밀번호 분실 복구, 스팸 방지, 약관 등 추가 필요
3. **개발 시간**: -1주 절약
4. **사용자 데이터 자동 보강**: 소셜 프로필에서 이름·프로필 사진 자동 획득

### 📅 이메일/비밀번호 도입을 검토할 시점
- **출시 후 1~2개월**: 베타 피드백에서 "소셜 로그인 안 된다"는 호소가 다수면 즉시 추가
- **V2.0 외국인 확장**: 카카오 없는 외국인 사용자 위해 필수
- **V1.3 B2B 가맹 배지**: 가맹점주는 회사 이메일로 별도 로그인 (개인 사용자와 분리)

### 🔗 참고
- Supabase Auth: signUp / signInWithPassword API는 이미 무료로 제공 → 코드 1~2일이면 추가 가능

---

## 2026-05-12: 백엔드 스택 — Supabase 단일화

### ✅ 결정
**Supabase** 하나로 백엔드 전체 처리 (PostgreSQL + Auth + Edge Functions + Storage).
데모 단계의 Firebase는 사용 안 함.

### 📌 근거
- Free 플랜으로 MAU 5만까지 무료
- 단일 vendor → 통합 SDK + 단순한 운영
- PostgreSQL 표준 SQL 사용 가능
- Edge Functions로 서버 로직 처리 (어뷰징 방지)

### 🔗 참고: 기획서 v2.0 9장 — 기술 스택 검토

---

## 2026-05-18: Flutter 선택의 장기적 정당성 검증

> 2026-05-12 결정의 보강. 사용자가 "본격 서비스화 시 다른 도구로 옮겨야 하나?" 질문하여 재검토.

### ✅ 결론 (변경 없음)
**Raw Flutter를 본격 서비스화 단계까지 그대로 사용한다.** 다른 도구로의 마이그레이션 계획 없음.

### 📌 검증 근거

#### 1. FlutterFlow vs Raw Flutter — 결과물은 동일
- FlutterFlow는 "Flutter 코드를 시각적으로 생성"하는 도구이지, 별개 프레임워크 아님
- 둘 다 결과물은 동일한 Dart/Flutter 코드
- 차이는 만드는 방식(시각 빌더 vs 직접 작성)일 뿐
- AI(Claude)가 코드를 작성하는 우리 워크플로에선 시각 빌더 이점 무효

#### 2. 산업 표준 사례 — Raw Flutter가 본격 운영 표준
| 서비스 | MAU | 도구 |
|--------|-----|------|
| 토스 | 2,500만+ | Raw Flutter |
| 신한 SOL | 1,000만+ | Raw Flutter |
| Google Pay | 1억+ | Raw Flutter |
| 알리바바 | 수억 | Raw Flutter |
| BMW iDrive | (전세계 차량) | Raw Flutter |

→ Voyna가 MAU 1억까지 가도 Flutter로 충분.

#### 3. Vendor Lock-in 회피
- FlutterFlow Pro 종료 시 → 빌드·배포 막힘
- Raw Flutter → 영구 무료, 100% 코드 소유권

#### 4. 마이그레이션이 진짜 필요한 시점
- iOS만 극도 성능 필요 (3D 게임 등) → Swift Native
- Android만 극도 성능 필요 → Kotlin Native
- **여행 배지 앱은 위 카테고리 아님** → Flutter 유지가 정답

### 📅 본격화 시 진짜 검토할 것들 (마이그레이션 ❌)
출시 3개월 후:
- Sentry/Firebase Crashlytics 통합 — 크래시 모니터링
- Mixpanel/Amplitude — 사용자 행동 분석
- Shorebird (CodePush 대체) — 앱 스토어 거치지 않는 핫픽스

출시 6개월 후:
- Supabase Pro 플랜 ($25/월) — MAU 5만 돌파 시
- CDN 도입 — 배지 이미지 캐싱
- i18n — 영어/일본어 다국어

출시 1년 후:
- Edge Functions → 전용 서버 마이크로서비스 분리 (필요 시)
- 머신러닝 추천 — 개인화

### 🔗 참고
- Flutter 공식 사례: https://flutter.dev/showcase

---

## 2026-05-18: 디스크 부족 → Android Studio 설치 보류, 일단 Chrome 미리보기로 진행

### 🚨 발견된 이슈
- 사용자 PC C 드라이브 여유 공간: **7.9 GB**
- Android Studio + SDK + Emulator 필요 공간: 약 **8 GB**
- → Android Studio 설치 시 디스크 거의 꽉 차서 동작 불안정 위험

### ✅ 임시 대응 (Option C)
1. Android Studio 설치 **보류**
2. Flutter 프로젝트는 **Chrome 미리보기로 우선 진행** (웹 빌드)
3. 백엔드(Supabase) 연동, 인증, 데이터 흐름 검증은 Chrome으로 모두 가능
4. UI 디자인의 한국어 폰트·터치 인터랙션 등 모바일 특화 동작은 추후 Android Emulator 또는 실기기에서 검증

### 📅 향후 검토 시점
- **단기 (1~2주)**: C 드라이브 정리 (임시 파일·다운로드·휴지통 정리, 약 15 GB+ 확보)
- **중기 (Phase 4 GPS 로직 단계)**: Android Studio 설치 필수
  - GPS는 Chrome에서 흉내내기 어려움 (실제 위치 변화 시뮬레이션 제한)
- **장기**: 본격 운영 시 노트북 교체 검토 (아래 결정 참조)

### 💡 디스크 정리 우선순위 (참고)
| 항목 | 예상 절약 |
|------|----------|
| 다운로드 폴더 정리 | 2~5 GB |
| 휴지통 비우기 | 0.5~2 GB |
| Windows 임시 파일 (cleanmgr.exe) | 2~5 GB |
| 잘 안 쓰는 프로그램 제거 | 5~10 GB |
| OneDrive 캐시 (로컬 비활성화) | 2~5 GB |
| Node.js / Python 캐시 정리 | 1~3 GB |

---

## 2026-05-18: 하드웨어 — MacBook 교체 검토 결과

### 검토 배경
사용자가 현재 Windows 10 노트북에서 작업 중. 디스크 부족 + 속도 이슈 + 향후 다른 프로젝트 진행 고려해 노트북 교체를 검토.

### ✅ 결론 (요약)
**MacBook 교체 권장 — 단, 모바일 개발 지속 의향이 있는 경우에 한해.**  
이 프로젝트만 보면 현재 Windows로도 충분. 다른 모바일 앱 프로젝트를 계속할 거라면 MacBook이 장기적으로 유리.

### 📌 MacBook 장점 (특히 모바일 개발)
1. **iOS 네이티브 개발 가능** — Xcode 사용, Codemagic 클라우드 빌드 의존도 ↓
2. **Apple Silicon 효율** — M3/M4 칩 성능 + 배터리 18시간
3. **Unix 환경** — 백엔드·서버 개발 시 npm/Python/Docker 표준
4. **Voyna 외 다른 모바일 프로젝트 진행 시** 큰 이점
5. **개발자 도구 생태계** — 대부분 Mac 우선 지원
6. **재판매 가치 높음** — 3~4년 후 50%+ 회수

### ❌ MacBook 단점
1. **가격** — 동급 Windows 대비 30~50% 비쌈
2. **Windows 전용 소프트웨어** 호환성 (한컴, 일부 금융 등)
3. **카카오톡 PC 등 일부 한국 앱 UX 차이**

### 💰 가격 비교 (2026년 기준 추정)
| 모델 | 가격대 | 권장도 |
|------|--------|--------|
| MacBook Air M3 16GB / 512GB | 약 180~200만원 | ⭐⭐⭐ MVP 개발에 충분 |
| MacBook Pro 14" M3 Pro 18GB / 512GB | 약 280~330만원 | 동영상 편집·디자인 작업도 함께 |
| **MacBook Air M2 (구형) 16GB / 256GB** | **약 130~150만원** | ⭐⭐⭐⭐ **가성비 최강** |
| Apple Refurbished MacBook Air M2 | 약 110~130만원 | 정품 보증 1년 |
| Windows 16GB / 1TB | 약 100~130만원 | 옵션 비교용 |

### 📌 권장 모델 (사용자 프로필 기준)
**MacBook Air M2/M3, 16GB RAM, 512GB SSD** — 약 150~180만원
- Voyna + 다른 앱 프로젝트 충분
- 영상/3D 작업 안 한다면 Pro 불필요
- 16GB RAM은 **필수** (8GB는 Flutter+Xcode 동시 실행 시 부족)

### 📅 구매 시점 추천
| 시점 | 추천 |
|------|------|
| **지금 즉시** | 디스크 정리로 임시 해결 후 결정. 급하지 않음 |
| **Phase 4 (GPS 로직)** | Android Emulator + 실기 GPS 테스트 시점 → 이 때 결정 |
| **출시 후 V1.1** | 본격 운영·확장 결정 시 |

### 🔗 참고
- Apple Refurbished Store (정품 +1년 보증, 10~20% 할인): https://www.apple.com/kr/shop/refurbished/mac
- 학생 할인: Apple 교육 스토어 (알토대학원생도 적용 가능할 수 있음)

---

## 2026-05-18: 개발 중 동작 확인 — Android Emulator 사용

### ✅ 결정
Phase 3~6 개발 중에는 **Android Emulator** (Windows에서 무료)로 빠른 검증.
iOS 동작 검증은 **W8 이후 Codemagic 클라우드 빌드 + 본인 iPhone TestFlight**로 진행.

### 📌 근거
1. **Windows 환경의 한계** — Mac이 없어 iOS Simulator 사용 불가
2. **Flutter 크로스 플랫폼** — Android에서 동작하면 iOS도 95% 동일하게 동작
3. **개발 속도** — Android Emulator는 핫리로드 3초 / iOS 빌드는 5~10분
4. **비용** — Apple Developer $99는 W8까지 미루기

### 📅 단계별 테스트 환경

| 단계 | 환경 | 비용 |
|------|------|------|
| W1~W7 (개발) | Android Emulator (Windows) | 0원 |
| W7~W8 (UI 검증) | Codemagic 클라우드 빌드 → 본인 iPhone | 0원 (월 500분 무료) |
| W9~W10 (베타) | TestFlight 50명 | Apple Dev $99 결제 |
| W11~W12 (출시) | App Store | 같음 |

---

## 2026-05-12: 앱 프레임워크 — Raw Flutter (FlutterFlow 미사용)

### ✅ 결정
**Flutter SDK 직접 사용** (Dart 코드 직접 작성). FlutterFlow는 사용하지 않음.

### 🤔 검토한 옵션
| 옵션 | 비용 | 적합도 |
|------|------|--------|
| A. Raw Flutter | 무료 (영구) | ✅ |
| B. FlutterFlow Free | 무료 (제한적) | △ (코드 export·App Store 배포 시 Pro 필요) |
| C. FlutterFlow Pro | $30/월 | △ (불필요한 비용) |
| D. SAP Build Apps | 무료 | ❌ (React Native — 카카오맵 재작성 필요) |

### 📌 근거
- 100% 무료 (출시 후에도 영구)
- Claude가 Dart 코드를 직접 작성 → 노코드 UI 빌더 불필요
- 진짜 개발 자산 = git에 모두 보관
- iOS 빌드는 Codemagic 무료 플랜으로 Mac 없이 진행

---

## 2026-05-12: 명소 30곳 (50곳 → 축소)

### ✅ 결정
MVP는 **서울 30곳 + 배지 30종**으로 출시. 50곳 → 30곳으로 축소.

### 📌 근거
- 12주 일정에 맞추기 위해 디자인·테스트 작업량 축소
- 특별 3 + 희귀 8 + 일반 19 = 30 (등급 균형 유지)
- 출시 후 매주 5~10곳씩 추가 → V1.1에 50곳 → V1.2에 100곳 확장 계획

### 🔗 참고
- 30곳 목록: `supabase/migrations/0002_seed_data.sql`
- 50곳 원본: 기획서 `data/seoul_50_locations.csv`

---

## 2026-05-12: 디자인 — 무료 AI 도구만

### ✅ 결정
MVP의 50종 배지 디자인은 **Microsoft Designer + Ideogram + Canva** 무료 도구만 활용.
외주 디자이너는 V1.1 이후 검토.

### 📌 근거
- 비용 0원 (예산 절감)
- AI 도구로 1~2주 안에 30종 양산 가능
- 사용자 반응 보고 V1.1에서 고품질 외주 업그레이드 결정

---

## 결정사항 추가 시 양식

새로운 중요 결정을 내릴 때 이 파일에 다음 형식으로 추가:

```markdown
## YYYY-MM-DD: 결정 제목

### ✅ 결정
한 줄 요약.

### 🤔 검토한 옵션
표 형식 비교.

### 📌 결정 근거
번호 매긴 이유.

### 📅 향후 계획 (필요시)
연기·재검토 일정.
```
