# Spec: DXF Cutting-Time & Bend-Count Estimator (Standalone Tool)

**Phase:** Pre-PPM, standalone validation tool (per D-197) — not integrated into ppm-app
**Depends on:** D-196 (resolution strategy), D-198 (bend extraction), D-199/D-200 (macro, filename convention)

**Scope superseded/expanded (July 2026):** the Estimator's scope has grown well beyond
this standalone tool — see D-227 onward and D-381–D-391 for bending cost, quoting,
admin costs, and the full unified workflow. This document remains accurate for the
original standalone DXF cutting-time/bend-count scope described below.

## What it does
A locally-run GUI tool (drag-drop window) that takes one or more Inventor flat-pattern
DXFs as input and produces, per part: a clean laser-ready DXF (cut geometry only) and
an Excel report row with cut length, pierce count, bend count, and resulting
cutting/bending time and cost — both per-piece and multiplied by quantity, with
quantity live-editable in the report. Resolves material/thickness/quantity from the
best available source (embedded metadata, filename, or an optionally-supplied Inventor
BOM export) with a flagged manual fallback. Designed to be run standalone and compared
against the shop's own laser/CAM software output before any rate is trusted.

## What it does NOT do
- Does not integrate with Supabase/ppm-app — standalone only (D-197)
- Does not require the D-199 macro to function — must work on existing, already-exported
  DXFs with inconsistent/legacy naming, not only future macro-exported files
- Does not parse DWG files — accepts DXF only; DWG files show a clear
  in-app notice directing the user to export as DXF from their CAD tool
  first (D-217)
- Does not hardcode Inventor's IV_* layer names as a fixed contract —
  layer classification is configurable via CAD profile presets (Inventor,
  SolidWorks pre-2022, SolidWorks 2022+, Custom), active profile selected
  in Settings (D-216)
- Does not modify, rename, or move original source DXF files in any way — all generated
  output (clean DXFs, Excel report) goes to a separate destination folder chosen by the user
- Does not attempt to make the Inventor macro assembly/BOM-aware — quantity resolution via
  BOM cross-reference lives entirely in this tool, not in the macro
- Does not compute press-brake bending *time* from bend count — outputs bend *count* only;
  bend-time costing uses the existing (placeholder) OP-008 press-brake norm separately (D-191)
- Does not yet use real CAM/laser-software cut-time data — placeholder rate formula only,
  explicitly editable so it can be run in parallel against real machine output for comparison

## Roles that interact with this feature
| Role | Can do |
|---|---|
| Voja / PM (only user for now) | Run tool, supply DXFs + optional BOM, edit rate constants, review/export report |

(Not role-gated — standalone desktop tool, pre-dates any PPM auth/role model.)

## Layer classification rule (confirmed via real export + Autodesk documentation)
**This rule is superseded by D-216** — layer names are now configurable
via a CAD profile system rather than hardcoded. The values below describe
the built-in **Inventor preset** (the default on first run); SolidWorks
pre-2022, SolidWorks 2022+, and Custom profiles are also built in.
The DXF parser reads layer names from the active profile at runtime.

Inventor preset layer classification:

- **Cut/pierce geometry (kept):** `IV_OUTER_PROFILE`, `IV_INTERIOR_PROFILE` (and
  equivalently-named inner-profile layers as they appear per export config)
- **Bend lines (counted, not cut):** `IV_BEND` (bend up), `IV_BEND_DOWN` (bend down) —
  one bend line entity = one bend; bend count = entity count across both layers
- **Excluded entirely (neither cut nor counted):** `IV_FEATURE_PROFILES` (formed
  features — louvers, ribs — not cut lines), `IV_TANGENT`, `IV_TOOL_CENTER`,
  `IV_ARC_CENTER`, `IV_ALTREP_*`, `IV_UNCONSUMED`, `IV_ROLL`, `IV_ROLL_TANGENT`

Verified against a real export (`testpart.dxf`: 8 LINEs on `IV_OUTER_PROFILE`, 1 on
`IV_BEND`, 3 on `IV_BEND_DOWN`) and cross-checked against Autodesk's documented
`FLAT PATTERN DXF` translator parameters (`BendUpLayer=IV_BEND`,
`InvisibleLayers=IV_ARC_CENTERS;IV_BEND_DOWN;IV_BEND;IV_FEATURE_PROFILES`, etc. —
consistent across Inventor versions and third-party DXF batch-export tools).

**Note:** laser-floor DXFs inspected during this spec session (`C518483`,
`Bottom_Sheet` samples) had no bend-line layer present at all — geometry was
flattened to layer `0` with no `IV_*` separation. This confirms the gap is in
*which export config/step* produced those files, not a limitation of Inventor's
DXF translator. The tool's input contract is the **Inventor-side flat-pattern
export** (`IV_*` layers present), not arbitrary laser-floor DXFs.

## Pierce count definition
One pierce per closed geometric loop on cut/pierce layers, **including the outer
profile** — i.e. total pierces = (number of interior closed loops) + 1.

