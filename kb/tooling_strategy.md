# TOOLING STRATEGY

## AI-Assisted Development Workflow

### Tool Roles (assigned, not interchangeable)

| Tool | Role | When to use |
|---|---|---|
| **Claude.ai Project** (this) | Architect + KB | Design decisions, schema design, KB updates, chat-end patches |
| **Claude Code (CLI)** | Primary coding agent | Multi-file features, DB migrations, refactors, full feature builds |
| **Cursor** | In-editor assistant | Fast edits, visual diff review, code cleanup, inline questions |
| **v0 (Vercel)** | Component generator | Complex isolated UI components — pipeline strip, AI bar, financials layout |
| **Claude Design / Artifacts** | UI exploration | Screen layout validation before committing to code |

### Workflow Sequence per Feature
```
1. Claude.ai → decision locked in KB
2. Claude Design → screen validated visually
3. v0 → complex components scaffolded (if needed)
4. Claude Code → full implementation (schema + API + UI wired together)
5. Cursor → review + cleanup
6. Playwright → regression test
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

Planned skills (create as patterns stabilize):
- `implementing-migration` — write migration → apply → verify → update types
- `implementing-rls-policy` — write policy → test with role → confirm isolation
- `implementing-api-route` — route → zod validation → typed response → test
- `implementing-component` — shadcn base → custom styling → role-aware props
- `kb-patch` — end-of-chat consolidation → generate patch → commit to GitHub

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
