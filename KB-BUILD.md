# KB-BUILD.md — PPM Condensed Build Context
> Source of truth: github.com/Prototipxyz/ppm-toolbox
> Full KB in /kb/. This file = decisions + schema + roles only. ~3k tokens.
> Upload this file to Claude.ai project panel after each session update.

---

## Project Identity
- **App:** PPM (working title) | candidate name: ORDO
- **Category:** Lightweight MES + job costing for SME manufacturers
- **Orgs:** Stirg Metal (accent #E8450A) + Prototip (accent #2563EB)
- **Supabase:** `bfhioxqspmypcnpmakyg`
- **Repo:** `Prototipxyz/ppm-app` (monorepo) | KB: `Prototipxyz/ppm-toolbox`
- **Deploy:** `ppm.prototip.xyz` (Vercel, existing account)

---

## Stack
Next.js 14+ App Router · TypeScript · Tailwind · shadcn/ui · Supabase (PostgreSQL + Auth + Storage) · Vercel · Groq (`llama-3.3-70b-versatile`) · Claude Haiku · Sentry · Zod + next-safe-action · TanStack Query · Playwright

---

## Route Structure
- `/app/...` — main app (Owner, Manager, Supervisor, PM)
- `/w/...` — Worker UI (PIN auth, mobile-only, zero shared components)

---

## Roles & Permissions
| Role | Financial | All Workers | Assign | Hours | AI Bar |
|---|---|---|---|---|---|
| Owner | ✓ | ✓ | ✓ | ✓ | ✓ |
| Manager | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor | ✗ | ✓ (all) | ✓ | ✓ | ✓ |
| Worker | ✗ | own only | ✗ | own only | ✗ |
| Viewer | read-only | ✗ | ✗ | ✗ | ✗ |

Worker login: PIN (Option C) — email once via invite, PIN daily on personal phone. `members.pin_hash` bcrypt.

---

## Key Entities (fields that matter for coding)
```
organizations:     id, code, name, org_type, parent_org_id, preferred_currency, drive_folder_id
organization_branding: organization_id, logo_url, logo_light_url, primary_color, document_font, doc_language
clients:           id, organization_id, code (C001 scoped per org), name, contact_name/email/phone
members:           id, organization_id, user_id, role, display_role, pin_hash, is_active
work_orders:       id, organization_id, code (WO-26-001), client_id, quote_id, title, status, priority, their_ref, start_date, deadline
quotes:            id, organization_id, code (Q-26-001), client_id, status, total_amount (LOCKED after Approved)
quote_lines:       quote_id, activity, billing_type, quantity, unit, rate, amount, sort_order
parts:             id, organization_id, work_order_id, part_number, display_name, parent_id (self-ref),
                   assembly_level (0/1/2), revision, photo_url
                   → operations via part_operations join table (max 12, D-122)
ppm_operations:    id (OP-00001), name, category, is_verified, usage_count, created_by_org_id
org_operations:    id, organization_id, ppm_operation_id, name, default_fulfillment,
                   default_assembly_levels[], is_active, sort_order
part_operations:   id, part_id, org_operation_id, status (Not Started/In Progress/Done/N/A),
                   fulfillment_type (in_house/outsourced/TBD), sort_order, added_by
operation_usage_log: ppm_operation_id, raw_name, organization_id — UNIQUE per org+name
stirg_hours_log:   work_order_id, operation_id, worker_user_id, date, norm_hours, actual_hours, log_type (Standard/Rework/Revision/Recall), pause_type
invoices:          code (INV-26-001), work_order_id, client_id, amount, currency, amount_eur, exchange_rate (default 117)
transactions:      date, type (Income/Expense), source, category, amount, currency, amount_eur
sequences:         name, year_code, last_num — drives WO-26-001, Q-26-001, INV-26-001, C001
part_reference_photos: organization_id, part_number, photo_url (canonical per org+PN, reused across WOs)
```

---

## Status Values (fixed, never change)
- WO status: `Draft → Active → On Hold → Delivered → Invoiced → Paid → Closed`
- Quote status: `Draft → Sent → Approved → Rejected → Expired`
- Part op status: `Not Started | In Progress | Done | N/A`
- Procurement: `Pending | Ordered | In Transit | Arrived | Cancelled`
- Hour log approval: `Approved | Queried | Adjusted`

---

## UI Constants
```
Status colors:
  Complete/Paid:    #16A34A (green)
  In Progress:      #D97706 (amber)
  Blocked/Overdue:  #DC2626 (red)
  Pending/Draft:    #0EA5E9 (sky)
  Not Started:      #6B7280 (grey)

Layout:
  Mobile: bottom nav + swipe
  Desktop ≥1024px: left sidebar
  Header: company name only, no logo
  Dark mode primary, light toggle available
  Monospace (font-mono): all part numbers, WO codes, financial figures
```

---

## Non-Negotiable Rules (code enforcement)
1. RLS on every table — no exceptions
2. Every table has `organization_id`
3. Use `(SELECT auth.uid())` never bare `auth.uid()` in RLS
4. `quotes.total_amount` never changes after status = Approved (D-40)
5. Rework = `log_type='Rework'` — never billed, always absorbed (D-26)
6. Worker UI (`/w/`) has no AI bar (D-90)
7. `work_orders.context` does not exist — removed (D-86)
8. Financial tables (quotes, invoices, transactions) = Owner + Manager only
9. Worker sees own `stirg_hours_log` rows only
10. Spec before code, always (D-109). Reviewer in fresh context (D-110).

---

## Build Sequence
```
Phase 1 — Schema + RLS + TypeScript types (current)
Phase 2 — Auth + App shell (layout, nav, dark mode, org switcher)
Phase 3 — Parts tracking (WO detail → Parts tab → pipeline strip) ← CORE FEATURE
Phase 4 — Work Orders list
Phase 5 — Worker UI (PIN flow, task queue, timer)
Phase 6 — Hours + Supervisor approval
Phase 7 — Financials
Phase 8 — Quotes + PDF export
Phase 9 — AI bar
```

---

## Workflow Per Feature (exact sequence)
```
1. SPEC → kb/specs/<feature>.md in ppm-toolbox (Claude.ai)
2. /spec → Claude Code confirms spec loaded
3. /plan → review + approve before any code written
4. /build → implement
5. /review → FRESH Claude Code session, diff only
6. /test → explicit inputs/outputs, all roles tested
7. COMMIT → pre-commit hooks gate → Vercel deploys
```

---

## Skills Available in Claude Code
```
/implement-migration    → migration → RLS → types
/implement-rls-policy   → all 5 roles, client SDK testing
/implement-api-route    → Zod schema + role guard + error handling
/implement-component    → shadcn + PPM tokens + role-aware + optimistic UI
/kb-patch               → end-of-session KB update → commit → CLAUDE.md updates
```
Plus agent-skills (Osmani): `/spec /plan /build /test /review /ship`

---

## BOM Logic (D-96, D-97, D-98)
- 3 levels max: L0=final assembly, L1=sub-assembly, L2=part
- Operations tracked per row — NOT separate PNs per operation
- Same PN in multiple assemblies = one parts row, quantity summed in queries
- L0 ops: powder_coated + assembly | L1: welded + assembly | L2: laser_cut/bent/cut_to_size/procured
- CAD Fixed + Drawings Ready apply at all levels
- N/A operations hidden in UI (D-75)
- Status rollup: assembly blocked if any child blocked (D-22)
- Flat view: deduplicated, total qty summed, "in N assemblies" shown in orange

---

## Parts/Operations Screen (D-162-175) -- Phase 3
- Ops: blocked flag + reason enum (Material wait/Machine issue/Quality issue/Procurement delay/Other), independent of status, overrides color to red. Fulfillment (in_house/outsourced) toggled inline per op-instance.
- Procurement (outsourced ops): status/lead_time/sent/expected/actual dates. last_order_date = WO.deadline - lead_time - 3d buffer. Alerts: green/blue/amber/red.
- Flat view: Assembly(has children)/Parts(leaf)/All filter; List(default)/Cards toggle on md+; mobile = compact bullet+OpName status-lights, tap to expand.
- Search bar: paste PNs -> select matches; unmatched -> prompt qty/desc -> add ad-hoc part. Delete allowed only when leaf (live-computed, no cascade needed).
- AI bar: zero-token chip resolution (PN -> assigned-op chips -> catalog-op chips -> "+new op"), tap = instant action; free-text API path remains for the rest.
- Export: per-operation columns (not summary string); "Consignment note" template for any op-filtered set.
- Validated (v2, D-162/163/165/166/167) via ppm-parts-ops.jsx artifact. Unvalidated (v3, D-168-174) -- prototype in Claude Code, not artifact (OQ-55).

---

## Tools (what each is for)
| Tool | Use for |
|---|---|
| Claude.ai project chats | Decisions, specs, architecture, KB updates |
| Claude Code (terminal) | All coding — migrations, components, routes, tests |
| Lovable | Throwaway visual mockups only — screenshot, discard code |
| Sentry | Passive error monitoring |
| Playwright | E2E tests, CI gate |

---

## New Chat Opener
```
PPM build — continue. Read KB-BUILD.md in project files.
Decisions run D-01 to D-175. 
Last completed: [X].
Next: [Y].
```
