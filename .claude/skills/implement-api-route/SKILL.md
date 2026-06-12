---
name: implement-api-route
description: Write a type-safe Next.js API route or server action for the PPM app. Use for any data mutation or query that originates from the UI. Covers Zod validation, role checking, error handling, and typed responses.
---

# Skill: implement-api-route

## PPM Route Conventions
- Server actions live in `app/actions/<domain>.ts`
- API routes (webhook receivers, external integrations) in `app/api/<domain>/route.ts`
- Never put business logic in route handlers — extract to `lib/<domain>/`
- All mutations go through server actions, not API routes

## Steps

### 1. Define the Zod schema first
Before writing any handler logic:
```typescript
import { z } from 'zod'

const UpdatePartStatusSchema = z.object({
  partId: z.string().uuid(),
  operation: z.enum(['cad_fixed', 'drawings_ready', 'laser_cut', 'bent',
    'cut_to_size', 'procured', 'welded', 'powder_coated', 'assembly']),
  status: z.enum(['Not Started', 'In Progress', 'Done', 'N/A']),
})

type UpdatePartStatusInput = z.infer<typeof UpdatePartStatusSchema>
```

### 2. Write the server action with next-safe-action
```typescript
'use server'
import { createSafeActionClient } from 'next-safe-action'
import { createServerClient } from '@/lib/supabase/server'

const action = createSafeActionClient()

export const updatePartStatus = action
  .schema(UpdatePartStatusSchema)
  .action(async ({ parsedInput: { partId, operation, status } }) => {
    const supabase = createServerClient()

    // Role check — always explicit, never implicit
    const { data: member } = await supabase
      .from('members')
      .select('role')
      .single()
    if (!member || !['Owner', 'Manager', 'Supervisor', 'Worker'].includes(member.role)) {
      throw new Error('Unauthorized')
    }

    const { error } = await supabase
      .from('parts')
      .update({ [operation]: status })
      .eq('id', partId)

    if (error) throw new Error(error.message)
    return { success: true }
  })
```

### 3. Error handling checklist
- [ ] Zod validation error → return structured error, not 500
- [ ] Auth error → return 401, never leak details
- [ ] DB error → log to Sentry, return generic message to client
- [ ] Not found → return 404, not empty array
- [ ] Permission denied by RLS → return 403

### 4. Role guard pattern
Every mutation must explicitly check role before touching DB:
```typescript
const ALLOWED_ROLES = {
  updatePartStatus: ['Owner', 'Manager', 'Supervisor', 'Worker'],
  createWorkOrder: ['Owner', 'Manager'],
  approveHours: ['Owner', 'Manager', 'Supervisor'],
  viewFinancials: ['Owner', 'Manager'],
} as const
```

### 5. Financial mutation guard
For any action touching quotes, invoices, or transactions:
```typescript
// Quoted total is LOCKED after approval — never modify it
if (quote.status === 'Approved') {
  throw new Error('Cannot modify approved quote total')
}
```

### 6. Test the action
```typescript
// Test: valid input succeeds
// Test: invalid input returns Zod error
// Test: wrong role returns 401
// Test: Worker cannot update another worker's hours
// Test: financial action blocked for Supervisor role
```

## Evidence required before marking done
- [ ] Zod schema defined before handler
- [ ] Role check explicit in handler
- [ ] All error paths return structured errors
- [ ] Financial mutations check quote lock status
- [ ] Tests cover valid input, invalid input, wrong role
- [ ] No `any` types

## Anti-rationalization
| Excuse | Counter |
|---|---|
| "RLS handles auth, I don't need role checks in the handler" | RLS handles data isolation. Role checks in handlers handle permission logic RLS can't express (e.g. quote lock). Both are needed. |
| "I'll add error handling later" | Unhandled errors leak stack traces to clients and break the UI silently. |
| "The input is already validated on the client" | Client validation is UX. Server validation is security. Never trust client input. |
