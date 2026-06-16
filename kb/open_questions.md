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
| OQ-50 | **Members backfill — manual step after Voja's first Supabase Auth sign-up.** Migration 6 includes a conditional INSERT for Voja as Owner of both orgs, but `auth.users` was empty at migration time so 0 rows were inserted. After Voja signs up (email invite or magic link), run: `INSERT INTO public.members (organization_id, user_id, role, is_active, joined_at) SELECT o.id, u.id, 'Owner', true, now() FROM public.organizations o CROSS JOIN auth.users u WHERE o.code IN ('STIRG', 'PROTO') AND u.email = 'voja.g.95@gmail.com' ON CONFLICT (organization_id, user_id) DO NOTHING;` Required done-criterion for Phase 1: Voja must be active Owner of each org before any RLS-protected table can be accessed. Does NOT block Session 2. | After first Auth sign-up |
| OQ-56 | Visual identity exploration starting point: logo-first (brand seed informs screen design) or app-screen-first (parts tracker direction, logo follows)? Not yet decided. | Design exploration |
| OQ-57 | Plain-language change-summary step for /review — proposed addition to help non-developer (PM/engineer background) sign off on RLS/financial changes without reading code. Not yet formalized into kb-patch or a new skill. | Process improvement |
| OQ-58 | **Phase 1 completion status uncertain as of 2026-06-16.** decisions.md shows Session 1 complete (D-145-148) but no logged evidence for Sessions 2-5 (operational/financial migrations, seed data, final RLS verification per phase-1-implementation-workflow.md). OQ-50 (members backfill) also still shows as unresolved precondition. Needs verification against actual Supabase state before Phase 2/3 work begins — do not assume Phase 1 done without checking `supabase db diff` and the RLS verification report. | Immediate |

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
