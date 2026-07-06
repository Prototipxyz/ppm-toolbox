# Spec: Estimator Unified Workflow

**Supersedes/expands:** kb/specs/dxf-cutting-time-estimator.md (original standalone
scope, D-197). That document remains accurate for its narrower original purpose;
this document is the current, full scope.

**Governing decisions:** D-227–D-241 (product reframe, monetization), D-274–D-275
(operation categories), D-308–D-329 (weld costing, Send-to-Estimator macro),
D-347–D-368 (feature extraction, `batch_parts_data.json` schema), D-381–D-411
(design phase: norms philosophy, ingestion correction, UX & design system),
D-412–D-420 (raw stock consolidation, tube/pipe stock logic, cut-length
optimization), D-421–D-432 (screen list finalization, product renamed to
"PPM Estimator"), D-433–D-445 (New Job data sourcing, sparse-job handling,
job numbering, Quote/WO fork), D-446–D-448 (Quote screen delivery date,
per-operation breakdown option), D-449–D-459 (Batch Review bulk-edit
redesign, thumbnails, identifier fields), D-460–D-471 (Job History, command
palette scope, Convert-to-WO confirmation, system overlays, shortcut set,
fail-report/cut-list/kerf resolutions).

**Resolved screen list (9 screens):** EULA, Activation, Dashboard, New Job,
Batch Review, Main Review, Quote (includes PDF export config, D-422), Settings,
Job History. About/License is a modal off the sidebar (D-424), not a
standalone screen. "Import" is not a standalone nav item — re-importing into
an open job is a contextual button on Main Review instead (D-466).

## Pipeline overview

Launch → New Job → Ingestion → Batch Review (triage) → Analysis → Main Review
(editable report) → Quote → PDF. Settings underlies all stages.

## 1. Launch (D-386)

No setup wizard, never blocks. Missing norms/rates/machine config → dismissible
warning banner. Analysis still runs; affected line items flag instead of failing.

## 2. New Job

Job/Quote number (auto-suggested from local job history, always editable —
D-443, resolves multi-install numbering collisions without new infrastructure),
Customer (existing, searchable, or new — persists for reuse), deadline, ordered
qty for the top-level assembly (D-387) — independently overridable per line
item later, and again on the Quote screen. Recent Jobs quick-access on the
dashboard, distinct from full Job History (D-402).

**Four parallel data-sourcing paths, presented as equal choices (D-436–D-439):**
1. **Import PPM Toolbox Handoff** — the Job Package (manifest + BOM + DXFs +
   weld report)
2. **Import Individual Files** — one dedicated slot per supported data type
   (DXF, BOM, weld bead report, weldment cut list), each with a downloadable
   blank template (D-438) using the exact same column schema as the macro
   export — one shared parser for both sources. The BOM slot explicitly
   carries operation REQ/DONE data too (D-440), not just material/geometry.
3. **Start Blank** — zero parts, "Add Part" inserts an editable row directly
   on Main Review (D-439). Skips Batch Review (nothing to triage).
4. **Duplicate Existing Quote** — forks a full previous job (all parts,
   operations, pricing) into a new independent copy (D-437). Skips Batch
   Review.

Paths 1–2 proceed to Batch Review next if anything needs triage; paths 3–4 go
straight to Main Review.

**Sparse and partial jobs are the ordinary case, not a degraded one (D-434):**
a job with a single part and a single operation must work with no special
handling. A BOM with no REQ/DONE columns at all (plain external spreadsheet,
or no PPM Toolbox marking metadata) simply means every part starts with zero
operations assigned — same code path as a PPM-Toolbox BOM where all flags
happen to be 0 (D-441). Job Package data legitimately omits whole categories
(no weldment → no weld data) without that being a failure state (D-433) —
distinct from D-382's fault isolation, which covers expected-but-broken data.

**Sidebar "Import" resolved (D-466):** not a standalone nav item — re-importing
data into an already-open job is a contextual button on Main Review instead.

## 3. Ingestion (D-388)

Two paths, always both available, never mutually exclusive:
- **Job Package**: folder containing `manifest.json` + `batch_parts_data.json` +
  `StructuredBOM.xlsx` + DXFs + `WeldBeadReport.xls` (produced by
  `PPM_SendToEstimator` — spec: send-to-estimator.md; macro not yet built).
- **Individual import**: DXF folder / BOM file / weld report file separately,
  usable even after a Job Package is already loaded.

Re-importing one data type after a Job Package is loaded performs a **targeted
merge** — overwrites only that data type's fields, rest of the job untouched
(D-394).

Job-input schema is NOT a new format: `batch_parts_data.json`/`manifest.json`
(D-347–D-368) already covers part type, material, thickness, mass, surface area,
flat-pattern dimensions, holes (plain/tapped with counts and thread designations),
countersinks/counterbores, and warnings. Bend count and bend-line-length
(complexity signal) are NOT in this JSON — both derived by the Estimator from the
DXF bend layer at ingestion time (D-397).

