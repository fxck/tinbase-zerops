-- tinbase reads supabase/migrations/*.sql on start, exactly like the Supabase CLI,
-- and applies them idempotently to the managed Postgres it points at.

create table if not exists public.bench (
  id         bigint generated always as identity primary key,
  label      text        not null default 'bench',
  n          int         not null default 0,
  payload    text,
  created_at timestamptz not null default now()
);

-- Index so the "filtered query" workload exercises an index scan, not a seq scan.
create index if not exists bench_n_idx on public.bench (n);

-- Benchmarks talk to PostgREST with the service_role key, so RLS isn't required,
-- but disabling it keeps the anon key usable from Studio / the browser demo too.
alter table public.bench disable row level security;

-- Exposed as POST /rest/v1/rpc/reset_bench — a fast TRUNCATE that restarts the
-- identity sequence so read workloads get contiguous ids 1..N.
create or replace function public.reset_bench() returns void
  language sql
  security definer
as $$
  truncate table public.bench restart identity;
$$;
