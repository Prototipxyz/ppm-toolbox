---
name: implement-rls-policy
description: Write and verify RLS policies for a PPM table. Use immediately after every migration. Tests policy against all 5 roles from the client SDK, never from SQL Editor which bypasses RLS.
---

# Skill: implement-rls-policy

## PPM Role Reference
| Role | org access | financial data | worker data |
|---|---|---|---|
| Owner | own org | yes | yes |
| Manager | own org | yes | yes |
| Supervisor | own org | no | all workers |
| Worker | own org | no | own only |
| Viewer | own org | read-only | no |

## Steps

### 1. Enable RLS on the table
```sql
ALTER TABLE <table_name> ENABLE ROW LEVEL SECURITY;
```

### 2. Write SELECT policy
```sql
CREATE POLICY "<table>_select" ON <table_name>
  FOR SELECT USING (
    organization_id IN (
      SELECT organization_id FROM members
      WHERE user_id = (SELECT auth.uid())
      AND is_active = true
    )
  );
```

### 3. Write INSERT policy
```sql
CREATE POLICY "<table>_insert" ON <table_name>
  FOR INSERT WITH CHECK (
    organization_id IN (
      SELECT organization_id FROM members
      WHERE user_id = (SELECT auth.uid())
      AND role IN ('Owner', 'Manager')
      AND is_active = true
    )
  );
```

### 4. Write UPDATE policy (needs both USING and WITH CHECK)
```sql
CREATE POLICY "<table>_update" ON <table_name>
  FOR UPDATE
  USING (organization_id IN (
    SELECT organization_id FROM members
    WHERE user_id = (SELECT auth.uid()) AND is_active = true
  ))
  WITH CHECK (organization_id IN (
    SELECT organization_id FROM members
    WHERE user_id = (SELECT auth.uid()) AND is_active = true
  ));
```

### 5. Financial data tables — add role restriction
For tables with financial data (quotes, invoices, transactions):
```sql
-- Restrict SELECT to Owner + Manager only
CREATE POLICY "<table>_select_financial" ON <table_name>
  FOR SELECT USING (
    organization_id IN (
      SELECT organization_id FROM members
      WHERE user_id = (SELECT auth.uid())
      AND role IN ('Owner', 'Manager')
      AND is_active = true
    )
  );
```

### 6. Worker-scoped tables (stirg_hours_log)
```sql
-- Workers see only their own rows
CREATE POLICY "hours_log_worker_select" ON stirg_hours_log
  FOR SELECT USING (
    CASE
      WHEN EXISTS (
        SELECT 1 FROM members
        WHERE user_id = (SELECT auth.uid())
        AND role IN ('Owner', 'Manager', 'Supervisor')
        AND is_active = true
      ) THEN organization_id IN (
        SELECT organization_id FROM members
        WHERE user_id = (SELECT auth.uid()) AND is_active = true
      )
      ELSE worker_user_id = (SELECT auth.uid())
    END
  );
```

### 7. Test each policy from client SDK
**Critical: SQL Editor bypasses RLS. Test from client SDK only.**

For each role, create a test Supabase client with that role's JWT and verify:
- [ ] Owner: can read/write own org, cannot read other orgs
- [ ] Manager: can read/write own org, cannot read financials of other orgs
- [ ] Supervisor: can read parts/hours, cannot read quotes/invoices
- [ ] Worker: can read own hours only, cannot read other workers' hours
- [ ] Viewer: can read specified data, cannot write anything
- [ ] Unauthenticated: cannot read anything

### 8. Cross-org isolation test
```sql
-- Verify no row from org B is accessible when authenticated as org A member
-- Must return 0 rows
SELECT count(*) FROM <table_name>
WHERE organization_id = '<org_b_id>';
-- Run this as org A member via client SDK
```

## Evidence required before marking done
- [ ] RLS enabled on table
- [ ] All four operations covered (SELECT, INSERT, UPDATE, DELETE)
- [ ] Each role tested from client SDK
- [ ] Cross-org isolation confirmed
- [ ] No policy uses bare `auth.uid()` — must use `(SELECT auth.uid())`

## Anti-rationalization
| Excuse | Counter |
|---|---|
| "The application layer handles access control" | Application bugs can bypass application checks. RLS cannot be bypassed by application bugs. |
| "I tested it in the SQL Editor" | SQL Editor runs as superuser and bypasses RLS entirely. Means nothing. |
| "I'll test all roles at the end" | Policies interact. Test each one immediately after writing it. |
