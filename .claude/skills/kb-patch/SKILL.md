---
name: kb-patch
description: End-of-session KB consolidation. Use at the end of every Claude.ai chat session that produced decisions, resolved questions, or changed architecture. Generates precise patches, commits to ppm-toolbox, triggers CLAUDE.md auto-update.
---

# Skill: kb-patch

## When to run
At the end of every Claude.ai session that produced any of:
- New D-numbered decisions
- Resolved open questions
- Architecture changes
- New feature specs
- Workflow changes

## Steps

### 1. Identify what changed this session
List every decision made, every question resolved, every new spec written.
Format:
```
Changed:
- decisions.md: add D-112, D-113
- open_questions.md: resolve OQ-34, OQ-35; add OQ-36
- tooling_strategy.md: update workflow sequence
- specs/worker-pin-auth.md: new file
```

### 2. Generate precise patches
For each changed file, generate only the changed lines.
Never rewrite entire files unless the file is new.
Use exact line references where possible.

### 3. Apply patches to ppm-toolbox
```bash
# Edit the relevant kb/ file
git add kb/<changed-file>.md
git commit -m "kb: <brief description of what changed>

Decisions: D-112 (worker PIN auth), D-113 (spec location)
Resolved: OQ-34 (Node.js), OQ-35 (SSH keys)
Session: <date>"
git push
```

### 4. Verify GitHub Action fired
- Go to github.com/Prototipxyz/ppm-toolbox/actions
- Confirm regenerate-claude-md workflow ran successfully
- Confirm CLAUDE.md timestamp updated

### 5. Confirm next session context
The next Claude Code session will automatically read updated CLAUDE.md.
No manual context pasting needed.

## Token optimization rules
- Patches only — never paste full file contents
- One commit per session — batch all changes
- Commit message includes decision numbers for traceability
- If no decisions were made, no commit needed

## Evidence required
- [ ] All decisions D-numbered and added to decisions.md
- [ ] All resolved questions moved to resolved section
- [ ] All new specs in kb/specs/
- [ ] Commit pushed
- [ ] GitHub Action completed successfully
