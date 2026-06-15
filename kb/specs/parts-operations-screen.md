# Spec: Parts/Operations Screen — Views, Filters, Search, AI Chips

**Phase:** 3
**Depends on:** phase-1-schema.md (parts, part_operations, ppm_operations, org_operations)

## What it does
The Parts tab's primary screen: Tree (hierarchy) and Flat (deduped) views of a WO's BOM, each part showing its assigned operations with status/blocked/fulfillment, editable inline. Includes Assembly/Parts/All filtering, List/Cards layout choice on larger screens, a top search bar for bulk PN selection/add/delete, and a zero-token chip-based AI command bar.

## What it does NOT do
- Does not replace the AI free-text bar — chips are a fast path alongside it (D-174)
- Does not cascade-delete assemblies (D-173)
- Does not persist "list vs cards" or "assembly/parts/all" as org-level settings — per-session UI state only (confirm if persistence wanted later)

## Roles that interact with this feature
| Role | Can do |
|---|---|
| Owner/Manager/Supervisor | Full access: view, edit ops, filter, search, add/delete parts (D-127 still applies to op add/remove) |
| Worker | Not applicable — Worker UI (/w/) has its own simplified screen, no AI bar (D-90) |
| Viewer | Read-only: views/filters, search, no edits/add/delete |

## Acceptance criteria
- [ ] Tree view: hierarchical, expandable, ops panel always visible on md+, compact "● Op Name" status-light list + tap-to-expand on mobile (D-170)
- [ ] Flat view: deduped by PN (qty summed, D-120), Assembly/Parts/All toggle (D-168), List/Cards toggle on md+ (D-169, default List)
- [ ] Every PN has a visible copy icon (D-171)
- [ ] Search bar accepts pasted multi-PN text, selects matches, flags unmatched with "add as new part" → qty/description prompt (D-172)
- [ ] Parts deletable only when leaf (live-computed); one-tap-then-confirm (D-173)
- [ ] AI bar: progressive PN→op chip resolution, tap-to-cycle/add instantly (zero-token), free-text fallback to API (D-174)
- [ ] Blocked/Flagged/Done stat click and operation-filter both produce the same deduped filtered-results list, no modal (D-167)

## Edge cases
- Pasted PN matches a part currently hidden by Assembly/Parts/All — selection still applies (filter affects display, not selection)
- Deleting the last child of an assembly: assembly's `hasChildren` recomputes false on next render, "Delete" becomes available for it too (D-173) — no special-case code
- AI chip resolution finds both a PN match and an item-number match in the same input — first matching token wins
- Ad-hoc part (added via search) has no `item`/hierarchy — Flat view only, excluded from Tree

## Data touched
- Tables read/written: parts, part_operations, org_operations, ppm_operations
- New ad-hoc parts (D-172) and deletions (D-173) write to `parts`
- RLS: delete permission matches existing part-edit permissions (Owner/Manager/Supervisor per D-127); no new role needed

## Failure / Disable Behavior (D-149)
- AI chip resolution unavailable → existing "+ Add operation" dropdown and status-cycle controls remain (every chip action has a non-chip equivalent)
- Search-bar paste matching nothing → no selection change, unmatched list shown, no error state
- List/Cards and Assembly/Parts/All are pure display filters — defaulting to All/List never hides functionality, only changes layout

## Known constraints
- v2 of this screen (Tree/Flat/Procurement/blocked/export/AI bar core) was built and tested as a Claude.ai artifact (ppm-parts-ops.jsx) — validates D-162/163/165/166/167
- v3 (D-168–174) is unvalidated — prototype in Claude Code with incremental edits rather than a full-artifact rewrite (OQ-55)
- Mobile tap targets ≥44px (implement-component convention) apply to chips and status-lights