## 4. Batch Review (D-407)

Triage screen between Ingestion and the main Review screen. Lists only flagged
parts (missing material, missing thickness, unresolved qty, zero operations
assigned — D-442) with a Part Number as the primary identifier (DXF filename
shown only as secondary text, only when one exists — D-451, since not every
part type produces one). Checkbox row-selection plus a unified Bulk Edit
control (field-selector dropdown — Quantity/Material/Thickness/Operations —
plus one value input and Apply, one field at a time — D-449, D-453, D-454)
applies only to selected rows. Rows expand to assign individual operations
inline, mirroring Main Review's pattern (D-450). A thumbnail slot per row
supports manual image attachment via a "+" placeholder; BOM/macro auto-pull
is deferred but the slot is designed to accommodate it later without
restructuring (D-452, OQ-149). Resolved/total progress indicator, dual-path
footer: fix everything first, or proceed with just the currently-clean parts
(never-block principle, D-386). Locked design, confirmed working.

## 5. Analysis pass (D-382, D-395, D-397, D-398)

- DXF cut length + pierce count → laser cost (existing presets.json rate lookup)
- DXF bend layer → bend count AND bend-line length → complexity classification
  (simple/complex threshold, fully user-adjustable, D-392) → bend cost. Additive
  to existing count×norm-time costing (D-357), not a replacement.
- Feature/operation counts (holes, threads, countersinks, counterbores, part
  type, material, thickness) × norm hours from settings
- Weld bead report → weld time/cost/consumables (existing validated logic,
  D-308–D-324, unchanged)
- Surface area → paint time/cost
- Every operation instance carries its own separate fixed setup-time/cost
  sub-line, distinct from per-unit time/cost (D-389)
- CAD/modeling time: fully manual per-PN entry, no formula (D-395, supersedes
  D-383). Optional starting suggestion = part count × configurable avg
  hours/PN (default 1.5h), pre-fills the manual field (D-398)
- Fault isolation: any single PN or operation failure flags and skips only
  that item — run never aborts (D-382, extends D-149). Self-diagnostic checks
  per operation per PN; all flags/warnings/errors logged to a fail report per
  run: a flat log, one row per issue — Job number, Part Number, Operation,
  Issue type, Timestamp — exportable, accessible via a "View Fail Report"
  link on Main Review/Batch Review (D-469))

## 6. Main Review screen

Hierarchical assembly/sub-assembly/part tree, flat-view toggle (parts-only or
assemblies-only), filterable by two independent taxonomies: part type (Sheet
metal, Machined, Weldment, Tube/Pipe, Purchased — D-352's enum, describing what
the part fundamentally IS) and operation category (D-274/275's categories,
describing what work happens to it — a Sheet metal part can carry both a Weld
and a Paint operation without being a Weldment part type). Per PN: weight,
volume, area, type, qty; operations in working order with hours/cost per-PN and
per-total-qty, including the setup-time sub-line, with column headers on
operation rows (D-415) rather than bare "unit"/"total" labels. This screen IS
the internal report — "export" is a button here, not a separate screen (D-390).

Summary panel (right rail): Total Cost, Total Hours, Weight stacked vertically
(D-414). By-operation cost/time breakdown. Raw Stock Needed — one consolidated
list covering sheet stock (D-372–375), tube/pipe/bar stock as piece-counts of
standard lengths (D-416, not raw meters), and weld consumables broken down by
wire type/diameter and gas type (D-308–324, D-412). No standalone stock-count
tile at the top level (D-413) — detail lives only in this list.

**Progressive disclosure** (D-409): individual per-row expand/collapse, plus a
global expand-all/collapse-all toggle.

**Universal editability** (D-396): every hour, cost, qty, parameter is directly
editable inline. No per-field confirmation — one "unsaved changes, are you
sure?" prompt on navigating away from a screen/job with pending edits.
Confirm-before-delete (D-405) is a separate, distinct mechanism for destructive
actions (deleting a job or customer record).

## 6a. Cut-length optimization (tube/pipe/bar)

1D bin-packing: required length × qty per PN against standard stock bar length
(OQ-125) and an adjustable kerf width (per machine/saw, Settings). Outputs an
optimized cut plan plus total stock pieces required (D-418), feeding the Raw
Stock Needed panel. Exportable as a standalone shop-floor document (D-419,
format: PDF, one page per stock bar showing its cuts and offcut (D-470).

Length data source: manual entry, or (unvalidated) extraction from Inventor's
native Weldment Cut List feature (D-417) — to be tested in a separate macro
session. The optimization algorithm itself is built now, independent of which
source feeds it (D-420); only the import mechanism changes later.

## 7. Quote window

Checklist to select which items/operations are customer-visible, plus an
"Include per-operation cost breakdown" checkbox (unchecked by default) to
optionally expose per-operation cost detail beyond rolled-up line totals
(D-448). Margin %, risk %, ecology % — all percentage-based, same mechanism
(D-384, D-391). Qty multiplier from Job creation, overridable here too
(D-387). A separate, manually-entered Delivery Date field — distinct from
the Job's "deadline" (customer's requested date) — represents the company's
committed date and is what appears on the customer PDF (D-446). The rough
duration estimate (total hours ÷ configurable working-hours/day) remains
strictly internal, shown only in the editing panel to help decide on a
Delivery Date — explicitly NOT real capacity/resource scheduling (D-385) and
never appears on the PDF (D-447). PDF export configuration lives in this
screen's "Generate PDF" flow, no separate screen (D-422). Customer record
persists for future jobs.

