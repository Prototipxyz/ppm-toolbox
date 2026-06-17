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

