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
| OQ-68 | Part-identity field should likely be split into separate typed fields (document_number / manufacturer_pn / client_artikelnummer) rather than one overloaded 'part number' string -- real-world evidence (Stadler ÖBB NV case study, D-187/188): only 50% of a manually-built BOM's Part Number column directly matched the source document number; the rest were manufacturer catalog codes or ad-hoc annotated text. Winkler tank BOMs (third confirming source, 2026-06-18) show the same pattern from the opposite direction: only 18 of 27 Offer_Winkler.xlsx line items resolved to a BOM Part Number via normalized prefix-matching (the Offer's bare structured code vs. the BOM's code+description concatenation), with 2 confirmed genuine code collisions (same structured code reused for two different sibling parts within one tank's own BOM) and the remainder either manufacturer catalog numbers or one likely data-entry error. Needs resolution before the Quoting & Estimation initiative or any parts-identity schema work proceeds. | Quoting & Estimation / parts schema |
| OQ-69 | Winkler BOM fixtures (real ongoing client, first fully in-house Stirg design, D-190) surfaced findings to hold for cross-analysis: (1) hierarchy depth reaches 5 levels in both tanks -- fourth confirming source against D-96's 3-level model, alongside GST (OQ-59, depth 7) and Stadler (OQ-62); (2) BOM Structure field ('Normal'/'Purchased'/'Inseparable') is not a reliable make/buy signal here -- most actually-purchased items (Kohler valves, JUMO sensor, Harting connector) are tagged 'Normal', only FLEXA conduit + KVT fasteners tagged 'Purchased'; Offer's own Make-or-Buy column is also mostly empty (3/27 filled) -- neither source gives reliable make/buy classification for most parts in this source; (3) Suppliers sheet has exactly 93 records, identical count to Offer_GST.xlsx's Suppliers sheet (OQ-59 #4) -- second confirming source that one master supplier list is copied across different client offers rather than maintained per-client; (4) 91 of ~140-149 unique parts are literally shared between the 200L and 900L tanks, including a fully identical 'Elektrical Cabinet Box' sub-assembly tree -- same shared-module pattern as Stadler's SWC/UWC shared-fittings finding (OQ-62 #6), now seen in self-designed work too; (5) several leftover unrenamed default Inventor part names appear identically in both tanks ('Part100', 'Part258', 'A$Cc5f8cb19') -- never renamed. Hold all for the cross-analysis chat once Siemens/Supplier 4 are also done -- do not resolve individually per-source. | Cross-analysis phase |

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

## Operations norming session (Stirg_Operacije_Norms.xlsx, D-191–197)
| # | Question | Priority |
|---|---|---|
| OQ-70 | Vendor reply lead-time (elapsed waiting on RFQ responses) needs a home. Confirmed NOT part of the Operations cost-rate table (D-192) — likely belongs on the purchased-part or vendor record as a tracked lead-time field, feeding scheduling rather than costing. Schema/concept not yet designed. | Procurement / scheduling feature |
| OQ-71 | DXF naming convention (PN_MATERIAL_THICKNESS_QTY or similar) not yet defined — required for tier-2 fallback in D-196's resolution strategy. Needs a concrete format spec before the DXF estimator tool can be built. | Before DXF estimator build |
| OQ-72 | Calibration plan for `Stirg_Operacije_Norms.xlsx` placeholder norm hours (D-195) — no defined trigger/process yet for when a placeholder gets replaced with a real measured value (e.g. after N logged jobs, manual review cadence, automatic once variance data exists). | Post-launch, once hour-logging exists |

## DXF Estimator Spec Session — OQ-73 Resolved, OQ-74 Partially Resolved

| OQ-73 | ~~Whether Stirg's actual DXF exports include bend lines on a separate, consistent layer.~~ RESOLVED 2026-06-19 — confirmed via real export (`testpart.dxf`) and Autodesk's documented `FLAT PATTERN DXF` translator parameters: bend lines export reliably to `IV_BEND`/`IV_BEND_DOWN` layers, version-stable, not config-fragile. Earlier laser-floor DXF samples without bend layers reflect a downstream export/CAM step producing laser-ready files, not a translator limitation — Inventor's flat-pattern export (the estimator tool's actual input) does carry bend lines when exported with default layer settings. See D-201. | Resolved |
| OQ-74 | **Partially resolved 2026-06-19.** Bend-line embedding mechanism resolved as a non-issue — it's layer name (`IV_BEND`/`IV_BEND_DOWN`), not text/XDATA/custom property, and Inventor already does this natively (see OQ-73/D-201). What remains open from OQ-74's original scope: the D-199 macro's mechanism for embedding *worker-supplied* values (qty/material/thickness) as DXF metadata — layer-name encoding vs. text entity vs. true DXF custom property/XDATA — still not chosen, since none of these are things Inventor captures automatically the way it does bend geometry. | Before macro build |

