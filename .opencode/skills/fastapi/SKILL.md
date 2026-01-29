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
