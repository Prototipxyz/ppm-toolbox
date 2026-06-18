# TOOLING STRATEGY

## AI-Assisted Development Workflow

### Tool Roles (confirmed, not interchangeable)

| Tool | Role | Status |
|---|---|---|
| **Claude.ai Project** (this) | Architect + KB + specs + decisions | Active |
| **Claude Code (CLI)** | Primary coding agent — multi-file, migrations, full features | Install next |
| **agent-skills (Osmani)** | Skills + slash commands + subagent review | Install with Claude Code |
| **Context7 MCP** | Live library docs injected into Claude Code context | Install with Claude Code |
| **Lovable** | Throwaway UI sketchpad only — validate screens visually before coding | Use when needed |
| **Sentry** | Error tracking — day one of app repo | Install at app repo creation |
| **Playwright** | E2E tests — CI gate, never ships without passing | Install at app repo creation |

Cursor: deferred. Add only if Claude Code workflow hits friction.
v0: deferred. Use only for isolated complex components if needed.

### Workflow Per Feature (exact sequence, every time)
```
Step 1 — SPEC (Claude.ai, this chat)
  Write 10-line spec in kb/specs/<feature-name>.md
  Covers: what it does, what it doesn't, acceptance criteria, edge cases
  Must include "Failure/Disable Behavior" section per D-149 — no spec is
    complete without it
  Commit to ppm-toolbox → CLAUDE.md auto-updates

Step 2 — VISUAL (Claude Design, D-176)
  For new/changed screens: describe screen + requirements in Claude Design
  Iterate until visual direction satisfactory (golden-middle: dense but
    hierarchical, D-87/88/91 role-aware progressive disclosure)
  Hand resulting design to Claude Code as visual reference for /build
  Included in existing Pro/Max subscription — no extra cost

Step 3 — BUILD (Claude Code)
  Run /spec to confirm Claude Code read the spec
  Run /plan — review and approve the plan before any code written
  Run /build — Claude Code implements
  Never accept output without reading every file changed

Step 4 — REVIEW (Claude Code, fresh session)
  New Claude Code session, sees only the diff
  Run /review — Osmani's review skill, fresh context
  Fix anything flagged before proceeding

Step 5 — TEST (Claude Code)
  Run /test — write tests with explicit inputs/outputs
  For financials + RLS: test every role, every edge case
  Tests must pass before commit

Step 6 — COMMIT
  Pre-commit hooks run: TypeScript compiles, tests pass, RLS check
  Push to ppm-app → Vercel auto-deploys to ppm.prototip.xyz
```

---

## CLAUDE.md Strategy

`CLAUDE.md` in repo root is auto-generated from KB files via GitHub Action.
Sub-folder `CLAUDE.md` files exist per major module with localized context:
- `/supabase/CLAUDE.md` — RLS patterns, migration conventions, table naming
- `/app/CLAUDE.md` — route structure, component patterns, role-awareness rules
- `/app/w/CLAUDE.md` — Worker UI constraints (no AI bar, PIN auth, mobile-only)

**Rule:** CLAUDE.md is distilled (~200 lines max). KB files are the full source. Never inline KB content verbatim — link and summarize.

---

## MCP Strategy

### Connected MCPs (available now)
| MCP | Use in Claude Code |
|---|---|
| Supabase | Read schema, run migrations, inspect RLS policies |
| GitHub | Commit KB patches, create PRs, read codebase |
| Notion | Sync meeting notes, log decisions |
| Google Calendar | Link WO deadlines to calendar |
| Google Drive | Manage WO folder structure |
| Make | Trigger automations, check scenario status |

### MCP in Claude.ai API calls (AI bar backend)
The AI bar calls Anthropic API with Supabase MCP injected — Claude reads live org data to answer questions like "What's blocking C518314?"

---

## Skills Strategy

Skills = reusable Claude Code workflows for atomic operations.

**Mechanism:** `.claude/commands/*.md` files in ppm-app repo. Claude Code reads these as `/command-name` project slash commands. Secondary copy in `.claude/skills/*/SKILL.md` (agent-skills format). The `.claude/commands/` path is operative (D-148).

Implemented skills (all 5 live):
- `/implement-migration` — write migration → apply → verify → update types
- `/implement-rls-policy` — write policy → test with role → confirm isolation
- `/implement-api-route` — route → Zod validation → typed response → test
- `/implement-component` — shadcn base → PPM design tokens → role-aware props
- `/kb-patch` — end-of-chat consolidation → generate patch → commit to GitHub

