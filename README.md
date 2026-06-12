# PPM Toolbox

Knowledge base, architecture decisions, and AI context files for the **PPM** manufacturing SaaS platform.

## Structure

```
CLAUDE.md                    ← AI context file (auto-regenerated from kb/)
kb/
  vision.md                  ← Product vision, problem, target market
  architecture.md            ← Stack, integrations, build workflow
  entities.md                ← Data model, all tables
  permissions.md             ← Roles, org types, permissions matrix
  workflows.md               ← Core workflows WF-01 to WF-09
  features.md                ← Feature specs
  users.md                   ← User journeys per role
  decisions.md               ← All D-numbered decisions
  open_questions.md          ← Resolved and open questions
  tooling_strategy.md        ← Tool roles, MCP/skills/token strategy
  stirg_document_brand.md    ← Stirg document brand spec
scripts/
  generate_claude_md.py      ← Regenerates CLAUDE.md from KB
.github/workflows/
  regenerate-claude-md.yml   ← Auto-runs generate_claude_md.py on KB changes
```

## How to Update the KB

1. Edit any file in `kb/`
2. Commit and push
3. GitHub Action auto-runs `generate_claude_md.py` and updates `CLAUDE.md`
4. Next Claude Code session picks up the changes automatically

## How to Add a Decision at End of Chat

Claude generates a precise patch at end of session. Apply it:
```bash
# Edit the relevant kb/ file
# Commit
git add kb/decisions.md
git commit -m "kb: add D-99 ..."
git push
```

## Tech Stack
Next.js 14+ · TypeScript · Tailwind CSS · shadcn/ui · Supabase (PostgreSQL + Auth + Storage) · Vercel · Claude Code · Groq
