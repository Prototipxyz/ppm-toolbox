# DECISIONS

## Architecture
- D-01: Multi-tenant SaaS — one app, one DB, RLS isolation per organization
- D-02: Users are global; role is per organization
- D-03: Org switcher shown only if member belongs to 2+ organizations
- D-04: Org types: company / group / solo / platform
- D-05: Group holding structure via parent_org_id
- D-06: Two-layer roles: functional role (permissions) + display role (free text label)
- D-70: **Terminology: Organizations / Members / Clients** (supersedes earlier "companies/users")
- D-71: App working title: **PPM** (Prototip Project Management). Final name candidate: **ORDO**.
- D-74: Clients tab uses local DB — not Attio (zero tokens, instant, offline)
- D-76: GitHub account: `Prototipxyz`. Vercel active. PPM = new repo separate from prototip.xyz.
- D-77: Stirg management presentation postponed until further notice.

## Data Model
- D-07: Quote-first — folder created at Quote; WO opens on win
- D-08: Quote number = WO number (Q→WO prefix changes, number stays)
- D-16: `display_name` separate from `part_number` for human-readable display
- D-17: display_name rule — capital+digit start: keep underscores; else: underscores→spaces
- D-18: Empty BOM part numbers → auto C570001+ (above highest existing C561562)
- D-19: Photos Option B — per WO BOM line item (not global per PN)
- D-20: Three photo types: Reference (Inventor render), Issue (worker), Completion (optional)
- D-21: Parts hierarchy via parent_id self-ref; assembly_level 0/1/2
- D-22: Status roll-up automatic: assembly blocked if any child blocked
- D-23: BOM import from Inventor structured Excel (Item column = hierarchy)
- D-24: Exchange rate default 117 RSD/EUR, adjustable per transaction
- D-25: Rework tracked via stirg_hours_log.log_type (Standard/Rework/Revision/Recall)
- D-26: Rework always absorbed internally (covered by risk margin)
- D-78: Client numbering scoped per organization (C001 under Stirg ≠ C001 under Prototip)
- D-82: **Part revision letters** = A, B, C. `revision TEXT` field on parts table.
- D-84: **Photo reuse** — `part_reference_photos` table stores canonical photo per org+PN.
- D-86: `work_orders.context` field = **REMOVED.** `organization_id` is source of truth.

## BOM Structure
- D-96: **Three-level BOM maximum** (0=final assembly / 1=sub-assembly / 2=part). Operations are tracked per part/assembly row — no separate PN per operation. Matches Stirg's actual workflow and avoids the complexity of Stadler/SAP-style operation PNs.
- D-97: **Same PN in multiple assemblies** = one parts row per WO instance, quantity summed in queries. Total quantity required = sum across all parent assemblies.
- D-98: **Assembly-level operation assignment**: L0 (final) = paint + final assembly; L1 (sub) = weld + sub-assembly; L2 (part) = laser/bend/cut/procure. CAD Fixed + Drawings Ready apply at all levels.

## Features / UX
- D-28: AI bar persistent above bottom nav — not FAB, not tab
- D-29: Contextual chips change per screen; chip tap pre-fills text
- D-30: Chip actions = zero tokens (direct DB write)
- D-31: Smart chips skip parts already at target status
- D-32: AI restricted to manufacturing operations only (server-side guardrails)
- D-33: Two hour logging modes — factory real-time vs knowledge worker end-of-day
- D-34: Pause types: Break / Material wait / Machine issue / Other job / Other
- D-35: Knowledge worker minimum threshold: >20 min per WO to log
- D-36: Supervisor approval for worker hour logs (end-of-shift)
- D-37: Export reflects active filters
- D-38: All documents bilingual (SR primary, EN secondary)
- D-39: Quote internal costs hidden from client
- D-40: Quoted value fixed at approval; never changes
- D-43: Dark mode primary
- D-44: Stirg accent #E8450A | D-45: Prototip accent #2563EB
- D-46: Monospace for all engineering identifiers
- D-73: Supervisor sees all workers (flat, no team structure) — revisit after trial
- D-75: N/A operations hidden in Parts UI — only relevant operations shown
- D-72: Worker login: PIN code
- D-79: **App branding = company name in header only.** No logo or custom colors in app UI.
- D-80: **UI theming = light/dark toggle only.** Custom logo/fonts/colors for documents only.
- D-81: Workers use **personal phones, stay logged in.** No per-shift PIN re-entry.
- D-83: Google Drive folder creation = **manual** for now.
- D-85: `stirg_operations` = **self-service.** Each org fills in their own rates/norms.

