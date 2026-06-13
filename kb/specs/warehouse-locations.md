# Spec: Warehouse Location Tracking

**Phase:** Post-pilot (Phase N+1 relative to core build)
**Depends on:** Phase 1 schema, Worker UI (Phase 5), Parts pipeline (Phase 3)

## What it does
Allows an org to define physical storage locations (pallets or shelf bins), generate
QR-coded printable labels, and track where fabricated parts are stored between operations.
Workers drop off parts by scanning or typing a location after completing an operation.
The next worker sees the location before starting their operation. Tapping Start clears
the location and begins the timer simultaneously.

## What it does NOT do
- Does not track raw material inventory (sheet metal, fasteners) — handled by Business Central (D-135)
- Does not block work if location is skipped — warning flag only (D-138)
- Does not require dedicated storage per WO — parts go to any available space
- Does not integrate with Business Central at this stage
- Does not assign fixed locations per part number — any available space is valid

## Roles that interact with this feature
| Role | Can do |
|---|---|
| Owner | Same as Manager |
| Manager | Configure storage locations, resolve flags, print QR labels |
| Supervisor | Resolve location flags, view part locations across all WOs |
| Worker | Drop-off scan after operation, see pick-up location before starting |
| Viewer | Read-only location visibility |

## Storage location setup
- Manager configures: type (Pallet / Shelf Bin), zone label, rows per zone, positions per row
- App generates codes: Zone-Row-Position → A-02-04 (3-part, D-132)
- QR PDF generated per location, label dimensions configurable (OQ-48)
- Fallback: worker types location ID if camera unavailable (D-133)
- Locations can be marked inactive without deleting history

## Core drop-off / pick-up flow
1. Worker completes operation → taps Done → prompted for drop-off location + quantity
2. Scans QR or types location ID → "8 of 12 at A-02-04" saved to part location record
3. Skip allowed → PN flagged, Supervisor notified (D-138)
4. Next worker sees "Parts at A-02-04 — 8 pcs" on their task card before starting
5. Taps Start → location cleared, timer begins atomically (D-137)
6. If previous worker skipped → next worker's Start tap shows soft prompt: "Confirm where you found them" → ratifies the flag (D-142)
7. Location persists through N/A operations silently (D-140)

## Batch operations (D-141)
- Worker selects multiple PNs (same or different WOs) → assigns to one location in single scan
- Quantity entered per PN individually after scan
- Natural use case: laser operator cuts parts from same material sheet across multiple WOs

## Partial completion (D-139)
- Location record stores quantity + location: "8 of 12 at A-02-04"
- Start tap by next operator decrements quantity or clears if all taken
- Remaining quantity stays visible at location for subsequent pick-ups
- UI treatment for "8 cut / 4 not started" TBD (OQ-47)

## Flag resolution
- Skip on drop-off → warning flag on PN, visible to Supervisor
- Supervisor can manually enter location after asking worker
- Next operator's Start tap can ratify by confirming found location
- Flag never blocks subsequent operations (D-138)
- Flag auto-clears when location is confirmed by any means

## Acceptance criteria
- [ ] Manager can configure storage locations (type, zone, row count, position count)
- [ ] App generates sequential 3-part location codes (Zone-Row-Position)
- [ ] QR PDF generated per location, label dimensions configurable
- [ ] Worker can drop off with QR scan or manual ID entry
- [ ] Worker can batch-assign multiple PNs to one location in single scan
- [ ] Quantity at location tracked correctly on partial completion
- [ ] Start tap clears location and starts timer atomically
- [ ] Skip creates flag visible to Supervisor, never blocks work
- [ ] Next operator sees location and quantity on task card before starting
- [ ] N/A operations carry location forward silently
- [ ] Next operator Start tap ratifies skip flag via soft "where did you find them" prompt
- [ ] Locations can be deactivated without losing history

## Data model additions

**storage_locations**
```
id, organization_id, code (A-02-04), type (pallet/shelf_bin),
zone, row, position, is_active, notes
UNIQUE (organization_id, code)
```

**part_locations**
```
id, organization_id, part_id, work_order_id, location_id,
quantity, stored_by (user_id), stored_at (timestamp),
cleared_by (user_id), cleared_at (timestamp),
skip_flagged (bool), flag_resolved_by (user_id), flag_resolved_at (timestamp)
```

## Edge cases
- QR damaged / camera broken → manual ID entry always available
- All locations full → no hard block; worker adds free-text note on drop-off
- Part spans multiple locations (split batch) → one part_locations row per location
- N/A operations in sequence → location carries through silently, no prompt
- Worker taps Start with "location unknown" flag → soft prompt to confirm found location, skippable
- Worker stores parts before any operation is complete (e.g. pre-staged) → Supervisor can manually assign location

## Known constraints
- Feature is optional per org — zero UI impact on orgs that don't enable it
- Stirg physical layout must be confirmed before generating location codes (OQ-46)
- Label dimensions needed before PDF generator build (OQ-48)
- Not required for Stirg pilot — implement after core workflow is stable
- Decisions: D-131 through D-142
