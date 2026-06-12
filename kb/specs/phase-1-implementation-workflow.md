# Phase 1 Implementation Workflow
## Database Schema + RLS + TypeScript Types

This is the exact sequence of actions from zero to a production-ready database.
Do not skip steps. Do not reorder steps.

---

## Pre-flight checklist (do these before opening Claude Code)

### 1. Install Node.js 18+
```bash
# Check if installed
node --version

# If not installed — download from nodejs.org (LTS version)
# macOS with homebrew:
brew install node
# Windows: download installer from nodejs.org
```

### 2. Install Claude Code
```bash
npm install -g @anthropic-ai/claude-code
claude --version  # verify install
claude            # first run — will prompt for Anthropic login
```

### 3. Set up SSH keys (for GitHub — do once, permanent)
```bash
# Generate key
ssh-keygen -t ed25519 -C "your-email@example.com"
# Press Enter for default location, set a passphrase

# Copy public key
cat ~/.ssh/id_ed25519.pub
# Paste this into github.com → Settings → SSH and GPG keys → New SSH key

# Test
ssh -T git@github.com
# Should say: Hi Prototipxyz! You've successfully authenticated
```

### 4. Create ppm-app repo on GitHub
```bash
# Via GitHub web UI: github.com/new
# Name: ppm-app
# Private: yes
# Do NOT initialize with README (we'll push from local)
```

### 5. Clone ppm-toolbox (KB repo) locally
```bash
git clone git@github.com:Prototipxyz/ppm-toolbox.git
cd ppm-toolbox
```

### 6. Initialize ppm-app as monorepo
```bash
# Back up one level
cd ..
mkdir ppm-app && cd ppm-app
git init
git remote add origin git@github.com:Prototipxyz/ppm-app.git

# Initialize Next.js
npx create-next-app@latest . \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*"

# Initialize Supabase
npx supabase init
# This creates supabase/ directory with config.toml

# Link to existing Supabase project
npx supabase link --project-ref bfhioxqspmypcnpmakyg
```

### 7. Install core dependencies
```bash
npm install @supabase/supabase-js @supabase/ssr
npm install zod next-safe-action
npm install @tanstack/react-query
npm install sentry
npx shadcn@latest init
# Choose: Default style, Zinc base color, CSS variables: yes

# Dev dependencies
npm install -D @playwright/test
npm install -D husky lint-staged
npx husky init
```

### 8. Install agent-skills
```bash
# Inside Claude Code (after opening it in ppm-app directory)
/plugin marketplace add https://github.com/addyosmani/agent-skills.git
/plugin install agent-skills@addy-agent-skills
```

### 9. Add Context7 MCP
```bash
# In Claude Code settings or via config
# Add to .claude/settings.json:
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server-supabase@latest",
        "--project-ref", "bfhioxqspmypcnpmakyg"]
    }
  }
}
```

### 10. Copy skills into ppm-app
```bash
cp -r ../ppm-toolbox/.claude/skills ./  # copies all 5 PPM skills
```

### 11. Set up pre-commit hooks
```bash
# .husky/pre-commit
#!/bin/sh
npx tsc --noEmit          # TypeScript must compile
npx eslint src/           # No lint errors
# Tests run in CI, not pre-commit (too slow)
```

---

## Phase 1 Execution in Claude Code

Open Claude Code in the `ppm-app` directory:
```bash
cd ppm-app
claude
```

### Session 1 — Foundation migrations (tables 1–5)
```
/spec  → confirm Claude Code read phase-1-schema.md from ppm-toolbox
/plan  → review the migration plan for organizations through members
        Approve plan before proceeding
/build → Claude Code writes migrations 1–5
        READ every migration file before approving
/review → open new Claude Code session, review diff only
/test  → RLS policies tested for orgs, branding, members
```

### Session 2 — Operational migrations (tables 6–11)
```
/spec  → same spec, reference tables 6–11
/plan  → migration plan for sequences through procurement
/build → migrations 6–11
        READ every file
/review → fresh session
/test  → RLS for work_orders, quotes, parts
```

### Session 3 — Hours + financial migrations (tables 12–19)
```
/spec  → same spec, reference tables 12–19
/plan  → migration plan for stirg_operations through equipment
/build → migrations 12–19
        Pay special attention to stirg_hours_log (Worker-scoped RLS)
        Pay special attention to financial tables (Owner+Manager only)
/review → fresh session
/test  → RLS for hours (Worker sees own only), financials (Supervisor blocked)
```

### Session 4 — Seed data + type generation
```
Prompt: "Apply seed data from spec. Both orgs, existing WOs, existing 365 parts.
Fix U-03 (branding against wrong entity). Fix U-04 (Ivan Advokat as Prototip client).
Then run supabase gen types and commit types/supabase.ts"

READ the seed SQL before applying
Verify both orgs visible in Supabase dashboard
Verify types file generated cleanly
```

### Session 5 — Final verification
```
Prompt: "Run the full RLS verification checklist from implement-rls-policy skill.
Test every role on every table. Cross-org isolation test. Report results."

Review the report.
Any failure = fix before moving to Phase 2.
```

---

## Phase 1 Done Criteria

Before declaring Phase 1 complete and starting Phase 2:

- [ ] All 19 tables exist in Supabase dashboard
- [ ] `supabase db diff` shows no pending migrations
- [ ] `supabase gen types typescript` runs clean, no errors
- [ ] `types/supabase.ts` committed
- [ ] RLS verification report: all roles pass on all tables
- [ ] Cross-org isolation verified
- [ ] Seed data: both orgs, Voja as Owner of each, existing WOs and parts
- [ ] TypeScript compiles: `npx tsc --noEmit` zero errors
- [ ] Pre-commit hooks running
- [ ] Sentry installed and reporting to project

---

## What Phase 2 covers (for reference)
- Supabase Auth setup (email/password + Worker PIN flow)
- Next.js middleware for role-based routing
- App shell: layout, navigation, dark mode, org switcher
- No domain features yet — just the skeleton

---

## GitHub token for this session
Store in `.env.local` (never commit):
```
NEXT_PUBLIC_SUPABASE_URL=https://bfhioxqspmypcnpmakyg.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sb_publishable_i9V8xr4SJQ4V1b-6T9k49Q_gQLBJLIm
SUPABASE_SERVICE_ROLE_KEY=<get from Supabase dashboard → Settings → API>
```