**Quote-to-WO conversion:** forks a new, independent Job record — the original
Quote is untouched (D-444). Numbering uses a prefix swap on the same number
(e.g. Q-2026-001 → WO-2026-001), marked provisional pending OQ-146/147 (D-445).
No confirmation dialog — non-destructive, executes immediately, confirmed via
toast notification (D-465).

## 8. Settings

Company info, WPS/welding data, all norm hours/costs/thresholds (including the
bend-complexity threshold, CAD-hours-per-PN default, and kerf width per machine/
saw), margin defaults, stocked-materials list (extensible — add/delete rows,
D-455), machines/parameters table, About/License info (D-401, separate from
the Activation flow itself). Company Info and Customer records share two
universal identifier fields — "VAT/Tax ID" and "MB" (registration number) —
rather than country-specific pairs, adapting to whatever a given country's
equivalent is (D-459); both appear on every Quote PDF (D-458).

## 9. Job History

Full, searchable record of every Quote and Work Order — distinct from the
Dashboard's lightweight Recent Jobs list (D-402). Infinite scroll, not
pagination (D-460). Search matches job number, customer name, or part number;
part-number matches return job-level results, not a drill-down into the part
itself (D-463). Filterable by type (Quote/Work Order) and date range. Clicking
a row opens directly into Main Review (D-461). A "Duplicate" action exists as
both an inline row action here and through New Job's "Duplicate Existing
Quote" path (D-437) — same underlying picker, not two implementations
(D-462). Work Orders show a "Forked From" reference back to their originating
Quote (D-444).

## Cross-cutting: reliability & UX

- Fault isolation, flag-and-skip, fail report per run (D-382) — see Analysis
- Undo/Ctrl+Z required on editable screens (D-399)
- Autosave to SQLite periodically during editing, not only on explicit save —
  crash costs minutes, not the session (D-400)
- Keyboard navigation (Tab/Enter) in dense editable tables (D-403)
- Toast/progress notifications for long background operations, never a frozen
  UI (D-404)
- Command palette (Ctrl/Cmd+K) to jump to any job/customer/part number —
  global, available from every screen; on Main Review, where a persistent
  visible search bar already serves this role, Cmd+K focuses that bar rather
  than opening a separate overlay (D-464)
- Non-blocking inline validation — highlight in place, never a halting popup
- Optimistic UI + silent background autosave, no visible "saving..." interrupt
- Persistent filter/view state across navigation
- Keyboard-shortcut cheat-sheet overlay (e.g. `?`)
- Breadcrumb header in nested hierarchy views
(all D-410 except where cited separately above)

## Language (D-406)

Two independent settings: global app-UI language (English/Serbian), and a
separate customer-facing quote-PDF export language — not linked to each other.

## Visual design system (D-408, D-411)

Recovered from the first-iteration "Batch Review" mockup, adopted app-wide:
accent blue `#2E7DD1`, amber `#d9920f` (warnings/flags), green `#16A34A`
(resolved/ready); Inter for UI text, JetBrains Mono for all data/numeric values;
native desktop window chrome (custom title bar, no browser furniture). Both
light and dark theme required — not dark-only (D-411 amends D-408).

## Open items

- Bar/tube/profile automatic stock-quantity calculation remains manual pending
  OQ-125/128/129 resolution — out of scope for v1 automation
- OQ-141 (Weldment Cut List viability, pending separate macro testing)
- OQ-142: machining (mill/turn) feature-based cost estimation — viable per
  industry precedent (Xometry/Protolabs-style geometry analysis), deferred
- OQ-146: WO numbering (prefix-swap is provisional, D-445) may not survive
  once OQ-147 is resolved
- OQ-147: centralized/pooled job numbering via a shared backend — deliberately
  deferred roadmap idea, possible paid bridge tier between Estimator (Tier 2)
  and PPM App (Tier 3), not scoped or built now
- OQ-149: thumbnail auto-pull mechanism (v1 is manual-only, D-452) — how
  Inventor would generate/export a part preview image and what convention
  carries it through the Job Package, not scoped, deliberately deferred
  until sheet-metal/weldment/tube pipeline is stable
