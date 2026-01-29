# Issue 2 - Add Stack-Specific Skills (MVP Set)

**Status:** DONE

## Overview

Create 10 stack-specific skills that agents can load on-demand to get specialized review guidance. Each skill is a markdown file with frontmatter following OpenCode skill conventions.

---

## Skill File Convention

All skills follow this structure:
- Location: `.opencode/skills/<skill-name>/SKILL.md`
- Frontmatter must include:
  - `name`: lowercase, matches folder name, 1-64 chars, alphanumeric with hyphens
  - `description`: 1-1024 chars, specific enough for agent to choose correctly

Example structure:
```markdown
---
name: example-skill
description: Brief description of what this skill provides
---

## Review Rules

[Checklist and guidance content]
```

---

## Subtasks

### 2.1 Skill: Next.js

**Status:** DONE

**Requirement:**
Add `.opencode/skills/nextjs/SKILL.md` with Next.js App Router review guidance.

**Implementation Details:**

```markdown
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
```

**Acceptance Criteria:**
- [ ] File exists at `.opencode/skills/nextjs/SKILL.md`
- [ ] Valid frontmatter with `name: nextjs`
- [ ] Contains rules for App Router, data fetching, performance
- [ ] Actionable checklist items (not vague guidelines)

---

### 2.2 Skill: React

**Status:** DONE

**Requirement:**
Add `.opencode/skills/react/SKILL.md` for React component architecture and hooks.

**Implementation Details:**

```markdown
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
```

**Acceptance Criteria:**
- [ ] File exists at `.opencode/skills/react/SKILL.md`
- [ ] Covers hooks rules, state, performance, accessibility
- [ ] Clear do/don't guidance

---

### 2.3 Skill: Angular

**Status:** DONE

**Requirement:**
Add `.opencode/skills/angular/SKILL.md` for Angular patterns.

**Implementation Details:**

```markdown
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
```

**Acceptance Criteria:**
- [ ] File exists at `.opencode/skills/angular/SKILL.md`
- [ ] Contains RxJS subscription management rules
- [ ] Contains change detection guidance (`OnPush`)

---

### 2.4 Skill: FastAPI

**Status:** DONE

**Requirement:**
Add `.opencode/skills/fastapi/SKILL.md` for FastAPI API design.

**Implementation Details:**

```markdown
---
name: fastapi
description: FastAPI endpoint design, Pydantic validation, dependency injection, and async patterns
---

## FastAPI Code Review Rules

### Endpoint Design
- Use appropriate HTTP methods (GET for reads, POST for creates, etc.)
- Return appropriate status codes (201 for create, 204 for delete, etc.)
- Use path parameters for resource identifiers, query params for filtering
- Group related endpoints with `APIRouter` and tags

### Pydantic Models
- Use Pydantic models for request body validation (not raw dicts)
- Define explicit response models with `response_model` parameter
- Use `Field()` for validation constraints (min/max, regex, etc.)
- Separate input models from output models (Create vs Response)

### Dependency Injection
- Use `Depends()` for shared logic (auth, db sessions, etc.)
- Database sessions should be dependencies, not global
- Close resources properly (use context managers or finally)

### Async
- Use `async def` for I/O-bound endpoints
- Don't mix sync and async database calls
- Use `asyncio.gather()` for parallel async operations
- Avoid blocking calls in async functions (use `run_in_executor`)

### Error Handling
- Use `HTTPException` for expected errors with proper status codes
- Create custom exception handlers for domain exceptions
- Don't expose internal error details to clients
- Log errors with context (request ID, user, etc.)

### Security
- Validate and sanitize all inputs
- Use `OAuth2PasswordBearer` or similar for auth
- Rate limit sensitive endpoints
- Never log sensitive data (passwords, tokens)
```

**Acceptance Criteria:**
- [ ] File exists at `.opencode/skills/fastapi/SKILL.md`
- [ ] Includes Pydantic validation guidance
- [ ] Includes response model guidance

---

### 2.5 Skill: NestJS

**Status:** DONE

**Requirement:**
Add `.opencode/skills/nestjs/SKILL.md` for NestJS patterns.

**Implementation Details:**

