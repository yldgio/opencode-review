---
name: react
description: React component patterns, hooks best practices, state management, and performance optimization
---

## React Code Review Rules

### Hooks Rules
- Hooks must be called at top level (not inside conditions, loops, or nested functions)
- Custom hooks must start with `use` prefix
- `useEffect` must have correct dependency array (no missing/extra deps)
- `useEffect` cleanup functions must be returned for subscriptions/timers

### State Management
- State should be as local as possible (don't lift prematurely)
- Avoid redundant state (derive values instead of storing)
- Use `useReducer` for complex state logic with multiple sub-values
- Prefer controlled components over uncontrolled (except file inputs)

### Performance
- Wrap expensive computations in `useMemo`
- Stabilize callbacks with `useCallback` when passed to memoized children
- Use `React.memo()` for components that render often with same props
- Avoid creating objects/arrays inline in JSX (causes re-renders)

### Component Design
- Single responsibility: one component, one purpose
- Props should be minimal and well-typed
- Avoid prop drilling > 2 levels (use Context or composition)
- Prefer composition over prop-based conditional rendering

### Accessibility
- Interactive elements must be keyboard accessible
- Use semantic HTML (`button` not `div onClick`)
- Images need `alt` text
- Form inputs need associated labels

### Anti-patterns
- Avoid `useEffect` for state derivation (compute during render instead)
- Avoid `useEffect` on mount for data that could be fetched server-side
- Avoid index as key in lists that reorder
