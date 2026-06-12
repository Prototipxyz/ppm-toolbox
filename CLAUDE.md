# CLAUDE.md — PPM Toolbox

> Auto-generated from `/kb/*.md`. Edit KB files, not this file directly.
> Full context: see `/kb/` directory.

---

## What This Project Is

**PPM** — multi-tenant SaaS manufacturing job management platform.
Lightweight MES with job costing for SME manufacturers in Serbia/ex-Yugoslavia.
Two live orgs: **Stirg Metal** (15-worker fab shop) + **Prototip** (engineering services, solo).

---

## Stack

- **Frontend:** Next.js 14+ App Router, TypeScript, Tailwind CSS, shadcn/ui
- **Database:** PostgreSQL via Supabase (`bfhioxqspmypcnpmakyg`)
- **Auth:** Supabase Auth — email/password for staff, PIN for Workers
- **Storage:** Supabase Storage
- **Hosting:** Vercel — separate project from prototip.xyz
- **AI base:** Groq API — `llama-3.3-70b-versatile`
- **AI paid:** Anthropic Claude Haiku
- **Error tracking:** Sentry (day one)
- **CI/CD:** GitHub Actions

---

## Route Structure

```
/app/...     → main app (Owner, Manager, Supervisor, PM)
/w/...       → Worker UI (PIN auth, mobile-only, zero shared components with /app)
```

---

## Critical Rules — Read Before Writing Any Code

1. **RLS on every table before any external user gets access.** No exceptions.
2. **Every table has `organization_id`.** Every query filters by it. RLS enforces this at DB level.
3. **Quoted value never changes after approval** (D-40). Never write code that modifies `quotes.total_amount` after status = Approved.
4. **Rework is always absorbed** (D-26). Log as `stirg_hours_log.log_type = 'Rework'`, never bill to client.
5. **Worker UI has no AI bar** (D-90). Don't add it to `/w/` routes.
6. **Role-aware home screens** (D-87). Each role gets a different default screen — enforce in middleware/layout.
7. **Optimistic UI** (D-89). Status updates reflect instantly; confirm server-side after.
8. **Destructive actions need multi-step confirmation** (D-95). BOM import deletes existing parts — make this visible.
9. **`work_orders.context` field does not exist** (D-86). Use `organization_id` as source of truth.
10. **Display names ≠ part numbers** (D-17). `display_name` auto-generated: capital+digit start → keep underscores; else → underscores to spaces.

---

## Naming & Formatting Conventions

- Monospace for: part numbers, WO codes (WO-26-001), quote codes (Q-26-001), invoice codes (INV-26-001)
- Status colors (never change): Complete=`#16A34A` · In Progress=`#D97706` · Blocked=`#DC2626` · Pending=`#0EA5E9` · Not Started=`#6B7280`
- Accent colors: Stirg=`#E8450A` · Prototip=`#2563EB` · Header/nav=`#0D1117`
- Dark mode primary, light mode toggle available
- App header: company name only — no logos, no custom colors in app UI

---

## Key Entities (short version)

```
organizations     → PPM subscribers (company/group/solo/platform)
members           → users within an org, each with a functional role
clients           → external parties per org (C001 scoped per org)
work_orders       → WO-26-001, status: Draft→Active→On Hold→Delivered→Invoiced→Paid→Closed
quotes            → Q-26-001 (same number as WO on win, prefix changes)
parts             → BOM lines, parent_id self-ref, assembly_level 0/1/2, 9 operations each
stirg_hours_log   → worker time entries with norm/actual, pause reasons, log_type
invoices          → INV-26-001
transactions      → income/expense ledger
```

Full schema: see `/kb/entities.md`

---

## Roles & Permissions (short version)

| Role | Key permissions |
|---|---|
| Owner | Everything + billing + members |
| Manager | All ops + financials + assign + approve hours |
| Supervisor | All workers visible, assign tasks, approve hours. No financials. |
| Worker | Own tasks only. PIN login. Simplified UI. No AI bar. |
| Viewer | Read-only. External client or auditor. |

Full matrix: see `/kb/permissions.md`

---

## BOM Structure

- **3 levels max:** L0=final assembly, L1=sub-assembly, L2=part
- **9 operations per part:** `cad_fixed`, `drawings_ready`, `laser_cut`, `bent`, `cut_to_size`, `procured`, `welded`, `powder_coated`, `assembly`
- **Operation status per part:** Not Started / In Progress / Done / N/A
- **N/A operations are hidden** in UI (D-75)
- **Status roll-up:** assembly blocked if any child blocked (D-22)
- **Operations are NOT separate PNs** — tracked per row, not as separate BOM entries (D-96)

---

## AI Bar (persistent, above bottom nav)

- Inactive: slim bar, ✦ icon
- Active: expands to contextual chips + text input + mic
- Context injected server-side: org, user role, active WO, current tab
- Guard: manufacturing ops only — off-topic politely declined
- Token routing: zero-token chip → SQL | Groq → Haiku → Sonnet

---

## DB Quick Reference

- Supabase project: `bfhioxqspmypcnpmakyg`
- Auth key: `sb_publishable_i9V8xr4SJQ4V1b-6T9k49Q_gQLBJLIm`
- Exchange rate default: 117 RSD/EUR (adjustable per transaction)
- Auto-numbering: C570001+ for empty BOM part numbers

---

## What NOT To Do

- Don't add features excluded in D-47–D-57 (no Gantt, no MRP, no real-time collab, no payroll, no GPS)
- Don't write cross-org queries without RLS
- Don't modify quoted totals after approval
- Don't add AI bar to Worker UI
- Don't create per-operation part numbers in BOM (D-96)
- Don't use `work_orders.context` — it was removed (D-86)

---

## KB Files (full context)

| File | Contents |
|---|---|
| `kb/vision.md` | Product vision, problem statement, target market |
| `kb/architecture.md` | Full stack, integrations, build workflow |
| `kb/entities.md` | Complete data model and table definitions |
| `kb/permissions.md` | Roles, org types, permissions matrix |
| `kb/workflows.md` | WF-01 through WF-09 |
| `kb/features.md` | Feature specs for all tabs and screens |
| `kb/users.md` | User roles, org types, key journeys |
| `kb/decisions.md` | All D-numbered decisions |
| `kb/open_questions.md` | Resolved and open questions |
| `kb/tooling_strategy.md` | Tool roles, MCP strategy, skills strategy |
| `kb/stirg_document_brand.md` | Stirg document/report brand spec |