```markdown
---
name: nestjs
description: NestJS module architecture, dependency injection, guards, interceptors, and DTO validation
---

## NestJS Code Review Rules

### Module Architecture
- One module per feature/domain
- Modules should export only what other modules need
- Use `forRoot`/`forRootAsync` for configurable modules
- Avoid circular dependencies between modules

### Controllers
- Keep controllers thin (delegate to services)
- Use DTOs for request validation, not raw objects
- Apply guards at controller or handler level as appropriate
- Use proper HTTP status codes with `@HttpCode()`

### Services
- Services contain business logic
- Use constructor injection for dependencies
- Services should be stateless (no instance variables for request data)
- Use `@Injectable()` with appropriate scope (default singleton is usually correct)

### DTOs and Validation
- Use `class-validator` decorators on DTO properties
- Apply `ValidationPipe` globally or per-route
- Use `class-transformer` for type transformation
- Create separate DTOs for create/update operations

### Guards and Interceptors
- Guards for authentication/authorization
- Interceptors for logging, transformation, caching
- Use `@UseGuards()` and `@UseInterceptors()` decorators
- Order matters: guards run before interceptors

### Error Handling
- Use built-in exceptions (`NotFoundException`, `BadRequestException`, etc.)
- Create exception filters for custom error formatting
- Don't catch and ignore errors silently

### Security
- Validate all DTOs with `ValidationPipe`
- Use `@Exclude()` to hide sensitive fields in responses
- Implement rate limiting with `@nestjs/throttler`
- Sanitize user input before database queries
```

**Acceptance Criteria:**
- [ ] File exists at `.opencode/skills/nestjs/SKILL.md`
- [ ] Includes `class-validator` guidance
- [ ] Includes pipes and validation guidance

---

### 2.6 Skill: .NET

**Status:** DONE

**Requirement:**
Add `.opencode/skills/dotnet/SKILL.md` for ASP.NET Core.

**Implementation Details:**

```markdown
---
name: dotnet
description: ASP.NET Core patterns, dependency injection, middleware, async/await, and security
---

## .NET Code Review Rules

### Dependency Injection
- Register services with appropriate lifetime:
  - `Singleton`: stateless, thread-safe services
  - `Scoped`: per-request services (DbContext, etc.)
  - `Transient`: lightweight, stateless services
- Avoid captive dependencies (Singleton depending on Scoped)
- Use `IOptions<T>` pattern for configuration

### Async/Await
- Use `async`/`await` for I/O-bound operations
- Always pass `CancellationToken` and respect it
- Avoid `.Result` or `.Wait()` (causes deadlocks)
- Use `ConfigureAwait(false)` in library code
- Prefer `ValueTask` for hot paths that often complete synchronously

### Controllers
- Keep controllers thin (delegate to services)
- Use `[ApiController]` attribute for automatic model validation
- Return `ActionResult<T>` for type safety
- Use `[ProducesResponseType]` for API documentation

### Middleware
- Order matters: add middleware in correct sequence
- Authentication before Authorization
- Error handling middleware should be first (to catch all exceptions)
- Use `app.UseExceptionHandler()` for production error handling

### Model Validation
- Use Data Annotations or FluentValidation
- Validate at API boundary, not deep in business logic
- Return `400 Bad Request` for validation failures
- Include validation errors in response body

### Security
- Use `[Authorize]` attribute with policies
- Validate anti-forgery tokens for forms
- Use parameterized queries (EF Core does this by default)
- Don't log sensitive data
- Use HTTPS redirection middleware

### Entity Framework Core
- Use `AsNoTracking()` for read-only queries
- Avoid N+1 queries (use `Include()` or projection)
- Use migrations for schema changes
- Don't expose entities directly (use DTOs)
```

**Acceptance Criteria:**
- [ ] File exists at `.opencode/skills/dotnet/SKILL.md`
- [ ] Includes DI lifetime guidance
- [ ] Includes async/await and `CancellationToken` rules

---

### 2.7 Skill: Docker

**Status:** DONE

**Requirement:**
Add `.opencode/skills/docker/SKILL.md` for container best practices.

**Implementation Details:**

