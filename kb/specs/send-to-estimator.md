# Send to Estimator — Feature Spec

**Status:** Specified, not yet built  
**Scope:** PPM Toolbox (iLogic macros)  
**Entry point:** Global Form — new button, last position before Settings  

---

## Overview

One button that chains all export macros sequentially and assembles the
output into a Job Package folder ready for one-step Estimator ingestion.
Sits alongside existing individual macro buttons — does not replace them.

---

## Button placement

Global Form, bottom row, last button before Settings:

```
[ Export Flat Pattern ]  [ Batch Export ]  [ Operations Setup ]
[ Mark Operations ]      [ Export Part Data ]  [ Send to Estimator ]  [ Settings ]
```

Label: **"Send to Estimator"**  
Icon: package/export arrow (distinct from individual export buttons)

---

## Sequence

### Step 1 — Operations warning dialog
Before any export runs, show a non-blocking confirmation dialog:

```
┌─────────────────────────────────────────────────────┐
│  ⚠  Before continuing                               │
│                                                     │
│  Please verify that operations are assigned to      │
│  all parts and assemblies before exporting.         │
│                                                     │
│  [ Check Operations ]    [ Continue ]    [ Cancel ] │
└─────────────────────────────────────────────────────┘
```

- "Check Operations" → opens PPM_OperationsSetup (existing macro), dialog stays open
- "Continue" → proceeds to Step 2
- "Cancel" → aborts, no files written

### Step 2 — Destination picker
Show a small destination dialog:

```
┌─────────────────────────────────────────────────────┐
│  Job Package destination                            │
│                                                     │
│  [  C:\path\to\assembly\parent\folder      ] [...]  │
│                                                     │
│  Package name: JobPackage_[PN]_[YYYYMMDD]           │
│                                                     │
│  [ Export ]    [ Cancel ]                           │
└─────────────────────────────────────────────────────┘
```

- Path field pre-filled with assembly parent folder (default)
- User can paste any path directly into the field
- Browse button `[...]` opens folder picker dialog
- Last-used path remembered per Inventor session (not persisted across sessions)
- Package name is auto-generated, not editable

### Step 3 — Progress UI
Replace destination dialog with a progress panel (same window):

```
  ✓ Creating package folder
  ● Exporting DXF files...        [12 / 27]
  ○ Exporting BOM...
  ○ Exporting Weld Bead Report...
  ○ Writing manifest
```

Non-cancellable once started (consistent with existing batch export behavior).

### Step 4 — Batch DXF export
Calls the same logic as `PPM_BatchExportFlatPatterns`:
- Exports all sheet-metal parts from the assembly
- DXFs written to the **existing dedicated DXF folder** (unchanged, existing behavior)
- DXFs **also copied** into `[PackageRoot]/dxf/` subfolder
- Skips single-part `PPM_ExportFlatPattern` entirely
- Missing material/thickness → flagged in summary, does not block

### Step 5 — Structured BOM export
Calls `PPM_ExportPartData` in Job Package mode:
- Produces **3 sheets only**: PARTS, ASSEMBLIES, BOM_FLAT
- No REPORT sheet (completion percentages not needed by Estimator)
- Output: `[PackageRoot]/bom/StructuredBOM.xlsx`

### Step 6 — Weld Bead Report (SendKeys automation)
Only runs if active document is a weldment assembly (check
`ThisDoc.Document.SubType` or presence of weld features before attempting).
If not a weldment: skip silently, note in manifest as `weld_report: null`.

If weldment:
```vb
' Fire the command
ThisApplication.CommandManager.ControlDefinitions _
    .Item("AssemblyWeldBeadReportCmd").Execute()

' Dialog 1: "Include All Subassemblies" → accept with Enter
System.Threading.Thread.Sleep(800)
System.Windows.Forms.SendKeys.SendWait("{ENTER}")

' Dialog 2: Report Location — send full output path then Save
System.Threading.Thread.Sleep(800)
Dim weldPath As String = PackageRoot & "\weld\WeldBeadReport.xls"
System.Windows.Forms.SendKeys.SendWait(weldPath)
System.Threading.Thread.Sleep(300)
System.Windows.Forms.SendKeys.SendWait("{ENTER}")
```

- SendKeys works here because no other windows are open mid-sequence
- Sleep timings are conservative; adjust if dialogs are slow on Stirg machine
- Output: `[PackageRoot]/weld/WeldBeadReport.xls`

### Step 7 — Write manifest.json
Written last, after all files confirmed present.

```json
{
  "package_version": "1.0",
  "generated": "2026-07-01T10:30:00",
  "toolbox_version": "1.x",
  "assembly": {
    "part_number": "NR01555346",
    "description": "AdBlue Tank Assembly",
    "mass_kg": 85.2,
    "part_count": 27,
    "weldment": true
  },
  "files": {
    "bom": "bom/StructuredBOM.xlsx",
    "dxf_folder": "dxf/",
    "dxf_count": 21,
    "weld_report": "weld/WeldBeadReport.xls"
  },
  "package_complete": true
}
```

If weld report was skipped: `"weld_report": null`  
If any DXFs had missing metadata: `"dxf_warnings": ["PN1", "PN2"]`

### Step 8 — Completion summary dialog

```
┌─────────────────────────────────────────────────────┐
│  ✓  Job Package created                             │
│                                                     │
│  21 DXF files                                       │
│  StructuredBOM.xlsx  (27 parts, 8 assemblies)       │
│  WeldBeadReport.xls  (32 beads)                     │
│                                                     │
│  ⚠  3 parts flagged — missing material/thickness    │
│                                                     │
│  [ Open Folder ]    [ Close ]                       │
└─────────────────────────────────────────────────────┘
```

---

## Job Package folder structure

```
JobPackage_[AssemblyPN]_[YYYYMMDD]/
  manifest.json
  bom/
    StructuredBOM.xlsx
  dxf/
    [PN]_[MAT]_[THK]_[QTY].dxf
    ...
  weld/
    WeldBeadReport.xls
```

Flat folder per output type. No ZIPping — Estimator reads the folder directly.
ZIP manually if sending by email.

---

## Estimator ingestion (future — not built yet)

Estimator "Open Job Package" flow:
1. User points to `JobPackage_xxx` folder
2. Estimator reads `manifest.json` to discover all files
3. Parses `StructuredBOM.xlsx` → parts list with quantities
4. Parses DXF files → cutting/bending time per part
5. Parses `WeldBeadReport.xls` → weld time and consumables
6. Pre-fills all computable fields; user completes manual entries
7. User reviews and generates quote

---

## Error handling

Consistent with D-149 (Graceful Degradation):
- DXF export failure on one part → flag, continue with rest
- BOM export failure → abort sequence, show error (BOM is required)
- Weld report failure → skip, `weld_report: null` in manifest, warn in summary
- Destination folder not writable → show error before starting
- `manifest.json` written last — if missing or `package_complete: false`,
  Estimator treats the package as incomplete and warns user

---

## Implementation notes

- New macro file: `PPM_SendToEstimator.iLogicVb`
- Calls existing macro logic via shared subroutines (not duplicate code)
- `PPM_ExportPartData` needs a `JobPackageMode As Boolean` parameter
  that suppresses the REPORT sheet — no other behavior change
- Global Form button wired to this macro
- SendKeys approach confirmed viable (OQ-87): no competing windows
  in sequential execution context
