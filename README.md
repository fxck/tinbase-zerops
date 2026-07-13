# tinbase on Zerops

Runs the **[tinbase](https://www.tinbase.dev)** backend — the Supabase-compatible
API (REST, Auth, Storage, Realtime) plus the Studio dashboard — against a Postgres
you provide, via tinbase 0.10's `--database-url`.

This is *just tinbase*, packaged to deploy as a Zerops service. It holds none of
its own state: point it at a managed Postgres and the data lives there.

```
supabase-js / any client  →  tinbase (this service)  →  your Postgres
```

## What's here

- [`package.json`](./package.json) — a single dependency, `tinbase`.
- [`supabase/migrations/`](./supabase/migrations) — schema tinbase applies on start,
  exactly like the Supabase CLI (here: a `bench` table + a `reset_bench()` RPC).
- [`zerops.yaml`](./zerops.yaml) — builds and runs
  `tinbase start --host 0.0.0.0 --port 3000`, reading `DATABASE_URL` from the env.

## Configuration

- `DATABASE_URL` (required) — the Postgres to serve. Must be a **superuser** (or a
  role with `CREATEROLE`): tinbase bootstraps the `anon` / `authenticated` /
  `service_role` roles on first start.
- `TINBASE_JWT_SECRET` (required) — signs the anon / service_role JWTs. Share it with
  every client that needs to mint or validate keys.

## Run locally

```bash
npm install
export DATABASE_URL="postgresql://user:pass@host:5432/dbname"
export TINBASE_JWT_SECRET="any-32+-char-string"
npm start           # REST at :54321, Studio at :54321/_/
```

Used by the [tinbase-benchmark](https://github.com/fxck/tinbase-benchmark) recipe as
the backend service.
