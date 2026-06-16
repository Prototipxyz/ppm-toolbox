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
