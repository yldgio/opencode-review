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
