# Spec: Estimator Unified Workflow

**Supersedes/expands:** kb/specs/dxf-cutting-time-estimator.md (original standalone
scope, D-197). That document remains accurate for its narrower original purpose;
this document is the current, full scope.

**Governing decisions:** D-227–D-241 (product reframe, monetization), D-274–D-275
(operation categories), D-308–D-329 (weld costing, Send-to-Estimator macro),
D-347–D-368 (feature extraction, `batch_parts_data.json` schema), D-381–D-411
(design phase: norms philosophy, ingestion correction, UX & design system),
D-412–D-420 (raw stock consolidation, tube/pipe stock logic, cut-length
optimization).

## Pipeline overview

Launch → New Job → Ingestion → Batch Review (triage) → Analysis → Main Review
(editable report) → Quote → PDF. Settings underlies all stages.

## 1. Launch (D-386)

No setup wizard, never blocks. Missing norms/rates/machine config → dismissible
warning banner. Analysis still runs; affected line items flag instead of failing.

## 2. New Job

Job/Quote number, Customer (existing, searchable, or new — persists for reuse),
deadline, ordered qty for the top-level assembly (D-387) — independently
overridable per line item later. Recent Jobs quick-access on the dashboard,
distinct from full Job History (D-402).

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
parts (missing material, missing thickness, unresolved qty, etc.) with inline
fix controls, a resolved/total progress indicator, bulk-fix actions, and a
dual-path footer: fix everything first, or proceed with just the currently-clean
parts (never-block principle, D-386). Confirmed via first-iteration mockup —
not new scope invented this session.

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
  run (format not yet specified — OQ-134, still open)

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
format TBD — OQ-139).

Length data source: manual entry, or (unvalidated) extraction from Inventor's
native Weldment Cut List feature (D-417) — to be tested in a separate macro
session. The optimization algorithm itself is built now, independent of which
source feeds it (D-420); only the import mechanism changes later.

## 7. Quote window

Checklist to select which items/operations are customer-visible. Margin %, risk
%, ecology % — all percentage-based, same mechanism (D-384, D-391). Qty
multiplier from Job creation, overridable here too (D-387). Rough duration
estimate = total hours ÷ configurable working-hours/day — explicitly NOT real
capacity/resource scheduling, which stays with PPM App (D-385). Generates PDF.
Customer record persists for future jobs.

## 8. Settings

Company info, WPS/welding data, all norm hours/costs/thresholds (including the
bend-complexity threshold, CAD-hours-per-PN default, and kerf width per machine/
saw), margin defaults, stocked-materials list, machines/parameters table,
About/License info (D-401, separate from the Activation flow itself).

## Cross-cutting: reliability & UX

- Fault isolation, flag-and-skip, fail report per run (D-382) — see Analysis
- Undo/Ctrl+Z required on editable screens (D-399)
- Autosave to SQLite periodically during editing, not only on explicit save —
  crash costs minutes, not the session (D-400)
- Keyboard navigation (Tab/Enter) in dense editable tables (D-403)
- Toast/progress notifications for long background operations, never a frozen
  UI (D-404)
- Command palette (Ctrl/Cmd+K) to jump to any job/customer/part number
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

- **OQ-134** [OPEN] Fail-report format (per-PN/per-operation granularity assumed,
  output format and UI surfacing not yet specified)
- Bar/tube/profile automatic stock-quantity calculation remains manual pending
  OQ-125/128/129 resolution — out of scope for v1 automation
- OQ-139 (cut list export format), OQ-140 (kerf granularity — flat vs. lookup
  table), OQ-141 (Weldment Cut List viability, pending separate macro testing)
- OQ-142: machining (mill/turn) feature-based cost estimation — viable per
  industry precedent (Xometry/Protolabs-style geometry analysis), deferred
  until sheet-metal/weldment/tube pipeline is stable
