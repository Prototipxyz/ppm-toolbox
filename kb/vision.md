# PRODUCT VISION

## 1. Product Vision

A multi-tenant SaaS manufacturing job management platform built by Voja Gavrilović (mechanical engineer, Šabac, Serbia). Designed initially for personal use across two business contexts, intended to scale into a commercial product sold to SME manufacturers in Serbia and the former Yugoslav region.

The platform combines:
- Job/work order management (Quote → WO → Invoice lifecycle)
- Production part tracking with per-operation pipeline visualization
- Procurement tracking
- Job costing (quoted vs actual vs billed)
- Worker hour logging with norm vs actual comparison
- AI-assisted operations via a persistent chat bar
- Multi-company white-label branding on documents

**Working title:** PPM (Prototip Project Management)
**Candidate product name:** ORDO (Latin for "order/sequence/arrangement" — preferred candidate, not finalized)

The platform is specifically NOT a competitor to SAP or Business Central. Target positioning: simple enough to be understood immediately, powerful enough to replace Excel + WhatsApp for production management.

**Product category:** Lightweight MES (Manufacturing Execution System) with job costing — closest to Odoo Manufacturing stripped of 80% complexity with modern UX. The honest one-line description: what you get if Odoo Manufacturing and Jobber had a child, raised on a factory floor in Serbia, with an AI assistant.

---

## 2. Problem Statement

### For Voja personally
- Manages projects across two contexts (Stirg Metal as employee, Prototip as owner)
- No single tool handles both production tracking and engineering services billing
- Manual status tracking via Viber messages, Excel, paper
- No live job costing — no visibility into actual vs quoted costs during a job
- No structured way to track worker hours per operation for norm validation

### For Stirg Metal
- 15-worker railway subcomponents manufacturer
- Uses Business Central (BC) for official accounting — BC does not provide shop-floor production tracking
- Job status communicated via Viber — no structured record
- No real-time visibility into which parts are blocked or where production is delayed
- No live job costing against quoted values
- Worker hours not tracked per operation — cannot validate norms or identify inefficiency

### For the target market
- Thousands of SME manufacturers in Serbia and former Yugoslavia use Excel + WhatsApp + paper
- SAP/Business Central costs €50,000–5,000,000+/year with 1–3 year implementations
- No affordable, modern, mobile-first tool exists for this segment
- No tool designed by someone who actually works in a factory

---

## 3. Target Market

**Primary pilot:** Stirg Metal d.o.o. — railway subcomponents manufacturer, ~15 workers, Šabac, Serbia

**Secondary (personal):** Prototip — engineering services startup (3D scanning, CAD, DFM, RE, 3D printing, laser), sole operator

**Commercial target:**
- SME manufacturers in Serbia, Croatia, Slovenia, Bosnia, North Macedonia
- Revenue €500k–10M/year
- Using Excel + WhatsApp + paper for production management
- Cannot afford or implement Business Central / SAP
- Sheet metal, fabrication, assembly, contract manufacturing