```markdown
---
name: docker
description: Dockerfile best practices, security hardening, multi-stage builds, and image optimization
---

## Docker Code Review Rules

### Base Images
- Pin base image to specific version (not `latest`)
- Use official images from trusted sources
- Prefer minimal images (`alpine`, `slim`, `distroless`)
- Regularly update base images for security patches

### Build Optimization
- Use multi-stage builds to reduce final image size
- Order instructions by change frequency (cache optimization)
- Combine `RUN` commands to reduce layers
- Use `.dockerignore` to exclude unnecessary files

### Security
- Run as non-root user (`USER` directive)
- Don't store secrets in image (use runtime injection)
- Don't use `--privileged` without justification
- Scan images for vulnerabilities
- Set `readonly` root filesystem where possible

### Health Checks
- Include `HEALTHCHECK` instruction
- Health check should verify app is actually working
- Set appropriate interval and timeout

### Instructions
- Use `COPY` instead of `ADD` (unless extracting archives)
- Set `WORKDIR` before `COPY`/`RUN`
- Use explicit `EXPOSE` for documentation
- Set meaningful `LABEL` metadata

### Example Good Dockerfile Pattern
```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Runtime stage
FROM node:20-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
USER appuser
EXPOSE 3000
HEALTHCHECK CMD wget -q --spider http://localhost:3000/health || exit 1
CMD ["node", "server.js"]
```
```

**Acceptance Criteria:**
- [ ] File exists at `.opencode/skills/docker/SKILL.md`
- [ ] Mentions `USER` directive for non-root
- [ ] Mentions `HEALTHCHECK` instruction

---

### 2.8 Skill: GitHub Actions

**Status:** DONE

**Requirement:**
Add `.opencode/skills/github-actions/SKILL.md` for CI checks.

**Implementation Details:**

```markdown
---
name: github-actions
description: GitHub Actions workflow security, performance optimization, and best practices
---

## GitHub Actions Code Review Rules

### Security
- Pin actions to full commit SHA (not `@v1` or `@main`)
- Use minimal `permissions` block (principle of least privilege)
- Never echo secrets or use them in URLs
- Use `secrets.GITHUB_TOKEN` instead of PATs when possible
- Audit third-party actions before use

### Permissions
```yaml
permissions:
  contents: read  # Minimal by default
  # Add only what's needed:
  # pull-requests: write
  # issues: write
```

### Secrets
- Store secrets in repository/organization secrets
- Use environments for production secrets with approvals
- Don't pass secrets as command arguments (visible in logs)
- Mask sensitive output with `::add-mask::`

### Performance
- Use caching for dependencies (`actions/cache` or built-in)
- Run independent jobs in parallel
- Use `concurrency` to cancel redundant runs
- Consider self-hosted runners for heavy workloads

### Workflow Structure
- Use reusable workflows for common patterns
- Use composite actions for shared steps
- Set appropriate `timeout-minutes` to prevent hung jobs
- Use `if:` conditions to skip unnecessary jobs

### Triggers
- Be specific with `paths` and `branches` filters
- Use `workflow_dispatch` for manual triggers
- Consider `pull_request_target` security implications

### Common Anti-patterns
- Avoid `actions/checkout` with `persist-credentials: true` unless needed
- Avoid running on `push` to all branches
- Avoid hardcoding versions that need updates
```

**Acceptance Criteria:**
- [ ] File exists at `.opencode/skills/github-actions/SKILL.md`
- [ ] Includes `permissions:` minimal scope guidance
- [ ] Includes action pinning security rule

---

### 2.9 Skill: Azure DevOps Pipelines

**Status:** DONE

**Requirement:**
Add `.opencode/skills/azure-devops/SKILL.md` for Azure Pipelines.

**Implementation Details:**

