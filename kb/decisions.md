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

## Project & Workflow Decisions (from chats)
- D-112: **Product category = lightweight MES with job costing** — closest to Odoo Manufacturing stripped of 80% complexity. One-line: "What you get if Odoo Manufacturing and Jobber had a child, raised on a factory floor in Serbia, with an AI assistant."
- D-113: **Worker UI is the real moat** — no ERP has a good factory-floor UI. PIN login, simplified interface, real-time operation tapping with pause reasons is what manufacturers actually need and currently solve with paper and WhatsApp.
- D-114: **BOM queries use recursive CTEs** — `parent_id` self-reference with `assembly_level` requires PostgreSQL recursive common table expressions for hierarchy traversal. Plan for this in Phase 1 schema.
- D-115: **KB-BUILD.md = condensed project file for new chats** — ~3k token summary of all decisions, entity fields, roles, status values. Full KB stays in GitHub as source of truth. KB-BUILD.md uploaded to Claude.ai project panel, updated after each session.
- D-116: **New chat opener standard format** — start every new project chat with: "PPM build — continue. Read KB-BUILD.md. Last completed: [X]. Next: [Y]."
- D-117: **Session sync rule** — at end of every chat that produced decisions: run kb-patch skill, push to GitHub, regenerate KB-BUILD.md, re-upload to project panel.
- D-118: **BOM display_name rule for compound names** — names with multiple capitalised segments (e.g. "Magna-Lok Rivet") are kept as-is. Only single-word names with underscores get underscore→space treatment. (From BOM analysis chat.)
- D-119: **Generic CAD names flagged for review** — BOM import flags names like "Product1", "Part1", "Assembly" as requiring manual rename before production use. Shown in amber in review UI.
- D-120: **Parts deduplication in flat view** — flat list shows unique PNs with total quantity summed across all parent assemblies. "In assemblies" column shows count in orange when PN appears in multiple places.


## Configurable Operations (D-121 to D-130)
- D-121: Fixed 9-column parts schema replaced with three-tier configurable system:
  Global pool (PPM-managed) → Org catalog (per org) → Part assignment (per part).
  The 9 hardcoded op columns on `parts` table are removed entirely.
- D-122: Pipeline strip maximum = 12 segments. Only assigned non-N/A ops render.
  PM can add/remove ops on a part card up to the 12-segment ceiling.
- D-123: Operation fulfillment flag on every part-level assignment:
  `fulfillment_type: in_house / outsourced / TBD`.
  Outsourced ops automatically generate a procurement item.
- D-124: Global pool operation IDs = `OP-00001` sequential with leading zeros.
  Category stored as separate field, not encoded in ID.
- D-125: Global pool promotion trigger = cross-org only (Option B).
  Same op name (fuzzy matched) in 5+ distinct orgs triggers admin review queue.
  Single-org internal usage never triggers promotion regardless of frequency.
- D-126: Admin review flow — PPM admin panel shows flagged ops.
  Decision: approve into global pool / reject / merge with existing op.
  Approved ops receive permanent OP-NNNNN ID.
- D-127: Add/remove operations on part card = Owner, Manager, Supervisor only.
  Worker cannot add or remove operations.
- D-128: Removing an In Progress operation is hard-blocked.
  Must be reset to Not Started before removal. Warning shown.
- D-129: New op added to a part → saves automatically to org catalog.
  Never goes directly to global pool. Cross-org usage count triggers promotion per D-125.
- D-130: Two industry presets at launch:
  Sheet Metal Fabrication (Stirg profile) + Engineering Services / Prototyping (Prototip profile).
  Each is a curated starter op set. Fully adaptable after activation.
- D-98: ~~Assembly-level operation assignment hardcoded (L0/L1/L2 per op type)~~
  SUPERSEDED by D-121/D-130. Now a soft suggestion (`default_assembly_levels[]`
  on `org_operations`), not a hard rule.

## Warehouse & Location Tracking
- D-131: **Warehouse location tracking = optional org feature.** Enabled per org by Manager. Not required for pilot — post-pilot Phase N+1.
- D-132: **Storage location types: Pallet or Shelf Bin.** Org configures count and type. App generates sequential 3-part location codes: Zone-Row-Position (e.g. A-02-04).
- D-133: **Location codes are short alphanumeric, human-readable.** QR codes generated as printable PDF with configurable label dimensions. Fallback: worker types location ID manually if camera unavailable.
- D-134: **Storage location setup managed by Manager role** (not Owner-only, not Supervisor).
- D-135: **General material inventory excluded from scope.** Raw stock handled by Business Central. Worth revisiting post-pilot as Phase N+2.
- D-136: **Drop-off scan is the primary location commitment.** After completing an operation, worker scans or types destination location + quantity. Skippable with flag — never a blocker.
- D-137: **Tapping Start on an operation clears the previous storage location** — no separate pick-up scan. Start = "I have the parts" + timer begins simultaneously (Model B).
- D-138: **Location skip = warning flag on PN, never a work blocker.** Supervisor resolves manually, or next operator ratifies by confirming where they found parts when tapping Start.
- D-139: **Quantity at location model.** Location record stores "N of M at A-02-04." Start tap decrements or clears. Drop-off sets new quantity and location.
- D-140: **Location persists through N/A operations.** Last known drop-off carries forward silently until the next active operation's Start tap clears it.
- D-141: **Batch scan supported.** Worker selects multiple PNs (same or different WOs) and assigns to one location in single scan. Quantity entered per PN.
- D-142: **Next operator's Start tap ratifies previous skip flag** by prompting "confirm where you found them" — soft prompt, skippable.
- D-143: **Three-tier warehouse model.** Tier 1 = disabled (default, all orgs). Tier 2 = simple/flat named locations (LOC-001), free text names, no enforced structure — for shops where parts go wherever there is space. Tier 3 = structured Zone-Row-Position codes (A-02-04), zones map to permanent physical fixtures not functional areas. Orgs upgrade Tier 2 → Tier 3 without losing data. `organizations.warehouse_tier` field: none/simple/structured.
- D-144: **QR label size defaults: 100×50mm (bin/shelf) and 148×105mm A6 (pallet).** Custom width/height input available. OQ-48 resolved — no need to ask Stirg upfront.

## Phase 1 Build — Session 1 (2026-06-14)
- D-145: **`public.clients` renamed to `public._legacy_clients`** to resolve naming collision. The new `public.clients` table (external parties per D-70/D-78) cannot coexist with the old `clients` table which held org-level entities. Old 2 rows (Stirg Metal, Ivan Advokat) preserved in `_legacy_clients` for migration in migration 6.
- D-146: **Migration history repair** — 8 remote migration versions from legacy ppm setup (20260609192327 through 20260611092839) marked as `reverted` in `supabase_migrations.schema_migrations`. Schema and data untouched. Required to unblock `supabase db push` in the new ppm-app repo.
- D-147: **Seed migration `20260614000006_seed_orgs_and_members.sql` required before Session 2.** Must run before migrations 6–19 because later tables FK into `organizations`. Must: insert Stirg Metal org (code: STIRG, org_type: company), insert Prototip org (code: PROTO, org_type: solo — new, did not exist), move Ivan Advokat from `_legacy_clients` into `public.clients` under Prototip org (U-04), insert Voja as Owner member for both orgs, fix `organization_branding` rows for both orgs (U-03).
- D-148: **All 5 PPM skills implemented and live as Claude Code project slash commands.** Mechanism: `.claude/commands/*.md` files in ppm-app repo — Claude Code reads these automatically as `/command-name` slash commands. Files also exist in `.claude/skills/*/SKILL.md` (agent-skills format, secondary). The `.claude/commands/` path is operative. Skills: `/implement-migration`, `/implement-rls-policy`, `/implement-api-route`, `/implement-component`, `/kb-patch`.

## System Resilience & Fallback Principles
- D-149: **Graceful degradation is a standing requirement.** Every automated/AI/optional
  feature must have a manual equivalent for core workflows (status updates, hours,
  quotes, invoices). Non-core features must be toggleable per-org without breaking
  anything. Every feature spec must answer: "What happens if this is OFF or FAILS?
  Does core still work?" Applies retroactively to D-123, D-125, D-137, AI bar, push
  notifications, photo reuse, status rollup caching.

## Phase 1 Follow-up & Cross-Phase Resolutions (D-150 to D-161)
- D-150: **Group org RLS validated via synthetic seed data** (parent + 1 subsidiary)
  before Phase 3. Fallback if RLS recursion is impractical: parent-dashboard reads
  via SECURITY DEFINER function instead of policy recursion.
- D-151: **"Win" transition = one server action, independently-retryable steps,
  never blocked by side-effect failure.** Failed steps (folder rename, BOM trigger)
  create a flagged task for Owner/Manager + expose a manual retry button. Spec:
  `kb/specs/win-transition.md` (Phase 8). This retryable-steps pattern is the
  template for all multi-system transitions.
- D-152: **Procurement auto-gen (D-123) never auto-deletes.** Fulfillment change
  away from outsourced leaves the procurement item in place
  (`source: 'auto_generated'` flag) for Manager review. Fulfillment change TO
  outsourced links to an existing matching item instead of duplicating.
- D-153: **Assembly status rollup materialized** via `computed_status` column/trigger
  on `parts`, updated on child `part_operations` change. Self-healing backstop:
  scheduled recompute job if trigger fails. Tree view never computes rollup live.
- D-154: **Recursive CTE load test required before Phase 3 sign-off** (3 levels,
  ~365 parts, worst-case fan-out). If >200ms, extend materialization
  (`part_hierarchy_flat` view per WO, refreshed on BOM import/structural change).
  Results logged as D-154a/b once measured.
- D-155: **Norm-vs-Actual report added to Phase 6 scope.** Hidden entirely
  (not empty) if `stirg_operations` has zero norm values for the org — appears
  automatically once OQ-09 data is entered. No schema change.
- D-156: **Quote Accuracy trend added to Phase 7 scope** (Reports Tab sparkline,
  last 10 closed WOs). Shows "Not enough data yet" if <3 closed WOs (D-94 empty
  state). No schema change.
- D-157: **AI-bar query pattern sketch required in Phase 3 spec** — write the SQL
  for a representative "what's blocking WO-X" query against the proposed Phase 3
  schema as a sanity check, 6 phases before AI bar is built.
- D-158: **OQ-31 resolved** — Worker home = single current-task card (primary),
  queue via swipe/expand (D-88). **Offline pattern**: optimistic local state +
  queued sync + visible "syncing" indicator; failed sync shows explicit retry
  message, never silent loss. Backstop: Supervisor can always manually correct
  any worker's hours/status (existing permission). Documented in
  `kb/specs/phase-5-worker-ui.md`.
- D-159: **Phase 5 Start-action built with post-Start hook list** (extension
  points). Warehouse location-clear (D-137) added later as a hook, not a Phase 5
  modification. Hooks are fire-and-forget — failure logged, never blocks the
  primary action (timer start).
