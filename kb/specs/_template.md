# Spec Template

Copy this file, rename it `<feature-name>.md`, fill in all sections before handing to Claude Code.

---

## Feature: [name]

**Phase:** [1 / 2 / 3]
**Depends on:** [list specs that must be complete first]

## What it does
[1–3 sentences. Plain language. What the user experiences.]

## What it does NOT do
[Explicit exclusions. What a developer might assume is included but isn't.]

## Roles that interact with this feature
| Role | Can do |
|---|---|
| Owner | |
| Manager | |
| Supervisor | |
| Worker | |
| Viewer | |

## Acceptance criteria
- [ ] [Specific, testable condition 1]
- [ ] [Specific, testable condition 2]
- [ ] [Specific, testable condition 3]

## Edge cases
- [What happens if X is empty]
- [What happens if Y fails]
- [What happens if user has no permission]

## Data touched
- Tables read: [list]
- Tables written: [list]
- RLS considerations: [anything non-standard]

## Failure / Disable Behavior (D-149)
- [What happens if this feature is turned OFF for an org?]
- [What happens if the automated/AI part of this feature FAILS at runtime?]
- [What is the manual fallback that keeps core workflows (status, hours, quotes, invoices) working?]

## Known constraints
- [Performance: e.g. "BOM can have 365+ parts — list must not block UI"]
- [Security: e.g. "Quoted total must not change after Approved status"]
- [UX: e.g. "Destructive action requires two-step confirmation"]
