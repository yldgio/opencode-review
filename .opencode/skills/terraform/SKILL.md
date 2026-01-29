---
name: terraform
description: Terraform IaC patterns, state management, security, and modular design
---

## Terraform Code Review Rules

### File Organization
- Use consistent file structure: `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`
- Group related resources logically
- Use `terraform.tfvars` for environment-specific values (never commit secrets)
- Keep `*.tfstate` files out of version control

### Variables
- Declare all variables in `variables.tf`
- Provide `description` for all variables
- Use `type` constraints (string, number, bool, list, map, object)
- Set sensible `default` values where appropriate
- Use `sensitive = true` for secrets
- Apply `validation` blocks for input constraints

### Security
- Never hardcode secrets, credentials, or API keys
- Use environment variables or secret managers for sensitive values
- Mark sensitive variables and outputs with `sensitive = true`
- Enable encryption at rest for storage resources
- Apply least privilege IAM policies
- Use private subnets and security groups appropriately

### State Management
- Use remote state backends (S3, Azure Blob, GCS, Terraform Cloud)
- Enable state locking to prevent concurrent modifications
- Enable state encryption at rest
- Use workspaces or separate state files per environment
- Never store state locally in production

### Modules
- Create reusable modules for common patterns
- Pin module versions explicitly
- Use outputs to expose necessary values
- Document module inputs and outputs
- Follow module structure: `main.tf`, `variables.tf`, `outputs.tf`, `README.md`

### Resource Naming
- Use consistent naming conventions
- Include environment, region, and purpose in names
- Use `random` provider for unique suffixes when needed
- Follow cloud provider naming rules and restrictions

### Best Practices
- Use `terraform fmt` for consistent formatting
- Run `terraform validate` before applying
- Use `terraform plan` to review changes before apply
- Prefer `count` or `for_each` over duplicate resource blocks
- Use `locals` for computed values and reduce repetition
- Use `depends_on` only when implicit dependencies aren't sufficient
- Pin provider versions in `required_providers` block

### Outputs
- Output only values needed by other configurations
- Mark sensitive outputs with `sensitive = true`
- Include resource IDs and endpoints for downstream use
- Document outputs with `description`

### Example Patterns
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

locals {
  base_name = "myapp-${var.environment}"
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket" "main" {
  bucket = "${local.base_name}-data"
  tags   = local.common_tags
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}
```