- D-160: **Prototip document brand spec** — new file `kb/prototip_document_brand.md`
  before Phase 8. Activity-based quote layout (vs Stirg's operations/materials/subs).
  Confirm document language default with Voja (Prototip may be EN-primary vs
  Stirg's SR-primary per D-38).
- D-161: **OQ-32 resolved** — two always-on layers: (1) passive badge counts
  (Supervisor approvals pending, skip-flags, Blocked WOs, overdue procurement) —
  computed independently of push, push-failure-proof; (2) OneSignal push, fixed
  initial event set (skip-flag→Supervisor, hour-log Queried→Worker,
  WO Blocked→Manager+Owner), per-member togglable, no rules engine. Passive badges
  are source of truth if push fails.

## Parts/Operations Mockup — Validated (D-162 to D-167)
Validated via ppm-parts-ops.jsx test artifact (Claude.ai Project sandbox).
- D-162: Operations carry an independent `blocked` flag + `blocked_reason` enum (Material wait / Machine issue / Quality issue / Procurement delay / Other) + optional note. Blocked renders red regardless of underlying status (Not Started/In Progress/Done).
- D-163: Per-op-instance fulfillment (in_house/outsourced, D-123) is an inline toggle on every assigned operation at any time — not just at assignment — and is what drives Procurement view population (D-152).
- D-164: Procurement lead-time model: each outsourced op-instance gets status (Not Ordered/Ordered/In Transit/Arrived/Unavailable-find replacement), lead_time_days, sent_date, expected_return_date, actual_return_date. last_order_date = WO deadline − lead_time − admin_buffer (default 3 days). Alerts: green=received, blue=on track, amber=order within 7 days of last_order_date, red=overdue-to-order / expected-after-deadline / Unavailable.
- D-165: Operations export as individual columns (one per distinct op name, pool + custom), value = status or "BLOCKED: <reason>" — not a single concatenated summary column.
- D-166: "Consignment note" export template — Items/PN/Name/Qty/Operation/Status + Sent/Expected/Received dates, for any operation-filtered part set (reusable across all outsourced ops, not destination-specific).
- D-167: Clicking a Blocked/Flagged/Done stat (or selecting an operation filter) replaces the active view with a deduped flat results list — no modal — with select-all and bulk-apply on the filtered set.

## Parts/Operations Screen — Specified, Not Yet Validated (D-168 to D-175)
Specified via design discussion (clarification Q&A); not yet built/tested in a working mockup. Confirm during Phase 3 implementation (OQ-55).
- D-168: Flat/filtered views get an Assembly/Parts/All toggle. Part = leaf (no children, computed live); Assembly = has children. Tree view unaffected.
- D-169: Flat/filtered/Procurement views get a List (default)/Cards toggle on tablet+. List = dense single-column rows, ops as inline "● Op Name" status-light chips, full ops panel on expand. Cards = grid, ops panel always open. Mobile always uses the compact list — no toggle.
- D-170: Mobile rows show assigned ops as a read-only "● Operation Name" status-light list under the part info; tapping the row expands the full interactive panel. Lights are not independently tappable.
- D-171: Visible copy-to-clipboard icon next to every PN, all screen sizes (not hover-only).
- D-172: Top-of-screen search/select bar accepts one or many PNs (typed or pasted, split on newline/comma/tab/space, case-insensitive). Matches select all for bulk actions; unmatched tokens offer "add as new part", prompting for qty/description (+ optional mass/material) before creating a minimal ad-hoc part.
- D-173: Parts are deletable only when they currently have no children (leaf, computed live) — deleting an assembly's children bottom-up naturally makes it deletable too; no cascade-delete is offered. One-tap-then-confirm; removes the part's operations/procurement records.
- D-174: AI command bar gets a zero-token chip-resolution mode (D-30 lineage): typed text is matched token-by-token against PNs/items; once resolved, the part's assigned ops appear as tappable status-colored chips (tap = cycle status instantly), then matching catalog ops not yet assigned (tap = add instantly), then — if nothing matches remaining text — "+ Add '<text>' as new operation" (tap = add custom op instantly, per D-129). Free-text AI/API path remains for anything chips can't express.
- D-175: Procurement lead-time/alert/consignment-note tracking (D-164/D-166) is scheduled within Phase 3 (Parts tracking) — the `procurement` table already exists from Phase 1, item generation is driven by Phase-3 fulfillment flags (D-123/D-163), and it addresses Stirg's real outsourcing pain (unlike warehouse-locations, which stays post-pilot). Subcontractor cost roll-up into Financials (Phase 7) is separate and unaffected.

## Visual Identity & Design Workflow (D-176 to D-179)
- D-176: **Claude Design = visual design tool**, included in existing Pro/Max
  subscription (research preview, no extra cost). Replaces "Lovable, optional"
  as Step 1.5 (Visual Validation) in the per-feature workflow — describe screen,
  iterate in Claude Design, hand result to Claude Code as visual spec for /build.
- D-177: **Color philosophy = consistency + familiarity, not color-psychology
  symbolism.** Existing status-color convention (D-43-46, traffic-light
  green/amber/red/sky/grey) is the correct "behavioral" pattern — universal
  recognition beats theoretical color meaning. Visual identity exploration
  (logo, app screens) inherits these status colors as fixed constraints.
- D-178: **"Instagram-easy, SAP-powerful" = interaction patterns, not visual
  mimicry.** Already encoded via D-88 (progressive disclosure), D-89 (optimistic
  UI), D-95 (two-step destructive confirm). Worker UI (/w/) is where
  consumer-app interaction patterns (swipe, tap-to-expand, large touch targets)
  matter most — already scoped that way.
- D-179: **Phase 3 slice (priority build) = full parts/assemblies tracker.**
  Scope: parts-operations-screen.md (D-162-175) + procurement-tracking.md
  (D-164/166/175) — operations per PN, status, pipeline strip, photos,
  outsourced flag, procurement/lead-time/last-order-date/alerts, exports.
  Excludes: financials, hours logging, CEO dashboard (deferred to later phases
  per existing sequence). AI bar: chip-resolution (D-174) included as
  zero-token UI logic; free-text AI path deferred to Phase 9 per D-157.
  Model strategy: Opus 4.8 for RLS/migrations/recursive-CTE logic, Sonnet 4.6
  for UI components and routine feature work (cost/risk-proportionate split).

## BOM Analysis Pipeline
- D-180: BOM/source-document analysis (Stadler, GST, Siemens, Supplier 4, cross-analysis)
  runs in separate Claude.ai chats — never Claude Code, which stays reserved for app
  build work. Model: Sonnet 4.6. Deterministic extraction (hierarchy parsing, image
  extraction, format classification) runs via code execution, not model reading of
  raw cells. Model judgment is reserved for classification/flagging calls and
  cross-source reconciliation notes. Each chat outputs a compact JSON fixture
  (no embedded images, no supplier/contact PII) to kb/test-fixtures/. Extracted
  images and any contact-level data go to Supabase Storage (private buckets:
  part-photos, kb-private-fixtures), never to the public ppm-toolbox repo.
- D-181: **Supabase Storage uploads now go through a deployed Edge Function
  proxy**, not a generated/deleted `sb_secret_` key per session (supersedes
  D-180 step 10's literal ritual -- see tooling_strategy.md). Function
  `kb-storage-upload` (project `bfhioxqspmypcnpmakyg`) holds the service-role
  key only inside its own runtime (Supabase auto-injects
  `SUPABASE_SERVICE_ROLE_KEY`, never exposed to the calling chat). Hardcoded
  bucket allowlist (`part-photos`, `kb-private-fixtures` only), path-traversal
  validation (whole-segment check, not substring -- substring match
  false-flagged a real PN, `C518846.2.1.2..jpg`), upsert writes, 200-files/
  request cap. Auth = anon/publishable key (non-secret) + a random token
  embedded in the function's own source, retrievable via `get_edge_function`
  in any future chat -- never persisted in Claude memory. Kept live in
  production for now rather than torn down after use; see OQ-60.

## Multi-Instance Orders & Unit Traceability

- **D-181: Work Orders can span multiple assembly types; quantity lives on a per-assembly-line multiplier, not a WO-level field.** A WO may need N units of assembly X and M of assembly Y at once (e.g. 3xSWC + 2xUWC). Quantity is captured per (work_order, assembly_template) as `units_ordered`; BOM import explodes each template's per-unit quantities x units_ordered into that WO's parts rows, feeding the existing same-PN-multiple-assemblies summing rule (D-97) with correct numbers rather than changing it.
- **D-182: MOQ/minimum-order-quantity cost correctness needs no new schema in v1.** Procurement quantity is already manually entered (procurement-tracking.md); cost correctness comes from a PM entering the real purchased quantity (e.g. 100 screws for an MOQ) rather than the theoretical BOM requirement (5) -- no MOQ-specific feature needed. Deferred nice-to-have: display gross-requirement-vs-actual-ordered as a surplus figure once D-181's multiplier exists to supply the "gross requirement" side. General raw-material inventory/stock tracking remains excluded (D-135 unchanged, not reopened).
- **D-183: Unit-level serialization is an opt-in, per-org and per-assembly-template feature, default off.** Same customization pattern as org_operations-over-ppm_operations and the warehouse-location tiers -- most orgs won't need it, some (e.g. Stirg, for rail-client contractual/regulatory traceability) will. When enabled: serial format is fully org-configurable via the existing `sequences`/`next_code()` mechanism (Stirg's real `ST001, ST002...` format becomes its configuration, not a system default); the operation marking a unit as individually identifiable is set per assembly template, not a fixed global stage, since this varies by product; serials are assigned lazily, only when a specific unit reaches its template's serialization point -- never reserved upfront for a WO's full unit count, avoiding sequence gaps from cancelled or unbuilt units. Physical labeling (if used) reuses the existing QR/label-generation built for warehouse locations (D-133/D-144) rather than a second implementation.
- **D-184: Material-lot traceability, when enabled, is lot-to-unit granularity, never part-to-unit.** Track which material lot/cut-batch fed which serialized unit, not individual serialization of every component. Lot capture attaches to actions that already happen (a field on material receiving, a confirm-tap when starting a cutting/bending operation) rather than a dedicated logging step; lot data is optional per delivery and must degrade gracefully (D-149) when a supplier doesn't provide a mill certificate -- never blocks receiving or production. Default policy for a scrapped/rebuilt unit (provisional, easy to revise): new serial for the rebuild, original stays on record marked scrapped/voided.

## RLS Enablement Methodology

- D-185: **RLS enablement for the 15 currently-disabled tables follows a fixed single-combined-migration methodology, independent of policy content.** `ENABLE ROW LEVEL SECURITY` and `CREATE POLICY` ship in the same migration per table — never split, since a table with RLS on and zero policies blocks all access. Spec-first: policy content (org-scoping mechanism per table, role granularity) gets written in plain language before any SQL — see OQ-65 (dual schema / legacy table fate) and OQ-66 (role granularity), both unresolved. Model: Opus 4.8, extending D-179's RLS/migration routing. Verification: `pg_class.relrowsecurity`, not `information_schema` (existing established pattern). Testing isolation: the current single real auth user is Owner of both orgs and can't demonstrate cross-org denial alone — use a second single-org test user or `SET request.jwt.claims` simulation instead. Deferred to a future session (Voja working from home); not started 2026-06-18.


## Data Completeness

- D-186: **Extends D-149 (Graceful Degradation) to part-level data completeness.** Non-core fields on a part record (photos, supplier, lead time, description) may be null at creation and filled in at any time afterward; missing values never block that part's use in BOMs, work orders, or other core workflows. UI treatment for surfacing gaps is not decided here -- left to whichever feature spec actually builds the parts screen.


## Lost-Bid Case Studies & Quoting Logic (Stadler ÖBB NV)

- D-187: **Lost-bid case studies (no won client, e.g. Stadler ÖBB NV SWC/UWC bid) are tracked as dual-track artifacts.** D-180's BOM-pipeline mechanics (structure-first inspection, hierarchy-depth check, structured.json fixture) are reused for raw CAD-BOM extraction even though there's no real production outcome to validate against -- tagged distinctly in tooling_strategy.md's pipeline table, never conflated with won-client rows (Stadler, GST). In parallel, cost/operations logic specific to bid preparation feeds a separate Quoting & Estimation initiative (D-188) rather than the parts/operations pipeline.
- D-188: **Quoting & Estimation conceptual model confirmed** (the logic, not the specific rates -- those are case-study-specific and fluctuate). Part identity is multi-key: canonical/internal key + optional client-assigned number + optional document number + optional manufacturer PN, each scoped to its own relationship rather than forced into one field -- real-world evidence (ÖBB NV case study) shows a single 'part number' column gets overloaded with whichever identifier was on hand (document number, manufacturer catalog code, or ad-hoc annotated text); see OQ-68 for the still-open schema question this implies. Operations attach via a flag+cost join per operation type, with cost derived from a rate table (material x thickness/geometry -> time -> rate -> cost + prep constant) rather than stored as flat hours-per-part. Cost rolls up through make/buy-differentiated markup (confirmed real precedent in the case study: 30% in-house / 10% purchased). Procurement feasibility (lead time, MOQ, order date) is tracked as a separate axis from cost, never folded into price. Informs the still-empty `stirg_operations` table (OQ-09) without changing its current columns yet.
- D-189: **Cross-assembly quantity stays derived from multiple BOM-line rows (existing D-97/D-120 approach), not adopted as a precomputed local+other-assembly split.** The ÖBB NV case study's TEHNOLOGIJA file uses a 'Kom.' (local qty) + 'Kom u drugom sklopu' (other-assembly qty) = 'Ukupno' (total) pattern on a single row, but that only handles two buckets and risks drift from the underlying assembly relationships as they change. The existing per-(part, parent_assembly) row + flat-view summation (D-120) already scales to any number of assemblies and stays consistent by construction. No schema change now; if reused-part aggregation ever becomes a measured performance bottleneck, add an optional materialized total (trigger-maintained, following D-153's rollup pattern) as a later, additive change -- not adopted preemptively.

- D-190: **Winkler BOM source — extraction methodology choices (explicit "do as you think is best" delegation).** (a) Canonical part images stored once under a shared `STIRG/winkler/` Storage path rather than split per-tank — 91 of ~140-149 unique parts are identical across both tank BOMs, so a shared namespace avoids duplicate uploads; deviates from the strict per-source-label-per-fixture path convention (tooling_strategy.md) by design. (b) Offer_Winkler.xlsx's procurement rows are duplicated into each tank's public fixture, filtered by the sheet's own `Use` column (200L/900L/Both), keeping each fixture self-contained per the existing one-fixture-per-source pattern rather than introducing a third shared file. (c) Raw `Part Number` strings are preserved as-is in the BOM tree — no blanket code/description parser, since the separator between structured code and description is inconsistent (hyphen/underscore/space/none) and not all rows follow the pattern. A bounded, resolved cross-reference was built instead, specifically for the Offer's 27 real line items, via normalized prefix-matching against both BOMs (18/27 resolved, 9 held as unresolved/anomalous — see OQ-69).

- D-191: **Operations table — Setup vs. Run time split.** Every operation gets four norm-hour fields instead of one: Setup-Standard, Setup-Complex (h/batch, one-time per job/batch — tool change, programming, fixture prep) and Run-Standard, Run-Complex (h/unit, repeating per piece/hit/hole/meter). Applies uniformly to all operations (some legitimately have Setup = 0). Driven by Stirg's own observation that press-bending tool-change time was being conflated with per-hit run time. Implemented in `Stirg_Operacije_Norms.xlsx` (L–O columns); not yet reflected in `stirg_operations`/`ppm_operations` schema (still unbuilt per OQ-09).
- D-192: **OP-001 split into internal estimating vs. vendor sourcing.** OP-001 "Quoting & Estimating" narrowed to internal-only labor (CAD/BOM/cost review). New OP-027 "Vendor Sourcing & Quote Comparison" added, unit = per RFQ sent (not per part), covering vendor identification, RFQ emails, and quote comparison/entry for purchased components. Explicitly excludes vendor reply lead-time (elapsed waiting) — that is calendar/scheduling data, not labor-hour cost, and does not belong in this cost-rate table (see OQ-70).
- D-193: **Scrap/rework time excluded from operation norm hours by design.** Mistakes/rework are not built into any operation's Setup or Run norm. Handled today as a quoting-stage contingency markup (%, decided at quote time, independent of any single operation), and intended later as an empirically-derived figure from actual-vs-norm variance once real job hour-logging exists — not guessed into a flat norm now.
- D-194: **Laser cutting (OP-009) and welding (OP-016) flagged as formula-driven norm candidates, flat placeholders used as interim.** Both operations' real cycle time is driven by a continuous measure (cut length / weld length) plus a count (pierces / joints), not well captured by a single flat h/unit norm. Preferred real data sources identified: laser job-history output from the shop's own nesting/CAM software (cut time already calculated per real job) for OP-009; existing BOM weld-length lines (EN 15085-3, already captured per D-187/188 BOM pipeline) combined with a shop-measured deposition rate (h/mm) for OP-016. Flat placeholder values entered in `Stirg_Operacije_Norms.xlsx` for now, explicitly marked PLACEHOLDER, pending either data source.
- D-195: **All "Norm Hours" values in `Stirg_Operacije_Norms.xlsx` are unvalidated placeholders, explicitly approved as the starting baseline.** Voja confirmed: use the proposed placeholder figures (generic job-shop ballpark estimates, not Stirg-measured) as-is for now; refine via real job data once PPM logs actual hours against operations. Visually flagged in the file via yellow italic font + "PLACEHOLDER —" prefix in the Notes column, distinct from the existing yellow-background "assumption to update" convention.
- D-196: **DXF-based cut-time estimation — material/thickness/qty resolution strategy (proposed, not yet built).** Tiered fallback, evaluated in order: (1) part-record lookup — if the DXF's PN already exists in the parts tracker, pull material/thickness/qty from that record rather than re-deriving from the file; (2) filename parsing against an enforced naming convention (PN_MATERIAL_THICKNESSmm_QTYpcs.dxf or similar, to be defined) as best-guess for parts not yet in the system; (3) AI-assisted interpretation of inconsistent/malformed filenames (typo correction, fuzzy field recognition) only when strict parsing fails; (4) manual entry as ultimate fallback, always available. AI only asked to guess when rule-based parsing fails, and AI must request confirmation rather than silently accept low-confidence guesses on costing-relevant fields (material/thickness). Explicitly non-blocking: DXF upload/auto-estimation is an optional time-saving feature, core PPM workflows must function with or without it (consistent with D-149 Graceful Degradation Principle).
- D-197: **DXF cut-time estimator to be built as a standalone trial tool before PPM integration.** Geometry extraction (cut length, pierce/contour count from DXF) has no dependency on Supabase schema, auth, or org structure — build and validate it standalone (e.g. local script or simple drag-drop page, no deployment) against real DXFs and real laser-software output first. Once cutting-speed math is validated, the core parsing logic becomes a module called from PPM's batch-upload UI rather than a separate app — avoids committing schema/UI before the underlying time math is trustworthy.

- D-198: **Bend count is geometrically extractable from a DXF, conditional on bend lines being present and layer-separated.** Flat pattern DXFs from Inventor/SolidWorks may include bend lines on a distinct layer (or as a distinguishable linetype) — if so, counting those entities gives bend count with the same reliability as cut-length/pierce-count extraction (D-196 Tier 0/1). If bend lines are stripped before laser export (a real possibility, sometimes done deliberately so the laser doesn't attempt to cut them), bend count is not recoverable from that DXF and must come from elsewhere (3D model bend table, or BOM/operation data). Not yet confirmed which case applies to Stirg's actual exports — pending real sample DXF review (see OQ-73).
- D-199: **CAD-side pre-export macro approved as the preferred fix for DXF metadata + filename reliability, ahead of relying on export-template configuration alone.** Build order: Inventor iLogic macro first (current CAD system in use); SolidWorks VBA macro later, deferred until Stirg's possible future SolidWorks switch happens. Both must share one CAD-agnostic output contract (same filename format + same embedded metadata structure) so downstream DXF parsing never needs to know which CAD system produced the file. Macro behavior: prompts the laser-file-prep worker (shop-floor user, not engineer) for qty/material/thickness before export; blocks export until filled; writes the correct filename automatically; embeds the same values as DXF metadata (exact embedding mechanism — layer text vs. custom property — still open, see OQ-73). Material field is free text for now (D-200 supersedes with dropdown once real data exists); thickness likely a dropdown of common values (1mm, 2mm, 3mm...) with a manual/"Other" fallback, consistent with D-149 Graceful Degradation Principle.
- D-200: **Filename convention locked: `PN_MATERIAL_THICKNESSmm_QTYpcs.dxf`.** Applies as the Tier 2 fallback in D-196's resolution strategy, and as the macro's auto-written filename (D-199). Material dropdown explicitly deferred — free text for now; a fixed dropdown list should be sourced from real BOM/parts material data later, not invented ad hoc (avoids inventing a materials taxonomy disconnected from what parts records actually contain).

## DXF Estimator â€” Layer Rule, Scope & Resolution Chain (D-201 to D-206)

- D-201: **OQ-73 resolved â€” bend lines confirmed present and layer-separated in
  Inventor's flat-pattern DXF export**, via real export sample (`testpart.dxf`)
  and cross-checked against Autodesk's documented `FLAT PATTERN DXF` translator
  parameters. Fixed, version-stable layer vocabulary: `IV_OUTER_PROFILE` /
  `IV_INTERIOR_PROFILE` (cut geometry), `IV_BEND` / `IV_BEND_DOWN` (bend lines,
  one entity per bend), `IV_FEATURE_PROFILES` (formed features â€” excluded from
  cut geometry per explicit decision), plus several non-cutting reference layers
  (`IV_TANGENT`, `IV_TOOL_CENTER`, `IV_ARC_CENTER`, `IV_ROLL*`, `IV_ALTREP*`,
  `IV_UNCONSUMED`) discarded entirely. Earlier laser-floor DXF samples lacking
  bend-line layers reflect a downstream export/CAM step, not a translator
  limitation â€” the estimator tool's input contract is the Inventor-side
  flat-pattern export, not arbitrary laser-floor files.
- D-202: **DXF cutting-time estimator scoped as a standalone tool** (extends
  D-197): per-part pipeline reads an Inventor flat-pattern DXF, classifies
  geometry by the D-201 layer rule, computes cut length / pierce count / bend
  count, re-exports a clean laser-ready DXF (cut geometry only â€” no text, no
  bend lines, no markings), and writes an Excel report row. Interface: local
  GUI, drag-drop, editable rate-constant fields in both the tool form and the
  Excel output (placeholder defaults, D-195 convention). Output (clean DXFs +
  report) goes to a user-chosen destination folder; source DXFs and any
  supplied BOM file are never modified, renamed, or moved.
- D-203: **Pierce count = interior closed loops + 1** (the outer profile counts
  as one pierce).
- D-204: **Material/thickness resolution is metadata â†’ filename â†’ manual flag
  only â€” no BOM fallback.** These are part-intrinsic properties (true regardless
  of which WO/assembly the part is used in), owned by the D-199 macro's embedded
  metadata and the D-200 filename convention. BOM cross-reference is explicitly
  scoped to quantity only (D-205), since quantity is contextual to a specific
  assembly/WO rather than intrinsic to the part.
- D-205: **Quantity resolution chain: metadata â†’ filename â†’ optional BOM
  cross-reference â†’ flag+default(qty=1) â†’ manual.** BOM cross-reference (only
  when the user supplies an Inventor BOM Excel export alongside the DXF batch)
  has two paths depending on which BOM view is provided: Parts Only (flat) view
  â€” direct read of the `QTY` column, since Inventor's flat view already sums
  quantity across parent assemblies (consistent with D-97/D-120); Structured
  (hierarchical) view â€” tool walks the Item-number hierarchy and computes final
  per-PN quantity as the product of each ancestor's quantity down the tree,
  summed across all occurrences (real traversal algorithm, not a groupby â€” same
  family as D-114's recursive BOM logic, applied to a BOM Excel file rather than
  the `parts` table). PN matching between DXF and BOM rows is not assumed exact
  (per OQ-59/68/69 precedent) â€” unmatched rows are flagged, never silently
  attributed. This resolves the "should the macro pull qty from the assembly
  BOM" question raised this session: quantity resolution stays entirely in the
  estimator tool, not the macro â€” avoids making the macro assembly-context-aware,
  which would have required a different (batch/assembly-level) trigger point
  than D-199's part-level export-time prompt.
- D-206: **Estimator report computes per-piece and total (per-piece Ã— qty) time
  and cost separately, qty as a live-editable cell driving the total via
  formula, never hardcoded.** Per-piece figures are the values intended to
  later attach to a PN's norm data in PPM (`org_operations`/`part_operations`
  lineage, OQ-09); the qty multiplier is applied at the order/BOM-line level,
  matching D-188's existing quoting model (rate Ã— time â†’ cost, then quantity
  applied separately) rather than baking quantity into the part's own cost data.
## Inventor Macro â€” Revised Architecture: Two Macros, Model-Data-First (D-207 to D-210)

- D-207: **D-199 revised â€” macro reads material/thickness from Inventor's Sheet
  Metal Style automatically; worker prompt is a fallback, not the primary
  mechanism.** Every sheet-metal part has material + thickness as required
  inputs to its Sheet Metal Style (the flat-pattern unfold calculation depends
  on them), so this data already exists in the model and does not need to be
  re-typed by a human. The macro reads it directly; the worker is only
  prompted if the part's Sheet Metal Style is genuinely unset/missing this
  data â€” a real data-quality flag, not a routine step. Filename-writing and
  metadata-embedding behavior from D-199/D-200 are unchanged; only the
  material/thickness *source* changes, from "always ask" to "read first, ask
  only on gap." Quantity remains worker-prompted at the part level (D-199's
  original scope) â€” quantity is not part of the model.
- D-208: **Second macro added: assembly-level batch export, in scope from the
  start (not deferred).** Walks all components in an assembly, filters to
  sheet-metal-type parts only (`Document.SubType` check), exports each one's
  flat pattern. Distinct from the D-199/D-207 part-level macro â€” different
  trigger context (batch, from an assembly) â€” implemented as a separate
  macro rather than a single mode-switching one, since the two trigger points
  and data sources differ enough that branching would add complexity without
  benefit.
- D-209: **Batch macro runs unattended â€” no per-part prompts, no blocking.**
  Material/thickness read from each part's Sheet Metal Style (D-207's
  mechanism, reused). Quantity read from the assembly's own BOM (live, no
  Excel export/import step needed â€” the macro has direct API access to the
  assembly's BOM at run time, unlike the standalone estimator tool which
  needs a file). Anything missing or unresolvable (e.g. a part with no
  Sheet Metal Style data set) is flagged for manual review after the batch
  completes, never blocks mid-walk â€” consistent with D-149 Graceful
  Degradation applied to a batch context specifically.
- D-210: **Batch macro skips re-exporting unchanged parts on a re-run.**
  Inventor tracks flat-pattern-out-of-date state and document modification
  time natively; the macro compares each part's last-modified state against
  its destination DXF's last export and skips if unchanged. Not a new
  tracking mechanism â€” reuses data Inventor already maintains, so this adds
  negligible complexity for a real time saving on repeated exports of large,
  mostly-unchanged assemblies.

## Standalone Tool â€” Platform & PPM Integration Boundary (D-211)

- D-211: **DXF estimator stays a desktop application â€” not a web app â€” and
  does not write directly to PPM/Supabase even once PPM is live.** Desktop
  fits the actual usage pattern (local folder of 300+ files, single user, at
  their own machine) and preserves D-197's standalone/no-dependency
  rationale; a web version would require either server-side DXF parsing
  infrastructure or an unproven browser/WASM port of the parsing logic, to
  solve a remote-access problem that does not currently exist. PPM
  integration path is staged, not architected for immediately: the Excel
  report format is kept clean/structured enough to support a future PPM
  *import* screen (one-click, not automatic) once the tool's placeholder
  rates have been validated against real machine output; a live direct-write
  integration (estimator â†’ Supabase) is deferred to a later, explicitly
  scoped phase once the time math is trustworthy â€” not built now, to avoid
  wiring unvalidated data into production the same way D-197 already avoids
  committing schema/UI before the time math is proven.

## Scope Boundary â€” DXF Tool vs. PPM Quoting/Parts-Tracking (D-212)

- D-212: **DXF estimator explicitly stays scoped to DXF geometry extraction
  and per-piece time/cost data â€” does not grow into a parallel quoting or
  parts-tracking application.** Raised and considered this session (operations
  setup embedded in BOM custom properties, full quote generation from
  hourly rates, desktop parts/pre-production tracker) â€” all of this is
  already PPM's scope (D-121-130 configurable operations, D-188 Quoting &
  Estimation model, parts-operations-screen.md), already decided to live in
  the Supabase-backed multi-tenant app, not a single-user desktop tool.
  Building it twice risks two systems competing to own operations/rates/quotes
  data that drift apart over time. The estimator's role is the measurement
  instrument that validates per-piece time data (D-206) before that data
  feeds PPM's `org_operations` norm fields (OQ-09 lineage) â€” not a second
  system of record.
## Third Inventor Macro â€” CAD-Side Operations Tagging (D-213)

