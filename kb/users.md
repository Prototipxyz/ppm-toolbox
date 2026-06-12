# USERS & JOURNEYS

## Roles

| Role | Scope | Key permissions |
|---|---|---|
| super_admin | All organizations | Everything + create/disable orgs. Voja + future dev. |
| Owner | Own org | Everything + billing + member management + branding |
| Manager | Own org | All ops + all financials + assign tasks + approve hours |
| Supervisor | Own org | All workers visible (D-73), assign tasks, approve hours. No financials. |
| Worker | Own tasks only | See assigned ops, log own hours, flag quality issues. PIN login (D-72). Simplified UI. |
| Viewer | Read-only specified | External client or auditor |

Display role = free text label (e.g. "Head Welder") — no functional effect.

## Org Types

| Type | Example | Notes |
|---|---|---|
| company | Stirg Metal | Standard, full features |
| group | TechCo Group | Owns subsidiaries via parent_org_id; aggregated dashboard |
| solo | Welder's workshop | Single member, personal plan |
| platform | PPM admin | Voja + devs, sees all orgs |

## Member-Org Relationship
One user (one email) can belong to multiple orgs with different roles. Org switcher shown only when member belongs to 2+ orgs.

## Key User Journeys

**Voja (daily, Stirg context):**  
Login → company picker → Stirg Metal → CEO Dashboard → tap WO-26-001 → Parts tab → AI bar: "What's blocking C518314.1.1?" → Procurement tab → Financials → Export PDF

**Welder (morning):**  
Login → straight to task list (one org) → tap ▶ Start → work → Pause (select reason) → Resume → Done → supervisor sees log for approval

**PM (end-of-day hours):**  
Tap ✦ → type "3h CAD WO-26-001, 1.5h quote Q-26-004" → AI parses → confirm → logged

**CEO (Monday status check):**  
Login → dashboard: 5 WO cards → sees WO-26-001 red (blocked) → taps → Financials tab → done. Never drills into individual worker data.

**New customer onboarding:**  
Voja creates org → sets branding → invites Owner by email → Owner invites members → imports first BOM → production begins

**Quote lifecycle:**  
Inquiry → Quote created → Drive folder created → PDF SR/EN sent → Won: folder renamed, WO opens → BOM imported → delivery → invoice → close
