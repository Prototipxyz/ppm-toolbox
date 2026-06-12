# Spec: Phase 1 — Database Schema + RLS + Types

**Phase:** 1
**Depends on:** nothing — this is the foundation

## What it does
Creates the complete PPM database schema in Supabase with all tables, indexes, RLS policies, and seed data. Generates TypeScript types from the schema. After this phase, the database is production-ready and no further schema changes should be needed for Phase 2 (auth + UI shell).

## What it does NOT do
- Does not create any UI
- Does not implement auth flows (Phase 2)
- Does not import real BOM data (deferred, OQ-10)
- Does not set up stirg_operations rates (deferred, OQ-09)
- Does not create Google Drive folders (manual, D-83)

## Migration sequence (order matters — foreign keys require this order)
1. `organizations` (no dependencies)
2. `organization_branding` (depends on organizations)
3. `users` (Supabase Auth manages this — extend with custom fields only)
4. `members` (depends on organizations + users)
5. `clients` (depends on organizations)
6. `sequences` (no dependencies)
7. `work_orders` (depends on organizations + clients)
8. `quotes` + `quote_lines` (depends on work_orders + clients)
9. `parts` (depends on work_orders — self-referential parent_id)
10. `part_reference_photos` (depends on organizations)
11. `procurement` (depends on work_orders)
12. `stirg_operations` (depends on organizations)
13. `stirg_hours_log` (depends on work_orders + stirg_operations + members)
14. `hour_log_approvals` (depends on work_orders + members)
15. `activity_types` (depends on organizations)
16. `hours_log` (depends on work_orders + activity_types)
17. `invoices` (depends on work_orders + clients)
18. `transactions` (depends on organizations)
19. `equipment` (depends on organizations)

## RLS policy required on every table
All 19 tables need RLS enabled and policies written before this phase is complete.
Financial tables (quotes, quote_lines, invoices, transactions) — Owner + Manager only.
Hours tables (stirg_hours_log) — Owner/Manager/Supervisor see all; Worker sees own only.
Everything else — all active members of the org.

## Seed data required
Two organizations:
- Stirg Metal (id: existing, accent: #E8450A, type: company)
- Prototip (id: new, accent: #2563EB, type: solo)

One member per org (Voja, role: Owner).
Existing 365 parts migrated from current flat structure (parent_id=NULL until BOM import).
Existing WOs (WO-26-001, WO-26-002) migrated.
Ivan Advokat re-linked as client under Prototip org (U-04).

## Acceptance criteria
- [ ] All 19 tables exist with correct columns, types, and constraints
- [ ] Every table has `organization_id` column (except `users`)
- [ ] Every table has RLS enabled
- [ ] Every table has RLS policies tested from client SDK for all 5 roles
- [ ] Cross-org isolation verified — org A cannot read org B data
- [ ] TypeScript types generated and committed at `types/supabase.ts`
- [ ] `supabase gen types` runs without errors
- [ ] Seed data applied — both orgs visible, existing data migrated
- [ ] `(SELECT auth.uid())` used everywhere, never bare `auth.uid()`
- [ ] All FK columns indexed
- [ ] All `organization_id` columns indexed

## Edge cases
- `parts.parent_id` is self-referential — migration must handle this (add column after table creation, or use DEFERRABLE constraint)
- `sequences` table drives auto-numbering — seed with correct starting values (WO-26-NNN already at 002, Q-26-NNN at whatever current max is)
- `members.pin_hash` column — bcrypt hash, nullable (NULL until worker sets PIN), TEXT type
- Exchange rate default 117 RSD/EUR on `transactions` and `invoices`

## Data touched
- All tables (creating from scratch in new repo, migrating existing data from `bfhioxqspmypcnpmakyg`)
- Source DB: Supabase project `bfhioxqspmypcnpmakyg`
- Target: same DB (migrations applied to existing project)

## Known constraints
- RLS must be on ALL tables before any external member gets an account (non-negotiable)
- `parts` self-reference requires careful migration ordering
- Existing 365 parts have parent_id=NULL — acceptable, stays that way until BOM upload
- `work_orders.context` field does NOT exist — was removed (D-86)
- `organization_branding` currently seeded against wrong entity — fix in seed migration (U-03)
