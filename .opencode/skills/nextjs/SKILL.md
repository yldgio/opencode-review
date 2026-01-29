---
name: nextjs
description: Next.js 14+ App Router patterns, Server Components, API routes, and performance optimization
---

## Next.js Code Review Rules

### App Router Structure
- Verify `app/` directory structure follows conventions (`page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`)
- Check `use client` directive is only used when necessary (event handlers, hooks, browser APIs)
- Server Components should not import client-only libraries (useState, useEffect, etc.)

### Data Fetching
- Prefer Server Components for data fetching over client-side fetching
- Check for proper use of `cache()` for request deduplication
- Validate `revalidate` options for ISR (Incremental Static Regeneration)
- Ensure `generateStaticParams()` is used for static generation of dynamic routes

### Performance
- Images must use `next/image` with explicit `width`/`height` or `fill`
- Fonts should use `next/font` for automatic optimization
- Check for proper `Suspense` boundaries around async components
- Verify no blocking data fetches in layouts (affects all child routes)

### Security
- Server Actions must validate input
- No secrets exposed in client components
- Check `headers()` and `cookies()` usage is server-side only

### Common Anti-patterns
- Avoid `use client` at layout level (makes all children client components)
- Avoid fetching same data in multiple components (use cache or pass as props)
- Avoid `dynamic = 'force-dynamic'` without justification
