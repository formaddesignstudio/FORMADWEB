-- =========================================================
--  FORMAD Design Studio — Supabase 스키마
--  사용법: Supabase 대시보드 → SQL Editor → 이 파일 전체를 붙여넣고 Run
--  (여러 번 실행해도 안전하도록 작성되어 있습니다)
-- =========================================================

-- ---------------------------------------------------------
-- 1. 프로젝트
--    영문/국문을 한 줄에 나란히 두어, 표 편집기에서 한 프로젝트를
--    한 행으로 편집할 수 있게 했습니다. (index.html 의 PROJECTS + KRP 통합)
-- ---------------------------------------------------------
create table if not exists public.projects (
  code        text primary key,                    -- 예: A2601_MHG
  year        int  not null,
  type        text not null,                       -- Hospitality / Residential / Cultural / Office / Masterplan / Visualization
  kind        text not null default 'exterior',    -- exterior / interior / aerial  (사진 없을 때 placeholder 종류)
  status      text not null default 'TBD',         -- Built / In Progress / Construction / Entry / TBD
  featured    boolean not null default false,      -- 홈 슬라이드쇼 노출 여부

  name_en     text default '',
  name_ko     text default '',
  client_en   text default '',
  client_ko   text default '',
  loc_en      text default '',
  loc_ko      text default '',
  role_en     text default '',
  role_ko     text default '',
  area        text default '',
  collab      text default '',                     -- 협업사 (국문 상세에만 표시됨)

  text_en     text[] not null default '{}',        -- 본문 문단 배열
  text_ko     text[] not null default '{}',

  sort_order  int  not null default 0,             -- 목록 기본 정렬용 (클수록 위)
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ---------------------------------------------------------
-- 2. 프로젝트 사진
--    slot: 'card'(목록 썸네일) | 'hero'(상세 상단) | 'gallery'(상세 갤러리)
--    file: Storage 버킷 안의 파일명 (예: hero.webp)
--    aspect: "가로/세로" — CSS aspect-ratio 에 그대로 들어갑니다
-- ---------------------------------------------------------
create table if not exists public.project_photos (
  id           bigserial primary key,
  project_code text not null references public.projects(code) on delete cascade,
  slot         text not null check (slot in ('card','hero','gallery')),
  file         text not null,
  aspect       text not null default '3/2',
  sort_order   int  not null default 0,            -- gallery 내 순서
  created_at   timestamptz not null default now()
);
create index if not exists project_photos_code_idx
  on public.project_photos (project_code, slot, sort_order);

-- ---------------------------------------------------------
-- 3. 구성원
-- ---------------------------------------------------------
create table if not exists public.people (
  id         bigserial primary key,
  name_en    text default '',
  name_ko    text default '',
  role       text default '',                      -- 원본이 "PRINCIPAL, ARCHITECT · 대표, 건축가" 형태라 단일 컬럼
  bio        text default '',
  photo_file text default '',                      -- 인물 사진 (지금은 비어 있음, 나중에 추가 가능)
  sort_order int not null default 0,
  visible    boolean not null default true
);

-- ---------------------------------------------------------
-- 4. 뉴스
-- ---------------------------------------------------------
create table if not exists public.news (
  id          bigserial primary key,
  published_on date not null,
  category_en text default 'Studio',
  category_ko text default '스튜디오',
  title_en    text default '',
  title_ko    text default '',
  body_en     text default '',
  body_ko     text default '',
  visible     boolean not null default true
);

-- =========================================================
--  RLS (Row Level Security)
--  누구나 읽기 가능 / 쓰기는 로그인한 사용자만.
--  → 웹사이트에 박히는 anon 키가 노출돼도 데이터가 변조되지 않습니다.
-- =========================================================
alter table public.projects       enable row level security;
alter table public.project_photos enable row level security;
alter table public.people         enable row level security;
alter table public.news           enable row level security;

do $$
declare
  tbl text;
begin
  foreach tbl in array array['projects','project_photos','people','news'] loop
    execute format('drop policy if exists "public read" on public.%I', tbl);
    execute format('drop policy if exists "authenticated write" on public.%I', tbl);

    -- 익명 방문자 포함, 누구나 읽기
    execute format(
      'create policy "public read" on public.%I for select using (true)', tbl);

    -- 로그인한 사용자만 쓰기 (Supabase Auth 로 로그인한 관리자)
    execute format(
      'create policy "authenticated write" on public.%I for all to authenticated using (true) with check (true)', tbl);
  end loop;
end $$;

-- =========================================================
--  updated_at 자동 갱신
-- =========================================================
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists projects_touch on public.projects;
create trigger projects_touch before update on public.projects
  for each row execute function public.touch_updated_at();
