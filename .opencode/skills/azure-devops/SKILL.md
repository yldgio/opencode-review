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
- Use stages for environment progression (dev -> staging -> prod)
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
