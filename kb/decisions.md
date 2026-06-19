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

## DXF Estimator — Layer Rule, Scope & Resolution Chain

- D-201: **OQ-73 resolved — bend lines confirmed present and layer-separated in
  Inventor's flat-pattern DXF export**, via real export sample (`testpart.dxf`)
  and cross-checked against Autodesk's documented `FLAT PATTERN DXF` translator
  parameters. Fixed, version-stable layer vocabulary: `IV_OUTER_PROFILE` /
  `IV_INTERIOR_PROFILE` (cut geometry), `IV_BEND` / `IV_BEND_DOWN` (bend lines,
  one entity per bend), `IV_FEATURE_PROFILES` (formed features — excluded from
  cut geometry per explicit decision), plus several non-cutting reference layers
  (`IV_TANGENT`, `IV_TOOL_CENTER`, `IV_ARC_CENTER`, `IV_ROLL*`, `IV_ALTREP*`,
  `IV_UNCONSUMED`) discarded entirely. Earlier laser-floor DXF samples lacking
  bend-line layers reflect a downstream export/CAM step, not a translator
  limitation — the estimator tool's input contract is the Inventor-side
  flat-pattern export, not arbitrary laser-floor files.
- D-202: **DXF cutting-time estimator scoped as a standalone tool** (extends
  D-197): per-part pipeline reads an Inventor flat-pattern DXF, classifies
  geometry by the D-201 layer rule, computes cut length / pierce count / bend
  count, re-exports a clean laser-ready DXF (cut geometry only — no text, no
  bend lines, no markings), and writes an Excel report row. Interface: local
  GUI, drag-drop, editable rate-constant fields in both the tool form and the
  Excel output (placeholder defaults, D-195 convention). Output (clean DXFs +
  report) goes to a user-chosen destination folder; source DXFs and any
  supplied BOM file are never modified, renamed, or moved.
- D-203: **Pierce count = interior closed loops + 1** (the outer profile counts
  as one pierce).
- D-204: **Material/thickness resolution is metadata → filename → manual flag
  only — no BOM fallback.** These are part-intrinsic properties (true regardless
  of which WO/assembly the part is used in), owned by the D-199 macro's embedded
  metadata and the D-200 filename convention. BOM cross-reference is explicitly
  scoped to quantity only (D-205), since quantity is contextual to a specific
  assembly/WO rather than intrinsic to the part.
- D-205: **Quantity resolution chain: metadata → filename → optional BOM
  cross-reference → flag+default(qty=1) → manual.** BOM cross-reference (only
  when the user supplies an Inventor BOM Excel export alongside the DXF batch)
  has two paths depending on which BOM view is provided: Parts Only (flat) view
  — direct read of the `QTY` column, since Inventor's flat view already sums
  quantity across parent assemblies (consistent with D-97/D-120); Structured
  (hierarchical) view — tool walks the Item-number hierarchy and computes final
  per-PN quantity as the product of each ancestor's quantity down the tree,
  summed across all occurrences (real traversal algorithm, not a groupby — same
  family as D-114's recursive BOM logic, applied to a BOM Excel file rather than
  the `parts` table). PN matching between DXF and BOM rows is not assumed exact
  (per OQ-59/68/69 precedent) — unmatched rows are flagged, never silently
  attributed. This resolves the "should the macro pull qty from the assembly
  BOM" question raised this session: quantity resolution stays entirely in the
  estimator tool, not the macro — avoids making the macro assembly-context-aware,
  which would have required a different (batch/assembly-level) trigger point
  than D-199's part-level export-time prompt.
- D-206: **Estimator report computes per-piece and total (per-piece × qty) time
  and cost separately, qty as a live-editable cell driving the total via
  formula, never hardcoded.** Per-piece figures are the values intended to
  later attach to a PN's norm data in PPM (`org_operations`/`part_operations`
  lineage, OQ-09); the qty multiplier is applied at the order/BOM-line level,
  matching D-188's existing quoting model (rate × time → cost, then quantity
  applied separately) rather than baking quantity into the part's own cost data.