## Estimator → PPM Integration (OQ-75)

| OQ-75 | **PPM quote_lines schema gap for Estimator import.** PPM's current `quote_lines` table is structured as generic billing line items (billing_type: Hourly/Fixed/Per Unit), not part-indexed cost rows. The Estimator produces per-part cutting cost + bending cost + material cost. A PPM import screen will need a design decision on how quote_lines receive part-level cost data from the Estimator — whether as individual line items per part, rolled-up category lines (cutting total, bending total, material total), or a hybrid. Defer to PPM Phase 8 (Quotes) design. | Before PPM Phase 8 |

## Batch DXF Export — resolved and deferred items

| OQ-76 | **DXF layer filter in batch context.** Layer filter (keeping only IV_OUTER_PROFILE, IV_INTERIOR_PROFILES, IV_BEND, IV_BEND_DOWN) was implemented for the part-level macro but removed from the batch macro (D-265) due to DXF structure corruption. Needs a validated VB implementation tested against real DXF files before re-enabling in batch. Bend lines toggle UI is already in the batch dialog, wired to `includeBendLines` variable — just needs the filter subroutine re-validated. | Before batch macro v2 |
| OQ-77 | **Batch macro qty from BOM: 2 parts not found in BOM on first run of `13017522 Alat.iam`.** Parts were sheet metal but not present in the Parts Only BOM export — possibly phantom/suppressed components or parts with mismatched PN strings. Summary now lists missing PNs explicitly. Root cause not investigated. | Low priority — informational |

## PPM_ExportPartData Build Session — Open Items (OQ-78, OQ-79) — ADDRESSED BY D-298/D-299, PENDING VERIFICATION

| OQ-78 | ~~REPORT sheet operation-coverage % — eligible-parts denominator has no data-model backing yet.~~ ADDRESSED by D-299 — REPORT rebuilt to match GST tracker pattern (Completion % = DONE ✓ / REQ ✓, not coverage-of-all-parts). Not yet tested in real export — verify once Part 4 rebuild lands and is run in Inventor. | Verify after Part 4 test |
| OQ-79 | ~~BOM_FLAT and PARTS sheet Level column hardcoded to 1 for all rows.~~ ADDRESSED by D-298 — Level now derived from structured BOM's `Item` column dot-count (e.g. "9.1" = Level 2), confirmed real hierarchy data exists via `PPM_TestStructuredBOM.iLogicVb` diagnostic on `13017522 Alat.iam`. Not yet verified in the rebuilt main macro — verify once Part 4 lands. | Verify after Part 4 test |

## PPM_ExportPartData Part 4 Rebuild — New Open Item

| OQ-80 | **Structured BOM row enrichment match-by-PN may miss purchased/closed-document parts.** D-298's architecture enriches structured-BOM rows by matching Part Number against currently-open `ThisApplication.Documents`. If a part referenced in the BOM isn't open in the current Inventor session (e.g. purchased components, suppressed parts), enrichment fields (material, thickness, bends, op flags) will be blank rather than erroring — confirm this degrades gracefully in practice and doesn't silently drop rows entirely. | Verify during Part 4 testing |

## PPM_ExportPartData Part 4 — Post-Production-Test Status (resolves OQ-79, OQ-80; updates OQ-78)

