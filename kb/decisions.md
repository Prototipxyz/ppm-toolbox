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
