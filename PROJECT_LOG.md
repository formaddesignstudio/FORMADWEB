# FORMAD Design Studio — 웹사이트 프로젝트 기록

> 이 문서는 작업을 이어서 하기 위한 인수인계 노트입니다.
> 새 대화를 시작할 때 **"PROJECT_LOG.md 읽어줘"** 라고 하면 여기서부터 이어갈 수 있습니다.

---

## ▶ 다음 작업은 여기서부터 (2026-08-28 기준)

**완료된 것:** 배포 ✅ · 더미 데이터 정리 ✅ · 커스텀 도메인 연결 ✅ · 검색엔진 최적화(코드 작업) ✅
→ 사이트는 현재 **https://www.formadarchitects.com** 에서 정상 작동 중

### 🔴 지금 바로 하셔야 할 일 — 검색엔진 등록 (사람이 직접 해야 함)

코드 작업은 끝났습니다. 하지만 **검색엔진에 직접 등록하지 않으면 아무리 기다려도 검색에 뜨지 않습니다.**
아래 3개는 계정 로그인이 필요해서 직접 하셔야 합니다. 자세한 절차는
[6. 검색엔진 등록 절차](#6-검색엔진-등록-절차-직접-해야-하는-작업) 참고.

1. **구글 서치 콘솔** — search.google.com/search-console
2. **네이버 서치어드바이저** — searchadvisor.naver.com
3. **네이버 스마트플레이스** — smartplace.naver.com  ← 네이버 노출에는 이게 제일 효과적

> 소유확인 단계에서 "HTML 파일을 올리세요" 또는 "DNS TXT 레코드를 추가하세요" 화면이 나오면
> 그 화면을 알려주시면 처리해 드립니다.

### 그 다음 작업: Supabase 연동 (준비만 해둔 상태)

한 줄 요약: 지금은 프로젝트 정보와 이미지가 `index.html` 안에 직접 박혀 있어서,
내용을 바꾸려면 매번 코드를 고쳐야 합니다. 이걸 Supabase로 옮겨서
**코드를 건드리지 않고 프로젝트를 추가·수정**할 수 있게 만드는 것이 목표입니다.

**이미 준비해 둔 것** (index.html은 아직 안 건드림):
- `_images_for_supabase/` — base64에서 뽑아낸 이미지 13장 (git 제외됨)
- `supabase/schema.sql` — 테이블 4개 + RLS 정책. Supabase SQL Editor에 붙여넣으면 바로 실행됨

다음 대화를 시작할 때 이렇게 말씀하시면 됩니다:
> "PROJECT_LOG.md 읽고 Supabase 연동 시작하자"

시작하려면 **Supabase 프로젝트 URL과 anon 키**가 필요합니다.

---

## 1. 프로젝트 개요

| 항목 | 내용 |
|---|---|
| 회사 | FORMAD Design Studio (건축 설계 · 건축 CG/시각화) |
| 목적 | 회사 소개 및 프로젝트 포트폴리오 웹사이트 |
| 저장소 | https://github.com/formaddesignstudio/FORMADWEB |
| 호스팅 | Vercel (2026-08-28 선택) |
| 도메인 | **https://www.formadarchitects.com** (가비아 구입 · Vercel 연결 완료) |
| 주소 | 서울특별시 강남구 논현로 10길 30, 505-S268호 (개포동) |
| 연락처 | formaddesignstudio@gmail.com / +82 10 8885 8793 |

---

## 2. 현재 기술 구성

**한 줄 요약: 빌드 도구 없는 순수 HTML 파일 1개짜리 사이트입니다.**

```
FORMADWEB/
├─ index.html               ← 사이트 전체 (HTML + CSS + JS + 이미지 전부 이 안에, 약 4.1MB)
├─ og.jpg                   ← 링크 공유용 미리보기 이미지 (1200×630)
├─ logo.png                 ← 구조화 데이터(JSON-LD)의 로고 필드용
├─ robots.txt               ← 검색엔진 수집 허용 + 사이트맵 위치
├─ sitemap.xml              ← 검색엔진에 제출할 주소 목록
├─ googlee0ff9339882f2211.html  ← 구글 소유확인 파일 ⚠️ 지우면 안 됨
├─ supabase/schema.sql      ← (준비만 해둠) Supabase 테이블 + RLS 스키마
├─ _images_for_supabase/    ← (준비만 해둠) 추출한 원본 이미지 13장 · git 제외
└─ PROJECT_LOG.md           ← 이 문서
```

- **프레임워크 없음** (React, Next.js 등 사용 안 함). 파일을 브라우저로 열면 바로 보입니다.
- **빌드 과정 없음**. `npm install`, `npm run build` 같은 명령이 필요 없습니다.
- **폰트만 외부에서 불러옴**: Google Fonts (Inter, IBM Plex Sans KR, IBM Plex Mono)
- **이미지 13장이 파일 안에 base64로 박혀 있음** → 이것이 파일이 4MB로 큰 이유이며, 나중에 Supabase로 옮길 대상입니다.

### index.html 내부 구조 (줄 번호는 대략적)

| 줄 | 내용 |
|---|---|
| 1~11 | `<head>`, 메타태그, 폰트 로드 |
| 12~596 | `<style>` — 사이트 전체 CSS (43번 줄은 로고 이미지 base64) |
| 597~643 | 헤더 / 내비게이션 |
| 644~841 | `<main>` — 페이지 6개가 모두 여기 들어있음 |
| 843~ | 푸터 |
| 1218~1229 | `PHOTOS` — **base64 이미지 13장** (파일 용량의 대부분) |
| 1231~ | `PROJECTS`, `PEOPLE`, `NEWS` — 화면에 뿌려지는 데이터 배열 |
| 1295~1455 | `T`, `KRP`, `KRNEWS` — 한/영 번역 사전 |
| 1456~ | 렌더링 및 라우팅 JavaScript |

### 페이지 구성 (해시 라우팅 방식)

주소창의 `#/` 뒤에 붙는 값으로 페이지가 전환됩니다. 실제 파일은 하나뿐입니다.

- `#/` — 홈 (히어로 슬라이드쇼)
- `#/project` — 프로젝트 목록 (카테고리 필터 · 그리드/표 보기 전환 · 정렬)
- `#/project/{코드}` — 프로젝트 상세
- `#/about` — 스튜디오 소개
- `#/people` — 구성원
- `#/news` — 뉴스
- `#/contact` — 연락처

### 핵심 데이터 구조 (Supabase 이관 시 참고)

```js
PROJECTS = [{ code, year, type, kind, status, featured, photos:{hero, gallery:[...]}, ... }]
PEOPLE   = [{ n: 이름, r: 역할, ... }]
NEWS     = [{ 제목, 날짜, 본문 }]
PHOTOS   = { 키: { a: "가로/세로", u: "data:image/webp;base64,..." } }
```

- 다국어는 `T` 객체에 `키: [영문, 국문]` 배열로 저장되어 있고, `t('키')` 함수로 꺼내 씁니다.
- 이미지는 `PHOTOS` 객체의 **키 이름**으로 참조됩니다 (`hero`, `card`, `g1`~`g7`, `ngn_hero`, `ngn_g1`, `ngn_g2` 등).

---

## 3. 작업 이력

### 2026-08-28 — 배포 준비 및 1차 배포

- 프로젝트 현황 파악 완료
- **`index_9.html` → `index.html` 로 파일명 변경**
  - 이유: 웹 호스팅은 주소 최상단에서 `index.html`이라는 이름의 파일을 자동으로 찾아 보여줍니다. 다른 이름이면 접속 시 빈 화면 또는 404가 뜹니다.
- 호스팅으로 Vercel 선택 (무료 · 자동 HTTPS · GitHub 푸시 시 자동 재배포 · 추후 서버 기능 확장 가능)
- 이 문서 작성

### 2026-08-28 — 1차 배포 완료 및 더미 데이터 정리

- Vercel 배포 완료
- **더미 프로젝트 18개의 텍스트 삭제** (전체 20개 중 실제 2개는 유지)
  - 유지된 실제 프로젝트: `A2601_MHG`(호텔 가은 현상설계), `A2602_GGN`(네이쳐카니발 가평)
  - 삭제한 항목: 프로젝트명, 클라이언트, 지역, 면적, 담당역할, 상세 설명문 (영문 `PROJECTS` + 국문 `KRP` 양쪽 모두)
  - 유지한 항목: 프로젝트 코드, **카테고리(type)**, 연도, 이미지 종류(kind)
  - **삭제 이유:** 더미 데이터의 발주처 칸에 부산광역시 · 서울대학교 · 한국토지주택공사 · 인천광역시 · 양주시 · 광명시 · 청주시 등 **실존 공공기관이 적혀 있었음.** 가상의 프로젝트명은 미완성으로 넘어갈 수 있으나, 실존 기관을 발주처로 표기한 것은 허위 실적으로 읽힐 수 있어 공모전·입찰 실적 검증 시 문제가 될 소지가 있었음.
  - 더미 항목의 `featured`(홈 대표작 지정)도 함께 제거 → 홈 슬라이드쇼에는 실제 프로젝트 2개만 노출됨

- **빈 값 표시 처리** — 위 삭제로 생긴 빈 칸을 위해 헬퍼 함수 3개 추가
  - `pname(p)` — 이름이 비면 "Coming Soon" / "공개 예정" 표시
  - `fld(v)` — 그 외 빈 항목은 대시(—) 표시
  - `csub(p)` — 카드 부제에서 지역이 비면 " · " 구분자를 생략
  - 상세 페이지는 설명문이 없으면 본문 영역 자체를 그리지 않음
  - 새 상태값 `TBD` 및 번역 키 `st.TBD`, `proj.tbd` 추가

- `.gitignore` 추가 (`*.bak` 등 백업 파일 제외)
- 로컬 백업 `index.html.bak` 생성 (GitHub에는 올라가지 않음)

### 2026-08-28 — 커스텀 도메인 연결 완료 ✅

- **도메인 `formadarchitects.com` 구입(가비아) 및 Vercel 연결 완료**
- 방식: **가비아 네임서버 유지 + DNS 레코드 추가** (Vercel 네임서버로 변경하지 않음)

  | 타입 | 호스트 | 값 | TTL |
  |---|---|---|---|
  | A | `@` | `216.198.79.1` | 3600 |
  | CNAME | `www` | `bea797b311a94453.vercel-dns-017.com.` | 3600 |

- 대표 주소는 **`www.formadarchitects.com`** (apex는 308 리다이렉트, Vercel 기본 권장)
  - 짧은 주소를 대표로 바꾸고 싶으면 Vercel → Settings → Domains → Edit 에서 변경 가능
- HTTPS 인증서는 Vercel이 Let's Encrypt로 자동 발급·자동 갱신 (별도 구매 불필요)

**다음에 도메인 관련 작업할 때 참고할 사항:**

- A 레코드 IP는 `76.76.21.21`(구버전)이 아니라 **`216.198.79.1`** — Vercel IP 대역 확장분.
  구버전도 계속 작동하지만 신규 값이 권장
- **CNAME 값은 프로젝트마다 고유함.** 블로그·문서의 공통값 `cname.vercel-dns.com`을 쓰면 안 됨.
  반드시 Vercel Domains 화면의 복사 버튼으로 가져올 것. 값 끝 마침표(`.`)까지 포함
- 가비아 주의점: ① 구입 시 자동 생성되는 파킹용 레코드를 먼저 정리
  ② `확인` → `저장` 2단계를 모두 눌러야 반영 ③ "도메인 포워딩" 기능이 켜져 있으면 DNS보다 우선하므로 꺼야 함
- `Proxy Status: Unknown` 은 "프록시 유무를 확인하지 못했다"는 뜻으로,
  DNS 반영 전이거나 Cloudflare 등 프록시를 안 쓰면 **정상**. 판단 기준은 `Valid Configuration` 여부와 실제 접속
- 도메인 **자동 갱신 켜둘 것** (만료 시 사이트 중단 + 선점 위험)
- 확인 도구: [dnschecker.org](https://dnschecker.org)

### 2026-08-28 — 검색엔진 최적화(SEO) 코드 작업 ✅

**문제:** 배포·접속은 정상인데 구글·네이버에서 검색해도 사이트가 안 나옴.

**원인 진단:**

1. **검색엔진에 등록을 안 함** ← 원인의 90%.
   검색엔진은 새 도메인을 자동으로 찾아주지 않습니다. 외부 링크가 있거나 직접 등록해야 발견됩니다.
2. `<head>`에 **한국어 키워드가 하나도 없었음.** title·description이 영어뿐이라
   "포마드디자인스튜디오"로 검색하면 걸릴 단어가 없었음
3. OG 태그 · canonical · 구조화 데이터 · robots.txt · sitemap.xml 전부 없었음
4. **푸터 정적 주소가 옛 더미값(성동구 성수동, 04797)으로 남아 있었음** —
   JS가 실행되어야 실제 강남 주소로 바뀌는 구조였는데, **네이버 크롤러는 JS를 실행하지 않으므로
   틀린 주소를 수집해 갈 상태였음.** → 정적 HTML을 실제 주소로 교체

**작업 내용:**

| 파일 | 내용 |
|---|---|
| `index.html` `<head>` | title·description에 한국어 키워드 추가, `keywords`, `canonical`, OG 11개, Twitter Card, `robots`, JSON-LD 구조화 데이터 |
| `index.html` 푸터/태그라인 | 정적 주소를 더미값 → 실제 강남 주소로 교체 (3곳) |
| `robots.txt` (신규) | 전체 허용 + 네이버 Yeti·다음 명시 + 사이트맵 위치 |
| `sitemap.xml` (신규) | 홈 1개 (해시 라우팅이라 현재 색인 가능한 주소가 하나뿐) |
| `og.jpg` (신규) | 1200×630. 호텔 가은 hero 이미지를 가운데 크롭해 생성. 카카오톡은 webp를 못 읽어 JPG로 변환 |
| `logo.png` (신규) | JSON-LD `logo` 필드용 |

**아직 남은 구조적 한계 (지금은 손대지 않음):**

- 사이트가 `#/project` 같은 **해시 라우팅**이라, 검색엔진에게는 주소가
  `https://www.formadarchitects.com/` **하나뿐입니다.** `#` 뒤는 주소로 취급하지 않기 때문입니다.
  → 프로젝트 상세 페이지가 개별적으로 검색에 걸리는 것은 현재 구조로는 불가능
- 해결하려면 `/project` 같은 실제 경로 방식으로 바꾸고 페이지별 HTML을 만들어야 함(큰 작업).
  **실제 프로젝트가 2개뿐인 지금은 투자 대비 효과가 낮으므로, 등록 후 몇 주 지켜본 뒤 판단 권장**
- 첫 페이지 4MB 문제는 Supabase 이관으로 해결 예정

**기대치:**

- "포마드디자인스튜디오", "FORMAD Design Studio" 같은 **회사명 검색** → 등록 후 몇 주 내 상위 노출 가능
- "건축설계사무소" 같은 **일반 검색어** → 신규 사이트가 뚫기 매우 어려움. 기대하지 말 것
- 등록해도 구글 색인까지 며칠~2주, 네이버는 더 걸림. 다음날 확인해서 없는 것은 정상

### 알려진 이슈 / 참고사항

- **이 PC에 Git 명령줄 도구가 설치되어 있지 않습니다.** GitHub Desktop만 있습니다.
  - 커밋 · 푸시는 GitHub Desktop 화면에서 진행합니다.
  - GitHub Desktop 내장 git 경로: `C:\Users\USER\AppData\Local\GitHubDesktop\app-3.6.4\resources\app\git\cmd\git.exe` (직접 실행은 권한 문제로 막혀 있음)
- **첫 화면 로딩이 느립니다.** 이미지가 파일 안에 박혀 있어 4MB를 한 번에 받아야 하기 때문입니다. Supabase Storage로 이미지를 옮기면 해결됩니다.

---

## 4. 앞으로 할 일

### 다음 단계 — Supabase 연동 (아직 시작 안 함)

목표: 지금 `index.html` 안에 하드코딩된 이미지와 데이터를 Supabase로 옮겨서,
**코드를 고치지 않고도 프로젝트를 추가/수정**할 수 있게 만드는 것.

작업 순서(예정):

1. **Supabase Storage에 이미지 업로드**
   `PHOTOS` 객체의 base64 문자열 13개를 실제 webp 파일로 추출해 업로드
   → `index.html` 용량이 4MB → 약 100KB로 줄어듭니다.

2. **Supabase 데이터베이스 테이블 설계**
   `projects`, `project_photos`, `people`, `news` 테이블 생성
   (위 "핵심 데이터 구조" 참고)

3. **`PROJECTS` / `PEOPLE` / `NEWS` 하드코딩 배열을 Supabase 조회로 교체**
   supabase-js 라이브러리를 `<script>` 태그로 불러와 사용

4. **보안 설정**
   RLS(Row Level Security)로 "누구나 읽기 가능 / 쓰기는 관리자만" 정책 적용
   → 웹사이트에 노출되는 anon 키는 공개되어도 안전한 키입니다.

5. (선택) 관리자 페이지 — 로그인 후 브라우저에서 프로젝트를 직접 추가/수정

### 그 외 예정

- [ ] **🔴 검색엔진 3곳 등록** — 아래 [6번](#6-검색엔진-등록-절차-직접-해야-하는-작업) 참고. 이걸 해야 검색에 뜹니다
- [ ] **더미 자리 18개를 실제 프로젝트로 채우기** — 현재 "Coming Soon"으로 표시 중.
      실제 프로젝트가 부족하면 항목 수를 줄이는 것도 방법 (`PROJECTS` 배열에서 해당 줄 삭제)
- [x] ~~커스텀 도메인 구입 및 Vercel 연결~~ (2026-08-28 완료)
- [ ] Contact 페이지의 Behance / LinkedIn 링크가 현재 `#/contact`로 되어 있음 → 실제 주소로 교체 필요
- [x] ~~검색엔진 최적화 — 코드 작업(OG 이미지, sitemap, 구조화 데이터 등)~~ (2026-08-28 완료)
- [ ] 해시 라우팅(`#/`) → 실제 경로(`/project`) 전환 — 프로젝트가 늘어난 뒤 판단

---

## 5. 자주 쓰는 작업 방법

### 사이트를 수정하고 반영하는 법

1. `index.html`을 수정합니다.
2. 브라우저로 `index.html`을 직접 열어 확인합니다.
3. **GitHub Desktop**을 엽니다 → 왼쪽에 변경된 파일이 보입니다.
4. 왼쪽 아래에 무엇을 바꿨는지 한 줄 적고 **Commit to main** 클릭.
5. 위쪽 **Push origin** 클릭.
6. 1~2분 뒤 Vercel이 자동으로 새 버전을 배포합니다.

### 되돌리고 싶을 때

- GitHub Desktop 좌측 **History** 탭에서 이전 커밋을 우클릭 → **Revert changes in commit**
- Vercel 대시보드 → Deployments → 이전 배포 우측 `...` → **Promote to Production**

---

## 6. 검색엔진 등록 절차 (직접 해야 하는 작업)

> **순서 중요:** 코드 변경분을 먼저 GitHub Desktop으로 Push해서 배포가 끝난 뒤에 등록하세요.
> `robots.txt` · `sitemap.xml` · `og.jpg` 가 실제 주소에서 열려야 등록이 통과됩니다.
>
> 배포 확인용 주소 — 브라우저에서 열어서 내용이 보이면 성공:
> - https://www.formadarchitects.com/robots.txt
> - https://www.formadarchitects.com/sitemap.xml
> - https://www.formadarchitects.com/og.jpg

### 6-1. 구글 서치 콘솔

1. https://search.google.com/search-console 접속 (Gmail 계정으로 로그인)
2. 왼쪽 위 **속성 추가** → **URL 접두어** 선택 → `https://www.formadarchitects.com` 입력
   - "도메인" 방식은 DNS 설정이 필요해서 더 번거롭습니다. **URL 접두어를 고르세요.**
3. 소유권 확인 → **HTML 파일 업로드** 방식 선택 → 파일 다운로드
   → 그 파일을 `FORMADWEB` 폴더에 넣고 Push하면 됩니다 (필요하면 처리해 드립니다)

   > ⚠️ **`googlee0ff9339882f2211.html` 파일을 절대 지우지 마세요.**
   > 2026-08-28에 추가한 구글 소유확인 파일입니다. 내용은 한 줄뿐이고 쓸모없어 보이지만,
   > **이 파일이 사라지면 구글이 소유확인을 해제하고 서치 콘솔 데이터가 끊깁니다.**
   > 구글은 주기적으로 이 파일의 존재를 재확인합니다. 그냥 두세요.
   > 확인 주소: https://www.formadarchitects.com/googlee0ff9339882f2211.html
4. 확인 완료 후 → 왼쪽 **Sitemaps** → `sitemap.xml` 입력 → 제출
5. 위쪽 검색창에 `https://www.formadarchitects.com/` 입력 → **색인 생성 요청** 클릭

### 6-2. 네이버 서치어드바이저

1. https://searchadvisor.naver.com 접속 (네이버 계정으로 로그인)
2. **웹마스터 도구** → 사이트 등록에 `https://www.formadarchitects.com` 입력
3. 소유확인 → **HTML 파일 업로드** 선택 (구글과 동일한 방식)
4. 등록 후 왼쪽 메뉴에서:
   - **요청 → 사이트맵 제출** : `sitemap.xml`
   - **요청 → 웹페이지 수집** : `https://www.formadarchitects.com/`
   - **검증 → robots.txt** : 수집 허용 상태인지 확인

### 6-3. 네이버 스마트플레이스 ← 네이버 노출에 가장 효과적

웹사이트 크롤링을 기다리는 것보다 **훨씬 빠르고 확실합니다.**
등록되면 "포마드디자인스튜디오" 검색 시 회사 정보 카드가 바로 뜹니다.

1. https://smartplace.naver.com 접속
2. **신규 등록** → 업체 정보 입력
   - 상호: FORMAD Design Studio (포마드디자인스튜디오)
   - 주소: 서울특별시 강남구 논현로 10길 30, 505-S268호
   - 전화: 010-8885-8793
   - 홈페이지: https://www.formadarchitects.com
   - 업종: 건축설계 / 건축사사무소
3. **사업자등록증**이 필요합니다. 심사에 며칠 걸립니다.

### 등록 후 확인 방법

구글 검색창에 이렇게 쳐보세요 — 색인 여부를 바로 알 수 있습니다:

```
site:formadarchitects.com
```

- 결과가 나오면 색인 완료 (보통 등록 후 며칠~2주)
- 계속 0개면 서치 콘솔의 **색인 생성 요청**을 다시 눌러보세요

### 링크 공유 미리보기(OG) 확인

카카오톡·페이스북에 주소를 붙여넣었을 때 썸네일이 안 뜨면 캐시 때문입니다:

- 카카오톡: https://developers.kakao.com/tool/debugger/sharing → 주소 넣고 **캐시 초기화**
- 페이스북: https://developers.facebook.com/tools/debug/ → **Scrape Again**
