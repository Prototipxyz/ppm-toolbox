# WORKFLOWS

## WF-01: Quote → Work Order
```
Inquiry → PM creates Quote (Q-26-NNN) → Drive folder created
  → Quote built (operations + materials + subs + margins) → PDF SR/EN sent
  Win: → WO-26-NNN (same number) → folder renamed → BOM imported → production
  Lose: → status=Lost/Expired → archived to Clients/Lost Quotes/
```

## WF-02: BOM Import from Inventor
```
Inventor: open assembly → BOM dialog → Structured tab → Export Excel (.xlsx) with thumbnails
Script processes:
  1. Parse Item column (1, 1.1, 1.1.1) → parent_id hierarchy
  2. Extract embedded thumbnails → Supabase Storage → photo_url
  3. Decimal comma → decimal point in Mass column
  4. Strip whitespace, generate display_name (underscore logic)
  5. Auto-assign C570001+ to empty part_number rows
  6. DELETE existing flat parts for WO → INSERT structured parts
```

## WF-03: Part Status Update (3 paths)
```
A. Manual: tap card → expand → tap operation → cycles Not Started→In Progress→Done
B. Multi-select (zero tokens): Select → checkboxes → tap chip → direct DB UPDATE
   Smart: only updates parts where op ≠ Done (skips already done)
C. AI: type command → AI parses → SQL UPDATE → confirms
```

## WF-04: Worker Hours (Factory Floor)
```
Open app → see today's tasks → tap ▶ Start (timer begins)
  Interrupted → Pause → select reason:
    Break/Lunch | Waiting for material | Machine issue | Jumping to other job | Other+note
  Resume → tap Done → actual_hours calculated (excludes Break time)
  → appears in supervisor approval queue
Supervisor: reviews team logs → flags variances → Approved/Queried/Adjusted
```

## WF-05: Knowledge Worker Hours (End-of-Day)
```
Tap ✦ AI bar → type: "3h CAD on WO-26-001, 1.5h Q-26-004 quote, 1h shop floor"
→ AI parses → shows structured entries for confirmation → user confirms → logged
Rule: only log WOs where >20 min spent
```

## WF-06: Quality Issue
```
Worker: tap part → expand → Flag Issue → optional photo + note → submit
→ issue logged (timestamp, worker, photo, note)
Supervisor decision: Rework | Revision | Accept within tolerance
Rework: new hours_log entry, log_type=Rework, cost absorbed (risk margin covers it)
```

## WF-07: Financials
```
Quote approved → total fixed (never changes)
During job → hours + procurement → actual costs accumulate
Financials tab: Quoted | Actual | Billed → Profit = Billed − Actual
Rework shows as separate absorbed line
```

## WF-08: Export
```
Apply filters → tap Export → select format (CSV/Excel/PDF SR/EN)
Engine: reads org branding → applies logo/colors/font → generates file
```

## WF-09: Rework / Revision / Recall
```
Rework: operation done wrong → new hours_log (log_type=Rework) → absorbed
Revision: customer changes drawing → new part revision (parent_id links) → change order
Recall: delivered part returned → procurement-like item + rework log (log_type=Recall)
```
