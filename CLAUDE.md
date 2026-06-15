# CLAUDE.md — PPM Toolbox
> Last updated: 2026-06-15 05:26 UTC

> Auto-generated from `/kb/*.md`. Edit KB files, not this file directly.
> Full context: see `/kb/` directory. Specs: see `/kb/specs/`.

---

## What This Project Is

**PPM** — multi-tenant SaaS manufacturing job management platform.
Lightweight MES with job costing for SME manufacturers in Serbia/ex-Yugoslavia.
Two live orgs: **Stirg Metal** (15-worker fab shop, accent #E8450A) + **Prototip** (engineering services, solo, accent #2563EB).
Supabase project: `bfhioxqspmypcnpmakyg`

---

## Stack

- **Frontend:** Next.js 14+ App Router, TypeScript, Tailwind CSS, shadcn/ui
- **Database:** PostgreSQL via Supabase (`bfhioxqspmypcnpmakyg`)
- **Auth:** Supabase Auth — email/password for staff, PIN (Option C) for Workers
- **Storage:** Supabase Storage
- **Hosting:** Vercel — `ppm.prototip.xyz` subdomain
- **AI base:** Groq API — `llama-3.3-70b-versatile` ✅ account created
- **AI paid:** Anthropic Claude Haiku
- **Error tracking:** Sentry (day one)
- **Validation:** Zod + next-safe-action on every server action
- **Data fetching:** TanStack Query (optimistic UI)

---

## Route Structure

```
/app/...     → main app (Owner, Manager, Supervisor, PM)
/w/...       → Worker UI (PIN auth, mobile-only, ZERO shared components with /app)
```

---

## Skills Available

```
/implement-migration    → migration → RLS → types (use after every schema change)
/implement-rls-policy   → write + test RLS for all 5 roles
/implement-api-route    → server action with Zod + role check + error handling
/implement-component    → shadcn base + PPM tokens + role-aware + optimistic UI
/kb-patch               → end-of-session KB update → commit → CLAUDE.md auto-update
```

Also available via agent-skills: `/spec /plan /build /test /review /ship`

---

## Workflow Per Feature (exact sequence every time)

```
1. Spec written in kb/specs/<feature>.md (Claude.ai)
2. /spec → Claude Code confirms spec read
3. /plan → review and approve plan BEFORE any code
4. /build → implement
5. /review → FRESH SESSION, diff only
6. /test → explicit inputs/outputs, all roles
7. Commit → pre-commit hooks gate
```

---

## Critical Rules — Read Before Writing Any Code

1. **RLS on every table before any external user gets access.** No exceptions.
2. **Every table has `organization_id`.** Every query filters by it.
3. **Use `(SELECT auth.uid())` never bare `auth.uid()`** — bare re-evaluates per row.
4. **Quoted value never changes after approval** (D-40). Never modify `quotes.total_amount` after status = Approved.
5. **Rework always absorbed** (D-26). Log as `log_type = 'Rework'`, never bill.
6. **Worker UI has no AI bar** (D-90). Never render it in `/w/` routes.
7. **Role-aware home screens** (D-87). Middleware enforces per-role routing.
8. **Optimistic UI with rollback** (D-89). Status updates instant; roll back on server error.
9. **Destructive actions = multi-step confirmation** (D-95). BOM import shows consequences.
10. **`work_orders.context` does not exist** (D-86). Use `organization_id`.
11. **Financial tables = Owner + Manager only** (quotes, invoices, transactions).
12. **Worker sees own hours only** — RLS on `stirg_hours_log` must enforce this.
13. **Spec before code, always** (D-109). No exceptions.
14. **Review in fresh context** (D-110). Never review in the session that built.

---

## Naming & Formatting

- Monospace (`font-mono`): part numbers, WO codes, invoice codes, financial figures
- Status colors (never change): Complete=`#16A34A` · In Progress=`#D97706` · Blocked=`#DC2626` · Pending=`#0EA5E9` · Not Started=`#6B7280`
- Dark mode primary, light toggle available
- App header: company name only — no logos in app UI

---

## Worker PIN Auth (D-108)

Owner invites worker by email → Supabase Auth handles session → worker taps link once.
Every subsequent open: app shows PIN screen → PIN validated server-side against `members.pin_hash` (bcrypt).
Session stays alive on personal phone (D-81). If phone lost: owner deactivates member.
Zero custom auth logic — Supabase handles sessions entirely.
`members` table has `pin_hash TEXT` (nullable — NULL until worker sets PIN).

---

## Key Entities

```
organizations     → PPM subscribers (company/group/solo/platform)
members           → users within org, role + pin_hash
clients           → external parties per org (C001 scoped per org, D-78)
work_orders       → WO-26-001, Draft→Active→Delivered→Invoiced→Paid→Closed
quotes            → Q-26-001 (same number as WO on win)
parts             → BOM lines, parent_id self-ref, assembly_level 0/1/2, 9 ops each
stirg_hours_log   → worker time entries, norm/actual, pause reasons, log_type
invoices          → INV-26-001
transactions      → income/expense ledger
```

Full schema: `kb/entities.md`
Permissions: `kb/permissions.md`

---

## What NOT To Do

- Don't write cross-org queries without RLS
- Don't modify quoted totals after approval
- Don't add AI bar to `/w/` Worker UI
- Don't use bare `auth.uid()` in RLS policies
- Don't create per-operation part numbers in BOM (D-96)
- Don't use `work_orders.context` — removed (D-86)
- Don't add: Gantt, MRP, real-time collab, payroll, GPS, in-app messaging (D-47–D-57)
- Don't skip the spec step
- Don't review in the same session that built

---

## KB Files

| File | Contents |
|---|---|
| `kb/vision.md` | Product vision, problem, target market |
| `kb/architecture.md` | Stack, integrations, deployment |
| `kb/entities.md` | Complete data model |
| `kb/permissions.md` | Roles, org types, permissions matrix |
| `kb/workflows.md` | WF-01 through WF-09 |
| `kb/features.md` | Feature specs for all screens |
| `kb/users.md` | User journeys per role |
| `kb/decisions.md` | All D-numbered decisions (D-01 through D-111) |
| `kb/open_questions.md` | Resolved and open questions |
| `kb/tooling_strategy.md` | Tool roles, workflow sequence, MCP strategy |
| `kb/stirg_document_brand.md` | Stirg document brand spec |
| `kb/specs/phase-1-schema.md` | Phase 1 database spec |
| `kb/specs/phase-1-implementation-workflow.md` | Exact steps for Phase 1 |
| `kb/specs/_template.md` | Spec template for new features |
