# PERMISSIONS / ROLES MODEL
<!-- TERMINOLOGY: Organizations (PPM subscribers) | Members (people within org) | Clients (external parties) -->

## 9. Permissions and Roles

---

### Role Architecture — Two Layers

**Layer 1: Functional role** — controls what a member can DO in the system
**Layer 2: Display role** — free text label on their profile, no functional effect

Example: Functional role = `Worker`, Display role = "Head Welder"

---

### Functional Roles

#### `super_admin` (platform level)
- **Scope:** Entire platform — all organizations, all data
- **Assigned to:** Voja Gavrilović + future hired developer

#### `Owner` (organization level)
- **Scope:** Everything within their organization — all WOs, all financials, all members, branding, billing

#### `Manager`
- **Scope:** Full operational data — all WOs, all financials, assign tasks to any member, approve hour logs
- **Cannot:** Manage members, access billing

#### `Supervisor`
- **Scope:** All workers visible (flat, no team structure — D-73)
- **Can:** Assign tasks to workers, log hours for any worker, approve hour logs
- **Cannot:** See financial data

#### `Worker`
- **Scope:** Their assigned tasks and their own logs only
- **Login method:** PIN code (D-72)
- **UI:** Completely different simplified mobile interface

#### `Viewer`
- **Scope:** Read-only specified data
- **Use cases:** External client given link to their job status, auditor

---

### Organization Types

| Type | Example | Description |
|---|---|---|
| `company` | Stirg Metal | Standard multi-member org, full features |
| `group` | TechCo Group | Holding — owns subsidiaries, aggregated dashboard |
| `solo` | Welder's workshop | Single member, personal plan |
| `platform` | PPM admin | Voja + developers, sees all orgs |

**Group structure:** subsidiaries have `parent_org_id` pointing to the group. Group owner sees all subsidiaries as cards, can drill in to any. Data isolation still enforced at DB level between subsidiaries.

---

### Member-Organization Relationship

One user (one email/login) can be a member of multiple organizations with different roles in each. Company switcher shown only when member belongs to 2+ organizations.

---

### Permissions Matrix

| Capability | super_admin | Owner | Manager | Supervisor | Worker | Viewer |
|---|---|---|---|---|---|---|
| View all WOs | ✓ | ✓ | ✓ | ✓ | ✗ | Read-only |
| Financial data | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ |
| All worker hours | ✓ | ✓ | ✓ | ✓ (all — D-73) | Own only | ✗ |
| Create WO / Quote | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ |
| Assign tasks | ✓ | ✓ | ✓ | ✓ (all — D-73) | ✗ | ✗ |
| Update op status | ✓ | ✓ | ✓ | ✓ | Assigned only | ✗ |
| Log hours | ✓ | ✓ | ✓ | ✓ self+any | Own only | ✗ |
| Approve hour logs | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ |
| Flag quality issues | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ |
| Manage members | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ |
| Manage branding | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ |
| Create/disable orgs | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |

---

### Data Isolation

All operational tables contain `organization_id`. PostgreSQL RLS enforces session can only access rows matching the current org. DB-level enforcement — application bugs cannot leak cross-org data. **RLS required on ALL tables before any external member gets an account.**

Worker login method: **PIN code** (D-72). Per-shift vs stay-logged-in: UNKNOWN (OQ-02).
