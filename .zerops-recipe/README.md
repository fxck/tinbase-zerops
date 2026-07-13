# tinbase on Zerops — recipe

See the [root README](../README.md) · backend: **[tinbase.dev](https://www.tinbase.dev)**

## Recipe metadata

- **Name:** <!-- #ZEROPS_EXTRACT_START:name# -->tinbase<!-- #ZEROPS_EXTRACT_END:name# -->
- **Shape:** <!-- #ZEROPS_EXTRACT_START:shape# -->app<!-- #ZEROPS_EXTRACT_END:shape# --> — fork and deploy your own tinbase backend
- **Environments:** `Local` · `Stage` · `Small Production` · `HA Production`

## Tagline

<!-- #ZEROPS_EXTRACT_START:intro# -->
The tinbase backend — the Supabase-compatible API (REST, Auth, Storage, Realtime)
plus Studio — running on Zerops against a managed PostgreSQL. Point supabase-js at it.
<!-- #ZEROPS_EXTRACT_END:intro# -->

## Overview

<!-- #ZEROPS_EXTRACT_START:description# -->
[tinbase](https://www.tinbase.dev) is a Supabase-compatible backend that speaks the
same wire protocol as hosted Supabase, so `@supabase/supabase-js` and the Supabase
CLI work against it unchanged. As of 0.10 it runs against an external Postgres via
`--database-url`. This recipe deploys tinbase as its own Zerops service on top of a
**managed Zerops PostgreSQL**, so your data is durable and backed up while tinbase
supplies the API and Studio.

It's deliberately minimal: two services — `tinbase` (this repo) and `db` (managed
Postgres). tinbase applies `supabase/migrations/*.sql` idempotently on start and
serves REST + Studio on its subdomain. Because it holds no state (everything lives
in `db`), the HA tier runs several tinbase containers over one HA Postgres.

Use it as a standalone Supabase-style backend, or as the base other apps build on —
the [tinbase-benchmark](https://github.com/fxck/tinbase-benchmark) recipe layers a
supabase-js benchmark dashboard on top of exactly this.
<!-- #ZEROPS_EXTRACT_END:description# -->

## Features

<!-- #ZEROPS_EXTRACT_START:features# -->
- **Supabase API, self-hosted** — REST (PostgREST), Auth (GoTrue), Storage, Realtime and a Studio dashboard, from one service.
- **On a managed database** — runs against a durable, backed-up Zerops PostgreSQL, not an embedded engine.
- **Drop-in for supabase-js** — the official SDK and Supabase CLI point straight at it; migrations are the standard `supabase/migrations/*.sql`.
- **Studio included** — table editor, SQL console, auth, RLS, storage and live logs at `/_/`.
- **Stateless + scalable** — no local state, so the HA tier fans out across containers over one HA Postgres.
- **Tiny** — one npm dependency (`tinbase`) plus your migrations.
<!-- #ZEROPS_EXTRACT_END:features# -->

## First-run setup

<!-- #ZEROPS_EXTRACT_START:takeover-guide# -->
**Open Studio.** tinbase's subdomain serves the API; `/_/` is the Studio dashboard.
Authenticate with the service_role key (printed in the service logs, or minted from
`TINBASE_JWT_SECRET`).

**Point a client at it.** `const supabase = createClient('<tinbase-subdomain>', ANON_KEY)`
— the anon key is an HMAC-signed Supabase JWT derived from `TINBASE_JWT_SECRET`.

**It connects to `db` as the superuser** — tinbase creates the `anon` /
`authenticated` / `service_role` roles on first start, which needs `CREATEROLE`.
`DATABASE_URL` is wired from the managed db's superuser credentials automatically.

**Add your schema.** Drop SQL files in `supabase/migrations/`; tinbase applies them
idempotently on the next deploy, exactly like the Supabase CLI.
<!-- #ZEROPS_EXTRACT_END:takeover-guide# -->

## Knowledge base

<!-- #ZEROPS_EXTRACT_START:knowledge-base# -->
### Architecture

```
supabase-js / Supabase CLI / any client  →  tinbase  →  db (managed PostgreSQL)
```

- **tinbase** (this repo) runs `tinbase start --host 0.0.0.0 --port 3000` reading
  `DATABASE_URL`; serves REST + Studio on its subdomain.
- **db** is the managed PostgreSQL; only tinbase connects to it.

### Environment variables

- `TINBASE_JWT_SECRET` (project, auto-generated) — signs the anon / service_role JWTs.
- `DATABASE_URL` (wired) — `postgresql://${db_superUser}:${db_superUserPassword}@${db_hostname}:${db_port}/${db_dbName}` (superuser: tinbase needs `CREATEROLE`).

### Scaling

tinbase is stateless, so the **HA Production** tier runs 2–4 tinbase containers behind
the L7 balancer over one HA Postgres; the bootstrap is idempotent and shared-DB-safe
for REST / Auth / Storage. (Realtime CDC fan-out across many instances is maturing
upstream.) Every container shares `TINBASE_JWT_SECRET` (project scope).

### Troubleshooting

- **`permission denied to create role`** — `DATABASE_URL` isn't the superuser; tinbase can't bootstrap its roles without `CREATEROLE`.
- **Client gets 401** — the client's key isn't signed with this instance's `TINBASE_JWT_SECRET`.
<!-- #ZEROPS_EXTRACT_END:knowledge-base# -->