OQ-79: **RESOLVED.** Confirmed working in production via D-302 — real Level derivation verified on `13017522 Alat.iam` end-to-end run, not just diagnostic test. No longer open.

OQ-80: **RESOLVED — degrades gracefully.** Production run confirmed enrichment falls back to defaults (blank material/thickness/etc, Type="Part") when no document match is found, rather than dropping rows or erroring. No silent row loss observed.

OQ-78 remains open pending the Part 5 REPORT restructure below (Completion % formula itself is correct per D-299, but display scope — hiding zero-REQ ops — has not yet been implemented).

## PPM_ExportPartData Part 5 — Scoped for Next Session (sheet restructure)

| OQ-81 | **Sheet structure simplification requested.** Current 4-sheet layout (PARTS, ASSEMBLIES, REPORT, BOM_FLAT) to be replaced with: (1) a single Structured BOM sheet carrying full hierarchy (Item/Level, replacing PARTS+ASSEMBLIES) plus a new project-wide total-qty-per-PN column at the top/assembly level, (2) a separate, independently-generated flat parts-only BOM_FLAT sheet (same enrichment data, different aggregation — no Excel formula-linking between sheets per explicit decision, both sheets generated from one in-memory dataset per export run, matching the existing PARTS/BOM_FLAT no-drift principle). Thumbnails remain explicitly deferred (confirmed again this session, consistent with D-300). | Next session |
| OQ-82 | **REPORT sheet simplifications requested.** (1) Hide operations with REQ=0 entirely from the OPERATION COMPLETION table — only list operations actually required by at least one part. (2) Add a GST-tracker-style overall project summary block (Total PNs, parts/weld-assembly counts, similar shape to existing SUMMARY block already partially implemented per D-299). (3) Remove the per-operation column block from the REPORT's weld-assemblies list — list weld assemblies as PN/Description only, no inline op-flag columns (this was carried over from the original brief but does not match current intent). | Next session |

## Weld Bead Report / Estimator Weld Costing — New Open Items (OQ-83 to OQ-87)

| OQ-83 | WPS (Welding Procedure Specification) documents not yet collected or parsed. Needed to build the travel-speed/deposition-rate table that turns Bead Report Length data into time and consumable cost (D-308). Pending Voja locating/uploading the documents. | Before weld costing build |
| OQ-84 | Beveled/V-groove weld prep cross-section formula not yet validated against real data — only square-gap-fill/loft geometry confirmed (D-307, exact match on Groove Weld 1). Stirg uses multiple prep types depending on material thickness (confirmed by Voja), so the square-gap formula alone won't cover all groove welds. Needs a real measured length on an angled-prep bead to derive/confirm the trapezoid/triangle cross-section formula, same validation method used for D-307. | Before groove length derivation generalized |
| OQ-85 | Whether the WPS/weld rate table needs a per-client dimension (Stadler/GST/Siemens/Winkler may specify different WPS terms) or is one Stirg-internal standard applied regardless of client. Undecided — affects rate table schema; decide before WPS data is structured, since adding a dimension after the fact means migrating data, not just appending rows. | Before WPS table schema locked |
| OQ-86 | Estimator product naming — scope now extends beyond "Cuts and Bends" to include weld costing (D-308/D-309). Whether this warrants a rename or stays under the existing name with welding folded in is undecided. Cosmetic, low priority. | Low priority |
| OQ-87 | Whether the Bead Report can be triggered from iLogic (`AssemblyWeldBeadReportCmd` ControlDefinition) and whether doing so still throws the Report Location modal dialog, or can run silently/scriptably. All Bead Report data collected so far (D-306/D-307) came from manual Tools-menu runs, not iLogic automation. Determines whether Bead Report generation can become a one-click macro step or stays a manual-click-then-parse two-step workflow. | Before Bead Report automation attempted |

## Weld Rate Table — Resolved Items (OQ-83, OQ-85)

OQ-83: **RESOLVED 2026-07-01.** WPS documents parsed across all material groups.
Rate table built from 9 confirmed Stirg WPS RP anchor points + 5 placeholders
flagged per D-195 convention. See D-312 to D-317. File: `kb/weld_rate_table.json`.