---

## Token Optimization

- Zero-token path: chip actions → direct DB write, no AI involved
- Groq (free): simple natural language commands, low complexity
- Haiku: structured parsing, medium complexity
- Sonnet: complex multi-step queries, financial analysis
- KB files kept surgical — no bloat, no redundancy
- CLAUDE.md capped at 200 lines — sub-folder files handle depth
- GitHub Action regenerates CLAUDE.md on every KB commit automatically

---

## Component Library Decision

**shadcn/ui** as the base layer. Reasons:
- Copy-paste components, not a dependency — no lock-in
- Works perfectly with Tailwind
- Dark mode built in
- Radix primitives underneath (accessible, headless)
- Install only what's used — no bundle bloat

Custom design tokens sit on top of shadcn. Stirg orange (#E8450A) and Prototip blue (#2563EB) applied via CSS variables.

---

## BOM Analysis Pipeline Status

Per D-180. Each row = one Claude.ai chat, output = compact JSON fixture in kb/test-fixtures/.
Images and supplier/contact data go to Supabase Storage, never into this (public) repo.

| Source | Status | Fixture |
|---|---|---|
| Stadler | done (2026-06-17) | kb/test-fixtures/stadler_structured.json |
| Stadler (79000 SWC) | done (2026-06-18, text-only, no images -- Inventor export unavailable) | kb/test-fixtures/79000_structured.json |
| Stadler — ÖBB NV bid (lost, case study, D-187) | SWC spot-checked vs. manual file: 50% direct ID match, 92% qty agreement on matches (2026-06-18); UWC fully extracted, no images/material fields available (2026-06-18) | kb/test-fixtures/stadler-obb-nv_uwc_structured.json |
| GST | done (2026-06-17) | kb/test-fixtures/gst_structured.json |
| Winkler (200L FWT 41100) | done (2026-06-18) -- real ongoing client, first fully in-house Stirg design (not subcontractor-transferred); canonical images shared with 900L sibling under one STIRG/winkler/ Storage path (D-190) | kb/test-fixtures/winkler_200l_structured.json |
| Winkler (900L AWT 41200) | done (2026-06-18) -- see 200L row; 91 part numbers shared between both tanks | kb/test-fixtures/winkler_900l_structured.json |
| Siemens | not started | — |
| Supplier 4 | not started | — |
| Cross-analysis | not started | — |

## BOM Analysis Procedure (per-source checklist, D-180)

Setup (one-time, done): Supabase Storage buckets `part-photos` and
`kb-private-fixtures` (both private) already exist -- reuse across all
sources, never recreate. Path convention: {org_code}/{source_label}/
{part_number}.{ext} -- source-namespaced because raw/unassigned part
numbers are not guaranteed unique across different clients' BOMs (OQ-59).

Per source:
1. View the xlsx skill before touching any file.
2. Inspect structure first (sheet names, dims, header rows) -- never assume
   layout from the file name or a prior source's structure.
3. Identify the hierarchy column and empirically check max depth -- do not
   assume the documented 3-level model (D-96) holds without checking.
4. Extract embedded images via ws._images row anchors; dedupe to
   canonical-per-part-number (first occurrence wins).
5. Map operation/status columns as actually found -- record raw column
   name + cleaned key, don't force-fit to the 9-segment pipeline.
6. Extract procurement and supplier/contact data as separate sections.
   Supplier contact PII never goes in the public-repo fixture.
7. Build two outputs: <source>_structured.json (public, GitHub -- no PII,
   no embedded image bytes) and a private payload (Supabase
   kb-private-fixtures -- supplier directory + anything sensitive).
8. Write findings_for_cross_analysis as raw observations only -- flag
   conflicts with existing decisions, don't silently resolve them.
9. Push: GitHub (pipeline status table row + one consolidated OQ if
   warranted) + Supabase (images + private JSON).
10. For Supabase uploads: POST to the `kb-storage-upload` Edge Function
    (project `bfhioxqspmypcnpmakyg`) -- batch files as {bucket, path,
    content_base64, content_type}, max 200/request. Auth: anon key + the
    function's embedded token (recover via `get_edge_function` if not
    already in context -- never store the token in memory). Supersedes the
    per-session sb_secret_ key ritual (D-181).