## UX Principles
- D-87: **Role-aware home screen** — Worker sees personal task queue; Supervisor sees live team status board; Manager/PM sees WO job list with health indicators; Owner/CEO sees financial portfolio dashboard.
- D-88: **Progressive disclosure** — all screens start minimal; detail revealed only on tap/expand.
- D-89: **Optimistic UI** — status updates reflect instantly in UI before server confirmation.
- D-90: **Worker AI bar hidden** — Workers do not see the AI bar.
- D-91: **WO detail default tab is role-dependent** — Supervisor → Parts tab; Manager → Overview tab; Owner/CEO → Financials tab.
- D-92: **App language = floor language** — no software jargon. "Job" not "record", "task" not "entry".
- D-93: **Onboarding = first real action** — user completes one real task in first session; that is the tutorial.
- D-94: **Empty states are explicit and actionable** — never blank; always a message and single next action.
- D-95: **Destructive actions require explicit multi-step confirmation** — BOM import must show consequences and require deliberate confirmation.

## Explicitly Excluded
- D-47–D-57: No real-time collab, no MRP, no Gantt, no custom report builder, no email parsing, no bookkeeping, no payroll, no native app, no GPS tracking, no in-app messaging, no BYOK initially

## Toolchain & Build Approach
- D-99: **Build from scratch with Claude Code** — no boilerplate (MakerKit etc.). MakerKit only if auth/multi-tenancy hits a hard wall. Lovable = throwaway UI sketchpad only, never the product.
- D-100: **Claude Code only** — no Cursor. Add Cursor later if needed.
- D-101: **agent-skills via HTTPS first**, seamless transition to SSH once SSH keys configured on laptop. Install: `/plugin marketplace add https://github.com/addyosmani/agent-skills.git`
- D-102: **App repo = `ppm-app`, monorepo** — app + supabase migrations + docs in one repo. KB stays in `ppm-toolbox`.
- D-103: **Deployment = `ppm.prototip.xyz` subdomain** via existing Vercel account. Migrate to new domain later.
- D-104: **Sub-folder CLAUDE.md files generated as each module is reached** — not upfront.
- D-105: **All 5 PPM skills written before any coding begins** — `implement-migration`, `implement-rls-policy`, `implement-api-route`, `implement-component`, `kb-patch`.
- D-106: **Feature specs live in `kb/specs/` in ppm-toolbox repo** — tracked, feed CLAUDE.md, visible to developer on handover.
- D-107: **Build sequence = Schema first, then auth** — all migrations + RLS + seeding + TypeScript types before any UI.

## Worker Auth
- D-108: **Worker PIN auth = Option C** — Owner invites worker by email (Supabase Auth). Worker taps link once, session stored on personal phone (stays logged in, D-81). Every subsequent open shows PIN screen. PIN stored as bcrypt hash on `members` table, validated server-side. If phone lost: owner deactivates member, new phone requires one-time email link again. Zero custom auth logic — Supabase handles sessions entirely.

## Development Workflow
- D-109: **Spec-Driven Development** — every feature gets a 10-line spec in `kb/specs/` before Claude Code touches it. Format: what it does, what it doesn't do, acceptance criteria, edge cases.
- D-110: **Reviewer subagent in fresh context** — after every feature build, review runs in a new Claude Code session seeing only the diff. Never the session that built it.
- D-111: **No deadline but no drag** — build in focused sprints, one phase at a time, ship each phase to Vercel when stable. Stirg pilot when Phase 3 (Worker UI + hours logging) is complete.
