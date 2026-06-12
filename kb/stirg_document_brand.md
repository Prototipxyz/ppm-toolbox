# Stirg Metall — Document & Report Brand Spec

## Logo

| Variant | Usage |
|---|---|
| Dark logo (black wordmark + orange accent) | White/light backgrounds — quotes, invoices, standard reports |
| Light logo (white wordmark + orange accent) | Dark header bands, cover pages |

Source file: `Stirg_Logo.png` (contains both variants side by side — crop as needed per context).

---

## Color Palette

Derived from Nomotec brand sheet structure, applied to Stirg identity.

| Role | Name | Hex | RGB | Usage |
|---|---|---|---|---|
| **Primary accent** | Stirg Orange | `#E8450A` | R232 G69 B10 | Headers, dividers, accents, highlight cells |
| **Gradient mid** | Warm Orange | `#F3953F` | R243 G149 B63 | Gradient fills, secondary accents |
| **Gradient end** | Amber | `#F7A941` | R247 G169 B65 | Gradient end, warm highlights |
| **Primary dark** | True Black | `#000000` | R0 G0 B0 | Body text, logo on light bg |
| **Near-black** | Charcoal | `#1A1A1A` | R26 G26 B26 | Header bands, cover backgrounds |
| **Mid-grey** | Steel | `#4A4A4A` | R74 G74 B74 | Secondary text, table borders |
| **Light grey** | Fog | `#E8E8E8` | R232 G232 B232 | Alternating table rows, backgrounds |
| **White** | White | `#FFFFFF` | R255 G255 B255 | Page background, light logo context |

### Header Gradient (optional, cover pages / section headers)
Left `#E8450A` → mid `#F3953F` → right `#F7A941`

---

## Typography

Blastage (Nomotec original) is a commercial display font — replaced with **Oswald**, a free condensed sans-serif with comparable industrial character. Montserrat carries over unchanged.

| Role | Font | Weight | Size | Notes |
|---|---|---|---|---|
| Document title | Oswald | Bold (700) | 28–36pt | Cover page, all caps |
| Section headings (H1) | Oswald | SemiBold (600) | 16pt | All caps or title case |
| Sub-headings (H2) | Oswald | Regular (400) | 13pt | Title case |
| Body text | Montserrat | Regular (400) | 10–11pt | Default prose |
| Table header | Montserrat | Bold (700) | 9–10pt | All caps, white on `#E8450A` bg |
| Table body | Montserrat | Regular (400) | 9–10pt | Alternating `#FFFFFF` / `#E8E8E8` |
| Engineering IDs / codes | Courier New | Regular | 9–10pt | Part numbers, WO codes, invoice codes — monospace |
| Financial figures | Montserrat | SemiBold (600) | 10–11pt | Right-aligned |
| Footer / legal | Montserrat | Light (300) | 8pt | Grey `#4A4A4A` |

**Font sources (both free, Google Fonts):**
- Oswald: https://fonts.google.com/specimen/Oswald
- Montserrat: https://fonts.google.com/specimen/Montserrat

---

## Document Layout

### Page
- Size: A4 (210 × 297mm)
- Margins: Top 20mm · Bottom 20mm · Left 20mm · Right 20mm
- Language: Serbian primary, English secondary (bilingual per D-38)

### Header (all pages after cover)
- Left: Stirg logo (dark variant), height 12mm
- Right: Document title + code (e.g. `PONUDA / QUOTE   Q-26-001`)
- Divider: 2pt rule in `#E8450A` below header

### Footer
- Left: `Stirg Metall d.o.o. · PIB · MB · Address · Bank`
- Right: `Strana / Page X od / of Y`
- Divider: 0.5pt rule in `#4A4A4A` above footer
- Font: Montserrat Light 8pt, `#4A4A4A`

### Cover Page (quotes, formal reports)
- Full-width header band: Charcoal `#1A1A1A`, ~60mm tall
- Logo: light variant, centered or left-aligned in band
- Title below band: Oswald Bold 32pt, black
- Meta block (right-aligned): client name, date, document code, validity
- Accent rule: 3pt `#E8450A` under title

---

## Table Styles

### Standard Data Table
- Header row: background `#E8450A`, text white, Montserrat Bold 9pt, all caps
- Odd rows: `#FFFFFF`
- Even rows: `#E8E8E8`
- Borders: 0.5pt `#4A4A4A` outer; internal borders light grey `#E8E8E8`
- Numeric columns: right-aligned
- Code columns: Courier New monospace

### Financial Summary Table (quote totals, invoice)
- Label column: Montserrat Regular, left-aligned
- Value column: Montserrat SemiBold, right-aligned
- **Total row**: background `#1A1A1A`, text white, Montserrat Bold
- Subtotals: light `#E8E8E8` background

---

## Document Types & Specifics

| Document | Code format | Language | Notes |
|---|---|---|---|
| Quote | Q-26-NNN | SR + EN | Internal cost breakdown hidden from client |
| Work Order summary | WO-26-NNN | SR | Internal only |
| Invoice | INV-26-NNN | SR + EN | Via Pausal.rs; branding applied to export |
| Production report | — | SR | Parts list, op status, hours summary |
| Hours export | — | SR | Per WO or per period |

---

## Status Color Coding (in-document badges/cells)

Consistent with app status colors (architecture.md):

| Status | Background | Text |
|---|---|---|
| Complete / Paid | `#16A34A` | White |
| In Progress / Active | `#D97706` | White |
| Blocked / Overdue | `#DC2626` | White |
| Pending / Draft | `#0EA5E9` | White |
| Not Started / Closed | `#6B7280` | White |

---

## Iconography & Rules
- No decorative icons in print documents
- Orange `#E8450A` horizontal rules (2pt) used to separate major sections
- Thin grey (0.5pt `#E8E8E8`) rules between table rows
- Part number pipeline strip: not reproduced in print — replaced with text status column
