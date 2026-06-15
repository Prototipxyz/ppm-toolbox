# Spec: Procurement Lead-Time, Alerts & Consignment Notes

**Phase:** 3
**Depends on:** phase-1-schema.md (procurement table), D-123 (fulfillment_type auto-gen)

## What it does
Extends the existing Procurement tab: every outsourced operation-instance (D-163) gets a procurement record with status, lead time, and sent/expected/received dates. Computes a last-safe-order-date from the WO delivery deadline minus lead time minus an admin buffer, and shows a traffic-light alert (green/blue/amber/red) per item. A "Consignment note" export covers any operation-filtered set of parts for handoff to a subcontractor.

## What it does NOT do
- Does not manage raw material inventory (Business Central handles this, D-135)
- Does not auto-place orders or integrate with supplier systems — all fields manually entered
- Does not change Financials cost roll-up (Phase 7) — operational/status tracking only

## Roles that interact with this feature
| Role | Can do |
|---|---|
| Owner/Manager | Full: edit status/dates/lead-time, export consignment notes |
| Supervisor | View + edit status/dates (operational, not financial) |
| Worker | No access (Procurement tab not in Worker UI) |
| Viewer | Read-only |

## Acceptance criteria
- [ ] Every op-instance with fulfillment=outsourced (D-163) appears in Procurement
- [ ] Fields: status (Not Ordered/Ordered/In Transit/Arrived/Unavailable-find replacement), lead_time_days, sent_date, expected_return_date, actual_return_date
- [ ] last_order_date = WO.deadline − lead_time_days − admin_buffer_days (default 3)
- [ ] Alert tiers: green "Received {date}" / blue "Expected {date} ({n}d)" / amber "Order soon — by {last_order_date} ({n}d)" (bold if ≤2d) / red "OVERDUE TO ORDER" / "At risk — expected after deadline" / "Unavailable — find replacement"
- [ ] Consignment note export: Items, PN, Name, Qty, Operation, Status, Sent/Expected/Received dates, for the current operation-filtered set (D-166)

## Edge cases
- lead_time_days = 0 → last_order_date = deadline − buffer only; alert still computes
- expected_return_date in the past with no actual_return_date → shown as "Expected" but red (overdue), not silently green
- status manually set to "Unavailable - find replacement" → red alert regardless of dates
- Multiple op-instances on the same PN (different operations) get independent procurement records, keyed by pn+op

## Data touched
- Tables read/written: procurement, part_operations (read fulfillment), work_orders (read deadline)
- RLS: same as existing procurement table policies (Phase 1)

## Failure / Disable Behavior (D-149)
- WO.deadline unset → last_order_date can't compute; show lead-time/status fields only, no alert badge (never blocks editing)
- Consignment export unavailable with no operation filter active — button disabled (not hidden), tooltip explains why

## Known constraints
- Validated via ppm-parts-ops.jsx mockup (D-164/166) with 3 seeded cases covering all alert tiers — logic confirmed, UI placement (cards vs. list, D-169) not yet validated
- Admin buffer is a flat constant (3 days) in the mockup — confirm whether org-configurable before Phase 3 build
