# OPEN QUESTIONS & UNCERTAINTIES

## All Resolved

| # | Resolution |
|---|---|
| OQ-01 | Worker login: PIN code on personal phones |
| OQ-02 | Workers stay logged in — personal phones, not shared devices |
| OQ-04/05/06 | Organizations / Members / Clients model (D-70) |
| OQ-07 | Part revision letters: A, B, C (D-82) |
| OQ-09 | `stirg_operations` table: skip for now, upload later. Companies fill it out themselves (D-85). |
| OQ-10 | Inventor BOM: skip for now, upload later |
| OQ-11 | N/A operations hidden (D-75) |
| OQ-13 | App UI: same design for all orgs, light/dark toggle only. Company name in header. Logo/fonts/colors for documents only (D-79/D-80) |
| OQ-15/18 | Clients tab: local DB, Attio stays standalone |
| OQ-16 | No custom domain needed |
| OQ-17 | Push notification triggers: define later (Phase 3) |
| OQ-19 | Google Drive folder auto-creation: skip, manual for now (D-83) |
| OQ-20 | Make keep-alive ping: ✅ Running every 3 days, confirmed working |
| OQ-21 | Pausal.rs integration: skip for now |
| OQ-22 | App working title: PPM |
| OQ-23 | Stirg meeting: postponed |
| OQ-26 | Work laptop has Tailscale |
| OQ-27 | GitHub account: Prototipxyz ✅ — ppm-toolbox repo created |
| OQ-28 | Vercel active, hosts prototip.xyz. PPM deploys to ppm.prototip.xyz, new domain later. |
| OQ-29 | Sentry: install at ppm-app repo creation |
| OQ-30 | Groq API: ✅ account created, model: llama-3.3-70b-versatile |
| OQ-36 | Build approach: from scratch with Claude Code (D-99) |
| OQ-37 | Cursor: deferred (D-100) |
| OQ-38 | agent-skills: HTTPS install first, SSH when configured (D-101) |
| OQ-39 | App repo: ppm-app, monorepo (D-102) |
| OQ-40 | Deployment: ppm.prototip.xyz subdomain (D-103) |
| OQ-41 | Sub-folder CLAUDE.md: generate as each module is reached (D-104) |
| OQ-42 | Skills: write all 5 before coding (D-105) |
| OQ-43 | Spec location: kb/specs/ in ppm-toolbox (D-106) |
| OQ-44 | Build sequence: schema first, then auth (D-107) |
| OQ-45 | Worker PIN auth: Option C — email once, PIN daily, bcrypt on members table (D-108) |
| U-01 | Resolved by Organizations/Members/Clients model |
| U-02 | work_orders.context field: REMOVED (D-86) |
| U-03 | Branding seeded against wrong entity — addressed in migration 20260614000006_seed_orgs_and_members (Phase 1 Session 1 prerequisite) |
| U-04 | Ivan Advokat re-link: addressed in migration 20260614000006 — moves from `_legacy_clients` to `public.clients` under Prototip org |
| U-05 | stirg_operations: each org fills out own rates (D-85) |
| U-06 | Part hierarchy: update once BOM is uploaded |
| U-07 | C312029_Gummipuffer underscore display: acceptable |
| U-08 | Solo org onboarding: design later |
| U-09 | Revision letter field: add revision TEXT to parts table (D-82) |
| U-10 | Photo reuse: part_reference_photos table (D-84) |
| U-11 | Completion photo per operation: defer |
| U-12 | Supervisor sees all workers (D-73) |

## Still Open

