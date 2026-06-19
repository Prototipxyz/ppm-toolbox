# ENTITIES (DATA MODEL)
<!-- Organizations = PPM subscribers | Members = people within org | Clients = external parties -->
<!-- DB: bfhioxqspmypcnpmakyg | Auth key: sb_publishable_i9V8xr4SJQ4V1b-6T9k49Q_gQLBJLIm -->

## Core Tables

**organizations** ← rename from current `clients` table  
id, code, name, their_system, org_type (company/group/solo/platform), parent_org_id, preferred_currency, drive_folder_id, notes

**organization_branding** ← rename from `company_branding`  
organization_id (unique), logo_url, logo_light_url, logo_w/h_px, primary_color, secondary_color, background_color, document_name, document_address, document_pib, document_mb, document_bank, document_font (default Arial), doc_language (sr/en/bilingual)

**clients** ← NEW — external parties per organization  
id, organization_id, code (C001 — scoped per org), name, contact_name/email/phone, their_system, payment_terms_days, notes, drive_folder_id  
UNIQUE (organization_id, code)

**users** ← NEW (Supabase Auth)  
id (UUID), email (unique), name, avatar_url, is_super_admin (bool)

**members** ← NEW, replaces `company_users`  
id, organization_id, user_id, role (Owner/Manager/Supervisor/Worker/Viewer), display_role (free text), is_active, invited_at, joined_at  
UNIQUE (organization_id, user_id)

---

## Operational Tables

**sequences**  
name, year_code, last_num — drives next_code() function  
Formats: C001 | Q-26-001 | WO-26-001 | INV-26-001

**work_orders**  
id, code (WO-26-001), client_id, quote_id, title, context (Stirg/Prototip), status, priority, their_ref (BC ref), start_date, deadline, delivered_date, description, notes, drive_folder_id  
Status: Draft→Active→On Hold→Delivered→Invoiced→Paid→Closed

**quotes** / **quote_lines**  
Quote: code (Q-26-001), client_id, status (Draft/Sent/Approved/Rejected/Expired), total_amount, valid_until, notes (client-visible), internal_notes  
Lines: quote_id, activity, billing_type (Hourly/Fixed/Per Unit), quantity, unit, rate, amount, sort_order

**parts** — 365 GST parts seeded (flat, pending BOM reimport)  
id, work_order_id, part_number, pn_type, description, type, qty, thickness_mm, bends, weight_kg, material  
parent_id (self-ref, hierarchy), assembly_level (0=final/1=sub/2=part)  
photo_url (Supabase Storage, per WO instance — Option B)  
revision (TEXT, A/B/C revision letter — D-82)
display_name (auto-generated: underscore→space for descriptive names)  
Operations assigned via `part_operations` join table (max 12 per D-122)  
overall_status, notes | UNIQUE (work_order_id, part_number)

**procurement**  
work_order_id, item, type (Material/Service/Tooling), supplier, supplier_pn, qty, unit_price, currency, status (Pending/Ordered/In Transit/Arrived/Cancelled), order_date, eta, arrival_date, notes

**stirg_operations** ← EMPTY — awaiting Stirg Excel upload (OQ-09)  
code, category, name_srb, name_eng, unit, labor_rate_rsd, machine_rate_rsd, total_rate_rsd, markup_pct, quote_rate_rsd, quote_rate_eur, norm_hours_standard, norm_hours_complex

**stirg_hours_log**  
work_order_id, operation_id, worker_name, date, norm_hours, actual_hours  
started_at, paused_at, resumed_at, ended_at  
pause_type (break/material_wait/machine_issue/other_job/other), pause_note  
log_type (Standard/Rework/Revision/Recall)

**hour_log_approvals**  
work_order_id, reviewed_by, review_date, status (Approved/Queried/Adjusted), notes

**activity_types** (Prototip billing catalog — 7 seeded)  
name, billing_type, default_rate_eur, unit — e.g. 3D Scanning €45/h, CAD €32/h

**hours_log** (Prototip)  
work_order_id, activity_type_id, date, hours, quantity, rate_eur, total_eur, is_billable

**invoices**  
code (INV-26-001), work_order_id, client_id, pausal_reference, amount, currency, amount_eur, exchange_rate (default 117), issued/due/paid dates, status

**transactions**  
date, type (Income/Expense), source (Stirg/Prototip/Personal), category, description, amount, currency, amount_eur, work_order_id (opt), invoice_id (opt)

**equipment** (5 seeded — Einstar 2 €1200, Bambu H2S €1700, Prusa MK3S+ €1200, xTool D1 €1800, Dell €1700)  
name, category, purchase_price_eur, purchase_date, revenue_generated_eur

---

## Current DB State

- C001 Stirg Metal → organization ✓ (STIRG)
- Prototip org ✓ exists (PROTO); Ivan Advokat is C001 under PROTO in `public.clients` — resolved per U-04/OQ-49, confirmed live 2026-06-18
- Winkler Design is C001 under STIRG in `public.clients` — first fully in-house Stirg design project (200L FWT 41100 + 900L AWT 41200 tanks); BOM fixtures: kb/test-fixtures/winkler_200l_structured.json, winkler_900l_structured.json; confirmed live 2026-06-19
- All 365 parts have parent_id=NULL — awaiting structured BOM upload (OQ-10)
- `ppm_operations` / `org_operations` / `part_operations` tables do not exist yet — not seeded, contrary to prior note here (verified live 2026-06-18, see OQ-58)
- stirg_operations empty — awaiting Excel (OQ-09)
- Auto-number for empty BOM part numbers: C570001+ (above highest C561562)
- `_legacy_clients`/`company_branding` retained alongside the new org-scoped tables; several transactional tables (quotes/work_orders/invoices/transactions/parts/procurement/hours_log) still reference the legacy structure — see OQ-65
- RLS enabled on 5/20 tables (`organizations`, `organization_branding`, `users`, `members`, `clients`); 15 disabled — see OQ-66, D-185

---

## part_reference_photos
Canonical photo per part number per organization — enables photo reuse across WOs (D-84).

```
organization_id, part_number, photo_url, source (inventor_bom / manual), created_at
UNIQUE (organization_id, part_number)
```

**BOM import logic:**
1. For each part in BOM: check `part_reference_photos` for (org_id + part_number)
2. Found: copy URL to `parts.photo_url` — no re-upload needed
3. Not found: extract thumbnail from BOM → upload → save to `part_reference_photos` AND `parts.photo_url`
