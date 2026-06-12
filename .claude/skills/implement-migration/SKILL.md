---
name: implement-migration
description: Write, apply, and verify a Supabase database migration for the PPM app. Use when adding tables, altering columns, adding indexes, or modifying sequences. Covers the full cycle from SQL to verified TypeScript types.
---

# Skill: implement-migration

## Inputs required before starting
- [ ] Feature spec exists in `kb/specs/` describing what this migration supports
- [ ] Table name follows convention: plural snake_case (work_orders, not WorkOrder)
- [ ] All foreign keys identified
- [ ] RLS requirement confirmed (every table needs RLS — no exceptions)

## Steps

### 1. Write the migration file
- Location: `supabase/migrations/YYYYMMDDHHMMSS_<description>.sql`
- Timestamp: use current UTC time
- Include: CREATE TABLE, all constraints, all indexes, comments on non-obvious columns
- Never use CASCADE DELETE without a comment explaining why
- Always include `organization_id uuid NOT NULL REFERENCES organizations(id)` on operational tables
- Use `(SELECT auth.uid())` not bare `auth.uid()` in RLS — bare call re-evaluates per row

### 2. Index checklist
Every column that appears in a WHERE clause or RLS policy needs an index.
- [ ] `organization_id` indexed on every table
- [ ] Foreign keys indexed
- [ ] Status columns indexed if filtered frequently
- [ ] Composite indexes for multi-column filters

### 3. Apply migration
```bash
supabase db push
# or for local dev:
supabase migration up
```
Verify output — no errors, no warnings about missing RLS.

### 4. Write RLS policy immediately
Do not move on without RLS. Call implement-rls-policy skill now.

### 5. Regenerate TypeScript types
```bash
supabase gen types typescript --project-id bfhioxqspmypcnpmakyg > types/supabase.ts
```
Verify: new table appears in generated types file.

### 6. Seed test data (if needed)
- Add to `supabase/seed.sql`
- Include one row per org (Stirg + Prototip) for every new table
- Test data must exercise edge cases defined in the spec

## Evidence required before marking done
- [ ] Migration applied without errors
- [ ] Table visible in Supabase dashboard
- [ ] RLS policy written and tested (see implement-rls-policy)
- [ ] TypeScript types regenerated and committed
- [ ] No `any` types introduced

## Anti-rationalization
| Excuse | Counter |
|---|---|
| "I'll add the index later" | Indexes are part of the migration. Missing indexes on RLS columns cause full table scans in production. |
| "RLS can wait until the feature is done" | RLS is part of the migration. Any table without RLS is publicly readable via the API. |
| "I'll regenerate types later" | Stale types cause TypeScript errors that mask real bugs. Regenerate immediately. |
