---
name: angular
description: Angular component architecture, RxJS patterns, change detection, and module organization
---

## Angular Code Review Rules

### Module Organization
- Feature modules should be lazy-loaded where possible
- Shared module for reusable components/pipes/directives
- Core module for singleton services (provided in root)
- Avoid circular module dependencies

### Components
- Use `OnPush` change detection strategy for performance
- Inputs should be immutable (don't mutate input objects)
- Use `trackBy` function with `*ngFor` for lists
- Prefer standalone components for new code (Angular 14+)

### RxJS
- Always unsubscribe (use `takeUntilDestroyed()`, `async` pipe, or `DestroyRef`)
- Avoid nested subscribes (use `switchMap`, `mergeMap`, `concatMap`)
- Use `shareReplay` for HTTP calls that multiple subscribers need
- Handle errors with `catchError` (don't let errors kill the stream)

### Services
- Services should be `providedIn: 'root'` unless scoped to feature
- Use dependency injection, don't instantiate services manually
- HTTP calls belong in services, not components

### Templates
- Avoid complex logic in templates (use getters or pipes)
- Use `ng-container` for structural directives without extra DOM
- Sanitize dynamic HTML with `DomSanitizer` if needed

### Security
- Avoid `bypassSecurityTrust*` unless absolutely necessary
- Validate route parameters and query strings
- Use Angular's built-in CSRF protection with HttpClient