## Material / Thickness / Quantity resolution (per field, in priority order)

**Material + Thickness:**
1. DXF embedded metadata (present only on macro-exported files, per D-199 — future-dated)
2. Filename parsing against the `PN_MATERIAL_THICKNESSmm_QTYpcs.dxf` convention
   (D-200), tolerant of older/inconsistent real-world variants (confirmed two
   different separator/field-order patterns already exist in current files)
3. Flag as missing in the batch-review screen → manual input

**Quantity:**
1. DXF embedded metadata (macro-exported files)
2. Filename parsing
3. **BOM cross-reference** (optional — only if user supplies an Inventor BOM Excel
   export alongside the DXF batch):
   - **Parts Only (flat) BOM:** direct read of the `QTY` column per matched PN —
     Inventor's flat view already sums quantity across all parent assemblies
     (consistent with D-97/D-120's existing summation logic)
   - **Structured (hierarchical) BOM:** tool walks the Item-number hierarchy
     (`1`, `1.1`, `1.1.1` — same pattern as WF-02's BOM import) and computes
     final per-PN quantity as the product of each ancestor's quantity down the
     tree, summed across all occurrences of that PN in the structure. This is a
     real traversal algorithm, not a groupby — must be scoped as such at build time.
   - PN matching between DXF filename and BOM rows is not assumed to be a clean
     exact match (per OQ-59/68/69 precedent) — unmatched/ambiguous rows are
     flagged, never silently attributed.
4. Flag + default qty=1, visible in batch-review screen
5. Manual input (last resort)

**Both fallback chains converge on one batch-review screen** — not per-file popups.
Anything that resolved automatically (any source) flows through with zero clicks;
only flagged items require attention, presented as one editable table.

## Output behavior
- User selects a destination folder (separate from source folder)
- Per part: one clean re-exported DXF (cut/pierce geometry only, no text, no bend
  lines, no markings, single layer) written to destination folder
- One consolidated Excel report covering the full batch:
  - One row per part: PN, material, thickness, qty, cut length, pierce count,
    bend count
  - Rates & Constants section/sheet: cut speed (mm/min), pierce time (sec/pierce),
    bend time (sec/bend) — editable cells, placeholder defaults clearly marked
    (consistent with D-195's "PLACEHOLDER —" convention)
  - Per-piece cutting time/cost and bend time/cost as formulas referencing the
    rate constants (not hardcoded)
  - Total time/cost columns as formulas multiplying per-piece values by the qty
    cell — changing qty live-recalculates totals
- **Source DXF files are never modified, renamed, or moved** — read-only input

## Acceptance criteria
- [ ] Correctly separates cut geometry from bend lines using the `IV_*` layer rule
      on a real macro-exported (or equivalent) flat-pattern DXF
- [ ] Bend count matches manual count on `testpart.dxf` (4 bend lines: 1 IV_BEND + 3 IV_BEND_DOWN)
- [ ] Pierce count = interior holes + 1, verified against a part with known hole count
- [ ] Handles a batch of 300+ files without manual per-file intervention beyond the
      single batch-review screen for flagged items
- [ ] Filename parsing tolerates at least the two real naming variants already observed
- [ ] BOM cross-reference correctly computes multiplied quantity on a structured
      (hierarchical) BOM with at least 2 levels of nesting
- [ ] BOM cross-reference correctly reads flat quantity on a Parts Only BOM
- [ ] Rate constants are editable and changes propagate through all report formulas
- [ ] Re-exported DXF contains no text, no bend lines, no markings — cut geometry only
- [ ] Original source DXFs and any supplied BOM file are untouched on disk after a run

## Edge cases
- DXF has no `IV_BEND`/`IV_BEND_DOWN` entities at all → bend count = 0, not an error
  (flat parts are valid)
- Filename matches no known pattern and no BOM/metadata available → full flag,
  qty defaults to 1, material/thickness require manual entry
- BOM supplied but PN doesn't match any DXF in the batch → BOM row ignored, no error
  (informational note only)
- BOM supplied but a DXF's PN doesn't match any BOM row → falls through to
  flag/default qty=1, same as no-BOM case
- Structured BOM has a part appearing under multiple distinct parent paths →
  sum across all paths (already the established model, D-97/D-120)
- Two different parts in the batch resolve to the same output filename →
  flagged, never silently overwritten in destination folder

## Data touched
- Reads: source DXF files (read-only), optional BOM Excel export (read-only)
- Writes: new clean DXF files + Excel report to user-chosen destination folder only
- No database, no PPM schema involvement (standalone tool, D-197)

## Failure / Disable Behavior (D-149)
- BOM cross-reference unavailable/not supplied → quantity resolution falls through
  to flag+default+manual; tool remains fully usable without a BOM file
- Embedded metadata absent (pre-macro files, i.e. all current real files) → filename
  parsing is the working baseline; tool must not depend on the macro existing
- Rate constants left at placeholder defaults → report still generates, values
  visibly marked as unvalidated, never silently presented as authoritative

## Known constraints
- Build environment: standalone, in Claude Code (new local project, not inside
  `ppm-app`), per D-197 — never as a Claude.ai/chat-uploaded-files workflow; the
  20-files-per-chat limit is irrelevant since the tool reads a local folder directly
- Cutting-time formula is an explicit placeholder (D-194/D-195 lineage) — designed
  to run in parallel with real machine/CAM output for comparison, not as a trusted
  source of truth in v1
- SolidWorks export support deferred (D-199) — Inventor flat-pattern DXF only for v1
- Settings file architecture: three strictly separate local files —
  settings.json (user config, never touched by updates), presets.json
  (ships with app, replaced on update), telemetry_config.json (opt-in
  flag + anonymous ID only). Required from first build to support the
  Phase 2 telemetry pipeline (D-218) without restructuring.

## Product Strategy & Quotation Scope (D-227 to D-235)

### Tool reframing
The Estimator is a **laser+bending quotation engine** (D-229), not just a geometry
extractor. The geometry pipeline (D-201–D-217) is the calculation engine inside a
quotation workflow. The tool is a PPM gateway product (D-228): one-time purchase
(D-227), designed so company data transfers to PPM in one click when the shop is
ready to scale.

### Job / Customer model
Each estimation session is a **Job record**:
- Customer (from local customer list)
- Quote/Job reference (free-text or auto-generated Q-number)
- Project name (optional)
- Date
- Status: Draft / Sent / Won / Lost
- Margin % (shop markup, default 0%)
- Discount % (customer-facing reduction applied after margin, default 0%)

Cost flow: Raw cost → +Margin % → Selling price → −Discount % → Customer price (D-233)

### Local storage
SQLite file — job history + materials library in same file (D-230). No server
dependency. Future PPM export path: SQLite read → PPM API POST (deferred, OQ-75).

### Materials & Sheet Library (D-237)
Stored in SQLite. Per material record:
- Canonical ID (MAT-001 format), display name, density (g/cm³)
- Default sheet dimensions (width × height, mm)
- Cost per kg + cost per sheet (both stored, last-used mode remembered per material)
- Usage count (auto-incremented), favorite flag
- Alias fields: `inventor_name`, `laser_param_name`, free-text addable

Alias mapping: one-time setup in Settings → Materials Library → External Names.
Unmatched aliases flagged, never silently defaulted (D-237).
Sort order in pickers: favorites first → usage count descending.
Pre-seeded: S235, S355, 304 SS, 5754 Al; standard sheet sizes 3000×1500,
2500×1250, 2000×1000.

### Sheet cost inputs (D-231)
Two modes per material record:
- Cost per kg → computed: density × W × H × T / 1,000,000 × cost_per_kg = cost per sheet
- Cost per sheet → direct input

Default densities: steel 7.85, stainless 7.93, aluminium 2.70 g/cm³ (user-editable).

### Sheet utilization / material ordering (D-232)
User sets nesting efficiency % per material type. Tool outputs per material+thickness:
- Sheets needed (⌈total cut area ÷ (sheet area × efficiency %)⌉)
- Purchase cost (sheets needed × cost per sheet)
- Geometry cost (total cut area × cost per mm²)
- Scrap delta (purchase cost − geometry cost)

Efficiency % displayed prominently as a user estimate, never a computed fact.

### Export outputs (D-234, D-235)
Three outputs per Job:
1. **Clean laser-ready DXFs** — existing scope (D-202)
2. **Internal Excel cost sheet** — existing scope (D-206), extended: adds material
   cost columns (sheets needed, sheet purchase cost, geometry cost, scrap)
3. **Quote PDF** — two document types:
   - *Internal cost sheet*: all rates, times, costs visible
   - *Customer-facing quote*: rates hidden; configurable pages:
     - Page 1 (always): header, quote ref, customer, date, validity, grand total,
       payment terms, signature line
     - Optional: itemized per-PN breakdown (qty + line total, no rates)
     - Optional: summary by category (cutting/bending/material subtotals,
       margin/discount, grand total)
   Page selection at export time; default saveable per customer or globally.

## XDATA Metadata — OQ-74 Resolved (D-236)

testpart.dxf confirmed: Inventor does not natively embed sheet metal material or
thickness in DXF exports ($THICKNESS = 0.0; MATERIAL entries are visual rendering
objects only, not sheet metal properties).

**Resolution:** D-199 macro writes a custom XDATA block, app ID "PPM_ESTIMATOR":
```
1001
PPM_ESTIMATOR
1000
MATERIAL
1000
<Inventor Sheet Metal Style name>
1000
THICKNESS_MM
1040
<thickness as float>
```
This block becomes the top of the material+thickness resolution chain (D-204).
Pre-existing DXFs without this block fall through to filename parsing → flag unchanged.
OQ-74 fully resolved.
