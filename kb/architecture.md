# ARCHITECTURE

## Stack

| Layer | Technology |
|---|---|
| Frontend | Next.js 14+ (App Router), TypeScript |
| Styling | Tailwind CSS + shadcn/ui |
| Database | PostgreSQL via Supabase (`bfhioxqspmypcnpmakyg`) |
| Auth | Supabase Auth (email/password + PIN for Workers) |
| Storage | Supabase Storage (photos, logos, exports) |
| Hosting | Vercel (active, hosts prototip.xyz — PPM gets new repo + deployment) |
| Mobile | PWA — no native app |
| Error tracking | Sentry (add day one) |
| CI/CD | GitHub Actions (test → deploy) |
| Security | Snyk + Dependabot + OWASP ZAP + Playwright |
| AI base | Groq API — Llama 3.3 70B (free, 6k req/day) ✅ account created |
| AI paid | Anthropic Claude Haiku (~$0.50-1/org/month, absorbed) |
| AI enterprise | BYOK — Phase 3 |

## Route Structure

Two completely separate layouts sharing zero UI components:
- `/app/...` — main app (Owner, Manager, Supervisor, PM roles)
- `/w/...` — Worker UI (PIN-based, simplified, mobile-only)

## Multi-Tenancy
Shared database, shared schema. All tables have `organization_id`. PostgreSQL RLS enforces org isolation at DB level. **RLS must be enabled on ALL tables before any external member gets an account.**

## AI Integration
Every API call includes auto-injected system prompt: org context, user role, current screen, behavioral guardrails (operations-only).

Token routing:
- Zero-token path: multi-select chip → direct SQL
- Simple commands → Groq (Llama 3.3 70B, free)
- Structured parsing → Claude Haiku
- Complex queries → Claude Sonnet

Worker role: **AI bar hidden entirely** (D-90)

## Development Setup
- Work laptop: Tailscale installed ✓
- GitHub: `Prototipxyz` account ✓ — `ppm-toolbox` repo created ✓
- Vercel: active ✓ — PPM will be separate project from prototip.xyz
- Groq: account created ✓, model: `llama-3.3-70b-versatile`

## Recommended Build Workflow
1. **Claude.ai** (this project) — design decisions, KB updates, architecture
2. **Claude Design / Artifacts** — UI exploration and screen validation before coding
3. **v0 (Vercel)** — complex isolated component generation (pipeline strip, AI bar, financials layout)
4. **Claude Code (CLI)** — primary coding agent; multi-file features, migrations, refactors
5. **Cursor** — in-editor review, fast edits, cleanup

## Integrations

| Tool | Purpose | Status |
|---|---|---|
| Supabase | DB + Auth + Storage | ✅ Live |
| Google Drive | File storage | ✅ Set up — folder creation manual (D-83) |
| Attio CRM | Client relationships (standalone, not in-app) | ✅ Active |
| Google Calendar | Deadlines, reminders | ✅ Connected |
| Notion | Docs + notes | ✅ Active |
| Make | Supabase keep-alive ping (every 3 days) | ✅ Running — confirmed working |
| Groq | AI base layer (Llama 3.3 70B) | ✅ Account created |
| Pausal.rs | Legal invoicing (Prototip) | External manual |
| Business Central | ERP (Stirg) — complement via `their_ref` field | External manual |
| OneSignal | Push notifications | Phase 3 |
| Stripe | Subscription billing | Phase 4 |

## UI / Design System
- **Dark mode first** (primary), light mode available via toggle. Same design for all orgs (D-80).
- App header: shows **company name** only — no custom logo in the app (D-79)
- Stirg accent: `#E8450A` | Prototip accent: `#2563EB` | Header/nav: `#0D1117`
- Monospace for all part numbers, WO codes, financial figures
- Status colors (fixed): Complete=green · In Progress=amber · Blocked=red · Pending=sky · Not Started=grey
- Pipeline strip: 9 equal segments, grey/amber/green/hidden(N/A) — D-75
- Mobile: bottom nav + swipe. Desktop (≥1024px): left sidebar
- Component base: shadcn/ui — install only what's used; design system sits on top

## Business Model
| Tier | Size | Price |
|---|---|---|
| Solo | 1-3 members | €29-49/mo |
| Small shop | ≤15 members | €149-249/mo |
| Medium | 15-50 members | €299-499/mo |
| Enterprise | 50+ | Custom + BYOK |

Implementation fee: €500-1,500 one-time. AI cost absorbed in paid plans.

## Security Checklist (pre-pilot)
- [ ] RLS on all tables
- [ ] Sentry added
- [ ] Snyk + Dependabot on GitHub
- [ ] OWASP ZAP scan
- [ ] Playwright key flow tests
- [ ] Engineer review of RLS policies (20-40h)
