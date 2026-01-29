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