OQ-85: **RESOLVED 2026-07-01.** No per-client dimension needed on the weld rate
table. Stirg's RP speed data is internally consistent regardless of which client's
WPS form it appears on. Single flat table confirmed. See D-316.

## Weld Rate Table v1.1.0 Session (2026-07-01 continued)

OQ-84 remains open — bevel/V-groove cross-section formula not yet validated. Needs
one manual edge-length measurement in Inventor on a bevel-prep groove weld, same
method as the square-gap-fill validation (D-307). No documents needed — 30-second
Inventor task.

OQ-87 remains open — Bead Report iLogic automation (`AssemblyWeldBeadReportCmd`)
not yet tested. Needs live Inventor session, no documents needed.

| OQ-88 | **CS MAG thin fillet RP not found.** WPS 07/24 and WPS 89/24 (S355 MAG 135 FW a2/a3 PB) not locatable. CS-MAG-FW-MD-PB entry remains analytically extrapolated at ~36 cm/min (D-319). Upgrade to confirmed when document is found or real job is timed. | Low priority — extrapolation is defensible |

## Send to Estimator / OQ-87 Resolution

OQ-87: **RESOLVED 2026-07-01.** AssemblyWeldBeadReportCmd confirmed executable
from iLogic — fires two modal dialogs (subassembly checkbox + file save location).
Both handled via SendKeys in Send to Estimator sequential context. See D-329.

OQ-84: **RESOLVED 2026-07-01.** V-groove cross-section formula confirmed:
`area = thickness²` for full 2×45° symmetric chamfer. Length = Volume ÷ area.
No Inventor measurement needed — standard chamfer assumption confirmed by Voja.
Square-gap formula already confirmed (D-307). Half-V extrapolated by symmetry.
See D-330.

## DXF Export Layer Filter Redesign — New Open Questions (OQ-89 to OQ-92)

| OQ-89 | New `FilterDxfLayers` (D-334) has an untested edge case: `POLYLINE` entities' `VERTEX`/`SEQEND` children have no layer code of their own and must be grouped with their parent block rather than evaluated independently. Inventor flat-pattern exports are expected to only produce `LINE`/`ARC`/`CIRCLE`/`POINT`/`LWPOLYLINE`, so this may never trigger — needs verification once the new filter is live on a real export. | Verify after Claude Code implementation lands |
| OQ-90 | Whether `IV_*` layers other than the two directly confirmed leakers (`IV_ARC_CENTERS`, `IV_TANGENT` — D-333) also write entities despite `Visibility=OFF` in the INI (e.g. `IV_TOOL_CENTER`, `IV_FEATURE_PROFILES`, `IV_ALTREP_FRONT/BACK`, `IV_ROLL`, `IV_ROLL_TANGENT`). Not individually tested. The permissive-drop whitelist design (D-334) makes this moot for correctness, but confirming which layers actually leak would be useful if the INI itself is ever revisited. | Low priority — whitelist already covers it |
| OQ-91 | Single-part macro's exact final dialog `Size`/control layout after the resize (D-335) — left to the Claude Code implementation to finalize; needs a real-world check that the Export/Cancel buttons no longer clip. | Verify after Claude Code implementation lands |
| OQ-92 | `PPM_MarkOperations` bend detection on STEP-converted-to-sheet-metal parts (flagged in the Bend Diagnostic session, part `Phantom A Längsträger links`) — the proposed fix of probing a temp DXF export for `IV_BEND`/`IV_BEND_DOWN` entities depends on the DXF export pipeline itself being correct first. Blocked on D-331-D-335 landing and being verified working. | Blocked on DXF export fix (D-331-D-335) |

## Post-Fix Follow-on Open Questions (OQ-93 to OQ-95)