| # | Question | Priority |
|---|---|---|
| OQ-24 | Stirg subscription pricing | Before pilot |
| OQ-25 | Stirg account ownership | Before pilot |
| OQ-33 | First real screen after schema + auth — decide when Phase 2 begins | Phase 2 |
| OQ-34 | Node.js 18+ installation on work laptop — required before Claude Code install | Immediate |
| OQ-35 | SSH keys: generate on laptop + add to GitHub — required before first git clone | Immediate |
| OQ-50 | ~~Members backfill — manual step after Voja's first Supabase Auth sign-up.~~ RESOLVED 2026-06-18 — Voja signed up via Supabase Dashboard (voja.g.95@gmail.com, UID `fbe7ab25-11e7-40cd-a0a0-8442ebaf1c5e`, created 2026-06-17). Verified via direct query: `members` has 2 rows, both role=Owner/is_active=true, one per org (STIRG, PROTO); `users` mirror row present. | Resolved |
| OQ-56 | Visual identity exploration starting point: logo-first (brand seed informs screen design) or app-screen-first (parts tracker direction, logo follows)? Not yet decided. | Design exploration |
| OQ-57 | Plain-language change-summary step for /review — proposed addition to help non-developer (PM/engineer background) sign off on RLS/financial changes without reading code. Not yet formalized into kb-patch or a new skill. | Process improvement |
| OQ-58 | ~~Phase 1 completion status uncertain as of 2026-06-16.~~ RESOLVED 2026-06-18 — direct Supabase verification (`list_tables` + row counts) confirms `work_orders`, `quotes`, `quote_lines`, `parts` (365 rows), `procurement`, `stirg_operations`, `stirg_hours_log`, `activity_types`, `hours_log`, `invoices`, `transactions`, `equipment`, `sequences` all exist with data — further along than decisions.md's logged evidence suggested. Genuinely still missing: `ppm_operations`, `org_operations`, `part_operations`, `operation_usage_log`, `part_reference_photos`, `hour_log_approvals`. RLS: 5/20 tables enabled (`organizations`, `organization_branding`, `users`, `members`, `clients`); other 15 confirmed still disabled, exposed to anon/authenticated roles. Follow-on items this surfaced: OQ-65, OQ-66. | Resolved |
| OQ-59 | GST BOM fixture (first source done in the BOM analysis pipeline, D-180) surfaced four conflicts with documented assumptions: (1) raw Inventor Item-hierarchy depth reaches 7 levels vs. documented 3-level model (D-96); (2) part numbers in one BOM file mix 4 different formats (Inventor dot-path, bare numeric, one assembly using a distinct zone-style code, empty); (3) GST's actual operation/status columns don't match the architecture.md 9-segment pipeline (separate laser-cut/cut-to-length, 3-stage powder-coat dates, no In Progress state at source); (4) Offer_GST.xlsx has 93 full supplier records with no corresponding schema table. Hold all four for the cross-analysis chat once Stadler/Siemens/Supplier 4 are also done — do not resolve individually per-source. | Cross-analysis phase |
| OQ-60 | `kb-storage-upload` Edge Function kept live in production after this session. Anon key becomes effectively public once the app ships to real users, so a standing write-capable function is a real (low-severity: no read/list/delete, no PII exposure) surface. Harden (rate limit, stricter path-prefix enforcement) or tear down -- decide before public launch. | Before public launch |
| OQ-61 | Two trivial test files (`_test/ping.txt`, `_test/x.txt`) left in `kb-private-fixtures` from smoke-testing `kb-storage-upload`. Function has no delete capability by design. Cleanup via Supabase Dashboard, or add a scoped delete-by-prefix endpoint later. | Low priority |
| OQ-62 | Stadler BOM fixture (second source done, D-180) surfaced findings to hold for cross-analysis alongside OQ-59: (1) Stadler's own Pos.Nr (printed Stueckliste + drawing balloons, verified against the 80201-00 drawing -- 100% coverage, zero gaps on both the 1-47 part range and 81-93 weld range) has zero relationship to the Inventor xlsx Item hierarchy (88 shared part numbers cross-checked, 86 mismatches); (2) Pos.Nr is scoped to (parent_assembly, position), not to the part -- same Sachnummer can have a different Pos.Nr in different parent Stueckliste documents, so it cannot be a field on a global part record; (3) welds are flat BOM line items with linear-meter qty (EN 15085-3 / ISO 14343), a third distinct operations-modeling convention alongside GST's status columns and architecture.md's 9-segment pipeline; (4) insulation sub-assemblies use a fourth numbering convention -- locally sequential labels with no relation to the drawing-number system; (5) two source-data anomalies found and preserved as-is (one Werkstoff-norm typo, one document written in English against the de/hu convention); (6) CONFIRMED (79000 SWC analyzed 2026-06-18, see kb/test-fixtures/79000_structured.json) -- reuse is two-directional, not SWC-to-UWC only: 79101-09/-10/-21/-24 are natively defined in 79101-00 (SWC fresh-water shell) and reused in both 79201-00 (sibling SWC shell) and 80201-00 (UWC shell, matching qty/mass within rounding); 79201-32/-36/-42 are natively defined in 79201-00 itself and are the ones found inside 80201-00. SWC and UWC shells draw on a shared small-fittings catalog regardless of which product's drawing series first defined a given part; (7) weld-type-line *counts* match exactly between SWC and UWC's analogous shells (79101-00: 10 vs 80101-00: 10; 79201-00: 13 vs 80201-00: 13) -- only counts were available for comparison, not full type lists, so this is a same-design-different-scale hypothesis for cross-analysis, not a confirmed type match.  (8) The Stadler-direct ÖBB NV bid documents (STAR_12888725/726, SWC_Structured_BOM.xlsx, Offer_BOM.xlsx -- Stadler's own Artikelnummer/PDM-Dokumentnummer scheme, lost bid, see D-187) were pattern-scanned for any 5-digit-dash-2-digit Sachnummer-style value (the format used by both the 80000 UWC and 79000 SWC fixtures) -- zero matches found of that format anywhere in any column, confirming this is a third, fully separate identifier namespace, not a connection point for cross-analysis. Hold all for the cross-analysis chat once Siemens/Supplier 4 are also done -- do not resolve individually per-source. | Cross-analysis phase |
| OQ-63 | Serialization-point operation and material-lot-tracking applicability for 79000 SWC (and any future assembly templates) -- to be set per template once each is analyzed/built, per D-183. | When each template is built |
| OQ-64 | Real starting ST-number to seed the unit-serial sequence with, so it continues from whatever Stirg has already physically punched rather than colliding at ST001. Voja to find before go-live; not a blocker before then. | Pre-launch |
| OQ-65 | **Dual schema structures found live, not reflected in entities.md.** `_legacy_clients` (old client table, `company_type`/`parent_company_id` columns) and `company_branding` exist alongside the documented `organizations`/`organization_branding`/`clients` — not a clean rename as entities.md currently states. `quotes`, `work_orders`, `invoices`, `transactions`, `parts`, `procurement`, `hours_log` still reference the old structure (`client_id` int FK to `_legacy_clients`, `context` text check Stirg/Prototip) rather than `organization_id`. Decide: finish migrating these tables to `organization_id` + drop legacy tables, or keep both long-term. Blocks RLS policy design for these tables — see D-185. | Before RLS work |
| OQ-66 | RLS policy granularity: do all member roles (Owner/Manager/Supervisor/Worker/Viewer) get identical org-scoped access per table, or does access need to differ by role (e.g. Worker can't see `transactions`/`invoices`)? Decides whether each of the 15 RLS-disabled tables gets one simple policy or several role-conditional ones. Voja to resolve when home, alongside OQ-65 — see D-185 for the fixed methodology once both are answered. | Before RLS work |
| OQ-67 | `storage.objects` has zero RLS policies on both private buckets (`part-photos`, `kb-private-fixtures`) — currently closed to all client-SDK access rather than properly org-scoped. Needs policies keyed off the STIRG/PROTO path prefix, same D-185 methodology as the 15 disabled public-schema tables. Depends on OQ-50 (real second user to test cross-org denial) and likely OQ-66's role-granularity answer. | RLS rollout |
| OQ-68 | Part-identity field should likely be split into separate typed fields (document_number / manufacturer_pn / client_artikelnummer) rather than one overloaded 'part number' string -- real-world evidence (Stadler ÖBB NV case study, D-187/188): only 50% of a manually-built BOM's Part Number column directly matched the source document number; the rest were manufacturer catalog codes or ad-hoc annotated text. Needs resolution before the Quoting & Estimation initiative or any parts-identity schema work proceeds. | Quoting & Estimation / parts schema |

## Additional resolved from chats
| OQ-49 | Migration `20260614000006_seed_orgs_and_members.sql` applied 2026-06-14. Verified: STIRG + PROTO orgs, branding (correct colors + document names), Ivan Advokat as C001 under PROTO. Members row conditional on auth signup — see OQ-50. |
| OQ-36 | Product category confirmed: lightweight MES with job costing (D-112) |
| OQ-37 | BOM display_name compound name rule (D-118) |
| OQ-38 | Generic CAD name flagging in BOM import (D-119) |
| OQ-39 | Parts deduplication in flat view (D-120) |
| OQ-40 | KB-BUILD.md condensed file strategy confirmed (D-115) |
| OQ-41 | New chat opener format confirmed (D-116) |
| OQ-31 | Worker home screen: single current-task card (primary) + queue via swipe/expand (D-158) |
| OQ-32 | Notifications: passive badges (always-on, push-failure-proof) + fixed OneSignal alert set, per-member togglable (D-161) |

## Warehouse feature open questions
| OQ-46 | Confirm Stirg physical layout before warehouse implementation: how many permanent fixtures (racks, shelves, floor areas)? Best resolved by 20-min factory floor walkthrough, not abstract question. | Pre-warehouse feature |
| OQ-47 | Partial cut UI: if laser operator cuts 8 of 12 parts, does WO show 8 as "in progress at location" and 4 as "not started"? Treatment TBD. | Phase warehouse |
| OQ-48 | ~~QR label dimensions~~ RESOLVED — defaults: 100×50mm (bin) + 148×105mm A6 (pallet) + custom input. See D-144. | Resolved |

## Pending evidence / follow-up files (from D-149–D-161 resilience review)
| # | Item | When |
|---|---|---|
| OQ-51 | D-154 recursive CTE load test results not yet measured — record as D-154a/b once Phase 3 schema exists | Phase 3 sign-off |
| OQ-52 | `kb/specs/win-transition.md` not yet written (D-151) | Phase 8 |
| OQ-53 | `kb/specs/phase-5-worker-ui.md` not yet written — must include D-158 offline pattern | Phase 5 |
| OQ-54 | `kb/prototip_document_brand.md` not yet written (D-160) — needs Voja input on Prototip document language default | Before Phase 8 |

## Mockup status (parts/ops screen session)
| # | Note | Phase |
|---|---|---|
| OQ-55 | ppm-parts-ops.jsx v2 (D-162–167) built and tested in Claude.ai Project sandbox. v3 (D-168–174) specified via clarification but not built. AI bar in the mockup used claude-sonnet-4-6 (artifact API-proxy constraint) vs. production D-28 Haiku-first routing — no decision change, sandbox note only. Future iteration on this screen recommended in Claude Code (incremental edits) rather than full-artifact rewrites, for token efficiency. | Phase 3 |