- D-213: **Third macro: visual operation tagging in CAD, as the authoring step
  for a part's initial operation set â€” not a parallel source of truth to
  PPM's `part_operations`.** Worker views/rotates the actual 3D part or
  assembly in Inventor and marks which operations apply (welding, tapping,
  painting, etc.), written to custom iProperties, carried through the BOM
  export as columns. Rationale: judging which operations a part needs is
  more reliable looking at the real rotatable model than a flat thumbnail in
  a parts-tracker list â€” a genuine ergonomic/accuracy advantage over
  assigning operations later from a 2D BOM view alone.
  **Division of ownership (resolves the standalone-tool-vs-PPM tension raised
  in D-212):** CAD tagging seeds the *initial* `part_operations` assignment
  at BOM import time only â€” once a part exists in PPM, all further changes
  (adding Rework, toggling fulfillment in_house/outsourced per D-123, a
  Supervisor adjusting assignments mid-job) happen in PPM exactly as D-121-130
  already specify. CAD is the authoring tool for the starting state; PPM is
  the system of record from that point forward. Consistent with D-129 (new
  op assignment saves to org catalog, not directly to global pool) and D-186
  (initial/non-core data may be filled in or corrected later, never blocking).
  Mechanism (mirrors D-208's external-rule + ribbon-button pattern): separate
  external iLogic rule from the export macros, since tagging happens before
  export and is a distinct worker action.

## Standing Rule â€” Operation-Coverage Percentages Must Use the Eligible-Parts Denominator (D-214)

- D-214: **Any report or calculation expressing "what % of parts have
  operation X done/assigned" must divide by the count of parts actually
  eligible for/assigned operation X â€” never by the total BOM/part-number
  count.** Surfaced from a real defect: a prior BOM analysis report (GST,
  D-180 pipeline) computed weld completion against the full ~365-part-number
  list rather than only the parts actually requiring welding, producing an
  invalid/misleadingly low percentage. Applies independent of whether
  operation assignment originates from CAD tagging (D-213), PPM's
  `part_operations` table, or any other source â€” this is a correctness rule
  for the calculation itself, not a CAD-vs-PPM data-source question. Applies
  retroactively as a standing rule to all future BOM/operations analysis
  output (D-180 pipeline chats, PPM Reports tab per D-155/156, any
  operation-filtered stat per D-167).

## Cuts and Bends Estimator — Rate Tables, Layer Mapping, DWG, Telemetry (D-215 to D-218)

- D-215: **Rate constants are per-machine + per-material+thickness combination,
  not flat global values.** Cut speed (mm/min) and pierce time (sec) vary
  significantly by both material and thickness (e.g. stainless cuts slower
  than mild steel at the same thickness; doubling thickness more than halves
  achievable speed), so a single global constant would produce systematically
  wrong output for any batch spanning multiple materials. The rate table in
  Cut Rates Settings is keyed by machine + material + thickness — rows
  addable/removable, not a fixed list. Bend time is also per-machine (different
  press brakes) and optionally per-material+thickness, same table structure.
  The Excel report's per-piece time formulas reference this table via lookup
  (not hardcoded constants), so changing a rate cell recalculates all affected
  rows. Placeholder defaults ship with the app per D-195 convention, clearly
  marked as unvalidated until the user replaces them with real measured values.

- D-216: **D-201's hardcoded IV_* layer rule is superseded — layer classification
  is now configurable via a CAD profile system.** Different CAD tools export
  flat-pattern DXFs with different layer naming conventions; hardcoding
  Inventor's IV_* names would break any non-Inventor shop. The tool ships
  with three built-in presets and supports user-defined custom profiles:
  Inventor default (IV_OUTER_PROFILE / IV_INTERIOR_PROFILE / IV_BEND /
  IV_BEND_DOWN); SolidWorks pre-2022 (CUT / CUT / BEND / BEND — no up/down
  distinction by default); SolidWorks 2022+ (CUT / CUT / BEND-UP / BEND-DOWN
  — requires mapping file enabled on export side); Custom (all four layer
  name fields user-definable). The active CAD profile is selected in Settings,
  persisted locally, defaults to Inventor on first run. The DXF parser reads
  layer names from the active profile at runtime — never hardcoded strings.
  This is the primary mechanism for extending the tool to additional CAD
  sources in future (Fusion 360, Catia, Creo, etc.) — adding a new source
  is adding a new preset entry, no parser changes needed. The IV_* layer
  names documented in D-201 remain accurate as the Inventor preset's values,
  but are no longer the tool's fixed contract.

- D-217: **The tool accepts DXF files only — DWG is explicitly out of scope.**
  DWG is AutoCAD's proprietary binary format; reliable parsing requires a
  commercial library (ODA/Teigha) which adds cost and licensing complexity
  inconsistent with the tool's standalone/no-external-dependency posture
  (D-211). DXF is the standard format used by laser cutting shops and is
  natively exportable from every CAD tool that can also save DWG. DWG files
  dropped onto the tool show a clear, non-blocking notice: "DWG files are
  not supported — export as DXF from your CAD tool first." This is consistent
  with D-149 (graceful degradation, never silent failure) — the user gets an
  actionable message, not a parse error or silent skip.

- D-218: **Telemetry pipeline for cross-customer rate calibration — Phase 2,
  architecture must support it from day one.** The product vision (D-211,
  genuinely sellable to multiple shops) creates an opportunity: with explicit
  opt-in consent, installations can contribute anonymized machine configuration
  data (rate table values and machine types only — never part files, filenames,
  part numbers, or any shop-identifying information) to a private central store
  (Supabase, existing project bfhioxqspmypcnpmakyg) which the developer can
  query to derive improved default rate presets and push them as app updates.
  Existing users' own configurations are never overwritten by updates.
  Architecture requirement that must be implemented NOW (before settings
  screen is built): three strictly separate local files —
  settings.json (user's own config, never touched by app updates),
  presets.json (shipped with the app, replaced on update, never contains
  user-modified values), telemetry_config.json (opt-in flag + anonymous
  installation ID only). This separation is the sole Phase 1 requirement;
  the actual telemetry submission module, the Supabase endpoint, and the
  preset-derivation workflow are all Phase 2 and must not be built yet.
  Legal/compliance note: telemetry requires explicit opt-in (not opt-out)
  and a privacy notice specifying what is collected and how it is used —
  mandatory for EU/Serbian market compliance regardless of data minimization.
  The opt-in prompt appears on first run; declining has no effect on
  functionality.

## Cuts and Bends Estimator — Distribution, Quality, Legal (D-219 to D-222)

- D-219: **App must be distributable as a standalone Windows .exe via
  PyInstaller — code must support this from the start.** For distribution
  to other shops, the app cannot require Python to be installed on the
  target machine. PyInstaller bundles the entire app (including PySide6,
  ezdxf, openpyxl) into a standalone executable. Code requirements that
  must be respected from day one: a single `version.py` file containing
  only `__version__ = "x.y.z"` as the canonical version source; no
  hardcoded absolute paths anywhere in the code (all paths relative to
  the app's runtime location or the user's configured data directory);
  clean separation of app code from user data per D-218's three-file
  structure. PyInstaller packaging itself is a Phase 2 task — the code
  structure requirement is Phase 1.

- D-220: **Auto-update via PyUpdater (GitHub releases as distribution
  channel) — Phase 2, architecture-ready from day one.** PyUpdater
  (built on PyInstaller) enables the installed app to check a GitHub
  releases page on startup, notify the user of available updates, and
  apply them with one click. Updates are signed with a developer-held
  private key — only authorized releases apply. The update mechanism
  distinguishes app code updates (replaces the executable) from preset
  updates (replaces presets.json only) — rate table improvements can
  ship independently of full app releases. Phase 1 requirement: correct
  `version.py` and D-218 file separation. Phase 2: PyUpdater integration,
  GitHub releases workflow, signing key generation.

- D-221: **EULA accept screen on first launch — hook built now, text
  finalized before first external distribution.** A EULA is required
  before charging any non-Stirg customer. Minimum required content:
  description of what the tool does; disclaimer that time/cost estimates
  are based on user-configured placeholder rates and are not guaranteed
  to be accurate for binding quotes; limitation of liability for losses
  caused by incorrect estimates; license scope definition (one installation
  per company, or similar). The EULA text will be written in Serbian and
  English. The first-launch Accept/Decline button is built now as a hook
  (decline exits the app); the EULA text file ships with the app and is
  replaceable without a code change. Code signing certificate (~$100-300/yr,
  DigiCert or similar) to suppress Windows "Unknown publisher" warning —
  required before first external customer, not needed for internal Stirg use.

- D-222: **Standing production-quality rules for all Cuts and Bends
  Estimator code — every session.** These are non-negotiable baselines,
  not aspirational goals: (1) Per-file error isolation — every DXF
  processed in a batch is wrapped in its own try/except; any exception
  flags that file and continues the batch, never crashes the app.
  (2) Input validation at all boundaries — rate table fields, BOM Excel
  imports, DXF drops, settings imports — invalid input is rejected with
  a clear message at the point of entry, never reaches calculation logic.
  (3) Structured session logging — every session writes to
  logs/session_YYYY-MM-DD.log: files processed, flags raised, exports
  completed, errors with full tracebacks. Log files rotate (keep last
  30 days). (4) Top-level crash reporter — unhandled exceptions are
  caught at the application entry point, written to logs/crash_YYYY-MM-DD.log,
  and shown to the user as a clean "something went wrong — crash report
  saved at [path]" dialog, never a raw Python traceback. (5) Settings
  backup — before any write to settings.json, a timestamped backup copy
  is written to settings_backup/. (6) No hardcoded strings that belong
  in config (layer names, file paths, version numbers, rate values).
  (7) No silent failures anywhere — every error either recovers
  gracefully or surfaces explicitly to the user.

## Machine Parameter Import, Library UX, File Format Support (D-223 to D-226)

- D-223: **Machine selection uses a three-tier model: preset library
  (presets.json, ships with app/updates) → user's configured machines
  (settings.json, this shop's active machines) → favorite machine
  (settings.json, default selection).** The Bystronic parameter library
  generated from the .par file parser (D-215/D-216) is the source for
  presets.json, covering all machine models found (SPRINT3015, STAR3015,
  STAR4020, STAR4025, SPEED3015, SPEED4020, BYJIN3015, BYJIN4020,
  VENTION3015, SUN3015, etc.) with full rate tables per
  material+thickness+gas. New machines and corrected rates ship via
  app updates that replace presets.json only — user's own settings.json
  is never touched by updates (D-218).
  User's machine list ("My Machines"): on first launch (or after a
  library update adds new machines), the user sees a machine selection
  screen listing all machines in presets.json. They tick the ones their
  shop actually has — these get written to settings.json as active
  machines. "Load more machines" button always available in Settings to
  add more from the library later. Custom machines (not in the library)
  can also be added manually with their own rate tables.
  Favorite machine: one machine designated as the default selection,
  stored in settings.json. Always pre-selected when the app opens. Can
  be changed in Settings → My Machines → "Set as favorite."
  Pre-estimation confirmation popup: before every estimation run, a
  popup shows the currently selected machine and gas type and asks the
  user to confirm before proceeding. Popup is dismissible per-session
  (shows once per session on first run, then only shows again if the
  machine selection was changed since the last run in that session).
  Rationale: prevents silent errors from a machine selection left over
  from a previous session. Consistent with D-222's no-silent-failures
  rule.
  Material name normalization: the .par library contains duplicate
  material group names across different machine folders. presets.json
  normalizes these to standard names: Mild Steel, Stainless Steel,
  Aluminum, Copper, Brass, Titanium. The DIN code and original material
  number are preserved as metadata. Normalization mapping maintained in
  material_map.json, updatable without touching the parser or presets.

- D-224: **In-app raw parameter import ("Import Machine Parameters")
  — Option A, fully integrated into the estimator app itself.**
  Machine Settings screen includes an "Import Machine Parameters" button
  that opens a folder picker. The app scans the selected folder
  recursively for supported parameter files, parses them internally
  (same logic as the standalone parser scripts), normalizes material
  names via material_map.json, and adds the discovered machines and
  their rate tables to the user's local library. No external scripts,
  no command line, no Python knowledge required — the entire pipeline
  runs inside the app. Progress shown inline (files found → parsing →
  normalizing → machines discovered → confirm import). User reviews the
  discovered machines before committing — never silently overwrites
  existing configured rates. After successful import, newly discovered
  machines appear in "My Machines" with an option to set as active.
  Contributing back to the global preset library: after import, the app
  optionally (opt-in, per D-218's telemetry framework) submits the
  normalized rate table to the developer's central store (Supabase,
  project bfhioxqspmypcnpmakyg) so it can improve future presets.json
  releases for all users. Only normalized rate data is submitted — never
  raw files, never shop identity, never production data.

- D-225: **Supported parameter file formats — Bystronic .par native,
  Excel template universal fallback, Trumpf planned for v2.**
  v1 supports: (1) Bystronic .par files (confirmed XML-inside,
  machine model encoded in filename, full rate data available);
  (2) Excel template import — the app exports a blank, correctly
  structured template that any user can fill in manually regardless of
  machine brand, then import back. This covers 100% of brands without
  requiring reverse-engineering of proprietary formats. DWG files and
  unrecognized formats show a clear non-blocking message, never crash.
  Explicitly not supported in v1: Trumpf .geo/technology table files,
  Amada JKA/JKAX/JKF formats, Mazak/Mitsubishi proprietary formats.
  v2 target: Trumpf native support (technology tables exportable as
  readable text from the machine per confirmed forum evidence — needs a
  sample file to finalize the parser). All unsupported formats show:
  "This format is not yet supported — use the Excel template to enter
  parameters manually." Never "invalid file format" or a crash.
  Rationale: doing one format well (Bystronic .par) plus a universal
  manual fallback (Excel template) is more robust and honest than
  attempting to parse six proprietary formats with varying reliability.

- D-226: **presets.json is the app's shipped machine rate library —
  generated from the Bystronic .par parameter database, normalized via
  material_map.json, versioned, and updated with app releases.**
  Current library: 11 machine models (BYJIN3015, BYJIN4020, SPEED3015,
  SPEED4020, SPRINT3015, SPRINT4020, STAR3015, STAR4020, STAR4025,
  SUN3015, VENTION3015), 1,407 unique rate entries across Aluminum,
  Brass, Copper, Mild Steel, Stainless Steel, Titanium, thickness range
  0.8–25mm. Source: Bystronic factory parameter database (.par files),
  parsed with parse_bystronic_params_v3.py, normalized with
  build_presets_json.py + material_map.json. Regeneration workflow:
  obtain updated .par files → run parse_bystronic_params_v3.py →
  run build_presets_json.py → replace presets.json in app → release.
  The presets.json file structure: version, machine_count, total_entries,
  machines dict keyed by model name, each containing entry_count,
  materials list, thickness_range, laser_powers_w list, and rates array
  (material, material_raw, din_code, thickness_mm, gas, cut_speed_mm_min,
  pierce_time_sec, laser_power_w, nozzle, gas_pressure_bar,
  corner_speed_mm_min, param_date).

## Cuts and Bends Estimator — Product Strategy, Quotation Scope, Materials Library (D-227 to D-237)

- D-227: **Pricing model — one-time purchase for Estimator, subscription for PPM.**
  The Estimator is a pure local desktop tool with no server costs, no live service
  component, and no ongoing data dependency. A subscription on a local tool is a
  hard sell to SME manufacturers in the Serbian/Balkans market. The two-tier model
  (Estimator one-time purchase → PPM subscription) supports the gateway strategy
  structurally: low barrier entry product converts to recurring-revenue platform.

- D-228: **Estimator is a PPM gateway tool — company account transfers in one click.**
  The Estimator is designed from the start as a conversion tool for PPM. Data that
  transfers: org name, branding, customer list, job history. Full PPM setup
  (operations, rates, RLS roles, workers) happens inside PPM after transfer —
  the Estimator does not attempt to replicate PPM's configuration depth.
  Handoff message framing: "Your company, clients, and job history are already here."
  PPM import screen design is deferred to PPM Phase 8 (Quotes) — see OQ-75.

- D-229: **Estimator reframed as a laser+bending quotation engine, not just a
  geometry extractor.** Each estimation session is a Job record with: Customer
  (from local customer list), Quote/Job reference (free-text or auto-generated
  Q-number), Project name (optional), Date, Status (Draft/Sent/Won/Lost).
  This reframing defines the tool's competitive position and the PPM transition
  story. The geometry extraction pipeline (D-201 through D-217) is unchanged —
  it is now the calculation engine inside a quotation workflow.

- D-230: **Local job history stored in SQLite — same file as materials library.**
  SQLite handles hundreds of jobs × 50–300 parts each trivially, ships as a
  single local file, requires no server, and supports the future PPM export path
  (SQLite read → PPM API POST). No external database dependency for the
  standalone tool.

- D-231: **Sheet cost supports two input modes — cost per kg and cost per sheet.**
  Both stored on each material+thickness record. Last-used input mode remembered
  per material. Cost per kg path: tool computes cost per sheet via
  material density (g/cm³) × sheet width (mm) × sheet height (mm) × thickness (mm)
  / 1,000,000 × cost_per_kg. Cost per sheet: direct input, no conversion.
  Material densities ship as presets (steel 7.85, stainless steel 7.93,
  aluminium 2.70 g/cm³), user-editable per material record.

- D-232: **Sheet utilization via manual nesting efficiency % — Option A, not
  algorithmic nesting.** True 2D polygon nesting is out of scope for v1.
  User inputs a nesting efficiency % per material type (e.g. 70%) representing
  their real-world experience. Tool computes: total cut area per
  material+thickness from DXF geometry → divide by (sheet area × efficiency %)
  → sheets needed (rounded up) → purchase cost of full sheets ordered →
  cost of geometry actually used → scrap delta (purchase cost − used cost).
  The efficiency % is explicitly a calibration input — shops refine it over time
  against real production data. Displayed prominently as a user-set estimate,
  never presented as a computed fact.

- D-233: **Margin and discount fields on every Job record.**
  Calculation flow: Raw cost → +Margin % → Selling price → −Discount % →
  Customer price. Both fields editable on the Job record before any export.
  Margin is the shop's internal markup; discount is a customer-facing
  reduction applied on top. Both optional (default 0%).

- D-234: **Three export outputs per Job: clean DXFs, internal Excel, quote PDF.**
  (1) Clean laser-ready DXFs — existing scope (D-202). (2) Internal Excel cost
  sheet — existing scope (D-206), extended with material cost columns (sheets
  needed, sheet purchase cost, geometry cost, scrap). (3) Quote PDF — new.
  Two document types within PDF export: Internal cost sheet (all rates, times,
  costs visible) and Customer-facing quote (rates hidden, clean presentation).

- D-235: **Customer quote PDF has configurable page structure, selectable at
  export time.** Page 1 always included: header (shop logo, name), quote
  reference, customer, date, validity, grand total, payment terms, signature
  line. Optional pages selectable at export: (a) Itemized breakdown — one row
  per PN, qty, line total only, no unit rates; (b) Summary by category —
  cutting total, bending total, material total, subtotals, margin/discount
  applied, grand total. User selects which optional pages to include at export.
  Default page selection saveable per customer or globally in settings.

- D-236: **Macro writes PPM_ESTIMATOR XDATA block on DXF export — resolves
  OQ-74's remaining open item.** Confirmed via inspection of testpart.dxf:
  Inventor does not natively embed sheet metal material or thickness into
  DXF exports ($THICKNESS = 0.0; MATERIAL entries are visual rendering
  objects only). The D-199 macro writes a custom XDATA block using app ID
  "PPM_ESTIMATOR" containing: MATERIAL (string, Inventor Sheet Metal Style
  name), THICKNESS_MM (float). This XDATA block becomes the top of the
  material+thickness resolution chain (D-204), ahead of filename parsing.
  Pre-existing DXFs without this block fall through to filename parsing →
  manual flag unchanged. OQ-74 fully resolved by this decision.

- D-237: **Materials library with canonical IDs and alias mapping — stored in
  SQLite.** Each material record contains: canonical ID (MAT-001 format),
  display name, density (g/cm³), default sheet dimensions (mm), cost per kg,
  cost per sheet, usage count (auto-incremented on selection), favorite flag
  (manual). Alias fields: inventor_name (matched against XDATA MATERIAL value),
  laser_param_name (matched against rate table imports), additional free-text
  aliases. Alias mapping configured once in Settings → Materials Library →
  External Names. Unmatched aliases are flagged at resolution time, never
  silently defaulted — consistent with D-204/D-205 resolution chain rules.
  Starter library pre-seeded with common sheet metal materials (S235, S355,
  304 SS, 5754 Al) and standard sheet sizes (3000×1500, 2500×1250, 2000×1000).
  Sort order in pickers: favorites first, then by usage count descending.

## Cuts and Bends Estimator — Monetization Architecture (D-238 to D-241)

- D-238: **Demo mode is the default state for all installations — same .exe,
  no separate installer.** Every download starts in Demo mode until a valid
  license key is activated. Demo limits: max 3 parts per job; PDF export
  disabled; job history save disabled; Excel export works but watermarked
  "DEMO — Cuts and Bends Estimator"; clean DXF re-export disabled. Every
  restricted action surfaces a single non-blocking upgrade prompt with a
  purchase URL. No nagware, no countdown timers. Stirg (pilot org) receives
  a manually issued license key — no purchase required.

- D-239: **LicenseManager is a single utility class — the sole authority on
  licensed state.** Manages a fourth local file `license.json` (separate from
  the D-218 three-file structure, never touched by app updates):
  `{key, activated_at, machine_id, mode}`. Machine ID is a hash of stable
  hardware identifiers (CPU ID + disk serial), stored locally only.
  Activation flow: user enters key → app calls Gumroad license verify API
  (`POST api.gumroad.com/v2/licenses/verify`) → on success writes
  `license.json` → full mode unlocked permanently. On every subsequent
  launch: reads `license.json`, validates machine ID, skips network call
  entirely. No server dependency after activation — activated machines work
  forever offline. If `license.json` absent or corrupt → Demo mode.
  All restricted features check `LicenseManager.is_licensed() → bool` —
  no other licensing logic anywhere in the codebase. One license = one
  machine; additional machines handled manually by email at this stage.
  Two UI additions: Activation screen (shown post-EULA if no valid license,
  has "Continue in Demo" escape) and License tab in Settings (shows status,
  activation date, transfer option).
  Developer license: a hardcoded key `DEV-PROTOTIP-INTERNAL` in the source
  bypasses the Gumroad API call entirely — activates full mode on any machine
  without payment or network access. For developer/pilot use only; never
  published. Re-enter on each new machine as needed.

- D-240: **Gumroad is the license key authority and primary payment channel.**
  Handles EU VAT automatically, pays out to Serbian bank account, ~10% fee.
  License keys issued automatically on purchase (Gumroad built-in) or
  manually from the Gumroad dashboard for offline customers. Base price
  in EUR. No Supabase, no custom license server — Gumroad API is the only
  external dependency in the licensing flow.

- D-241: **Dual payment channel — Gumroad (online) and email/virman (offline).**
  Serbian and regional market: bank transfer (virman) remains the dominant
  B2B payment method; many shop owners will not use foreign online payment
  platforms. Offline flow: customer emails purchase request → seller sends
  proforma invoice (RSD or EUR, NBS middle rate on invoice date, includes
  PIB/MB/bank account per Prototip org branding) → customer pays via virman
  → seller confirms payment → manually issues license key from Gumroad
  dashboard → customer activates identically to online path. App is
  unaware of payment channel — activation screen and Gumroad API call
  are identical regardless of how the key was obtained. PPM upgrade
  credit (when PPM launches): Estimator customers identified via Gumroad
  customer list (email), offered discounted PPM onboarding via manually
  issued discount codes. No technical bridge between Gumroad and PPM
  required at this stage.

- D-242: **Excel PPM Tracker built as interim solution pending PPM app completion.**
  6-sheet workbook: RATES (static snapshot of `Stirg_Operacije_Norms.xlsx` at time of
  build, not a live link), BOM_IMPORT (paste zone for Inventor Structural BOM export,
  rows pre-sized for thumbnails), C&B_IMPORT (paste zone for Cuts & Bends Estimator
  output), PARTS (main working table — per-PN op tracking), REPORT (live COUNTIF
  dashboard, D-214 compliant denominator), LOOKUP (hidden named ranges).
  C&B cost auto-populated in PARTS via VLOOKUP on PN from C&B_IMPORT.
  Inventor thumbnails require manual paste into column A after BOM data import
  (Excel limitation — images cannot be VLOOKUP'd).
  File: `kb/excel-ppm-tracker/PPM_Tracker_Stirg.xlsx` (to be committed separately).

- D-243: **PARTS sheet op columns use two-level Excel column grouping.**
  Level 1 = category group (collapses all ops in a category e.g. all OBRADA cols).
  Level 2 = per-op pair (collapses individual REQ?/DONE? pair for one operation).
  Both levels independently toggleable. Default: all expanded. Header layout: Op.ID
  above operation name, REQ?/DONE? as labelled pair underneath — one visual block per op.

- D-244: **Type column replaces absolute Level number as auto-populate trigger.**
  Absolute level number (L0–L8) is CAD-structural, not production-meaningful, and
  inconsistent across projects (GST depth 1–7, Stadler depth 0–8). Type column values:
  `Part / Weld Assy / Mech Assy / Top Assy / Purchased`. Auto-populate macro rules:
  Part + Thickness>0 → OP-009 Laser Cutting + OP-014 Deburring;
  Part + Bend Count>0 → OP-012 Press Bending;
  Weld Assy → OP-015 Fit-up & Tack + OP-016 Welding (Full);
  Top Assy → OP-017 Painting + OP-020 Assembly;
  OP-023 Visual QC → all types.
  Manual override always available — Type is an editable dropdown, REQ cells are
  never locked. Level column retained as reference column only, drives nothing.

- D-245: **Excel tracker macro suite planned (four macros).**
  (1) BOM Import Cleaner — reads BOM_IMPORT, strips Inventor raw columns to
  Level/PN/Desc/Qty/Type/Thickness/Bends, pastes cleaned rows into PARTS, auto-sizes
  thumbnail rows, prompts user to paste image column manually.
  (2) Clear Job — resets all REQ/DONE cells and job header fields in one click.
  (3) Auto-Populate REQ — applies D-244 rules after BOM import; marks REQ cells,
  never overwrites existing manual entries.
  (4) Preset filter buttons — Show All / Parts Only / Weld Assemblies /
  Painting Required / Incomplete (has REQ ✓ but not all DONE ✓).
  Native AutoFilter also active for custom ad-hoc filtering.

- D-246: **OP-028 Milling and OP-029 Turning added to Stirg operation catalog.**
  Both in-house (Stirg has both CNC milling and turning machines). Placeholder rates
  (machine rate 5850 RSD/h matching mid-tier CNC overhead), all norm hours placeholder
  per D-195. Manual REQ assignment only — no auto-populate trigger exists in BOM
  data for these operations. Added to `Stirg_Operacije_Norms.xlsx` under OBRADA category,
  adjacent to other machining ops. To be reflected in `org_operations` seed data when
  Phase 1 schema work resumes.

- D-247: **Excel tracker BOM Import macro uses header-name matching, not column position.**
  Inventor BOM export column order confirmed from real export (screenshot): Item, Part Number,
  Thumbnail, BOM Structure, Unit QTY, QTY, Stock Number, Description, REV — but order varies
  by export settings and user. Macro scans row 1 headers by name (case-insensitive), maps
  dynamically. Tolerates any column order; robust to future export configuration changes.
  Also handles "Unit QTY" as fallback for "QTY" column name variation.

- D-248: **BOM Structure column → Type column mapping (Excel tracker).**
  Inventor BOM Structure values: Normal / Purchased / Phantom.
  Mapping: Purchased → Type = "Purchased" (auto-set by ImportBOM macro);
  Phantom → row skipped entirely (not imported to PARTS);
  Normal → Type left blank for manual assignment (Part / Weld Assy / Mech Assy / Top Assy).
  Manual override always available after import.

- D-249: **Inventor custom iProperty names standardized for Excel tracker integration.**
  Three iProperty columns to add in Inventor BOM Editor before export:
  `Thickness` (Number, mm), `Bends` (Number, count), `Material` (Text).
  Exact names used by ImportBOM macro for column matching (case-insensitive).
  These are not yet set up at Stirg — to be configured as part of CAD workflow setup.
  Until set, Thickness and Bends columns will be blank after import and must be filled manually.

- D-250: **Excel tracker macro suite delivered as `PPM_Macros.bas` (8 macros, expanded from D-245).**
  Delivered as standalone VBA module file — imported via Alt+F11 → File → Import in Excel,
  then buttons assigned manually on PARTS sheet. Not embedded as xlsm (Linux build environment
  lacks win32com; xlsm binary injection unreliable without it).
  Final 8 macros: ImportBOM, AutoPopulateREQ, ClearJob, FilterShowAll, FilterPartsOnly,
  FilterWeldAssemblies, FilterPaintingRequired, FilterIncomplete.
  FilterIncomplete uses a temporary helper column (written at runtime, cleared by FilterShowAll).
  AutoPopulateREQ reads op columns dynamically from row 7/8 headers — robust to column reorder.
  All filter macros use native Excel AutoFilter — compatible with manual ad-hoc filtering.
## Inventor Macro — Validated Export Mechanism (D-251)

- D-251: **`DataIO.WriteDataToFile` confirmed as the flat pattern DXF export mechanism
  for the iLogic macro on Inventor 2021.** No drawing document, no TranslatorAddIn, no
  INI file required. Export query string: `"FLAT PATTERN DXF?AcadVersion=2000"`.
  `IV_*` layer names (IV_OUTER_PROFILE, IV_INTERIOR_PROFILE, IV_BEND, IV_BEND_DOWN etc.)
  export natively without additional configuration. Flat pattern enters and exits cleanly
  via API — no stuck-state risk. DXF option is absent from Save Copy As in the Inventor
  2021 UI when working from a .ipt; the API path and the UI diverge here, and the API
  path is the correct one. Validated on a real Inventor 2021 installation with Sheet Metal
  Style material and thickness set.
## Inventor iLogic 2021 — Macro Patterns (D-252 to D-255)

- D-252: **iLogic 2021 assembly reference pattern.** Use `AddReference "System.Drawing"` and
  `AddReference "System.Windows.Forms"` at rule top. Never use `Imports` — it causes namespace
  conflicts with Inventor's own `Color`, `TextBox`, `Point` types. Always use full qualification
  (`System.Drawing.Color`, `System.Windows.Forms.TextBox` etc.) throughout the rule.

- D-253: **Part material read via `oDoc.ComponentDefinition.Material.Name`.** `oStyle.Name`
  returns the rule name (e.g. `A1.6_Aluminium_2.0_mm`), not the material. `oStyle.SheetMetal_Material`
  is unreliable in Inventor 2021. `ComponentDefinition.Material.Name` returns the actual assigned
  material (e.g. `EN 1050A`).

- D-254: **Thickness read via `oSMDef.Thickness.ModelValue * 10`.** Inventor internal units are cm;
  multiplying by 10 gives mm. `oStyle.Thickness.Value` and bare `oStyle.Thickness` both fail to
  compile in iLogic 2021.

- D-255: **`PPM_ExportFlatPattern` macro confirmed complete and working on Inventor 2021.**
  Final working call sequence: `AddReference` → guard (SheetMetal check) → read PN via
  `Inventor.Property` explicit type → read material via `ComponentDefinition.Material.Name` →
  read thickness via `oSMDef.Thickness.ModelValue * 10` → styled WinForms dialog (qty prompt,
  auto-read material/thickness shown in green, manual fallback if read fails) → folder picker →
  filename as `PN_MATERIAL_THICKNESSmm_QTYpcs.dxf` → `DataIO.WriteDataToFile("FLAT PATTERN
  DXF?AcadVersion=2000", path)` → `WriteXDATA` appends `PPM_ESTIMATOR` block before EOF.
  Validated end-to-end on Inventor 2021 with correct filename and XDATA output confirmed in Notepad.
## Inventor iLogic Macro — Final State (D-256 to D-258)

- D-256: **`PPM_ExportFlatPattern` macro — final validated state on Inventor 2021.**
  Complete working rule confirmed. Features: part number from iProperties (fallback to
  filename); material from `oDoc.ComponentDefinition.Material.Name`; thickness from
  `oSMDef.Thickness.ModelValue * 10` (cm to mm); styled WinForms dialog matching
  Inventor background (#3B4453); overwrite warning on existing file; layer filter —
  IV_OUTER_PROFILE and IV_INTERIOR_PROFILES always kept, IV_BEND + IV_BEND_DOWN
  toggleable via checkbox (default checked); layer definitions cleaned from TABLES
  section to match filtered entities; XDATA block (PPM_ESTIMATOR, MATERIAL,
  THICKNESS_MM) written before EOF; filename format: PN_MATERIAL_THICKNESSmm_QTYpcs.dxf.
  Distribution: exported as .iLogicVb to shared network folder; each machine adds
  folder once via Tools → iLogic → Edit iLogic Configuration → Rule Directories;
  INSTALL.bat copies rule file locally.

- D-257: **Macro distribution via App Rules + shared folder — zero ongoing maintenance.**
  Rule stored as `.iLogicVb` in shared network folder (e.g. \SERVER\Shared\iLogic or
  C:\Prototip\iLogic). Each machine requires one-time setup: run INSTALL.bat + add
  folder path in Inventor iLogic Configuration. Updates require only replacing the
  .iLogicVb file — no reinstall on any machine. Toolbar button created via right-click
  → Create Button in iLogic Browser App Rules tab.

- D-258: **Dialog visual style matches Inventor dark UI — confirmed palette.**
  Background: RGB(59, 68, 83) / #3B4453 (sampled from Inventor 2021 UI screenshot).
  Surface cards: RGB(72, 82, 98). Accent: RGB(46, 125, 209) / #2E7DD1. Text:
  RGB(230, 237, 243). Subtext: RGB(180, 190, 200). Green RGB(63, 185, 80) for
  auto-read confirmed values. Amber RGB(210, 153, 34) for manual input warning.
  Input fields: RGB(33, 38, 45). Fonts: Segoe UI 9-10pt for labels/controls,
  Consolas 11pt Bold for part number, Segoe UI Semibold 10pt Bold for material/
  thickness values. Light/dark toggle not feasible — Inventor 2021 does not expose
  its current theme via iLogic API.
## Inventor iLogic — PPM Tools Global Form and Distribution (D-259)

- D-259: **PPM Tools global iLogic form — launcher for Export Flat Pattern button.**
  Created as a global iLogic form (For all documents) with PPM_ExportFlatPattern.iLogicVb
  dragged onto it as a clickable button. Global forms stored at:
  C:\Users\Public\Documents\Autodesk\Inventor 2021\Design Data\iLogic\UI\PPM Tools.xml.
  iLogic forms are not dockable in Inventor 2021 (confirmed Autodesk community). Full
  dockable panel requires a .NET Inventor add-in compiled from Visual Studio — deferred.
  Ribbon buttons for external iLogic rules require Inventor 2023+ natively.
  Working daily workflow: iLogic Browser docked alongside model tree → Global Forms tab
  → double-click PPM Tools → click Export Flat Pattern. Two clicks total.
  Distribution package (shared drive): INSTALL.bat + PPM_ExportFlatPattern.iLogicVb +
  PPM Tools.xml + UPUTE.txt. INSTALL.bat copies both files to correct locations
  automatically. One manual step per machine: Tools → iLogic → Edit iLogic Configuration
  → add C:\Prototip\iLogic to Rule Directories. Total setup time per machine: ~5 minutes.


## iLogic Batch Export — PPM_BatchExportFlatPatterns (D-260 to D-265)

- D-260: **Batch macro walk strategy: `ThisApplication.Documents` filtered by `ReferencedDocuments`.**
  `ComponentOccurrences` API hard-crashes Inventor 2021 when assembly has broken cross-part
  associations (native crash, not catchable .NET exception). Safe alternative: iterate
  `ThisApplication.Documents`, filter to parts belonging to the assembly using a recursive
  `CollectReferencedPaths` subroutine that walks `oDoc.ReferencedDocuments`. If reference
  collection fails, parts are excluded (strict fallback) — never fall through to unfiltered
  walk. Confirmed working on `13017522 Alat.iam` with broken cross-part association errors.

- D-261: **`WriteDataToFile` requires the part to be the active document in batch context.**
  When parts are loaded as assembly component references (not active doc), `WriteDataToFile
  ("FLAT PATTERN DXF?AcadVersion=2000")` fails with E_FAIL (0x80004005). Fix: call
  `oPartDoc.Activate()` then poll `ThisApplication.ActiveDocument Is oPartDoc` every 100ms
  up to 5s timeout before calling `WriteDataToFile`. `oAsmDoc.Activate()` called in `Finally`
  block to always return to assembly context after each part export. `WriteDataToFile` creates
  the flat pattern automatically if none exists — no pre-activation API call needed.
  Confirmed invalid method names: `EnableFlatPattern()` and `ExitFlatPattern()` do not exist
  on `SheetMetalComponentDefinition` in Inventor 2021.

- D-262: **Batch BOM quantities sourced from Inventor BOM Excel export (Parts Only flat view).**
  Occurrence-walk qty counting crashes. Live BOM view API unconfirmed. Solution: user exports
  BOM from Manage → Bill of Materials → Export (Parts Only flat view). File auto-detected by
  scanning assembly directory for `.xlsx` files matching assembly name or containing "bom".
  Manual browse fallback always available. Sheet name: "BOM", headers row 1, columns:
  "Part Number" (B) and "QTY" (F). Last used destination folder persisted to
  `%TEMP%\PPM_BatchExport_LastFolder.txt` for next run pre-fill.

- D-263: **xlsx parsed as ZIP+XML — no OLEDB dependency in iLogic.**
  `System.Data.OleDb.OleDbConnection` not available in iLogic sandbox. xlsx is a ZIP
  containing XML. Parser uses `System.IO.Compression.ZipFile` + `System.Xml.XmlDocument`
  to read `xl/sharedStrings.xml` and `xl/worksheets/sheet{n}.xml`, resolving sheet index
  from `xl/workbook.xml`. Both namespaces confirmed available via `AddReference` in
  Inventor 2021 iLogic. File copied to `%TEMP%` before reading to avoid locking.

- D-264: **`ReferencedDocuments` recursive walk confirmed safe in iLogic 2021.**
  `oDoc.ReferencedDocuments` (direct references only, not recursive) is safe to iterate
  without crashing. Recursive walk implemented in `CollectReferencedPaths` subroutine with
  cycle detection via `HashSet` contains-check before recursing. Confirmed working on
  multi-level assembly with broken cross-part associations.

- D-265: **DXF layer filter removed from batch macro — raw export used.**
  Post-export layer filtering (rewriting DXF TABLES and ENTITIES sections line-by-line)
  corrupts DXF file structure in batch context — produces orphaned TABLE/ENDSEC tokens.
  Root cause: Python simulation of filter logic worked correctly but VB implementation
  had off-by-one issues in section boundary detection. Resolution: batch macro exports
  raw DXF (all layers) and appends XDATA only. Layer filtering deferred to downstream
  estimator tool which already handles DXF parsing. Bend lines toggle UI retained in
  dialog for future re-implementation once filter logic is validated on real files.

- D-266: **`PPM_BatchExportFlatPatterns` stored at `inventor-macros/` in ppm-toolbox repo.**
  File: `inventor-macros/PPM_BatchExportFlatPatterns.iLogicVb`. Added to same iLogic
  Rule Directory (`C:\Prototip\iLogic`) as `PPM_ExportFlatPattern`. Launched via PPM Tools
  global form — "Assembly Batch Export Flat Pattern" button added alongside existing
  "Part Export Flat Pattern" button. Final confirmed commit: `4848c748`.

## iLogic Batch Export — BOM Auto-Export (D-267)

- D-267: **Inventor 2021 BOM API confirmed for iLogic — Parts Only export to xlsx.**
  Confirmed working call sequence:
  ```
  Dim oBOM As BOM = oAsmDoc.ComponentDefinition.BOM
  oBOM.PartsOnlyViewEnabled = True
  Dim oView As BOMView = oBOM.BOMViews.Item("Parts Only")
  oView.Export(exportPath, kMicrosoftExcelFormat)
  ```
  `kMicrosoftExcelFormat` is a standalone constant — NOT qualified as
  `BOMExportFormatEnum.kMicrosoftExcelFormat` (compile error in iLogic 2021).
  Export must delete existing file first — `oView.Export` does not overwrite cleanly.
  Integrated into `PPM_BatchExportFlatPatterns` as first step: BOM auto-exported to
  `AssemblyName_Parts_BOM.xlsx` in assembly folder before dialog opens. Fallback chain:
  (1) auto-export via API → (2) scan folder for existing BOM xlsx → (3) manual picker
  → (4) qty=1. Dialog BOM field shows green (auto-exported), amber (fallback found),
  red (failed, no file). Final confirmed commit: `5038e5ae`.

D-268: INI config file controls DXF layer visibility at export time
  `WriteDataToFile("FLAT PATTERN DXF?Configuration=path")` query string confirmed
  working in Inventor 2021 iLogic. The config file path must be the full local path.
  Two configs installed to `C:\PPM Cuts and Bends\iLogic\`:
  - `PPM_FlatPattern_NoBends.ini` — IV_OUTER_PROFILE + IV_INTERIOR_PROFILES visible only
  - `PPM_FlatPattern_WithBends.ini` — adds IV_BEND + IV_BEND_DOWN visible (blue, Color=0,0,255)
  All other IV_ layers set Visibility=OFF in both configs. `AUTOCAD VERSION=AutoCAD 2007`.
  `CUSTOMIZE FILE=` left blank (Design Data path does not exist past Inventor 2021 folder).
  Visibility=OFF in INI suppresses display but does NOT prevent Inventor writing those
  entities to the DXF file — post-processing filter still required to remove them.

D-269: DXF post-processing pipeline — confirmed three-stage approach
  After every `WriteDataToFile` export, three stages run in sequence:
  Stage 1 (Pass 1 of FilterDxfLayers): line-by-line rename — any entity group-code-8
    value of `IV_OUTER_PROFILE` or `IV_INTERIOR_PROFILES` replaced with `0`.
  Stage 2 (Pass 2 of FilterDxfLayers): entity block collection — walk entity blocks,
    collect layer name, drop block if layer starts with `IV_` and is not a bend layer
    (or is a bend layer but `includeBendLines=False`). Structural markers (SECTION,
    ENDSEC, TABLE, ENDTAB, BLOCK, ENDBLK, EOF, LAYER, LTYPE, etc.) always pass through.
  Stage 3 (CleanEmptyLayers): removes LAYER TABLE entries for layers no longer used
    in ENTITIES section, and updates the `70` group code count to match.
  Result: no-bends export → only layer `0`; with-bends export → layer `0` + `IV_BEND`
    + `IV_BEND_DOWN`. No other IV_ layers present in either entities or layer table.

D-270: CleanEmptyLayers — pre-count required before writing
  The LAYER TABLE `70` group code (layer count) appears BEFORE the individual LAYER
  entries in the DXF file. A single-pass approach writes count=0 because no entries
  have been processed yet when the count line is encountered.
  Fix: two-pass approach — (1) scan table block and count which LAYER entries will be
  kept, (2) write output with correct count already known.
  Corruption symptom: AutoCAD validates count on open; count mismatch → file rejected.

D-271: AcDbLayerTableRecord subclass marker is reliable layer name anchor
  Within a LAYER table entry, group code 2 appears multiple times (e.g. after handle
  group code 5, and after AcDbLayerTableRecord subclass marker). Only the group-code-2
  value immediately following `AcDbLayerTableRecord` is the layer name.
  Layer `0` has name string "0" — this looks numeric, so `Integer.TryParse` check
  incorrectly skips it. Detection must be done via the subclass marker anchor, not
  by testing whether the value is numeric.

D-272: Single-part macro missing includeBendLines checkbox — outstanding fix
  `PPM_ExportFlatPattern.iLogicVb` currently hardcodes `WithBends.ini` and passes
  `True` to `FilterDxfLayers`. Both macros should have a bend lines checkbox defaulting
  to unchecked (False). Fix pending — to be completed in Claude Code (Opus) session.
  Default should be no bend lines for laser cutting workflow.

D-273: AC1021 (AutoCAD 2007) export version confirmed target
  INI file `AUTOCAD VERSION=AutoCAD 2007` produces AC1021 DXF header.
  Previous config at `X:\USER\Gavrilovic\` used `AutoCAD 2004` (AC1018).
  AC1021 is the target version for Stirg laser cutting software compatibility.
  Note: files exported before INSTALL.bat was run still show AC1018 — expected.

## PPM_MarkOperations Macro — Architecture Decisions (D-274 to D-280)

- D-274: **iProperty encoding for operation marking = Integer 1/0, one property per org
  operation, property name format `PPM_OP_XXXXX` (zero-padded 5 digits, underscore
  separator).** Every operation in the org config is written regardless of selection
  — selected = 1, unselected = 0 — to guarantee a consistent BOM column set across
  all parts and assemblies in a project. Non-empty (=1) means required; 0 or missing
  means not required. BOM consumers (Excel ImportBOM macro, PPM import) check for
  value = 1. DONE state is never written to CAD — lives only in Excel/PPM.

- D-275: **Global operations pool expanded to 60 operations across 11 categories,
  stored as `inventor-macros/config/ppm_global_operations.json` in ppm-toolbox repo.**
  Covers sheet metal cutting/forming/finishing, welding/joining, machining (mill/lathe/
  drill/tap/grind), assembly, quality, procurement, inspection, prototyping, documentation,
  logistics. JSON schema per entry: `{ "id", "name", "category", "description" }`.
  Bundled in repo (not Supabase-fetched) for v1 — updated manually when global pool grows.
  Future: org-type presets (woodworking, fabrication, etc.) to be added as named subsets.

- D-276: **Org config JSON at `X:\USER\Gavrilović\iLogic\config\ppm_operations_config.json`
  on install machine, generated by `PPM_OperationsSetup` rule.**
  Schema: `{ "org": "STIRG", "generated": "<ISO datetime>", "operations": [{ "id", "name",
  "category" }] }`. Config folder `config\` is a subfolder of the iLogic rule directory
  to keep the root clean as macro count grows.

- D-277: **Auto-populate rules are hardcoded in the macro (not JSON-driven) for v1.**
  Rules: sheet metal part → flag OP-00003 Laser Cutting + OP-00013 Deburring;
  part with bend features (`BendFeatures.Count > 0`) → flag OP-00009 Press Brake Bending.
  All rules skipped silently if the flagged op is not in the org config.
  JSON-driven rules deferred — add only if Stirg needs to customize without code change.

- D-278: **Assembly auto-populate disabled in v1.** Worker sees full org op list and
  selects assembly-level operations (fit-up, welding, painting, etc.) manually.
  Rationale: no reliable assembly-type discriminator available in iLogic without
  a prior iProperty set by the designer. May revisit if a consistent iProperty
  convention is established (e.g. `Assembly_Type = "Weld Assy"`).

- D-279: **`PPM_MarkOperations` and `PPM_OperationsSetup` are two separate external
  iLogic rules, both added to PPM Tools global form.**
  Setup = explicit deliberate action, not a first-run wizard embedded in the tagging rule.
  Form button order: (1) Part Export Flat Pattern, (2) Assembly Batch Export Flat Pattern,
  separator, (3) Mark Operations, (4) Operations Setup.

- D-280: **Global pool → org template selection model.** On first run of Setup rule,
  user sees all 60 global ops in a categorized scrollable checklist and selects the ones
  their company uses. Selection saved as org config. On subsequent tagging runs, only
  org-config ops appear in the Mark Operations dialog. User can re-run Setup at any time
  to add or remove ops from their org template.

## PPM_MarkOperations — Implementation Decisions (D-281 to D-286)

- D-281: **Bend detection in iLogic 2021 — three-stage cascade.**
  `BendFeatures` property not exposed on `SheetMetalComponentDefinition` in
  Inventor 2021 iLogic sandbox ("Public member 'BendFeatures' not found").
  Confirmed cascade implemented:
  Stage 1: iterate `oSMDef.Features`, count objects whose `.Type.ToString()`
    contains "bend" (case-insensitive).
  Stage 2: read `"Bend Count"` from `"Design Tracking Properties"` iProperty
    set — Inventor writes this automatically when flat pattern is computed.
  Stage 3: if both above return 0 AND `FlatPattern` exists AND `Thickness > 0`
    -> assume bends present (`bendCount=1`, method tagged `"FP+thickness assumption"`).
  Detection result written to `PPM_BendDetect` custom iProperty for diagnostics.
  On Stirg test part (13017522_8.2, 3mm): stages 1 and 2 returned 0;
  stage 3 (FP+thickness assumption) correctly flagged OP-00009.

- D-282: **Weldment assembly detection — direct welds check required.**
  `WeldmentComponentDefinition` type check alone is insufficient — parent
  assemblies of weldment sub-assemblies also return this type, causing
  false positives on the wrong level. Fix: cast to `WeldmentComponentDefinition`
  then check `oWeldDef.Welds.Count > 0` — only flag as weldment if welds
  exist directly on the active document. Confirmed working on Stirg test
  assembly 13017522_8 (weldment sub-asm) vs 13017522 Alat (top-level plain asm).

- D-283: **Weldment welding type — inform and highlight, do not pre-select.**
  Auto-pre-selecting MIG/MAG welding was rejected — wrong default if TIG or
  spot welding is used instead. Implemented: weldment detected -> no ops
  auto-checked in Joining category; green notice "select welding type(s) from
  Joining below"; JOINING category header rendered in cGreen instead of cAmber;
  scrollPanel auto-scrolled to Joining section on dialog open. Worker selects
  the correct welding type(s) manually with one click.

- D-284: **iLogic RunRule from inside ShowDialog — unreliable in Inventor 2021.**
  `iLogicVb.RunRule("PPM_OperationsSetup")` called from within a WinForms
  `ShowDialog()` message loop does not reliably launch the target rule.
  Workaround: "Vise operacija / More Ops" button uses `DialogResult.Retry`
  as sentinel; after `ShowDialog()` returns, macro checks for Retry result
  and shows a MessageBox directing user to run Operations Setup from the
  PPM Tools form manually. Full in-dialog launch deferred.

- D-285: **PPM Tools form button label fix — raw rule name shown instead of
  display name.** Root cause: network `PPM Tools.xml` was missing entirely;
  Inventor fell back to raw rule filename `PPM_OperationsSetup` as button label.
  Fix: wrote correct XML to `X:\USER\Gavrilovic\iLogic\PPM Tools.xml`
  explicitly via PowerShell WriteAllText. Both locations now have matching XML
  with human-readable button names.

- D-286: **PPM_MarkOperations button row layout — symmetric 20px margin.**
  `formH = sep2Y + 1 + 20 + 34 + 20` with `If formH < 660 Then formH = 660`.
  Three-button layout: "Vise operacija / More Ops" Size(150,34) at x=20;
  "Odustani / Cancel" Size(150,34) at x=200;
  "Potvrdi / Confirm" Size(170,34) at x=426 — right edge flush with
  scroll panel at 596px.

## PPM_MarkOperations — Further Implementation Decisions (D-287 to D-293)

- D-287: **Bend detection fix — feature name matching replaces type-string matching.**
  `oSMDef.Features` iteration with `.Type.ToString()` containing "bend" never fired —
  Inventor 2021 type strings do not contain "bend" for sheet metal forming features.
  Fix: match on `feat.Name` (case-insensitive) containing "Flange", "Fold", "Bend",
  "Hem", or "Roll". Confirmed working on real Stirg parts:
  Flat part (13017522_8.5): Face1, Face2, Corner Chamfer1, Cut1 — no match, not flagged.
  Bent part (13017522_8.4): Contour Flange1 — matched, flagged.
  Bent part (13017522_8.3): Contour Flange1 + Fold1 — matched, flagged.
  Stage 3 (FP+thickness assumption) removed entirely — was false-positiving on flat parts.

- D-288: **Hole and thread detection added to PPM_MarkOperations.**
  Iterates `oDoc.ComponentDefinition.Features.HoleFeatures` and `ThreadFeatures`.
  HoleType integer mapping confirmed in Inventor 2021 iLogic:
    21505 = Plain / Clearance hole
    21506 = Counterbore or Countersink
    Any other value = Unknown (logged with integer for future identification)
  HoleDiameter.Value works on individually-defined holes (multiply by 10 for mm).
  ThreadInfo.ThreadDesignation works (e.g. "M4.5x0.75").
  ThreadInfo.ThreadType works (e.g. "ISO Metric profile").
  Writes PPM_Holes iProperty: e.g. "3x plain, 1x cbore"
  Writes PPM_Threads iProperty: e.g. "M4.5x0.75 x1"
  Detection runs on all part types, not just sheet metal.

- D-289: **Auto-flag operations by name match, never by hardcoded ID.**
  Initial implementation hardcoded OP-00038/OP-00039 for Drilling/Tapping — wrong
  because org config IDs differ from global pool IDs. Fix: scan orgOps and match
  op(1) (name field) case-insensitive contains match:
    Holes present -> find op containing "drill"
    Threads present -> find op containing "tap" or "thread"
    Cbore/countersink (HoleType 21506) -> find op containing "countersink" or "counterbor"
    Bends present -> find op containing "flange", "fold", or "bend"
  This rule applies to ALL auto-detection in PPM_MarkOperations — never hardcode IDs.

- D-290: **Config mismatch warning added to PPM_MarkOperations.**
  When auto-detection fires for a feature type but no matching op exists in the org
  config, an amber warning label appears at the top of the scroll panel:
  e.g. "Rupe detektovane ali operacija nije u konfiguraciji / Holes detected but no
  Drilling op in org config". Non-blocking — worker can still confirm. Prompts user
  to run Operations Setup and add the missing operation.

- D-291: **WeldBead API confirmed blocked in Inventor 2021 iLogic sandbox.**
  Reflection scan on WeldBead object returns Type = System.__ComObject with only
  base Object methods (ToString, Equals, GetHashCode, GetType). All weld-specific
  properties (FilletSize, Length, Intermittent, StitchLength, Faces, Edges) throw
  "Public member not found on type WeldBead". No workaround available in iLogic.
  Only reliably accessible: Welds.Count, w.Name, w.Type (integer 100672768).
  Consequence: weld length/size cannot be read programmatically from iLogic rules.

- D-292: **Weld notes field removed from PPM_MarkOperations — no downstream consumer.**
  A per-weld structured input and a free-text weld notes field were prototyped but
  removed. Rationale: PPM app and Excel tracker have no field to receive this data yet.
  Building input UI before the consumer exists creates orphaned data. Revisit when
  PPM Phase 8 (Quotes) or Excel BOM Export macro defines a weld data schema.
  Current state: weldment detected -> green notice -> scroll to Joining -> worker
  selects welding type(s) manually. Clean, fast, no phantom data.

- D-293: **PPM Tools global form manually reorganized by Voja into numbered workflow sections.**
  Form now shows: 01. Operations (Choose Operations on Part/Assembly button),
  02. Laser Cutting Export (Assembly Level Batch Export / Part Level Export buttons),
  BOM Export Report / Kritika (placeholder, ...),
  Settings button, Done button.
  This manual reorganization reflects the intended CAD-to-PPM workflow order and will
  be the template for the PPM_ExportPartData macro button placement when built.

## PPM_ExportPartData Build Session — Workflow & Layout Decisions (D-294 to D-296)

- D-294: **Three-location file model formalized for iLogic macro development.**
  `C:\Users\zavarivanje\inventor-macros` is the sole git-tracked dev location (clone of
  `ppm-toolbox`) — the only location Claude Code or any editor should write to.
  `C:\PPM Cuts and Bends\iLogic\` (local deployment mirror) and `X:\USER\Gavrilović\iLogic\`
  (network deployment, production) are copy-only targets, never edited directly. After any
  macro build/edit lands in the git clone, the finished `.iLogicVb` file is copied to both
  deployment paths. Matches the macro's own existing auto-update check (compares network vs.
  local timestamps, expects local to catch up) — formalizes existing implicit behavior rather
  than changing it.

- D-295: **PPM_ExportPartData REQ/DONE column layout — single block, not paired.**
  PARTS and ASSEMBLIES sheets place all REQ columns first (one per org op, in org-op order),
  then all DONE columns in the same order, rather than adjacent REQ/DONE pairs per op.
  Headers: `[Op Name] REQ` / `[Op Name] DONE`. Rationale: 60 ops × paired columns = ~130-column
  sheet, unusable; block layout keeps REQ columns scannable together and DONE columns together
  for manual fill-in.

- D-296: **PPM_ExportPartData pre-scan runs before dialog opens.**
  Assembly walk for part/assembly counts (no iProperty reads, ~0.5s) executes before the export
  dialog is shown, displaying live counts rather than placeholder "---". Consistent with batch
  macro's pattern of showing real data in the dialog where feasible.

## PPM_ExportPartData Real-World Test & Architecture Revision (D-297 to D-299)

- D-297: **Compile bug found via real Inventor test: `rem` is a reserved VB keyword.**
  Part 3 build used `Dim rem As Integer` in `ColLetter` function — `rem` collides with the
  legacy `Rem` (comment) statement, causing "Identifier expected" / "Expression expected"
  compile errors in Inventor 2021's iLogic editor. Fixed by renaming to `remainder`. A
  follow-up grep for other reserved-word-as-identifier risks (`Date`, `Error`, `Print`, `Mid`,
  `Left`, `Right`, `Set`, `Type`, `Class`, `Name`, `Object`) found no further hits. Confirms
  chat-based code review cannot catch this class of bug — only compiling in the real Inventor
  iLogic environment surfaces reserved-keyword collisions.

- D-298: **PPM_ExportPartData data-collection strategy revised: native structured BOM export
  as skeleton, replacing flat `ThisApplication.Documents` walk.** Real test on `13017522
  Alat.iam` via disposable diagnostic macro `PPM_TestStructuredBOM.iLogicVb` confirmed
  Inventor's `[Structured]` BOM view (distinct from `[Parts Only]`, found via
  `oBOM.BOMViews.Item("Structured")`) exports genuine multi-level hierarchy through its `Item`
  column (e.g. `"9"`, `"9.1"`, `"9.2"` — dot-count = nesting depth, confirmed against known
  sub-assembly `13017522_8` with children `8.1`-`8.5`). This resolves OQ-79 (Level hardcoded to
  1): Level is now derived from Item-string dot-count rather than hardcoded. Architecture:
  export structured view to temp xlsx → parse with column-name-matching (not fixed index, since
  real data showed row-to-row column-count variance from `*Varies*` thumbnail values shifting
  subsequent cells) → use as row skeleton → enrich each row via existing per-document iProperty
  reads (material, thickness, bends, op flags) matched by Part Number → BOM_FLAT becomes a true
  PN-deduplicated rollup (qty summed across all occurrences) computed from the same enriched
  dataset, eliminating any need for cross-sheet formula/VBA linking since both PARTS and
  BOM_FLAT derive from one in-memory source per export run.

- D-299: **PPM_ExportPartData REPORT sheet reformatted to match existing GST tracker pattern,
  resolving OQ-78.** Reference file `PPM_Tracker_Stirg_v2_final.xlsx` REPORT tab already
  implements the correct denominator interpretation: "Completion % = DONE ✓ / REQ ✓ count per
  op", not coverage-over-all-parts. PPM_ExportPartData's REPORT sheet is being rebuilt to match:
  header block (Project/Client/Date), SUMMARY block, then OPERATION COMPLETION table
  (Op.ID | Operation | Category | REQ ✓ | DONE ✓ | Completion % | Status | Notes). DONE will
  read 0 for all ops until a separate DONE-marking workflow exists (manual Excel fill-in
  post-export) — Completion % showing 0%/N/A at export time is expected, not a defect.
  Additionally: checkmarks (✓) standardized as visual indicator on every sheet including
  BOM_FLAT (previously 1/0 numeric on BOM_FLAT only) for consistency.

- D-300: **Thumbnails explicitly deferred to v2.** Structured BOM export's Thumbnail column
  returns only the literal string `*Varies*` or blank — no actual image data — confirming
  thumbnail embedding requires a separate OOXML drawing-relationship implementation, out of
  scope for the current build.

- D-301: **Dev/deploy copy step automated — Claude Code copies on every write, not on request.**
  Standing instruction as of this session: after every file write/edit to the git clone
  (`C:\Users\zavarivanje\inventor-macros\`), Claude Code copies the result to the local
  deployment path (`C:\PPM Cuts and Bends\iLogic\`) automatically as the final step of the
  edit, without being asked each time. Removes manual copy-paste friction from the dev loop
  while preserving D-294's git-as-source-of-truth model.

## PPM_ExportPartData Part 4 — First Real End-to-End Run (D-302 to D-305)

- D-302: **Confirmed: Inventor's `[Structured]` BOM view's `Item` column produces correct,
  usable multi-level hierarchy in production.** First successful end-to-end run on `13017522
  Alat.iam` confirmed `Item` values like `"9"`, `"9.1"`-`"9.5"` correctly resolve to Level 1
  and Level 2 respectively via dot-count derivation (D-298's design). PARTS sheet now reflects
  true assembly nesting instead of the previous hardcoded Level=1 (closes OQ-79 for real,
  verified in production, not just diagnostic test).

- D-303: **Bug found and fixed: `Chr()` throws `ArgumentException` for Unicode code points above
  255 in iLogic's VB runtime.** `BuildReportSheet` used `Chr(10003)` (✓ checkmark) for REQ/DONE
  column headers, causing "Procedure call or argument is not valid" at xlsx-write time. VB's
  legacy `Chr()` is ANSI/ASCII-range-limited; `ChrW()` is the Unicode-safe equivalent and must
  be used for any character code point above 255. Localized via temporary per-sheet diagnostic
  Try/Catch wrapping in `WriteXlsx` (isolated the failure to `BuildReportSheet` specifically,
  since sheets 1/2/4 use literal "✓" string characters directly rather than `Chr()`). Fixed by
  replacing `Chr(10003)` with `ChrW(10003)`. New standing rule: any future `Chr()` usage for
  non-ASCII characters in this codebase must use `ChrW()`.

- D-304: **Critical data-integrity bug found: enrichment map silently overwrites on Part Number
  collision across different document types.** Real-world case on `13017522 Alat.iam`: a Part
  document and a Weld Assembly document both carry the literal Part Number `13017522_8`. The
  original `enrichMap` (keyed by PN string only) let whichever document was enumerated last by
  `ThisApplication.Documents` silently overwrite the other's Type/material/enrichment data —
  no error, no warning, wrong data in the export. This is a CAD data-quality problem (duplicate
  PN across different document types is itself a user/process error), not solely a macro bug,
  but the macro must never silently produce incorrect output from it.

- D-305: **PN collision handling = hard stop, not silent resolution.** Fixed: enrichment loop now
  detects when an incoming document's Type differs from an already-mapped PN's Type, adds the PN
  to a `collisionPns` list, and does NOT overwrite the existing entry. After the full enrichment
  pass, if any collisions were found, the macro shows a bilingual error listing every colliding
  PN ("Duplicate Part Number found across different document types — fix in CAD before
  exporting") and aborts before writing any xlsx file via `GoTo Cleanup`. No partial/corrupt
  export is ever produced. This establishes a standing principle for the macro suite: data
  integrity conflicts are surfaced loudly and block export, never silently resolved by
  last-write-wins.

## Weld Bead Report — Data Source Validation (D-306 to D-308)

- D-306: **Weld Bead Report (Inventor Weld tab → Bead Report) confirmed as a usable
  weld-data source for time/cost estimation, empirically validated on real Stirg
  data — not just documentation.** Tested across 3 sequential exports of the same
  assembly (Stadler AdBlue Tank, `NR01555346.iam`), growing to 15 beads (8 fillet,
  6 groove, 1 cosmetic). Per-type data shape confirmed: **Fillet** — Length direct
  from report; Volume÷Length (derived cross-section) clusters consistently within
  a leg-size class (~4.5mm² across 7 of 8 sampled beads, matching the textbook
  0.5×leg² formula for a 3mm leg; one outlier at 7.07mm² is a distinct, larger leg
  size). **Groove/butt** — Length reported as N/A, but Mass/Area/Volume are
  populated. **Cosmetic** — Length direct, Mass/Area/Volume all N/A (no real 3D
  weld geometry exists for cosmetic beads, only an edge selection).
  **Mass column is not trustworthy for consumable-cost estimates**: Groove Weld 1
  (8532mm³) reports 0.023kg, ~2.9× under what steel density (7.85g/cm³) predicts
  (~67g) — likely a placeholder/default material assigned to weld features rather
  than actual filler metal. Do not use Mass directly for rod/wire consumption
  costing without further investigation.
- D-307: **Groove/butt weld Length is recoverable via `Volume ÷ cross_section_area`
  — confirmed exact for square-gap-fill/loft groove geometry.** Validated against
  a real manual measurement: Groove Weld 1 (2mm gap between two 3mm plates,
  modeled as a loft fill) — measured actual length 1422mm; report Volume 8532mm³;
  derived cross-section = 8532÷1422 = 6.0mm² exactly, matching the geometric
  cross-section (2mm gap × 3mm plate = 6.0mm²) precisely. This is the same
  Volume=cross_section×Length relationship validated independently via the
  fillet cluster in D-306. **Only the square-gap-fill prep type is validated** —
  beveled/V-groove preps (angled edges) need a different cross-section formula
  (trapezoid/triangle area) and have not been tested against real data — see OQ-84.
- D-308: **Weld costing computation (Length × WPS-derived travel speed → time;
  × WPS-derived deposition rate → consumable mass; both rolled into cost via the
  existing rate/markup model, D-188) lives in the Estimator, not PPM.** The
  Bead Report Excel is consumed by the Estimator the same way DXFs already are —
  another geometry-derived input feeding the same kind of time/cost calculation
  the tool already performs for cutting and bending — not a fundamentally
  different computation requiring PPM. PPM does not recompute weld costs; it
  receives finished quote/job data through the existing Estimator→PPM transfer
  path once built (D-228/OQ-75 scope, unchanged). WPS (Welding Procedure
  Specification) documents are the rate-table source (travel speed, deposition
  rate per joint type + thickness + process + pass count) — not yet collected,
  see OQ-83.

## Three-Tier Product Gateway Strategy (D-309 to D-311)

- D-309: **Three-tier product strategy confirmed: CAD Toolbox family → Estimator →
  PPM, each fully standalone for its own purpose, each a deliberate gateway to
  the next.** Tier 1 (Toolbox): per-CAD-platform macro suites (Inventor today;
  SolidWorks and other CAD platforms planned later as separate, distinct
  toolboxes, not a single multi-CAD tool). Always produces raw, standard outputs
  (DXFs, BOM Excel, Bead Report Excel) unconditionally, regardless of whether any
  downstream tool is used — this is the product's core value on its own. One-time
  purchase, entry-level pricing, narrow per-CAD-platform market. Tier 2
  (Estimator): universal costing/quoting engine, broadening beyond "Cuts and
  Bends" naming to include weld costing (D-308) — rename not yet decided, see
  OQ-86. Accepts input via optional Job Package (from any Toolbox), raw
  DXF/Excel uploaded manually, or full manual entry — graceful-degradation
  pattern (same principle as D-149, applied at the product-tier level rather
  than within a single app). Hard scope boundary unchanged from D-212/D-228: no
  project tracking/status/location — future-tense costing (a job not yet
  committed to) only. Tier 3 (PPM, unchanged scope): only recurring-revenue tier,
  only multi-tenant, only present-tense live job tracking.
- D-310: **Job Package format is optional, Estimator-specific, and never
  replaces the Toolbox's raw outputs.** Every Toolbox always produces standalone
  DXFs/BOM Excel/Bead Report Excel as unconditional baseline behavior. Job
  Package is an additional, recommended-but-optional bundling format
  specifically shaped for one-step Estimator ingestion.
- D-311: **The Estimator owns the Job Package format spec, not the Toolbox.**
  Since multiple CAD-specific Toolboxes (Inventor, future SolidWorks, etc.) will
  feed one shared Estimator, the consuming tool defines the input contract and
  each Toolbox conforms to it — avoids the format spec being tied to one CAD
  platform's conventions and needing rework as new Toolboxes are added.

## Weld Rate Table — Schema, Data, and Calculation Model (D-312 to D-317)

- D-312: **Weld rate table lookup key is `(material_group, joint_type, throat_class,
  process, position)` — not `(material, process)` alone.** Confirmed empirically:
  SS304 MAG FW z2 PB = 65 cm/min vs S355 MAG FW a4 PB = 20 cm/min — a 3× speed
  difference driven by throat size, not material group. Material affects filler/gas
  selection but not travel speed as strongly as throat class does within a process.
  Throat classes: small (a1–a3 / leg ≤4mm), medium (a4–a5 / leg 5–7mm), large
  (a6+ / leg ≥8mm). BW entries keyed by joint_type only (no throat class — prep
  geometry captured in throat_note for reference).

- D-313: **Weld rate table v1.0 built and committed to ppm-toolbox as
  `kb/weld_rate_table.json` (14 entries, version 1.0.0).** 9 entries confirmed
  from real Stirg WPS RP documents; 5 placeholder entries flagged per D-195
  convention (same calibration-needed pattern as `Stirg_Operacije_Norms.xlsx`).
  Confirmed anchor points by source:
  - RP 47/22: Al 5754 TIG 141 FW a3 PB → 5–6 cm/min
  - RP 50/22: Al 5754 MIG 131 BW PB → 30 cm/min
  - RP 22/15: SS 304 TIG 141 FW PB → 6–7.5 cm/min
  - WPS 12/24: SS 304 MAG 135 FW z2 PB → 65 cm/min
  - WPS 20/25: SS 304 MAG 135 FW a3 PB → 70 cm/min
  - WPS 22/25: SS 316Ti MAG 135 BW 1/2V PA → 80 cm/min
  - RP 02/25: S355 MAG 135 FW a4 PB → 20 cm/min
  - RP 01/25 pass 1: S355 MAG 135 BW V PA → 24 cm/min
  - RP 01/25 pass 2: S355 MAG 135 BW V PA → 28.1 cm/min
  Placeholder entries: Al TIG FW PA (derived), Al TIG FW medium PB, Al TIG BW PB,
  Al MIG FW PB, S355 MAG FW medium PB.

- D-314: **Deposition rate formula confirmed for MAG/MIG entries:
  `deposition_g_per_m = π(d/2)² × wire_feed_mm_per_min × 7.85 / speed_cm_per_min × 100`**
  (result in g/m of weld length; 7.85 = steel density g/cm³; same formula
  implicit in Stirg's own WPS heat-input Excel cell `=(0.8×I×V×60)/(1000×speed)`).
  TIG deposition is not computable from the rate table — TIG rod is hand-fed and
  not metered on any confirmed RP document. TIG consumable cost requires a manual
  input field in the Estimator (rod diameter + estimated rods-per-metre), treated
  as a separate configurable constant rather than a derived value.

- D-315: **Arc-on efficiency factor lives in the Estimator UI as an editable
  per-job field, not baked into the rate table.** Travel speed in the rate table
  is pure arc-on speed only. Defaults: TIG 35%, MIG/MAG 45% — industry-standard
  starting points. User overrides per job based on assembly complexity (simple
  bracket vs complex multi-joint tank are genuinely different). Calibrate defaults
  from real job time logs post-launch, same D-195/OQ-72 pattern as norm hours.

- D-316: **WPS rate table has no per-client dimension — Stirg's internal RP
  documents are the authoritative source regardless of which client the WPS was
  originally written for.** Stadler-formatted WPS forms (WPS 20/25, 22/25, 12/24)
  contain Stirg's own production RP speed data; the client name on the header is
  the end-customer for traceability, not an indication that the speed data is
  client-specific. One flat rate table per process/material/joint/position
  combination is correct. Resolves OQ-85.

- D-317: **`weld_rate_table.json` is the Estimator's weld costing rate library,
  parallel in role to `presets.json` for laser cutting.** Same versioning
  convention (version field, generated date), same confirmed/placeholder
  distinction. Consumed by the Estimator to look up travel speed + deposition
  rate per bead (from Bead Report input), combined with arc-on efficiency (D-315)
  and welder hourly rate (from org settings) to produce time and consumable cost
  per weld bead. File location: `kb/weld_rate_table.json` in ppm-toolbox repo;
  will move to Estimator app bundle once Estimator weld costing module is built.

## Weld Rate Table v1.1.0 — New Entries and TIG Consumable Model (D-318 to D-321)

- D-318: **Three new confirmed entries added to weld_rate_table.json (v1.1.0):**
  - AL6060-TIG-FW-SM-PA: Al 6060 TIG 141 FW a3 PA → 36 cm/min (WPS 89/25).
    Flagged as Al 6060 alloy — use as analog for Al 5754 until 5754-specific RP found.
  - AL6060-TIG-FW-SM-DBL-PB: Al 6060 TIG 141 FW a3+a3 double-sided PB → 15 cm/min
    per pass, 2 passes (WPS 91/25). New geometry class: double-sided fillet.
  - SS304-MAG-FW-MD-PB-HC: SS 304 MAG 135 FW a3 double-sided PB → 102 cm/min,
    wire feed 15 m/min, 265A high-current spray, 2 passes (WPS 33/24). Complements
    existing WPS 20/25 entry (70 cm/min at 220A) — same joint, different current
    regime. Both are valid; 70 cm/min = standard, 102 cm/min = high-productivity.

- D-319: **CS MAG thin fillet (a3) speed upgraded from pure placeholder to
  analytically extrapolated: ~36 cm/min.** Derivation: travel speed is inversely
  proportional to weld cross-section at constant wire feed and process conditions.
  Confirmed CS a4 entry (RP 02/25) gives 20 cm/min at cross-section 16mm².
  Extrapolated a3 = 20 × (16/9) = 36 cm/min (cross-section 9mm²). No conflicting
  document found — CS MAG thin fillet RP documents not locatable. Upgrade to
  confirmed when a real CS MAG a2/a3 RP is found.

- D-320: **TIG consumable cost is derived from weld volume, not wire feed
  (which is unmeasured for manual TIG).** Formula confirmed:
  `consumed_g_per_m = cross_section_mm² × 1000 × density_g_cm³ / 1000 / efficiency`
  Al TIG efficiency = 65% (standard manual TIG transfer, confirmed against welder
  floor estimate). Welder's stated "1 rod per 10cm of a3 weld" resolved as a unit
  mismatch — correctly interpreted as 1 rod (1m stick) per ~1m of weld, which gives
  12.2 g/m deposited and aligns with the volume method to within the efficiency factor.
  SS TIG efficiency = 65% (same assumption, no floor data available). This method
  applies to all TIG entries where wire_feed_m_min is None in the rate table.

- D-321: **Weld cost calculation pipeline confirmed end-to-end on real assembly
  data (Stadler AdBlue Tank NR01555346, 32 beads).** Results with placeholder CS
  MAG speed (35 cm/min, now upgraded to 36 cm/min): total weld length 20.2m, arc-on
  time 57.7 min, total job time 2.14h, wire consumed ~2.85kg, gas ~807l,
  estimated total cost ~73 EUR at 25 EUR/h welder rate. All three bead types handled:
  fillet (direct length), groove (volume-derived length, D-307), cosmetic (direct
  length). Calculation logic validated as ready for Estimator implementation.

## Weld Manipulation Time Model (D-322 to D-324)

- D-322: **Full weld time model = three buckets: Setup + Repositioning + Arc-on.**
  Pure arc-time estimates undercharge by ~2.5× on real assemblies because
  setup and manipulation represent ~59% of total weld time independent of weld
  length. Formula: `Total_time = T_setup + (N_repositions × T_per_reposition)
  + (T_arc_on ÷ arc_on_efficiency)`. All three buckets are separate — folding
  manipulation into arc-on efficiency produces wrong results (overcharges small
  assemblies, undercharges large ones).

- D-323: **Manipulation model placeholder values — all editable in Estimator
  Settings, calibrate from real timed jobs (D-195 convention):**
  Setup times by auto-suggested complexity class:
  - Simple   (≤5 beads, 0 groove welds):          20 min [PLACEHOLDER]
  - Standard (6–20 beads, groove ratio <30%):      45 min [PLACEHOLDER]
  - Complex  (>20 beads or groove ratio ≥30%):     90 min [PLACEHOLDER]
  Reposition times:
  - Without crane (assembly mass ≤30kg):            5 min [PLACEHOLDER]
  - With crane    (assembly mass  >30kg):           25 min [PLACEHOLDER]
  Crane threshold: 30kg (EU manual handling guideline).
  Reposition count heuristic (user-editable suggestion):
  - ≤5 beads → 1 reposition
  - 6–15 beads → 2 repositions
  - 16–30 beads → 3 repositions
  - >30 beads → 4 repositions
  Arc-on efficiency (auto-selected from avg bead length, not user-editable):
  - avg bead <150mm → 30% (many short beads, high start/stop overhead)
  - avg bead 150–400mm → 38%
  - avg bead 400–800mm → 42%
  - avg bead >800mm → 45% (long continuous runs)

- D-324: **Crane flag is automatic if assembly mass is known; manual fallback
  if not.** Mass source priority: (1) Job Package iProperty from
  PPM_ExportPartData pipeline (fully automatic), (2) manual entry field in
  Estimator UI (single number). Assembly mass is not in the Bead Report — it
  must come from the BOM/iProperties pipeline or user input. The Estimator
  never blocks on a missing mass — if not provided, crane defaults to False
  with a visible warning ("Mass not provided — crane requirement not evaluated").
  Complexity class and reposition count are always auto-suggested from bead
  data and presented as one-click confirm-or-override fields, never silently
  applied without user visibility.

## Send to Estimator — Job Package Feature (D-325 to D-329)

- D-325: **"Send to Estimator" is a new button on the Global Form, last position
  before Settings, alongside all existing macro buttons — does not replace any
  of them.** It chains all export steps sequentially in one click: operations
  warning → destination picker → batch DXF export → BOM export → Weld Bead
  Report → manifest.json → completion summary. Spec: `kb/specs/send-to-estimator.md`.

- D-326: **Job Package folder structure confirmed:**
  `JobPackage_[AssemblyPN]_[YYYYMMDD]/` containing `manifest.json`,
  `bom/StructuredBOM.xlsx`, `dxf/[all flat pattern DXFs]`,
  `weld/WeldBeadReport.xls`. Flat folder per output type, not a ZIP —
  Estimator reads the folder directly. ZIP manually for email if needed.
  `manifest.json` written last; `package_complete: false` if sequence
  aborted — Estimator treats incomplete packages as a warning state.

- D-327: **Job Package save destination defaults to assembly parent folder,
  user-overridable.** Destination picker shows pre-filled path, free-text
  paste accepted, browse button `[...]` available. Last-used path remembered
  per Inventor session (not persisted across sessions). Package name
  auto-generated as `JobPackage_[PN]_[YYYYMMDD]`, not user-editable.

- D-328: **PPM_ExportPartData in Job Package mode produces 3 sheets only:
  PARTS, ASSEMBLIES, BOM_FLAT. No REPORT sheet.** Implemented via a
  `JobPackageMode As Boolean` parameter — suppresses REPORT sheet generation,
  no other behavior change. Existing individual Export Part Data button
  behavior unchanged (still produces all sheets).

- D-329: **OQ-87 resolved. AssemblyWeldBeadReportCmd confirmed executable
  from iLogic (live test by Voja, 2026-07-01).** Two modal dialogs fire:
  (1) "Include All Subassemblies" checkbox + Next, (2) Report Location file
  save dialog. Both handled via `SendKeys` in the sequential Send to Estimator
  context — no competing windows open mid-sequence, making SendKeys reliable
  here where it would be fragile in a standalone context. Sleep timings:
  800ms before each SendKeys call (conservative; tune if needed on Stirg machine).
  Weld Bead Report step skipped silently if assembly is not a weldment;
  noted as `weld_report: null` in manifest.

## Groove Weld Length Derivation — V-Groove Formula (D-330)

- D-330: **Groove weld cross-section formulas confirmed for all prep types used
  at Stirg. Length = Volume ÷ cross_section_area in all cases (D-307 method).**
  Prep type is selected by the user in the Estimator (one dropdown per groove bead
  or per assembly default); formula applied automatically:
  - **Square butt (gap fill):** `area = gap_mm × plate_thickness_mm`
    Confirmed exact: Groove Weld 1 (2mm gap × 3mm plate = 6mm², D-307).
  - **Full V-groove (2×45° symmetric chamfer, no root face):**
    `area = plate_thickness_mm²`
    Derivation: each chamfer = right triangle (height=t, base=t×tan45°=t),
    two sides: area = 2×(0.5×t×t) = t². For 3mm plate: 9mm². Resolved OQ-84 —
    no Inventor measurement needed; standard chamfer assumption confirmed by Voja
    as the correct prep model for Stirg's beveled groove welds.
  - **Half-V groove (one side chamfered only):**
    `area = 0.5 × plate_thickness_mm²`
    Derived from full V-groove formula by symmetry. Not yet validated against
    a real bead — flag as extrapolated until confirmed.
  No other prep types currently in use at Stirg. If new types arise, extend
  the formula table rather than replacing it.

## DXF Export Layer Filter — Pipeline Reality Check & Redesign (D-331 to D-335)

- D-331: **D-269/D-270/D-271 were design intent, never implemented — superseded.**
  Direct code inspection (both `PPM_ExportFlatPattern.iLogicVb` and
  `PPM_BatchExportFlatPatterns.iLogicVb`) confirms `FilterDxfLayers` in both files
  is byte-for-byte identical and implements Stage 1 only (line-by-line rename of
  `IV_OUTER_PROFILE`/`IV_INTERIOR_PROFILES` to layer `0`). No `CleanEmptyLayers`
  function exists in either file. The 3-stage pipeline described in D-269-D-271
  (rename -> drop non-bend IV_ blocks -> clean layer table) was never built as
  documented; those entries described a plan, not a validated result.

- D-332: **`CleanEmptyLayers` existed once, broke AutoCAD/laser-software file-open
  compatibility, and was manually removed by Voja. Hard constraint, not a style
  preference: no future fix may re-edit the `TABLES`/`LAYER` section of exported
  DXFs.** Layer table entries referencing zero entities in `ENTITIES` are harmless
  and may remain in the table. The corruption cause was almost certainly the `70`
  group-code layer-count mismatch (D-270's two-pass requirement) being handled
  incorrectly in the removed implementation — not layer-table editing in general,
  but rebuilding it is not worth the risk given a working non-table-editing
  alternative exists (D-334).

- D-333: **Confirmed with real INI (`PPM_FlatPattern_WithBends.ini`) and real DXF
  output: `Visibility=OFF` does not suppress entity export for `IV_ARC_CENTERS`
  or `IV_TANGENT`.** Both layers are correctly set `Visibility=OFF` in the INI's
  `[FLATPATTERN LAYER OPTIONS]` section, yet the exported DXF still contained live
  `POINT` entities on `IV_ARC_CENTERS` and `LINE` entities on `IV_TANGENT`. This
  upgrades D-268's note from theoretical to directly evidenced.

- D-334: **New `FilterDxfLayers` design: entity-block whitelist, scoped strictly to
  the `ENTITIES` section, never touches `TABLES`.** Replaces the old rename-only
  Stage 1 in both macros. Logic:
  - Pass through `HEADER`/`CLASSES`/`TABLES`/`BLOCKS`/`OBJECTS` unchanged.
  - Inside `ENTITIES`, parse entity blocks (each starts at a `0` group-code line +
    entity type name, runs to the next `0` group-code line or `ENDSEC`).
  - Layer `IV_OUTER_PROFILE` or `IV_INTERIOR_PROFILES` -> rewrite group code `8`
    to `0`, keep block.
  - Layer `0` -> keep as-is.
  - Layer `IV_BEND`/`IV_BEND_DOWN` -> keep only if `includeBendLines=True`, else drop.
  - Any other layer, **including any unrecognized `IV_*` layer** -> drop the entire
    block. Permissive-drop by design (confirmed by Voja) rather than an enumerated
    blacklist, so layers not individually tested (e.g. `IV_TOOL_CENTER`,
    `IV_FEATURE_PROFILES`) are covered without requiring per-layer validation.
  - No `TABLES`/`LAYER` edits, no `70` count changes (per D-332).
  - Known untested edge case: `POLYLINE` entities have `VERTEX`/`SEQEND` child
    blocks with no layer code of their own — must be grouped and kept/dropped with
    their parent `POLYLINE`, not evaluated independently. Flagged for Claude Code
    implementation; Inventor flat-pattern exports are expected to be
    `LINE`/`ARC`/`CIRCLE`/`POINT`/`LWPOLYLINE` only, so this may never trigger.

- D-335: **Fix scope confirmed: both macros get the new `FilterDxfLayers`. Batch
  macro's `chkBend` default (`Checked=True`) confirmed intentional by Voja, stays
  unchanged.** Single-part macro (`PPM_ExportFlatPattern.iLogicVb`) gets a new
  `chkBend` checkbox, default unchecked (`False`, per original D-272 intent — no
  prior deployed default to preserve here), wired identically to the batch macro's
  `iniPath` selection + `FilterDxfLayers(destPath, includeBendLines)` call. Single-part
  dialog also gets resized/relaid-out (current `Size(460,350)` clips the Export/Cancel
  buttons — bottom edge at y=318 vs. ~35-40px of required window chrome margin);
  reuse the batch macro's proven proportions rather than a minimal patch. Implementation
  assigned to a Claude Code session, both macros in one pass.

## DXF Export Fix Confirmed Working — Deployment & Follow-on Findings (D-336 to D-339)

- D-336: **New `FilterDxfLayers` (D-334) confirmed working on a real batch export.**
  Verified directly against actual DXF output: `ENTITIES` section contains only
  `LINE`/`ARC` blocks on layer `0`, no `IV_ARC_CENTERS` or `IV_TANGENT` entities present,
  `TABLES`/`LAYER` section untouched. Confirmed on a 33-part batch (27 successful exports).
  Single-part macro (`PPM_ExportFlatPattern.iLogicVb`) also confirmed working by Voja,
  bend-lines checkbox behaving correctly in both checked/unchecked states, dialog no
  longer clipping.

- D-337: **`PPM_BatchExportFlatPatterns.iLogicVb` `chkBend.Checked` default corrected
  from `True` to `False`.** Supersedes D-335's decision to leave the batch macro's
  default unchanged — Voja reversed that call after observing it in practice. Both
  macros now default to no bend lines, matching original D-272 intent.

- D-338: **Root cause of the 6 batch export E_FAIL failures (D-261 symptom) identified
  as stale/invalid computed sheet-metal state, not STEP-conversion, timing, or feature
  count.** Confirmed via three independent manual fixes: (1) `NR01555346-5` — toggling
  the sheet metal thickness override back to the 3mm rule (even though it was already
  correct) fixed the export; near-identical mirror-part `NR01555346-4` (same instant
  open time, same feature pattern) exported without issue, ruling out timing and part
  complexity as the cause. (2) A lathe/turned part modeled as sheet metal + drilled/tapped
  (not unique — similar parts export fine) — root cause not isolated beyond "stale state",
  ruled out "too many features" as a category-level explanation. (3) `Phantom A Rippe
  innen 3` — deleting the flat pattern, converting solid→sheet metal→solid and back
  fixed the export. All three fixes share no common trigger except forcing Inventor to
  recompute the sheet metal/flat-pattern definition. Working hypothesis (untested):
  `WriteDataToFile` assumes the flat pattern is already valid/computable and does not
  force a recompute — calling `.Update()` on the part document before export may prevent
  this class of failure proactively. Not yet verified — affected parts were manually
  fixed by Voja before the hypothesis could be tested against them directly.

- D-339: **`PPM_BatchExportFlatPatterns.iLogicVb` does not restore a part's original
  state after processing.** Confirmed on `Phantom A Rippe innen 3` — left open in flat
  pattern state after the batch macro completed, rather than returned to its pre-export
  state. Separate bug from the D-338 E_FAIL investigation; scoped as its own fix.

## Diagnostic/Auto-Recovery Tool Implemented — Untested Against Real Failure (D-340)

- D-340: **`TryRecoverAndExport` diagnostic/auto-recovery subroutine implemented in both
  export macros plus a new standalone macro `PPM_DiagnoseAndRecoverExport.iLogicVb`.**
  Design constraint maintained: only triggers after a `WriteDataToFile` exception, never
  runs on a successful first attempt — verified by code structure (call sites are inside
  `Catch` blocks only).

  API members used were confirmed via direct .NET reflection against
  `Autodesk.Inventor.Interop.dll` rather than assumed from memory or documentation,
  after two drafted member names turned out wrong:
  - `Document.RequiresUpdate` (Boolean) — **not** `ComponentDefinition.NeedsUpdate` as
    first drafted; that member doesn't exist.
  - `SheetMetalComponentDefinition.ActiveSheetMetalStyle.Thickness` returns a **String**
    expression (e.g. `"3 mm"`), **not** a `Parameter` object — first drafted as
    `.Thickness.ModelValue`, which would have thrown on every read (silently, since
    wrapped in `Try/Catch`, producing a permanently blank diagnostic column). Corrected
    to capture the raw string (`RuleThicknessRaw` CSV column) and additionally parse it
    via regex into a comparable mm value (`RuleThicknessMM` column, blank if the unit
    suffix doesn't match `mm`/`in`/`inch`) rather than guessing at format.
  - `SheetMetalComponentDefinition.HasFlatPattern` (Boolean) — confirmed as the correct
    direct property, replacing a fragile `Nothing`-check against `.FlatPattern`.

  Diagnostic snapshot on trigger: timestamp, part number, filename, original error,
  `RequiresUpdate`, sheet metal rule name, raw + parsed rule thickness, actual part
  thickness, flat-pattern-exists, part last-write-time, retry-succeeded — logged to
  `C:\PPM Cuts and Bends\iLogic\PPM_ExportDiagnostics.csv` (created with header on first
  trigger) regardless of outcome.

  **Status: implemented and verified to compile against correct API members, but
  functionally untested.** A deliberate attempt to reproduce the original E_FAIL
  condition (toggling sheet metal thickness override, the method that worked on
  `NR01555346-5` in D-338) did not reproduce the failure — all parts exported
  successfully on the first attempt, meaning `TryRecoverAndExport` was never triggered
  and no CSV file was ever created. The `.Update()`-before-retry hypothesis from D-338
  remains neither confirmed nor refuted.

---

## Diesel Tank Estimation Session & PPM Toolbox Feature Extraction — July 2026

**D-341** Bending machine routing rule for Stirg: thickness ≤4mm → TruBend 3100 (110t); >4mm → TrumaBend V1700S (187t). Applied per-part in Estimator at calculation time.

**D-342** Groove weld length recovery: Length = Volume ÷ 28mm² assumed cross-section (square gap fill). Placeholder pending OQ-84 validation. Used where Inventor weld bead report returns N/A in Length column.

**D-343** Weld deposition rate placeholder: 400 mm/min MIG/MAG for structural mild steel fillet welds. Requires shop-floor validation (OQ-97).

**D-344** Outsourced thick parts (thickness not in SPRINT4020 mild steel table): use nearest lower available laser rate as proxy for internal estimation only. Flagged explicitly in output. Not presented to customer as a laser rate.

**D-345** Engineering hours (quoting, CAD, DXF prep, laser programming, material receiving) are one-time project costs, amortized over production quantity in Estimator output.

**D-346** C-Schiene 29×15×2: manufactured in-house (laser cut + 2 bends per piece for C-profile). Not purchased. Processed as sheet metal OP-009 + OP-012.

**D-347** Hole instance count extracted via `HoleFeature.PositionPoints.Count`, not `HoleFeatures.Count`. The latter returns feature definition count (always 1 for multi-position holes); the former returns physical hole count.

**D-348** Thread data extraction uses two paths combined: (a) `HoleFeature.HoleType = kTappedHoleType` → read `ThreadDesignation` and `NominalSize` from HoleFeature; (b) `ThreadFeatures` collection for post-hoc threads applied to cylindrical faces. Both checked per part, results merged.

**D-349** Surface area source: `PartComponentDefinition.SurfaceBody.Area` (cm², convert ×100 to mm²). Works for all part types. The 1× (one-sided) or 2× (both sides) multiplier is applied in Estimator at calculation time — macro exports raw body area only.

**D-350** Batch JSON `batch_parts_data.json` written to Job Package output folder alongside DXFs, keyed by DXF filename stem. Contains all feature-extracted part data plus engineering hours block. Extends the existing Job Package format (see send-to-estimator.md) — not a separate format.

**D-351** Excel BOM columns generated dynamically: first-pass scan of all assembly parts builds a feature presence map; only columns with at least one non-null value across the assembly scope are generated.

**D-352** Part type flag auto-detected from Inventor environment: `sheet_metal` (flat pattern present), `weldment` (weldment environment), `tube_pipe` (heuristic: length >> cross-section), `machined` (solid, no flat pattern), `purchased` (no geometry or reference part). Written to JSON and Excel. Estimator uses flag to gate applicable operations.

**D-353** Flat pattern L×W boundary checks: stock threshold 1500×3000mm (yellow warning); orderable threshold 2000×4000mm (red error). Check applied per part. Written to JSON flags array and highlighted in Excel.

**D-354** Thickness validation: nominal series 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0, 6.0, 8.0, 10.0, 12.0, 15.0, 20.0, 25.0mm. Warn if extracted thickness deviates >0.1mm from nearest nominal (catches modelling errors like 3.02mm). Does not block export.

**D-355** Material grade warning: trigger if Inventor material name is "Generic", "General", empty string, or unrecognised. Warning written to JSON flags array and highlighted in Excel. Does not block export.

**D-356** Countersink and counterbore extraction: count only. Angle, type, and seat geometry not extracted — sufficient for OP-011 costing at current norm granularity. Fields: `countersinks_count`, `counterbores_count` (integers).

**D-357** Bend angles not extracted by macro or Estimator. Angle data lives on technical drawings. Estimator uses bend count × norm time; angle-specific tooling decisions made on shop floor.

**D-358** Mass exported per part via `MassProperties.Mass` (kg). Used for material cost cross-check and shipping weight. Written to JSON and Excel BOM.

**D-359** Weldment sub-assembly traversal in `PPM_SendToEstimator`: recursive, not fixed-depth. Macro walks full assembly tree to identify all weldment environments regardless of nesting level.

**D-360** Engineering hours optional interactive prompt in `PPM_SendToEstimator`: dialog at run time with pre-filled defaults for quoting, CAD, DXF prep, laser programming, and material receiving hours. Skippable (Cancel = no engineering block written to JSON). Validate workflow impact after first live run (OQ-99).

## Feature Extraction — API Verification Session, PPM_TestFeatureExtraction diagnostic (D-361 to D-368)

Session context: `GetPartFeatureData` (D-347–D-358) failed to compile and, once fixed to compile,
produced wrong values against real Inventor 2021 output (surface area always 0, bend count always 1,
hole/thread instance count always 1 regardless of real pattern/multi-point count, Content Center parts
misclassified). Each fix below was verified against Autodesk official docs and/or working forum/blog
code before being written, not guessed — `HoleTypeEnum.kTappedHole` (used pre-D-361) was a guess and
did not exist, which is why this verification pass was run before further building.

- **D-361** Tapped-hole detection: `HoleFeature.Tapped` (Boolean), not `HoleType = kTappedHole` (does
  not exist). Thread designation via `HoleFeature.TapInfo` cast to `HoleTapInfo` or `TaperedThreadInfo`
  (both have `.ThreadDesignation`).
- **D-362** Surface area: `PartComponentDefinition.MassProperties.Area` (×100, cm²→mm²), not
  `SurfaceBody.Area` — per-body physical properties are not reliably exposed via the API; official VBA
  sample confirms `MassProperties.Area` at the part level.
- **D-363** Bend count: `SheetMetalComponentDefinition.FlatPattern.FlatBendResults.Count`, calling
  `.Unfold()` first if `HasFlatPattern = False`. Supersedes the placeholder
  `If HasFlatPattern Then Return 1` stub that was never real logic.
- **D-364** Sheet metal detection: `SheetMetalComponentDefinition.HasFlatPattern`, not
  `FlatPattern IsNot Nothing`.
- **D-365** Purchased/Content Center detection: `PartComponentDefinition.IsContentMember`, not
  `ReferenceComponents.ContentCenterComponents.Count` (not a real property).
- **D-366** iLogic external rule constraint (structural, not domain-specific): a `Class` used as a
  function return type must be declared `Public`, or compilation fails with "cannot expose type
  outside the project through class 'ThisRule'" — the rule wrapper implicitly exposes `Sub Main`/
  functions as public. Also: single-line `Try : If ... Then ... : Catch : End Try` colon-chains are
  invalid VB.NET (the `Then` clause's statement list swallows the `Catch`/`End Try`); must be written
  as separate `Try` and `If` statements.
- **D-367** Hole/thread instance counting: **B-Rep face-based, not feature-based** — supersedes
  D-347/D-348 (`HoleFeature.PositionPoints`, used in D-347, could not be confirmed to exist in any
  official Autodesk documentation across multiple searches, and produced wrong counts on real parts —
  e.g. NR01555346-7 read as 1× instead of the real 24×). New method: each distinct `Face` where
  `Face.SurfaceType = SurfaceTypeEnum.kCylinderSurface` is one hole instance, verified correct against
  known ground truth (NR01555346-7: exact 24×M8×1.25 match). Thread designation read directly from
  `Face.ThreadInfos` → `ThreadInfo.ThreadDesignation`, which unifies tapped-hole and separate
  `ThreadFeature` detection (both surface as `ThreadInfo` entries on the same face) and is documented
  to work identically on derived parts, iParts, and iFeatures — i.e. parts with no usable feature
  history at all, which feature-tree walking cannot handle by construction.
- **D-368** Hole classification model: the feature tree defines hole **type and dimension** (plain
  diameter or thread designation) but never reliable **quantity** (D-367's rationale). B-Rep face scan
  supplies quantity for all cases. For non-threaded faces specifically: if a face's diameter matches a
  diameter present on some `HoleFeature` in the tree, classify as a drilled hole (real machining
  operation); if no `HoleFeature` in the tree has a matching diameter, classify as laser-cut-only
  (clearance hole with no drill/tap operation) — still recorded for laser time estimation, but not
  counted toward drilling/tapping operation cost. Threaded faces are always trusted directly from
  `Face.ThreadInfos` with no cross-reference needed, since that data comes from the face itself.

**D-369** Full-revolution hole/fillet classification (extends D-367, replaces the earlier two-trial
self-correcting design): confirmed empirically via `PPM_ProbeFace.iLogicVb` single-face probe on a real
hole — `Face.Evaluator.ParamRangeRect`'s **Y parameter is angular** (span = 2π to 14 significant
figures), **X is axial** (span = hole depth). `Get3dCurveFrom2dCurve` on a full-Y-range line segment
returns a `Circle` for a genuine hole (NOT `Circle3d` — that name doesn't compile; Inventor's curve
type naming isn't fully consistent, e.g. `Face.Geometry` likewise returns plain `Cylinder`, not
`Cylinder3d`), `Arc3d` for a partial arc (corner fillet, etc.) — confirmed by `TypeName()` reflection,
not assumed. Classification: sweep only the Y axis; `TypeOf result Is Circle`
→ real hole; `TypeOf result Is Arc3d` → fillet, excluded; any other result → inconclusive, fail-open
(kept as a hole candidate, flagged via warning) per D-149. No X-axis trial or midpoint-anchoring needed
— both were artifacts of not yet knowing which axis was angular.

**D-370** Laser-cut-vs-drilled classification (extends D-368) gets a second, physical signal alongside
the feature-tree presence check: if a hole's diameter is meaningfully smaller than the part's material
thickness, laser cutting cannot physically produce it cleanly, so it must be drilled/tapped regardless
of whether a matching `HoleFeature` exists in the tree. This supplements, not replaces, D-368's
presence-based match — a face is classified as drilled if *either* signal indicates it. Confirmed by
Voja from shop-floor knowledge (Stirg does use real Hole features for plain holes; the diameter/
thickness relationship is a genuine physical constraint, not a heuristic guess). Exact threshold ratio
not yet chosen — pending Voja's input (OQ-121 area), not something to look up or assume.

**D-370a** Modeling-discipline gap, philosophy (extends D-149): no single rule can fully compensate for
inconsistent feature-tree modeling across all of Stirg's real parts. The approach is layered heuristics
(concave/convex, arc-span, sub-1mm exclusion, diameter/thickness physical constraint, feature-tree
presence) that each reduce misclassification independently, combined via fail-open + warning flags —
never a single mechanism expected to solve it completely, and never silent exclusion on an unconfirmed
signal.

**D-371** Material warning check corrected (extends D-355): primary read is `PartDocument.
ActiveMaterial.Name`, not `PartComponentDefinition.Material.Name` (confirmed "hidden"/deprecated by
Autodesk community — a downstream/legacy property, not the driving one). Legacy property kept as
fallback only if `ActiveMaterial` is empty. Confirmed via real 29-part test run on NR01555346.iam:
`MATERIAL_UNRECOGNIZED` false positive on `Phantom A Kraftstofftank Diesel 1100 Liter` resolved, all
other 28 parts' values unchanged (no regression).

**D-371a** `PartDocument.ActiveMaterial.Name` format confirmed via real data (once the value was
actually displayed, not just used for a pass/fail check): `"N:MaterialName"` — an index prefix, not a
bare name (e.g. `"1:EN S235JR"`, `"1:Generic"`). D-371's `MATERIAL_UNRECOGNIZED` check used exact
string equality against `"generic"`/`"general"`, which silently missed `"1:Generic"` — a genuinely
unset material on `Phantom A Kraftstofftank Diesel 1100 Liter` that should have warned but didn't.
Fixed to substring match (`EndsWith(":generic")` etc.) instead of exact equality.


**D-372** [VALIDATED — confirmed live] `OVERSIZE_ORDERABLE` check redesigned: tier-fit against standard
sheet stock sizes (1250×2500, 1500×3000, 2000×4000mm, both flat-pattern orientations checked) replaces
D-353's fixed 1500×3000/2000×4000 threshold pair, which was confirmed wrong (NR01555346-1's
2373.15×996mm flat pattern fits 1250×2500 stock but was flagged oversize under the old logic). New
`LARGE_FORMAT_CONFIRM_STOCK` warning added for parts fitting only the largest tier. Tiers sourced from
ArcelorMittal e-steel France (EU mill) and regional stainless stockist data (Metal-Centar) — not yet
Stirg-supplier-specific (see OQ-124 phase 2). Confirmed via live 29-part run: NR01555346-1 and -3 no
longer show false `OVERSIZE_ORDERABLE`, 29/29 parts compiled and ran clean, no regression elsewhere.
Note: this run only exercises the "fits smallest tier" path — `LARGE_FORMAT_CONFIRM_STOCK` and true
`OVERSIZE_ORDERABLE` (fits no tier) remain unverified against real data, no test part large enough
exists in the current sample set.

**D-373** `SKIPPED_*_FACES` and other internal-diagnostic-only warnings (face-filter counts) remain in
`PPM_TestFeatureExtraction`'s `Warnings` output — useful for troubleshooting the standalone diagnostic
itself. When this logic is ported into `PPM_ExportPartData` for production use, these must be routed to
a separate debug-only field, not the primary `Warnings` field, since they clutter the field with
non-actionable internal filter counts rather than real part-level concerns.

**D-374** `MATERIAL_UNRECOGNIZED` renamed to `MATERIAL_NOT_SET` in `PPM_TestFeatureExtraction` (same
D-355 trigger logic — blank/`Generic`/`General`, substring match per D-371a — unchanged). Clearer,
actionable label; downstream Excel/PPM App display text "Please set material for this part" planned but
not yet wired anywhere. Confirmed via live run: `MATERIAL_NOT_SET` appears correctly on the diesel tank
part, same trigger case as the old `MATERIAL_UNRECOGNIZED`, no regression.

**D-375** Round-stock axial length calculation fixed: projects the part body's bounding box onto the
actual axis direction of the max-diameter convex face (`ProjectedLengthAlongAxis`), replacing the
original largest-of-3-bounding-box-dimensions shortcut, which was wrong for any disc/flange-shaped part
where diameter exceeds length. Confirmed correct in isolation via live run against real ground truth:
`SP000011992` ("...L=15...") now reports `RoundStock_L = 15mm` exactly. Note: this fix is validated
independently of the surrounding round-stock/hollow-detection gating logic, which is NOT validated —
see OQ-129.


## OQ-129 Gating Fixes + Pipe/Tube/Fitting Reference Scope (D-376 to D-380)

**D-376** OQ-129 fix strategy: gates (a) shape/extent, (b) wall-ratio, (c) standard-size
cross-check implemented and tested independently, not bundled in one patch — repeats the
v14 bundling lesson (single patch fixed length calc but introduced the coaxial-bore
regression, only caught after a full 29-part run). Order: (a) first — self-contained, no
external data dependency. (b) second — needs sourced tube wall-ratio range. (c) deferred —
blocked on OQ-125 dimension sourcing.

**D-377** OQ-129 gate (a) provisional threshold: round-feature diameter must be ≥10% of
the part's largest bounding-box dimension to attempt round-stock/pipe classification;
below that, treat as local boss/fitting, skip round-stock analysis entirely. Derived from
2 real data points: RD30 lug SP000011992 (Ø30mm face on ~30mm-extent part, ratio≈1.0, true
positive) vs. tank fitting boss (Ø30mm feature on 2380×1300×861mm tank, ratio≈0.013, the
real Bug B false-positive case — 691mm length misread). ~75× gap between the two known
cases; 10% is a round, conservative cutoff within that gap, not a precisely derived
boundary. Coarse/provisional, same caveat class as D-375's EN 10060 tolerance placeholder
— needs more real cases (ideally a genuine borderline one) before treated as final.

**D-378** OQ-125 scope narrowed: round profiles only (tube/pipe). Square/rect hollow
section (EN 10219/10220 rect variant) dropped from scope.

**D-379** Fitting classification scope: straight fittings only (nipple/socket), both BSP
and NPT thread families. Classified by OD+ID+length signature. No elbows/tees/reducers.

**D-380** Applicable standards identified for OQ-125 + fitting reference DB (dimension
values not yet sourced — standards identification only):
- Steel round tube/pipe: carbon EN 10216-1 (seamless) / EN 10217-1 (welded); stainless
  EN 10216-5 (seamless) / EN 10217-7 (welded). Same dimensional backbone across grades,
  differ by part-number/grade table, not separate size series.
- Aluminum tube: separate standard family, not EN 10216/10217 — EN 754 (drawn) / EN 755
  (extruded). Typically specified by actual measured OD/wall, not nominal series like
  steel NPS/DN — breaks the nominal-cross-check pattern, needs its own actual-dimension
  table.
- BSP fittings: DIN 2999 obsolete, superseded by ISO 7-1 (BSPT, tapered) / ISO 228-1
  (BSPP, parallel) for thread form. Fitting body dims (nipple/socket OD, length) via
  BS EN 10241.
- NPT fittings: thread form via ASME B1.20.1. Fitting body dims via ASTM A733, referenced
  against NPS nominal size (not actual OD) — same nominal-vs-actual gap as steel pipe.

---

## Stadler AdBlue/Diesel Tank Estimation — Scope, Feature Data & Pricing (July 2026)

**D-361** TM000207992 Halter Tankstutzen gespiegelt: top-level diesel tank laser-cut part (tank nozzle holder, mirrored). EN S235JR 3mm, qty 1/unit. Bolted interface only — no welds, no sub-assembly weld report.

**D-362** NR01481349.4 (22mm EN 1.4404): outsourced cutting, real reference 126 EUR/pc (2pcs/unit). SPRINT4020 stainless ceiling 20mm — in-house impossible. 20mm SS rate used as internal proxy only.

**D-363** ArmaFlex RAIL SD RA-25-99/EA: cut in-house (specialised jigsaw). Material 8,355.45 RSD/m² (71.41 EUR/m²). Labour manual estimate 0.1h/pc. AdBlue tank only — 5 pieces (NR01481349.13–17). Diesel tank has no insulation.

**D-364** Painting: liquid wet paint (not powder coating), RAL 7016/7024, in-house OP-017. Stadler explicitly requested wet paint.

**D-365** Corrected feature data from PPM_TestFeatureExtraction (supersedes all prior BOM-sourced values for this assembly):
- NR01555346-1: 12 bends, 2×Ø86 laser holes
- NR01555346-2: 2 bends, 2×Ø60.3 laser holes
- NR01555346-3: 2 bends, 1×Ø102.6 + 6×Ø45 laser holes
- NR01555346-4: 4 bends; NR01555346-5: 4 bends
- NR01555346-6: 12×M8×1.25 tapped (old BOM had 1×plain — wrong)
- NR01555346-7: 24×M8×1.25 tapped (confirmed)
- NR01555346-8: 8×M6×1 tapped, machined OD90/ID48 (thread was wrongly stated as M8)
- Phantom A Befestigungswinkel_1: 8 bends
- Phantom A Längsträger links/rechts: 2 bends each, 4×Ø17.5 laser holes each
- Phantom A Befestigung adblue: 2 bends, 2×Ø17 laser holes
- Phantom A.1 Flansch 12xM8: 24×Ø8.6 laser clearance holes (NOT tapped — previous session incorrect)
- Phantom A.1 Deckel: 12×Ø8.5 laser holes
- Phantom A Gewindehinterlage: 2×M16×2 tapped, 25mm outsource
- Phantom A Anschraubpunkt Tank: 4×M16×2 tapped, 40mm outsource
- Phantom A Gewindeplatte M8: 2×M6×1 tapped, 17mm outsource
- C-Schiene all variants: 8 bends/pc (not 2 as previously assumed)

**D-366** Large-format sheet flag: NR01555346-1 (2373×996mm) and NR01555346-3 (2294×1014mm) exceed 1500×3000mm stock — require ordered 2000×4000mm sheets. Both fit orderable threshold.

**D-367** Tank cap pricing confirmed (local supplier, in stock, ex-VAT):
- AdBlue tank cap (Čep AD blue, art. 1293): 620.00 RSD/pc = 5.30 EUR/pc
- Diesel tank cap (Čep rezervoara, art. 7079): 750.00 RSD/pc = 6.41 EUR/pc

---

## Estimator — Unified Workflow & Reliability Model (July 2026)

**D-381** Bend costing gains a second signal: DXF bend-layer line length, classified
simple/complex against a length threshold, feeding bend time/cost. Additive to D-357
(bend count × norm time) — does not replace it. Threshold value(s) not yet defined (OQ-131).

**D-382** Estimator fault-isolation principle: a failure on any single part number or any
single operation within a part number flags and skips that item only — the run never
aborts on partial bad input. Extends D-149 (Graceful Degradation) to the Estimator's
batch-processing context. Self-diagnostic checks run per operation per PN; all flags/
warnings/errors are written to a fail report per run (format TBD, OQ-134).

**D-383** Administrative/CAD time cost split: 3D modeling/CAD time is calculated
automatically per PN as a function of feature count + bend count (exact formula TBD,
OQ-132). All other admin costs — drawing prep, laser-program prep, indirect/overhead
salary allocation, one-off costs (e.g. FEA) — are manual per-job entries, not derived.

**D-384** Quote margin is percentage-based, applied to raw cost. Risk factor and
ecology factor are proposed additions to the quote markup structure.

**D-385** Real capacity/resource scheduling is explicitly out of Estimator scope —
that responsibility belongs to PPM App (Tier 3, per three-tier strategy). Estimator
produces only a rough duration estimate: total calculated production hours ÷
configurable working-hours-per-day.

**D-386** First-run/missing-configuration state: Estimator never blocks. Missing norms/
rates/machine config produces a warning (banner/flag), analysis still runs and flags
affected line items rather than preventing job creation.

**D-387** Qty multiplier (ordered quantity) is set at Job creation for the top-level
assembly, independently overridable per line item (e.g. spares ordered in a different
quantity than the assembly).

**D-388** v1 data ingestion supports both a JSON import path (schema not yet defined,
OQ-135) and always-available individual manual import per data type (DXF folder,
structured BOM, weld bead report, etc.). Manual import remains usable after a JSON
import to support isolated partial re-import (e.g. re-importing only weld data after
rework, without redoing the whole job).

**D-389** Every operation instance carries a separate fixed setup-time/cost sub-line
tied to its parent operation, distinct from that operation's per-unit/count-based
time and cost.

**D-390** No standalone "internal costing report" screen. The hierarchical assembly/
sub-assembly/part review screen (with flat-view toggle) is itself the internal report;
producing the report is an export action from that screen.

**D-391** Risk factor and ecology factor in quote markup are percentage-based,
applied the same way as margin (D-384). Closes OQ-133.

---

## Estimator — Norms Philosophy, Ingestion Correction, UX & Design System (July 2026)

**D-392** Bend-complexity length threshold (OQ-131) is a fully user-adjustable field in
the Estimator's norms/settings configuration, not hardcoded. Ships with a provisional
starting value, tuned by the user against real shop experience.

**D-393** CAD/modeling time formula (OQ-132): no codified industry standard exists for
sheet-metal CAD modeling hours by complexity — confirmed by research, not assumed.
Superseded by D-395 (CAD time made fully manual) — kept here for the research finding,
not the formula approach it originally proposed.

**D-394** Manual re-import after an existing JSON import performs a targeted merge:
only the fields belonging to the re-imported data type (e.g. weld data) are
overwritten; all other job data is untouched. Closes OQ-136.

**D-395** CAD/modeling time is a fully manual per-part-number entry in the Estimator
UI — no automatic formula from feature count or bend count. Supersedes D-383.

**D-396** Universal editability: every hour, cost, quantity, and calculated parameter
in the Estimator is user-adjustable. No per-field confirmation prompt — a single
"are you sure?" prompt fires when the user attempts to leave a screen/job after
making unsaved changes, catching unintentional edits without adding friction to
deliberate bulk adjustment.

**D-397** Bend-length complexity data (D-381) is derived by the Estimator from the
DXF bend layer at ingestion time — the same mechanism already used for bend count
(send-to-estimator.md, Estimator ingestion step 4). No new field added to
`batch_parts_data.json`.

**D-398** Engineering CAD-hours starting suggestion (`engineering.cad_h`, D-360's
optional macro prompt) is calculated as: (part-number count in the job) × a
configurable average hours-per-PN value (default placeholder 1.5h). Simple
count-based multiplier — not the rejected feature/bend formula (D-395/D-383). Only
pre-fills the Estimator's manual CAD-hours field as a starting point; fully
user-editable per D-396. Closes OQ-135 together with the schema-reuse finding below.

**D-399** Undo (Ctrl+Z) required on editable screens. Depth/scope (single-level vs
multi-step stack) left as an implementation default.

**D-400** Autosave + crash recovery: the Estimator periodically autosaves in-progress
job edits to SQLite (not only on explicit save), so a crash costs at most a few
minutes of work.

**D-401** About/License screen: separate from the Activation flow. Shows current
license tier, expiry, activate/deactivate controls, and a support contact link.

**D-402** Recent Jobs quick-access on the dashboard — distinct from the full Job
History screen — one-click reopen of the last few jobs.

**D-403** Keyboard navigation (Tab/Enter cell-to-cell movement) required in dense
editable tables, given the volume of inline editing D-396 introduces.

**D-404** Long background operations (large DXF batch parsing, large PDF generation)
show toast/progress notifications rather than a frozen-looking UI.

**D-405** Confirm-before-delete required for destructive actions (deleting a job,
a customer record) — separate mechanism from D-396's edit-navigation prompt.

**D-406** UI language is bilingual (English + Serbian), as two independent settings:
a global app-UI language setting, and a separate customer-facing quote-PDF export
language setting (e.g. Serbian UI while quoting a German/English-speaking client
like Stadler or Siemens). Closes OQ-137.

**D-407** Screen sequence: "Batch Review" (flagged-parts triage, bulk-fix actions,
partial-proceed — confirmed via the existing first-iteration mockup) sits between
Ingestion and the main hierarchical Review screen. Not a new screen invented this
session — recovered from prior design work.

**D-408** App-wide visual design system adopted from the existing Batch Review
mockup rather than re-decided per screen: accent blue `#2E7DD1` / amber `#d9920f` /
green `#16A34A` status coding, Inter for UI text, JetBrains Mono for all data/numeric
values, native desktop window chrome (custom title bar, no browser furniture).
Extended by D-412 to support both light and dark theme, not dark-only.

**D-409** Progressive disclosure on the main Review screen: individual per-row
expand/collapse, plus a global "expand all / collapse all" toggle.

**D-410** Additional proven UX patterns adopted: command palette (Ctrl/Cmd+K) to
jump to any job/customer/part number; non-blocking inline validation (highlight in
place, never a halting popup); optimistic UI with silent background autosave
(D-400) rather than a visible "saving..." interrupt; persistent filter/view state
across navigation; a keyboard-shortcut cheat-sheet overlay (e.g. `?`) to make
D-403's navigation discoverable; breadcrumb header in nested hierarchy views.

**D-411** Both light and dark theme required — not dark-only. Extends/amends D-408's
design system.

---

## Estimator — Raw Stock Panel, Tube/Pipe Stock Logic & Cut-Length Optimization (July 2026)

**D-412** Raw Stock Needed (Summary panel) lists all job consumables, not just sheet
stock: sheet stock (auto-calculated, D-372–375), tube/pipe/profile stock (D-416,
D-420), and weld consumables — wire and gas (already calculated per D-308–324),
broken down by wire type/diameter and gas type separately. One consolidated list.

**D-413** Summary panel has no standalone "Stock Sheets" quick-stat tile — sheet
count is shown only within the detailed Raw Stock Needed list (D-412), not
duplicated as a top-level tile.

**D-414** Summary panel's top-level stats (Total Cost, Total Hours, Weight) are
stacked vertically in a single column, not a 2x2 grid.

**D-415** Operation line items (Laser Cut, Bend, Weld, etc.) get column headers
analogous to the part-level row (MATERIAL/QTY/WEIGHT/COST), so unit-vs-total
time/cost values are self-explanatory rather than relying on bare "unit"/"total"
text labels.

**D-416** Tube/pipe/round/profile stock needed is expressed as a count of standard
stock-length pieces (ceiling of total cut length needed / standard stock length per
material/profile), matching the existing sheet-stock rounding logic (D-372–375) —
not displayed as raw linear meters. Depends on standard-length reference data per
profile/material (OQ-125, still open) for the underlying data; this decision fixes
the display/calculation rule itself.

**D-417** Cut-length data for tube/pipe/bar part numbers has two sources: manual
entry, or extraction from Inventor's native Weldment Cut List feature (for parts
belonging to a modeled weldment with that feature populated). Manual override
always available per D-396. Unvalidated — to be empirically tested in a separate
macro session before being trusted as a macro-side data source.

**D-418** Cut-length optimization uses a 1D bin-packing algorithm: inputs are
required length x qty per PN, standard stock bar length per material/profile
(OQ-125), and a kerf width value adjustable per machine/saw in Settings (machines/
parameters table, alongside existing laser/press-brake machine config). Output is
an optimized cut plan plus total stock pieces required, feeding the Raw Stock
Needed panel (D-412).

**D-419** The optimized cut plan is exportable as a standalone shop-floor document,
alongside the existing DXF/BOM/quote exports — exact format not yet decided
(OQ-139).

**D-420** Cut-length optimization (D-418) is built into the Estimator now, not
gated on D-417's Weldment Cut List validation. The algorithm/UI operates on
length x qty data regardless of source — manual entry today, macro-extracted
later if separate macro-session testing confirms the Weldment Cut List path is
reliable. Only the import mechanism changes later, not the optimization math.

---

## Estimator — Screen List Finalization & Pitch Mockup Scope (July 2026)

**D-421** Phone/responsive support applies only to the standalone pitch-mockup
artifact used to demo the Estimator concept to Voja's boss. The production
Estimator remains a PySide6 desktop application (no mobile/phone target) — stated
explicitly to prevent a future reader or build session from inferring a
responsive/mobile requirement from that mockup discussion.

**D-422** PDF export configuration is not a separate screen — it lives inside the
Quote screen's "Generate PDF" flow. Resolves the ambiguity left over from the
original pre-redesign screens list.

**D-423** On first launch (or whenever core config — company info, machine
parameters, norm hours/costs — is missing), the Estimator shows a dismissible
prompt offering a direct shortcut into Settings to fill it in. Refines D-386's
warning mechanism with a concrete, actionable UX — remains fully non-blocking:
dismissible, skippable, the user can proceed without completing it.

**D-424** About/License is a modal/panel triggered by clicking the existing
sidebar license/demo-mode status indicator — not a separate main-nav screen.
Keeps the nav focused on daily-use screens; matches the common pattern of
account/plan status living behind a click on its own indicator rather than
occupying a dedicated nav slot.

**Resolved screen list (10 screens, no remaining ambiguity):** EULA, Activation,
Dashboard, New Job, Import, Batch Review, Main Review, Quote (includes PDF export
config), Settings (includes D-423's first-run shortcut destination), Job History.
About/License is a modal off the sidebar (D-424), not a standalone screen.

---

## Estimator — New Job Data Sourcing, Sparse Jobs, Job Numbering & Quote/WO (July 2026)

**D-433** Job Package ingestion only populates whichever operation-relevant data
categories are actually present in the imported data — a job with no weldment has
no weld data, a job with no sheet-metal parts has no laser/bend data, and this is
normal, not a flagged/failed state. Distinct from D-382's fault isolation, which
covers expected-but-broken data, not legitimately absent categories.

**D-434** A job must be fully startable with as little as one part and one
operation. This is an ordinary case, not a degraded one — no minimum part count
or operation-type requirement is enforced anywhere in ingestion or Main Review.

**D-435** The individual manual-import UI shows one dedicated slot/button per
data type the app supports (DXF, BOM, weld bead report, weldment cut list, etc.),
regardless of what a specific job needs. Unused slots simply stay empty — the
user only fills in what's relevant to their job.

**D-436** Manual data entry supports both paths, not one or the other: direct
in-app entry (add parts/rows by hand in the UI) and filled-in template files
(D-438's templates). The in-app path is confirmed required, not just an
assumption Claude Design happened to make.

**D-437** "Reuse existing quote" duplicates a full previous job — all parts,
operations, and pricing — into a new editable job. The duplicate is a fork:
editing it does not affect the original job. Closes OQ-145.

**D-438** Manual-fill templates reuse the exact existing column schema of the
macro-generated exports (StructuredBOM.xlsx, WeldBeadReport.xls) rather than a
separate format — one import parser handles both macro output and hand-filled
templates identically. Closes OQ-143.

**D-439** In-app manual part entry is an "Add Part" action on the Main Review
screen, inserting a blank, immediately-editable row — no separate wizard or
screen. Bypasses Batch Review (nothing to triage on manually-entered data).
Closes OQ-144.

**D-440** The "BOM file" slot in Individual Import explicitly carries operation
REQ/DONE data (D-274/295's per-operation columns), not just material/geometry —
this is the existing BOM export structure, not a new one. The slot's UI copy
should say so explicitly, since a user manually filling the blank template
(D-438) needs to know operation flags belong in this same file, not somewhere
else.

**D-441** BOM import does not require REQ/DONE operation columns to be present.
If a BOM has none (e.g. it wasn't sourced from PPM Toolbox — a plain external
spreadsheet, or geometry-only DXF/weldment-cut-list import with no BOM at all),
every part simply starts with zero operations assigned — functionally identical
to a PPM-Toolbox BOM where all REQ columns happen to be 0. No separate "plain
BOM mode" or code path is needed; the same parser handles both uniformly.

**D-442** Batch Review's triage scope extends to flag any part with zero
operations assigned, not just missing material/thickness (its original scope
per the first-iteration mockup). Necessary because D-434 requires every costed
job to have at least one operation somewhere — a part with none is meaningfully
incomplete, not a legitimate absence like D-433's missing-weld-data case.
Remains non-blocking per D-386: flagged parts proceed normally, operations get
assigned manually in Main Review.

**D-443** Job/Quote number is auto-suggested (next sequential number based on
local job history) but always editable, per D-396's universal editability
principle — not a locked auto-generated field. Resolves both the single-user
convenience case and the multi-user collision case (multiple standalone local
installs with no shared counter) with the same mechanism: single-user shops get
a correct suggestion for free; multi-user shops overwrite the suggestion with
the real number from whatever external system (Business Central, a shared
Excel sheet) is already their source of truth today. No new infrastructure
required.

**D-444** Quote-to-WO conversion forks a new Job record — the original Quote is
untouched, the new WO record is independently editable from that point forward
(same pattern as D-437's duplicate-quote fork).

**D-445** [PROVISIONAL] WO numbering uses a prefix swap on the same number
(e.g. Q-2026-001 -> WO-2026-001) rather than an independent WO sequence. Marked
provisional — revisit once the numbering question is settled more broadly (ties
to OQ-146/147's unresolved centralized-numbering questions).

---

## Estimator — Quote Screen Delivery Date (July 2026)

**D-446** Quote screen gets a distinct, manually-entered "Delivery Date" field —
separate from the "deadline" captured at New Job creation. Deadline represents
the customer's requested/needed-by date; Delivery Date represents the company's
committed date being quoted back, which may differ.

**D-447** The internal working-hours/day-derived duration estimate (D-385)
never appears on the customer-facing PDF — it remains an internal planning
aid only, shown in the Quote screen's editing panel to help the preparer
decide on a Delivery Date, but dropped entirely from PDF export. The PDF's
"Estimated duration" checkbox is replaced by a "Delivery Date" item instead.

---

## Estimator — Batch Review Bulk-Edit, Settings Materials & Serbian Identifiers (July 2026)

**D-449** Batch Review bulk actions require checkbox row-selection first — "Apply
material," "Set quantity," "Assign operations" then act only on the selected
subset (via dropdown for material/operations, a typed field for quantity), not
blanket application to every flagged row.

**D-450** Batch Review rows are expandable to assign individual operations
inline, mirroring Main Review's expand/operation-row pattern — not limited to
the bulk "assign default operations" action.

**D-451** Batch Review's primary identifier column shows Part Number (works
for any part type), not a DXF filename. DXF filename, when one actually exists
(sheet-metal parts only), is shown as secondary/supplementary detail, not the
primary label — fixes the bug where every row displayed ".dxf" regardless of
part type.

**D-452** Thumbnail images: manual add only for v1 (click + on an empty
thumbnail slot per part). BOM/macro auto-pull is deferred, not built now —
but the data model and UI should be designed to anticipate it (e.g. an image
reference field per part that's populated manually today, macro-populated
later, without restructuring). Closes the v1-scope half of OQ-149.

**D-453** Batch Review's bulk-action bar includes one control per bulk-settable
flagged field, consistently — Material, Thickness, Quantity, and Operations —
not an ad-hoc subset. Thickness was missing from the first pass despite being
a flaggable field.

**D-454** Batch Review's bulk-edit control is a single unified interface — a
field-selector dropdown (Quantity/Material/Thickness/Operations) plus one value
input and Apply, editing one field at a time — rather than four simultaneous
mini-forms in a row. Resolves the layout crowding/truncation from the prior
pass. Refines D-453's requirement (all four fields covered) without dictating
this specific UI shape, which Claude Design arrived at and is now confirmed.

**D-455** Settings' Materials tab (sheet stock tiers, tube/pipe standard
lengths) supports adding new rows, not just editing the pre-populated set —
consistent with D-396's universal editability principle, extended here to
adding/removing entries, not just editing existing values.

**D-456** Company Info (Settings) includes PIB (Tax ID) and MB (Company
Registration Number) fields — standard Serbian business identifiers, used on
legal/fiscal documents. Not previously captured anywhere in the data model.

**D-457** Customer records include PIB and MB fields, always visible (not
conditional on customer nationality/type) — same two Serbian business
identifier fields as D-456, captured per customer, not just for the user's
own company.

**D-458** PIB and MB appear on every customer-facing Quote PDF, unconditionally
— not gated on whether the customer is Serbian/local.

---

## Estimator — Identifier Consolidation, Job History, System Overlays & Final Resolutions (July 2026)

**D-459** Company Info and Customer records use two universal fields, not
three: the existing "VAT / Tax ID" field is kept as-is and serves as the
universal tax-identifier field (covers PIB, VAT, EIN, or whatever a given
country's equivalent is) — no separate dedicated PIB field. "MB" is added as
a second, distinct field for company registration number (covers MB, KVK,
HRB, etc. depending on country). Supersedes D-456 and D-457's three-field
structure; D-458's substantive requirement (both identifiers shown on every
Quote PDF, for both company and customer) is unchanged, just now expressed
as two fields instead of three.

**D-460** Job History uses infinite scroll, not pagination.

**D-461** Clicking a job row in Job History opens directly into Main Review for
that job — consistent with D-402's one-click-reopen behavior on the Dashboard.

**D-462** "Duplicate" is available both as an inline row action on Job History
and through New Job's "Duplicate Existing Quote" path (D-437) — both use the
same underlying job picker, not two separate implementations.

**D-463** Part-number search across all jobs returns job-level results (which
jobs contain a matching part), not a direct jump to the part itself.

**D-464** Command palette (Cmd/Ctrl+K, D-410) is global — available from any
screen, not only Main Review. On Main Review, where a persistent visible
search bar already exists, Cmd+K focuses that same bar rather than opening a
separate overlay; elsewhere it opens the palette directly.

**D-465** "Convert to Work Order" (D-444) has no confirmation dialog — it's
non-destructive (forks a new record, original Quote untouched), so a blocking
prompt would be inconsistent with D-386. Executes immediately; a toast
notification (D-404) confirms the new WO number.

**D-466** "Import" is removed as a standalone sidebar nav item. Re-importing/
updating data into an already-open job (D-388/D-394's targeted merge) is
instead a contextual action button on Main Review — e.g. "Import/Update Data"
— alongside the existing Add Part (D-439) and Export (D-390) actions. Closes
OQ-148. Reduces the screen count from 10 to 9.

**D-467** Keyboard shortcut set (D-410's cheat sheet, now concrete): Cmd/Ctrl+K
command palette, Cmd/Ctrl+N New Job, Cmd/Ctrl+S save, ? show cheat sheet,
Cmd/Ctrl+F search/filter, Cmd/Ctrl+H Job History, Cmd/Ctrl+Z / Shift+Z undo/
redo, Tab/Shift+Tab next/previous cell, Enter confirm cell & move down, Esc
cancel edit/close dialog, Cmd/Ctrl+P Generate PDF, Cmd/Ctrl+Shift+? Convert
to Work Order.

**D-468** Ctrl+S is supported despite continuous autosave (D-400) — forces an
immediate save and shows a brief confirmation toast (D-404's pattern). Costs
nothing to support and avoids the appearance of a broken shortcut for users
with explicit-save muscle memory.

**D-469** Fail-report format (closes OQ-134): a flat log, one row per issue —
Job number, Part Number, Operation (if applicable), Issue type, Timestamp.
Exportable via the same Excel pattern as the internal costing report.
Accessible via a "View Fail Report" link on Main Review/Batch Review, not a
dedicated screen.

**D-470** Cut list export format (closes OQ-139): PDF, one clear page laid out
per stock bar (each cut length and any offcut shown per bar) — a shop-floor
physical reference, not an editable spreadsheet.

**D-471** Kerf width granularity (closes OQ-140): one flat value per saw/
machine, not a material/blade-specific lookup table — same provisional-and-
tunable philosophy as the bend-complexity threshold (D-392) and CAD-hours
norm (D-393). Revisit with real data if it proves too coarse.

---

## Stirg Metall — Stadler Rail Tank Estimation (Continued, July 2026)

**D-472** Deburring (OP-014) applied per unique part type for weldment assemblies — not per individual blank. Diesel tank: 23 unique types; AdBlue tank: 9 unique types.

**D-473** Painting placeholder: Diesel tank 300 EUR/unit, AdBlue tank 100 EUR/unit. In-house wet paint (OP-017) including materials, car reference (door≈70 EUR, bumper≈100 EUR). Subject to EN 45545 subcontractor quote (OQ-149).

**D-474** DXF bend line count = physical press brake strokes and is the authoritative source for OP-012 costing. PPM_TestFeatureExtraction BendCount = 2× physical count — enumerates bend faces (inner+outer), not bend feature definitions. Confirmed on NR01555346-1 (DXF=6 / FE=12), all C-Schiene variants (DXF=4 / FE=8).

**D-475** PPM Estimator pitch demo rebuilt from decoded Claude Design source exports (Main Review, Quote, Settings). Exact CSS tokens, layout, and component patterns matched from dc-runtime bundles. Three interactive screens: Main Review (part tree + 4-column op layout + setup sub-lines + summary rail), Settings (norms table + material rates), Quote (internal working area + Option A customer preview).

**D-476** Tube/pipe stock section omitted from demo Raw Stock Needed panel — no tube/pipe parts in the Diesel/AdBlue tank BOM.

**D-477** "VAT / Tax ID" label used consistently throughout all demo UI, correcting PIB/Tax ID inconsistency present in source design files.

**D-478** Material cost rates confirmed for Stirg estimation model: EN S235JR = €2/kg, EN 1.4404 SS = €6/kg, ArmaFlex RAIL RA-25 = €71.41/m² (8,355 RSD/m²). Applied per-part from massKg × qty × rate. Outsourced parts with real reference price (NR01481349.4 oc=126 EUR, ArmaFlex oc=137.69 EUR) exclude separate material cost — already included in their outsource/material line.

**D-479** Customer-facing quote confirmed as Option A: single line "Diesel & AdBlue Tank Assembly — complete" with qty, delivery date, and total (margin applied). No operation breakdown, no margin/risk/ecology figures visible to customer.

**D-480** Custom "Add line" in Main Review supports 5 types: Fixed cost, New part, Service, Procured part, New assembly — each with description, qty, unit cost. Added lines appear in the assembly tree, contribute to total, and persist in shared storage.

---

## Stirg — Estimation Model Refinements (July 2026, continued)

**D-481** Engineering hours auto-suggestion: Estimator proposes `0.35h × unique PN count` as a starting value. User can approve or override any figure. Value is always editable, never locked.

**D-482** Weld in Main Review = one grouped summary row per assembly: total bead count, total weld length (mm), computed time at norm speed (D-474), total cost. Source is the per-assembly weld report; individual seams are not displayed in the UI tree.

**D-483** Production PPM Estimator app to be built in a new dedicated Claude Code chat — not from the current estimation session.

**D-484** ArmaFlex insulation has 5 separate BOM rows (NR01481349.13–17) with individual areas sourced from Excel BOM session: .13=0.531m², .14=0.535m², .15=0.224m², .16=0.177m², .17=0.111m². Each carries independent material cost = area × €71.41/m². Not grouped into one ARM entry.

**D-485** Fixed costs = separate group at the bottom of Main Review, below fabricated, machined, and purchased parts. Confirmed line types: engineering hours (rate × hours, PN-count suggestion per D-481, always adjustable), FEM (total ÷ project qty), transport, and any user-added fixed items. Each line has editable description, quantity, and rate.

**D-486** Summary rail breakdown (from top): Total Cost → split into Materials Total + Operations Total + Fixed Costs Total → each section expandable to per-type detail → materials list each showing editable per-unit price and computed quantity.

---

## Stirg — Excel Cost Report Design (July 2026)

**D-487** Formula column not visible in Excel cost report. Derivations live in cell formulas only.

**D-488** Weld summary row = Level 2 under its parent assembly in the cost report.

**D-489** Cost report organised per unique PN — each part number appears exactly once. Qty = total usage for one main assembly. Assembly headers are grouping/shading context only. This is an estimating report, not a structural BOM.

**D-490** Both EUR/pc and EUR×qty columns included. Unit cost allows auditing of high-total rows without manual division.

**D-491** Item numbers not included in cost report. Customer PN is used directly. Report is internal only — no cross-reference to customer BOM required.

**D-492** Two cost columns per data row — Internal (real company rate) and Quotable (rate with markup). Both live, both formula-linked to Sheet 1.

**D-493** Excel cost report has three sheets: Sheet 1 = Parameters & Norms (all editable inputs), Sheet 2 = Main Review (full PN breakdown, formula-linked to Sheet 1), Sheet 3 = Quote (order qty, margin, risk, profit).

**D-494** All data columns on Sheet 2 carry Excel AutoFilter. Filterable by Type, Material, Operation, Level etc.

**D-495** Material cost has markup. Per-material markup % defined on Sheet 1. Cost price and quotable price both visible on Sheet 1.

**D-496** Summary table frozen above all data rows on Sheet 2. Always visible when scrolling.

**D-497** FEM = manual entry per job on Sheet 1 Fixed Costs block.

**D-498** Rate reference column removed from Sheet 2. Actual rate values live in cells via formula from Sheet 1.

**D-499** Quote sheet has order qty input field. Total = per-assembly cost × order qty.

**D-500** Quote sheet has editable Risk % and Margin % fields applied on top of quotable subtotal.

**D-501** Sheet 2 includes ×order qty columns — 6 cost columns total: EUR/pc int · EUR/pc quot · EUR×1 int · EUR×1 quot · EUR×16 int · EUR×16 quot.

**D-502** Material markup is per-material on Sheet 1, not a global percentage.

**D-503** Quote sheet shows single total only — no line-item breakdown visible.

**D-504** Quote sheet includes Profit field: Total Quoted − Internal cost total, both at full order qty.

**D-505** Profit = Total Quoted − Total Internal, both calculated at full order qty level.

**D-506** Engineering hours auto-calculated: COUNT(unique PNs in Sheet 2) × editable h/PN value on Sheet 1. Appears as a line item in Fixed Costs group on Sheet 2.

**D-507** Order qty = single editable cell on Sheet 1 Job Parameters block. Referenced by all ×qty columns on Sheet 2 and Quote sheet.

**D-508** Manipulation time and preparation time combined into one Handling sub-row per operation on Sheet 2. Separately editable on Sheet 1 norms table. Displayed as one combined row in Sheet 2.

**D-509** Handling weight bracket placeholder values (editable on Sheet 1): <5kg=0.03h/pc, 5–20kg=0.07h/pc, 20–50kg=0.15h/pc, >50kg=0.35h/lift. Crane threshold = 50kg editable.

**D-510** Setup appears as its own visible sub-row under each operation in Sheet 2.

**D-511** Handling + prep time multiplied by general labour rate. General labour rate = separate editable cell on Sheet 1 Labour & Handling block.

**D-512** Visual design principle for Excel report: assembly header rows = dark blue fill / white bold text, part rows = medium grey / bold PN, operation rows = white / normal indented, setup and handling sub-rows = light fill / italic further indented, material rows = light amber tint, weld rows = medium grey italic, separator lines between parts.

**D-513** Setup sub-row rate = machine rate for that operation (machine is occupied during setup). General labour rate applies to handling/prep rows only.

**D-514** Sheet 1 input blocks physically and visually separated: Job Parameters block (order qty, job number, client) is separate from Labour & Handling block (general labour rate, crane threshold, weight bracket table).

---

## PPM Estimator — Norm Calibration (July 2026)

**D-527** CANCELLED. C-Schiene b=4 bends per piece is correct per DXF extraction. Earlier Excel implementation error (b=4→b=2) must be reverted.

**D-532** Press bend (OP-012) cycle time is two-tier based on bend line length, both values include operator repositioning: short bend (fold line ≤1 m) = 30 s/bend = 0.00833 h/bend; long bend (fold line >1 m) = 60 s/bend = 0.01667 h/bend. Source: Voja, Stirg measured. Both stored as editable seconds on Sheet 1; hidden column divides by 3600 for cost formulas.

**D-533** Sheet 1 norms table stores all operation cycle values in natural units (seconds, minutes, or mm/min) with a visible Unit column. A hidden column converts to h/unit for cost formulas. All cost formulas reference the hidden converted column only.

**D-534** Weld time formula: weld_hours = (weld_length_mm ÷ arc_speed_mm_min ÷ 60) ÷ operating_factor. Operating factor default = 30% (manual MIG/MAG, per AWS D1.1 / Lincoln Electric Procedure Handbook). Editable on Sheet 1. Sheet 2 summary includes an informational row converting total weld hours to elapsed shift-days so worker 3-day estimate is visible alongside cost. Arc-on speed (mm/min) is a separate editable cell; 400 mm/min is current placeholder (OQ-157).

**D-535** Weld grinding (OP-013) basis changes from h/weldment to h/m of weld length. Formula: grinding_hours = total_weld_mm ÷ 1000 × h_per_m. Default placeholder: 0.050 h/m (3 min/m) = moderate structural dressing. Editable on Sheet 1. Actual value depends on weld position and customer surface requirement.

**D-536** Assembly & Seal (OP-020) placeholder = 4.0 h/weldment assembly, pending Stirg measured time on a comparable job (OQ-158). Replaces previous 0.5 h/sub-assembly.

---

## PPM Estimator — Norm Calibration & Sheet Count (July 2026, continued)

**D-537** Bend line length extraction added to PPM feature extraction pipeline. IV_BEND and IV_BEND_DOWN DXF layers contain individual line segments; measuring each segment enables the two-tier 30s/60s bend cycle rule (D-532). Output: per-PN list of individual bend line lengths alongside bend count. Implementation: enhance PPM_TestFeatureExtraction / PPM_ExportPartData in next macro session.

**D-538** External welder market reference for Stadler UWC tank: €1,000/set for complete welding. PPM Estimator model at 104 mm/min arc speed + 30% operating factor yields ~€1,634/set (diesel + adblue combined), ~64% above reference. Delta attributable to: (a) arc speed placeholder may still be too conservative; (b) reference covers welding labour only; (c) different tank geometry. Reference retained as sanity-check anchor, not a binding target.

**D-539** Bend cycle time simplified to flat 40 s/bend for all bends (middle ground between 30 s short and 60 s long from D-532), including operator repositioning. Applies until OQ-159 (bend line length extraction) is resolved. 40 s/bend = 0.01111 h/bend. Implemented in OP-012 norms row on Sheet 1.

**D-540** Weld arc speed calibrated to 104 mm/min to match worker estimate of 3 working days for diesel+adblue tank welding (44,992 mm total at 30% operating factor, 8 h shift). Formula: 44,992 ÷ (3 × 8 × 0.30 × 60) = 104.1 mm/min. This is a calibrated placeholder, not a measured WPS value (OQ-157). Arc speed, operating factor, and shift hours are all editable on Sheet 1.


## RFQ Quick-Scope Tool (July 2026)

**D-541** New standalone tool confirmed: same-day RFQ Quick-Scope, separate from
both the Estimator and the cost-report pipeline (D-491–511). Output = per-PN
register + scope summary + open-questions list. Explicitly no costing/quoting.
Purpose: categorize incoming client packages (drawings, STEP, BOM, emails) into
scope of work before committing to STEP→Inventor conversion + op-marking.

**D-542** Tool runs via Claude Code on Voja's machine against the client folder
tree directly (not pasted into chat) — token cost and confidentiality (client
proprietary drawings/contacts) both rule out chat-based bulk processing. Core
extraction logic (BOM/PDF parsing) prototyped and verified in Claude.ai first
against one real sample before porting.

**D-543** Register schema locked (real sample: Elbit 06030-01069-01, Y88159A-00
BOM): identifiers (multi-key per D-188) · name · BOM position/qty/parent ·
part type (D-352 taxonomy, STEP-derived, confidence-flagged) · make/buy +
reason · material · thickness · size/bbox/mass (STEP) · tolerances (general +
notable GD&T) · surface treatment · additional requirements (marking, QA,
packaging, certs) · export-control flag · source refs · per-PN open questions.

**D-544** Join key = filename-derived part number (strip "un" prefix; split on
`#`/`_`/concatenated "Rev" token), confirmed equal to both the containing
folder name and the client BOM's PART NUM column on real data. Folder path is
assembly-hierarchy context, not the primary join key — layout varies (per-part
folders, all-in-one, STEP-only, split STEP/PDF folders) but filename-PN join
holds across all observed cases.

**D-545** Material and thickness are drawing/STEP-sourced only for the Elbit/
Yugoimport package — this client's BOM (Y88159A-00__BOM.xlsm) has no material
or thickness columns at all. Not assumed universal — future sources checked
independently per D-180 procedure.

**D-546** Register requires an export-control flag field. Client BOM carries
paired Control Class/GOV Authority/License Request/Control List/Under
Regulation columns (×2 sets) — present but blank on inspected rows. Compliance
axis, not a costing axis.