```markdown
---
name: azure-devops
description: Azure DevOps pipeline security, YAML structure, variable management, and deployment patterns
---

## Azure DevOps Pipelines Code Review Rules

### Security
- Use service connections with minimal permissions
- Store secrets in Variable Groups linked to Key Vault
- Use secure files for certificates/keys
- Enable branch policies for protected branches
- Require approvals for production environments

### Variables
- Use Variable Groups for shared configuration
- Mark sensitive variables as secret (masked in logs)
- Use template expressions `${{ }}` for compile-time, `$()` for runtime
- Don't hardcode environment-specific values

### Task Management
- Pin task versions (`task@2` not `task`)
- Use built-in tasks over script when available
- Set `continueOnError` only when intentional
- Use `condition` for conditional execution

### Stages and Jobs
- Use stages for environment progression (dev → staging → prod)
- Use deployment jobs for environment deployments
- Define explicit `dependsOn` for job ordering
- Use parallel jobs where independent

### Environments
- Create environments for each deployment target
- Configure approvals and checks on environments
- Use environment variables for environment-specific config
- Track deployments in environment history

### Templates
- Extract reusable steps into templates
- Use parameters for template customization
- Store templates in a shared repository
- Version template references

### Best Practices
- Use `checkout: self` with `fetchDepth: 1` for faster clones
- Cache dependencies with `Cache@2` task
- Set reasonable `timeoutInMinutes`
- Use `PublishPipelineArtifact` for outputs
```

**Acceptance Criteria:**
- [ ] File exists at `.opencode/skills/azure-devops/SKILL.md`
- [ ] Includes service connection security rules
- [ ] Includes variable/secret management guidance

---

### 2.10 Skill: Bicep

**Status:** DONE

**Requirement:**
Add `.opencode/skills/bicep/SKILL.md` for infrastructure-as-code rules.

**Implementation Details:**

```markdown
---
name: bicep
description: Azure Bicep IaC patterns, parameterization, security, and modular design
---

## Bicep Code Review Rules

### Parameters
- Use parameters for values that vary between deployments
- Mark sensitive parameters with `@secure()` decorator
- Provide `@description()` for all parameters
- Use `@allowed()` for constrained values
- Set sensible `@minLength()`, `@maxLength()`, `@minValue()`, `@maxValue()`

### Security
- Never hardcode secrets, connection strings, or keys
- Use Key Vault references for secrets
- Apply least privilege to managed identities
- Enable diagnostic settings for auditing
- Use private endpoints where available

### Resource Naming
- Use consistent naming convention
- Include environment, region, workload in names
- Use `uniqueString()` for globally unique names
- Follow Azure naming rules and restrictions

### Modules
- Break down large templates into modules
- One module per logical resource group
- Use outputs to pass values between modules
- Store shared modules in a registry

### Best Practices
- Use `existing` keyword to reference existing resources
- Use `dependsOn` only when implicit dependencies aren't enough
- Prefer symbolic names over `resourceId()` functions
- Use loops (`for`) instead of copy-paste for similar resources

### Outputs
- Output only values needed by other templates/scripts
- Mark sensitive outputs with `@secure()` (Bicep handles this)
- Include resource IDs for downstream references

### Example Patterns
```bicep
@description('Environment name')
@allowed(['dev', 'staging', 'prod'])
param environment string

@description('SQL admin password')
@secure()
param sqlAdminPassword string

var baseName = 'myapp-${environment}-${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${baseName}sa'
  location: resourceGroup().location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}
```
```

**Acceptance Criteria:**
- [ ] File exists at `.opencode/skills/bicep/SKILL.md`
- [ ] Includes `@secure()` decorator guidance
- [ ] Includes least privilege and Key Vault references

---

## Files to Create

| File | Action |
|------|--------|
| `.opencode/skills/nextjs/SKILL.md` | CREATE |
| `.opencode/skills/react/SKILL.md` | CREATE |
| `.opencode/skills/angular/SKILL.md` | CREATE |
| `.opencode/skills/fastapi/SKILL.md` | CREATE |
| `.opencode/skills/nestjs/SKILL.md` | CREATE |
| `.opencode/skills/dotnet/SKILL.md` | CREATE |
| `.opencode/skills/docker/SKILL.md` | CREATE |
| `.opencode/skills/github-actions/SKILL.md` | CREATE |
| `.opencode/skills/azure-devops/SKILL.md` | CREATE |
| `.opencode/skills/bicep/SKILL.md` | CREATE |

---

## Dependencies

- Issue 1 must define detection matrix that maps to these skill names

---

## Testing

For each skill:
1. Verify file exists at correct path
2. Validate frontmatter has required `name` and `description`
3. Verify `name` matches folder name
4. Test loading with `skill({ name: "<skill-name>" })` in OpenCode
