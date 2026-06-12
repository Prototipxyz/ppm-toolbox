---
name: implement-component
description: Write a React component for the PPM app. Use for any new UI component — from a simple status badge to the full pipeline strip. Covers shadcn/ui base, PPM design tokens, role-awareness, optimistic UI, and mobile-first layout.
---

# Skill: implement-component

## PPM Design Tokens (never hardcode these values)
```typescript
// Status colors — fixed, never change
const STATUS_COLORS = {
  'Complete':     { bg: '#16A34A', text: 'white' },
  'In Progress':  { bg: '#D97706', text: 'white' },
  'Blocked':      { bg: '#DC2626', text: 'white' },
  'Pending':      { bg: '#0EA5E9', text: 'white' },
  'Not Started':  { bg: '#6B7280', text: 'white' },
} as const

// Accent colors per org (applied via CSS variable, not hardcoded)
// --accent: set to #E8450A for Stirg, #2563EB for Prototip at org context level

// Typography
// Monospace: font-mono — for part numbers, WO codes, financial figures
// Body: system font stack via Tailwind

// Layout
// Mobile: bottom nav + swipe (default)
// Desktop ≥1024px: left sidebar
```

## Steps

### 1. Establish role awareness before writing any JSX
```typescript
type ComponentProps = {
  // Always pass role explicitly — never read from global state in components
  userRole: 'Owner' | 'Manager' | 'Supervisor' | 'Worker' | 'Viewer'
}
```

### 2. Start from shadcn/ui primitive
```bash
# Install only what you need
npx shadcn@latest add button
npx shadcn@latest add badge
# etc — never install the full library
```

### 3. Apply PPM design tokens
```tsx
// Correct — uses token
<span className="font-mono text-sm">{part.part_number}</span>

// Wrong — hardcodes value
<span style={{ fontFamily: 'monospace' }}>{part.part_number}</span>
```

### 4. Worker UI rules (applies to all components in /app/w/)
- [ ] No AI bar — do not render it, do not import it
- [ ] No financial data — do not query or display
- [ ] Mobile-only layout — no desktop sidebar
- [ ] Large tap targets — minimum 44px height on interactive elements
- [ ] Minimal text — floor language only (D-92)

### 5. Optimistic UI pattern (D-89)
```tsx
// Status updates reflect instantly before server confirmation
const [optimisticStatus, setOptimisticStatus] = useState(part.status)

const handleStatusChange = async (newStatus: string) => {
  setOptimisticStatus(newStatus) // instant UI update
  const result = await updatePartStatus({ partId: part.id, status: newStatus })
  if (result?.serverError) {
    setOptimisticStatus(part.status) // roll back on error
    toast.error('Update failed')
  }
}
```

### 6. Progressive disclosure (D-88)
```tsx
// Start collapsed, expand on tap
const [expanded, setExpanded] = useState(false)
return (
  <div>
    <button onClick={() => setExpanded(!expanded)}>
      {/* minimal summary view */}
    </button>
    {expanded && (
      <div>{/* full detail view */}</div>
    )}
  </div>
)
```

### 7. Empty states (D-94)
```tsx
// Never return null or blank div for empty data
if (parts.length === 0) {
  return (
    <EmptyState
      message="No parts on this job yet"
      action={{ label: "Import BOM", onClick: handleImport }}
    />
  )
}
```

### 8. Destructive action pattern (D-95)
```tsx
// Two-step confirmation for destructive actions
// Step 1: show consequences
// Step 2: require explicit typed confirmation
<DestructiveConfirm
  title="Replace BOM"
  consequences={[
    `This will delete ${existingParts.length} existing parts`,
    'This action cannot be undone',
    `New BOM has ${newParts.length} parts`,
  ]}
  confirmText="REPLACE BOM"
  onConfirm={handleBomImport}
/>
```

## Evidence required before marking done
- [ ] Role prop explicit on component
- [ ] No hardcoded color values — uses tokens
- [ ] Worker UI: no AI bar, no financials
- [ ] Optimistic updates with rollback on error
- [ ] Empty state handled
- [ ] Destructive actions have two-step confirmation
- [ ] Mobile tap targets ≥44px

## Anti-rationalization
| Excuse | Counter |
|---|---|
| "I'll make it role-aware later" | Role-unaware components ship to wrong users. Role is a prop from day one. |
| "The rollback is unlikely to be needed" | Rollback is needed whenever the network fails. Mobile users on factory floors have unreliable connections. |
| "Empty states can be a blank screen" | Blank screens confuse users and create support requests. |
