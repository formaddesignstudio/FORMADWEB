# FORMAD Design Studio — 웹사이트 프로젝트 기록

> 이 문서는 작업을 이어서 하기 위한 인수인계 노트입니다.
> 새 대화를 시작할 때 "PROJECT_LOG.md 읽어줘"라고 하면 여기서부터 이어갈 수 있습니다.

---

## 1. 프로젝트 개요

| 항목 | 내용 |
|---|---|
| 회사 | FORMAD Design Studio (건축 설계 · 건축 CG/시각화) |
| 목적 | 회사 소개 및 프로젝트 포트폴리오 웹사이트 |
| 저장소 | https://github.com/formaddesignstudio/FORMADWEB |
| 호스팅 | Vercel (2026-08-28 선택) |
| 도메인 | 미보유 — 우선 Vercel 기본 주소 사용, 추후 연결 예정 |
| 연락처 | formaddesignstudio@gmail.com / +82 10 8885 8793 |

---

## 2. 현재 기술 구성

**한 줄 요약: 빌드 도구 없는 순수 HTML 파일 1개짜리 사이트입니다.**

```
FORMADWEB/
├─ index.html        ← 사이트 전체 (HTML + CSS + JS + 이미지 전부 이 안에 있음, 약 4.1MB)
└─ PROJECT_LOG.md    ← 이 문서
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

- [ ] 커스텀 도메인 구입 및 Vercel 연결
- [ ] Contact 페이지의 Behance / LinkedIn 링크가 현재 `#/contact`로 되어 있음 → 실제 주소로 교체 필요
- [ ] 검색엔진 최적화 (Open Graph 이미지, sitemap 등)

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
