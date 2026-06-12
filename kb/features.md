# FEATURES

## Jobs / Work Orders
- Unified list: Quotes (Q-) and WOs (WO-) with status badges, priority, progress bar, quoted/billed amounts
- Filter chips: All / Active / Sent / Draft / Closed | Actions: + Quote, + WO
- Q→WO conversion: prefix changes, number stays; folder renamed at conversion
- WO status: Draft → Active → On Hold → Delivered → Invoiced → Paid → Closed
- `their_ref` field links to client ERP (Business Central, etc.)
- Google Drive folder created at Quote stage, renamed at WO win

## WO Detail Tabs
Overview · Parts · Procurement · Quote · Financials · Hours (scrollable tab bar)

**Overview:** 2×2 metric grid (client, deadline, their_ref, parts %), progress bar with 4 status counts, issues panel (amber)

**Parts (BOM):**
- 3 views: Tree (hierarchy, expandable) / Flat list (default, filterable) / Procurement (bought-in only)
- Part card: part number (monospace bold), description, type/qty/material, 9-segment pipeline strip, status badge
- Pipeline strip: CAD Fixed · Drawings Ready · Laser Cut · Bent · Cut to Size · Procured · Welded · Powder Coated · Assembly. Grey=not started, Amber=in progress, Green=done. N/A segments hidden (D-75)
- Expanded card: reference photo, per-operation statuses, norm hours, notes/flag
- Multi-select mode: checkboxes → batch action chips → direct DB write (zero tokens)
- Smart chips: skip parts already at target status
- Status hierarchy: assembly = blocked if any child blocked; complete only when all children complete

**Procurement:** items per WO, supplier, status (Pending/Ordered/In Transit/Arrived/Cancelled), ETA, issue notes

**Quote:**
- 3 sections: Operations (h × rate), Materials, Subcontractors
- Summary: subtotal → risk margin % → overhead % → markup % → **Total RSD + EUR**
- Internal cost breakdown hidden from client
- Actions: PDF SR/EN export, Send

**Financials:**
- 3-column: Quoted (blue, fixed) | Actual (amber, live) | Billed (green)
- Profit card: Gross Profit, Margin %, Quote accuracy %
- Breakdown table: Operations / Materials / Subcontractors / Rework (absorbed, red) / Overhead
- Rework always absorbed internally, shown as separate line for quality tracking

**Hours:** See Workflows — two modes (factory real-time / knowledge worker end-of-day)

## AI Chat Bar
- Persistent above bottom nav; part of layout flow, not floating
- Inactive: slim bar, ✦ icon, placeholder text
- Active: expands to contextual chips (change per screen) + text input + mic + attachment
- Context injected server-side: org, user, role, active WO, current tab
- Guard: manufacturing operations only; off-topic requests politely declined
- Token routing: simple commands → Groq (free); structured parsing → Haiku; complex queries → Sonnet

## CEO Dashboard
Multiple active WO cards: code, client, progress %, RAG status, blocked count, deadline, margin indicator. Single-glance status for parallel jobs.

## Exports
- Button per screen; dropdown: Current view CSV / Full list Excel / PDF SR/EN / filtered subsets
- Respects active filters. All PDFs apply org branding.

## Company Branding (D-79/D-80)
**App UI:** Company name shown in header. Light/dark toggle for all users. Same design for all organizations — no custom colors or logos in the app.
**Documents & reports only:** Logo (dark + light variants), primary color, font family, document identity (name, PIB, MB, address, bank, language). Applied to all PDF/Excel exports.

## Reports Tab (Stirg)
Metric cards: Active WOs, Delivery rate, Quote accuracy, Rework cost. Quick export list for common report types.

## Finance Tab (Prototip)
Income/expense metrics, recent transactions, equipment ROI progress bars.

## Features Explicitly Excluded
Real-time collaborative editing, MRP, Gantt scheduling, custom report builder, email parsing, double-entry bookkeeping, payroll, native app, GPS tracking, in-app messaging