| OQ-93 | Test the `.Update()`/forced-rebuild-before-export hypothesis (D-338) the next time a part throws this specific E_FAIL pattern, before manually fixing it via thickness toggle or solid-conversion — to get a clean before/after confirmation of the mechanism. Affected parts in this session were already manually fixed before the theory could be tested. | Test next occurrence |
| OQ-94 | `PPM_BatchExportFlatPatterns.iLogicVb` should restore each part's pre-export state (e.g. flat pattern active/inactive) after processing, rather than leaving it altered (D-339). Needs a fix — scoped separately from the E_FAIL root-cause investigation (D-338/OQ-93). | Fix pending |
| OQ-95 | Build a diagnostic/test macro to capture part state (thickness override vs. sheet metal rule, flat pattern validity, last-updated timestamp, etc.) when a batch export throws E_FAIL, so recurrence of this pattern can be triaged without manual toggling. Also considered: double-click on a failure-list entry to activate that part directly from the summary window for on-the-spot fixing (requires converting the failure list from read-only TextBox to a ListBox with a click handler matching back to the loaded PartDocument, per D-260's document walk). Bundle both together when picked up, since both concern the batch macro's per-part failure-handling lifecycle. | Design pending |

## Diagnostic Tool Status — Revision to OQ-93, New Open Question (OQ-96)

OQ-93 (previous text: "test the `.Update()` hypothesis next occurrence") is **not
resolved by this attempt** — a deliberate re-break of a previously-failing part did not
reproduce the E_FAIL condition, so the diagnostic tool (D-340) was never triggered.
OQ-93 stays open, unchanged in substance: still needs a real, naturally-occurring
failure to test against, since deliberate reproduction attempts have now failed once.

| OQ-96 | Toggling the sheet metal thickness override — the method that resolved `NR01555346-5` in D-338 — did **not** reproduce the E_FAIL condition on retry (D-340). This means the original three failures either required a more specific state than a simple thickness-override change, or involved something transient (Inventor session state, document history, etc.) not captured by that single manual action. Worth noting whatever else is different (freshly-opened vs. long-running Inventor session, order of operations, etc.) the next time this pattern occurs naturally, since the mechanism is less understood than D-338 implied. | Watch for next natural occurrence |

---

## Diesel Tank Estimation Session — July 2026

**OQ-97** [OPEN] Weld deposition rate validation: measure real MIG/MAG mm/min on Stirg shop floor for structural S235JR fillet welds. Current placeholder 400 mm/min (D-343). Most significant accuracy lever for OP-016 cost on large weldments.

**OQ-98** [OPEN] `AssemblyWeldBeadReportCmd` automation from `PPM_SendToEstimator`: test recursive weldment traversal (D-359) and per-weldment report invocation without modal dialog blocking macro. Test on main tank weldment (NR01555346) first. Fallback if blocked: output checklist of weldments needing manual export.

**OQ-99** [OPEN] Engineering hours prompt (D-360): validate that dialog does not disrupt workflow in practice. Review after first live run on Stirg dev PC.

**OQ-100** [OPEN] All parts in Stadler diesel tank assembly require hole/thread re-verification via corrected macro (`PositionPoints.Count` fix, D-347). Known wrong entries: NR01555346-7 = 24× M8×1.25 tapped (10mm deep); NR01555346-8 = 8× M8×1.25 tapped.

**OQ-101** [OPEN] Deburring (OP-014) and visual QC (OP-023) norms applied per-blank produce disproportionate cost share (~34% combined in current diesel tank run). Evaluate applying these per sub-assembly rather than per individual blank for weldment assemblies.

**OQ-102** [OPEN] Assembly hours (OP-020): current placeholder 0.5h/sub-assembly is the weakest norm estimate. Requires measured time from Stirg shop on a comparable welded tank to calibrate.

**OQ-103** [OPEN] Markup structure for Stadler client: confirm whether flat 30% applies across all operation types or whether Stirg applies variable margins per operation category.

**OQ-104** [OPEN] KROMA level sensor MWAS 2.710-630/121 procurement: designed for FANINA (PL), requires FANINA technical release before KROMA ships. Contact: Mateusz Socha (mateusz.socha@fanina.pl). Escalation path: raise with Stadler (Jonathan Erny) whether they can provide FANINA release or accept an alternative sensor.

**OQ-105** [OPEN] SP-numbered purchased parts in Stadler package (SP100233354 tank cap, SP100233515 filler neck, SP100598235 socket fittings G3/4"): confirm with Stadler whether customer-furnished or Stirg-procured. Affects quotation scope materially.

**OQ-106** [OPEN] FEM structural calculation (EN 12663-1 P-III, 2024, CL1): confirm whether Stirg has in-house capability or must subcontract. Required deliverable per Stadler spec — must be resolved before final quotation.

**OQ-107** [OPEN] Pressure leak test certification: diesel tank at 0.3 bar, AdBlue tank at 0.5 bar (railway ordinance 51.1 chap. 8). Confirm whether Stirg has in-house test equipment or must outsource.

## Feature Extraction Diagnostic Session — OQ-108 to OQ-115

**OQ-100 partial resolution:** NR01555346-7 confirmed correct (24×M8×1.25 exact match) under the
B-Rep method (D-367). NR01555346-8 designation conflict (diagnostic reads 8×M6x1; OQ-100 originally
expected 8×M8×1.25) remains open — needs Voja's physical/drawing confirmation, not a code question.
Separately, an M10-vs-M8×1.25 mismatch on `SP000011992 A.1 Erdungsauge RD30 L=15 M10` was found to be
a modeling mistake on the part itself, now fixed by Voja — not a diagnostic bug. No longer tracked.

**OQ-108** [OPEN] Concave/convex face filter (D-367 extension): algorithm verified (`Face.Evaluator.
GetNormal` always points out of the solid, per Autodesk's official B-Rep training material; compare
to the radial vector from the cylinder axis) but not yet built into the diagnostic macro. Needed to
stop convex faces (external round stock, bosses) from being misread as holes — confirmed real bug via
`SP000011992` reading its own Ø30 bar stock OD as a plain hole.

**OQ-109** [OPEN] Thickness-vs-hole-diameter sanity warning: not yet built. Flag (not exclude) faces
where diameter < ~30% of sheet thickness as implausible for a real machining/laser operation. Would
also help catch fillet-derived sliver faces (e.g. the Ø0.2mm reading on `Phantom A Gewindeplatte M8`).

**OQ-110** [OPEN] Sub-1mm face exclusion: not yet built. Faces below ~1mm diameter are near-certainly
fillet artifacts, not real holes — should be dropped from hole lists entirely (with a count-of-skipped
warning for visibility), not just flagged.

**OQ-111** [OPEN] Laser-cut vs. drilled/tapped classification (D-368): not yet built into the
diagnostic. Presence-based, not quantity-based, per D-368 — cross-reference B-Rep face diameter against
the *set* of diameters present on `HoleFeature`s in the tree (existence only, not instance count, since
D-367 established feature-tree instance counts are unreliable). No match → laser-cut-only, tracked
separately for laser time estimation but not counted as a drill/tap operation.

**OQ-112** [OPEN] Round bar stock recognition: brainstormed, not designed. Idea: detect cylindrical
raw-stock parts (e.g. `RD30` naming convention), compute length along the cylinder axis from the
bounding box, group by diameter+length+qty for a future "bar stock" material/costing category in the
Estimator. Needs its own design session — separate from the hole/thread extraction work.

**OQ-113** [OPEN] Assembly-level and single-part-document support: confirmed scope gap. The diagnostic
macro currently requires an open `AssemblyDocument` and only extracts features from `PartDocument`s
referenced by it — assemblies' own features (if any) and standalone single-part-document runs are not
covered. Structural change to `Main()`'s document walk, deferred until hole/thread detection itself is
trustworthy.

**OQ-114** [OPEN] Countersink/counterbore instance counting: still feature-presence-only (D-367/D-368's
B-Rep approach not yet extended to cs/cb). No real test data exists yet — every diagnostic run so far
has shown 0 countersinks and 0 counterbores across all parts, so this is unvalidated either way.

**OQ-115** [OPEN] `SurfaceEvaluator.GetParamAtPoint`/`GetNormal` exact VB.NET call signature (array
sizes, `SolutionNatureEnum` usage) sourced from an official Autodesk C# training sample (ADN-DevTech
GitHub repo), not yet run in Inventor 2021 iLogic. First real compile-and-run will confirm or falsify.

## Concave/Convex Filter + Laser-Cut Classification Test Run

**OQ-108 partial resolution:** Concave/convex filter (`GetNormal` + radial vector) confirmed working
on the one case verifiable by eye — `SP000011992 Erdungsauge`'s own Ø30 bar-stock OD is now correctly
excluded (`SKIPPED_1_CONVEX_FACES`), leaving only its genuine tapped hole. `GetParamAtPoint`/`GetNormal`
compiled and ran without `CONCAVITY_CHECK_FAILED` on any of 29 parts, so OQ-115's signature question is
resolved — real, working. Not yet verified against a known false-negative case (a genuine hole that
should NOT be filtered) — only the false-positive direction is confirmed so far.

**OQ-110 resolved:** Sub-1mm face exclusion confirmed working — `Phantom A Gewindeplatte M8`'s earlier
`8×Ø0.2` fillet-artifact entries are gone (`SKIPPED_8_SUB1MM_FACES`), no regression on real small
features elsewhere in the 29-part run.

**OQ-116** [OPEN] D-368's laser-cut classification produced a 100% non-match rate — `Holes_Plain` empty
across all 29 parts, everything routed to `Holes_Laser`, including on parts with clearly-modeled Hole
features (e.g. NR01555346-7's own 4×Ø25). This is a systematic failure, not a plausible real-world
result, and points at `HoleFeature.HoleDiameter` (used to build the Pass-1 `knownDiameters` catalog) —
either the property isn't returning what was assumed, or there's a units/rounding mismatch against the
B-Rep-computed diameter. Not yet verified against official docs. Blocks D-368 from being trusted until
resolved.

**OQ-117** [OPEN] Thickness-sanity warning (OQ-109's implementation) over-fires on blind/tapped holes —
`Gewindeplatte M8`'s M6×1 taps on 17mm stock trigger `HOLE_SMALLER_THAN_THICKNESS`, but a blind tapped
hole has no reason to approach material thickness the way a through-cut does. Likely needs to apply
only to non-threaded (through) holes, or use different logic for blind features.

**OQ-118** [OPEN] Cosmetic: `Warnings` field can contain duplicate identical entries (seen twice on
`Gewindeplatte M8`) — needs dedup before this is presentable in a real BOM export.

## Full-Revolution Arc-Span Filter Test Run

**OQ-116 resolved:** root cause was never `HoleFeature.HoleDiameter` — it was fillet arcs and real
holes both being concave, which the concave/convex filter alone can't distinguish. Confirmed via Voja's
Inventor screenshots (Measure tool) that the earlier `4×Ø25`/`2mm` "holes" on NR01555346-7 were inner/
outer corner fillets inherited from a STEP-derived base solid, not laser-cut or drilled features.

**OQ-115 partially resolved:** `Face.Evaluator.ParamRangeRect`, `Get3dCurveFrom2dCurve`, and
`Arc3d.SweepAngle` confirmed to compile and run without exceptions across all 29 real parts (zero
`ARC_SWEEP_CHECK_FAILED`), and confirmed **correct** on the one case verifiable against Voja's
screenshots — NR01555346-7 now shows `SKIPPED_4_PARTIAL_ARC_FACES` (the 4 corner fillets), with its
`24×M8x1.25` tapped count unchanged. Still open: coverage.

**OQ-119** [OPEN] Arc-span check returns `ARC_SWEEP_CHECK_INCONCLUSIVE` on the majority of cylindrical
faces across the 29-part run (e.g. 76 times on the diesel tank alone) — neither parametric axis trial
resolves to an `Arc3d`. The check fails open (face is kept as a hole candidate, never silently dropped),
so nothing has been wrongly excluded, but coverage is incomplete — other parts' `Holes_Laser` entries
may still contain unflagged fillets beyond the one case confirmed by eye. Working hypothesis, untested:
both trial line segments anchor at `ParamRangeRect.MinPoint`, likely a parametric seam/boundary
(a common degenerate point in ASM cylindrical parametrization); using a mid-range value for the fixed
coordinate while still sweeping the other axis across its full range may resolve more cases. Next test.

