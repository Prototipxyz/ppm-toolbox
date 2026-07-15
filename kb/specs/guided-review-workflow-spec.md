# PPM Guided Review Workflow — Specification (Draft v1)

## 1. Purpose

Replace today's manual "open every part one by one" workflow with a chained
pipeline: feature-recognition diagnostics → triage queue → interactive human
review → Mark Operations write-back → ready for Send to Estimator / BOM / DXF
export.

## 2. Core principle

**Feature recognition proposes. Human review + Mark Operations disposes.**
Diagnostic macros (`PPM_TestFeatureExtraction` and its eventual production
counterpart) stay permanently read-only — they never write to a part.
Mark Operations, run through this guided review, is the *only* step that
writes final, authoritative values. This is not new behavior being invented
for this spec — it's what the diagnostic already does today; this workflow
just gives its output somewhere structured to land.

## 3. Scope

**In scope:** every part and subassembly referenced by a top-level assembly.
**Out of scope (v1):** this workflow does not itself compute costing (that's
the Estimator's job) and does not replace running any individual macro by
hand — see §6.

## 4. State model

### 4.1 Permanent record — iProperties (on each part/subassembly document)

New custom iProperty set, namespaced `PPM_*`:

| Property | Values | Notes |
|---|---|---|
| `PPM_ReviewStatus` | `Pending` \| `Confirmed` \| `NeedsInput` | drives the queue |
| `PPM_PartTypeFinal` | `sheet_metal` \| `machined` \| `tube_pipe` \| `purchased` | human-confirmed; may equal or override the diagnostic's guess |
| `PPM_PartTypeSource` | `Diagnostic` \| `UserOverride` | audit trail |
| `PPM_SubassemblyTreatment` | `PurchasedUnit` \| `WalkChildren` \| N/A | subassemblies only — see §5 Phase 2 |
| `PPM_ReviewedDate` | date | |
| `PPM_ReviewNotes` | free text | optional |

**Why iProperties, not a database, for the permanent record:** they travel
with the file, are visible to anyone who opens the part outside this
workflow, and survive total loss of any session/cache file. This is the
robustness property that matters most: the CAD files are always the ground
truth.

### 4.2 Disposable cache — session file (SQLite)

One file per top-assembly review session (e.g.
`<AssemblyName>_review_session.sqlite`, stored alongside the assembly).

Single table: `queue(PN, doc_path, tier, status, last_touched)`.

**Purpose:** fast resume without rescanning every file in a large assembly.
**Explicitly not authoritative** — if this file is lost or corrupted, nothing
is lost. Worst case, the queue is rebuilt by rescanning `PPM_ReviewStatus`
across the assembly. Slower, never wrong.

This split is deliberate: the session file and iProperties never hold the
same fact twice. iProperties own *decisions*; the session file owns *queue
position*, nothing else. Two places holding the same fact is exactly the
condition that produces "session says done, write failed, nobody notices"
bugs — this design structurally avoids that class of bug rather than relying
on discipline to avoid it.

## 5. Workflow

**Phase 0 — Trigger.** User runs the orchestrator macro after parts are
modeled/converted from STEP and assembled.

**Phase 1 — Diagnostic pass** (existing, read-only). Run the feature
extraction diagnostic across every referenced document. No writes.

**Phase 2 — Build the unique-PN queue.**
- Walk the assembly tree, collect every unique Part Number — dedup by
  Sachnummer, not file path (a PN can appear at multiple positions).
- For each subassembly node: if it already carries
  `PPM_SubassemblyTreatment = PurchasedUnit` from a prior session, **skip its
  children entirely** — do not enumerate them, do not add them to the queue.
  If untreated, add the subassembly itself to the queue with a pending
  treatment decision (see Phase 3).
- Assign each item a triage tier:
  - **Tier 1 (blocking):** `MATERIAL_NOT_SET` or equivalent missing-data flags
  - **Tier 2 (judgment):** `REVIEW_MAYBE_PURCHASED_HARDWARE`,
    `STOCK_MATCH_CLOSE_REVIEW`, `DISC_SHAPED_LOW_CONFIDENCE_TURNING`,
    `CONFIRM_TURNING_OPERATION`, undecided subassembly treatment
  - **Tier 3 (clean):** no flags, high-confidence match
- Sort queue Tier 1 → Tier 2 → Tier 3.

**Phase 3 — Interactive review loop.** For each queue item in order:
- Show PN, recognized features, the diagnostic's proposed classification, and
  every warning it raised.
- **Subassembly with no treatment decision yet:** ask *"Purchased unit
  (exclude children) or walk into children?"* before anything else. If
  Purchased Unit is chosen, write `PPM_SubassemblyTreatment = PurchasedUnit`
  immediately — this takes effect for the rest of *this* session too, not
  just future ones.
- User can accept as-is, override Part_Type / material / other fields, add
  notes.
- **Mark Done** writes `PPM_ReviewStatus = Confirmed` + final values, advances
  to the next item.
- **Pause** exits the loop; the session file retains position; relaunching
  resumes at the first non-Confirmed item.
- Tier 3 items are eligible for bulk-accept without opening each one
  individually — still individually reviewable if the user wants to check.

**Phase 4 — Handoff.** Once every item is Confirmed, the assembly is ready
for batch Mark Operations and downstream BOM/DXF export/Send to Estimator.

## 6. Cross-cutting requirement: PurchasedUnit exclusion

**Any macro that walks the assembly tree for BOM, DXF export, or costing
purposes must check `PPM_SubassemblyTreatment` and skip children of any
subassembly marked `PurchasedUnit`.** This is a hard requirement, not an
optimization — without it, a purchased sub-assembly's internal parts leak
into BOMs and DXF exports and clutter project management with irrelevant
bits, which is the exact problem this flag exists to prevent.

Known macros that need this check added: `PPM_ExportPartData`,
`PPM_BatchExportFlatPatterns`, and the eventual Send to Estimator chain.
This list should be re-verified against the actual macro suite before
implementation — treat it as a starting point, not confirmed complete.

## 7. Independent operations preserved (D-149)

This orchestrator is a convenience wrapper, not a replacement. Every macro it
chains together — diagnostic, Mark Operations, individual exports — remains
independently runnable exactly as it is today. Nothing about this workflow
removes the ability to run one macro on one part by hand.

## 8. Open questions (pending OQ numbers)

- Exact iLogic mechanism for reading/writing custom iProperties reliably —
  needs empirical verification against real Inventor API docs/forum samples,
  per project convention (no assumed API members).
- SQLite access from iLogic — same empirical-verification requirement: does
  Inventor's iLogic environment provide a usable SQLite driver out of the
  box, or does this need an external DLL reference (same category of
  question as the Newtonsoft.Json dependency already resolved for the
  diagnostic)?
- Exact review-form UI layout — fields, buttons, first-pass mockup vs.
  iteration.
- Whether Tier 3 bulk-accept is a per-session opt-in or a persistent
  preference.
- How re-running the diagnostic on an already-`Confirmed` part should
  behave — silently re-flag, require re-confirmation, or leave alone unless
  the geometry actually changed since confirmation.
- Confirm the full list of macros affected by §6 against the real current
  macro suite.

## 9. Dependencies

- `PPM_TestFeatureExtraction` (or its production successor) — diagnostic
  engine, must stay read-only.
- `PPM_MarkOperations` — existing, becomes the final write step.
- Warehouse `stock_reference` JSON export — already in place, used by the
  diagnostic's gate (c).

## 10. Explicitly not changed by this spec

- No changes to the Warehouse workbook, export script, or existing
  diagnostic logic beyond what's already validated.
- No new classification logic — this spec is about *what happens to* the
  diagnostic's output, not about improving the diagnostic itself.
