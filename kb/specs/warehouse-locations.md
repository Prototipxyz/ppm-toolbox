# Spec: Warehouse Location Tracking

**Phase:** Post-pilot (Phase N+1 relative to core build)
**Depends on:** Phase 1 schema, Worker UI (Phase 5), Parts pipeline (Phase 3)

## What it does
Allows an org to optionally define physical storage locations, generate QR-coded
printable labels, and track where fabricated parts are stored between operations.
Workers drop off parts by scanning or typing a location after completing an operation.
The next worker sees the location before starting. Tapping Start clears the location
and begins the timer simultaneously.

The feature is entirely optional and has three tiers — orgs adopt as much structure
as their physical space warrants (D-143).

## What it does NOT do
- Does not track raw material inventory (sheet metal, fasteners) — handled by Business Central (D-135)
- Does not block work if location is skipped — warning flag only (D-138)
- Does not require dedicated storage per WO — parts go to any available space
- Does not assign fixed locations per part number — any part can go anywhere
- Does not integrate with Business Central at this stage
- Does not enforce functional zones — locations map to physical structures only

## Roles that interact with this feature
| Role | Can do |
|---|---|
| Owner | Same as Manager |
| Manager | Enable feature, configure locations, resolve flags, print QR labels |
| Supervisor | Resolve location flags, view part locations across all WOs |
| Worker | Drop-off scan after operation, see pick-up location before starting |
| Viewer | Read-only location visibility |

---

## Three-tier model (D-143)

### Tier 1 — Disabled (default)
Warehouse module not enabled. Zero UI anywhere in the app. No location prompts,
no storage setup, nothing. This is the default for all orgs.

### Tier 2 — Simple mode
Manager creates a flat list of named locations manually. No enforced structure.
Names are free text: "Big rack", "Small shelf", "Floor pallet 1", "Near the door."
App generates a QR code and printable label per location.
Location codes are short auto-incremented: LOC-001, LOC-002, etc.
Good for small shops (like Stirg) where parts go wherever there is space.
Upgrade to Tier 3 is possible at any time — existing locations are preserved.

### Tier 3 — Structured mode
Manager defines physical structures: permanent fixtures (rack, shelf unit, floor area)
that don't move. Each structure gets a zone letter. Manager sets row count and
position count per zone. App generates 3-part codes: Zone-Row-Position → A-02-04.
Zones map to physical objects ("A = rack near entrance"), not functions ("A = welding staging").
Any part can go to any location regardless of zone.
Good for larger shops with defined racking systems.

**Label PDF defaults (OQ-48 resolved):**
- Tier 2: 100×50mm (fits Brother/Zebra label printers)
- Tier 3: 100×50mm per bin position; 148×105mm (A6) for pallet-level labels
- Both tiers: custom width/height input available

---

## Storage location setup (Tier 2)
- Manager taps "+ Add location" → enters name → app generates LOC-NNN code + QR
- Print label: select size → PDF download
- Locations can be marked inactive without losing history

## Storage location setup (Tier 3)
- Manager defines zones: letter + physical description ("A — rack near entrance")
- Sets rows per zone and positions per row
- App bulk-generates all location codes + QR PDFs in one action
- Individual locations can be deactivated without losing history

---

## Core drop-off / pick-up flow
1. Worker completes operation → taps Done → prompted for drop-off location + quantity
2. Scans QR or types location code → "8 of 12 at A-02-04" saved to part location record
3. Skip allowed → PN flagged, Supervisor notified (D-138)
4. Next worker sees "Parts at A-02-04 — 8 pcs" on their task card before starting
5. Taps Start → location cleared, timer begins atomically (D-137)
6. If previous worker skipped → next worker's Start tap shows soft prompt:
   "Where did you find these parts?" → ratifies the flag on confirmation (D-142)
7. Location persists through N/A operations silently (D-140)

## Batch operations (D-141)
- Worker selects multiple PNs (same or different WOs) → assigns to one location in single scan
- Quantity entered per PN individually after scan
- Natural use case: laser operator cuts parts from same sheet across multiple WOs

## Partial completion (D-139)
- Location record stores: quantity + location ("8 of 12 at A-02-04")
- Start tap by next operator decrements quantity or clears if all taken
- Remaining quantity stays visible at location for subsequent pick-ups
- UI treatment for split quantities TBD (OQ-47)

## Flag resolution
- Skip on drop-off → warning flag on PN, visible to Supervisor
- Supervisor can manually enter location after asking worker
- Next operator's Start tap ratifies by confirming found location
- Flag never blocks work (D-138)
- Flag auto-clears when location confirmed by any means

---

## Acceptance criteria
- [ ] Warehouse module disabled by default — zero UI impact when off
- [ ] Manager can enable Tier 2 or Tier 3 independently
- [ ] Tier 2: Manager creates flat named locations, app generates LOC-NNN + QR
- [ ] Tier 3: Manager defines zones/rows/positions, app bulk-generates codes + QR PDFs
- [ ] QR PDF generated per location, two size defaults + custom dimensions
- [ ] Worker can drop off with QR scan or manual code entry
- [ ] Worker can batch-assign multiple PNs to one location in single scan
- [ ] Quantity at location tracked correctly on partial completion
- [ ] Start tap clears location and starts timer atomically
- [ ] Skip creates warning flag visible to Supervisor, never blocks work
- [ ] Next operator sees location and quantity on task card before starting
- [ ] N/A operations carry location forward silently
- [ ] Next operator Start tap ratifies skip flag via soft location prompt
- [ ] Locations can be deactivated without losing history
- [ ] Tier 2 orgs can upgrade to Tier 3 without losing existing location data

---

## Data model additions

**storage_locations**
```
id, organization_id, tier (simple/structured),
code (LOC-001 or A-02-04), name (free text, Tier 2),
zone (Tier 3), row (Tier 3), position (Tier 3),
type (pallet/shelf_bin), is_active, notes
UNIQUE (organization_id, code)
```

**part_locations**
```
id, organization_id, part_id, work_order_id, location_id,
quantity, stored_by (user_id), stored_at (timestamp),
cleared_by (user_id), cleared_at (timestamp),
skip_flagged (bool), flag_resolved_by (user_id), flag_resolved_at (timestamp)
```

**organizations table addition:**
```
warehouse_tier (none/simple/structured) — default 'none'
```

---

## Edge cases
- QR damaged / camera broken → manual code entry always available
- All locations full → no hard block; worker adds free-text note on drop-off
- Part spans multiple locations (split batch) → one part_locations row per location
- N/A operations in sequence → location carries through silently, no prompt
- Worker taps Start with "location unknown" flag → soft prompt, skippable
- Tier 2 → Tier 3 upgrade: existing LOC-NNN locations preserved, new structured locations added alongside
- Worker stores parts before any operation logged → Supervisor can manually assign location

## Known constraints
- Feature is optional — Tier 1 (disabled) is default for all orgs
- Stirg likely starts at Tier 2 — confirm before implementation (OQ-46)
- Label dimensions resolved: 100×50mm default with custom input option (OQ-48 resolved)
- Not required for Stirg pilot — implement after core workflow is stable
- Decisions: D-131 through D-143
