# Code Review Multi-Agent System

A multi-agent code review system for [OpenCode](https://opencode.ai) that automatically adapts to your project's technology stack.

## Features

- **Automatic Stack Detection** - Detects your project's technologies (React, Next.js, FastAPI, Docker, etc.)
- **Specialized Agents** - Frontend, backend, and DevOps review specialists
- **Remote Skills** - Installs curated skills from [yldgio/anomalyco](https://github.com/yldgio/anomalyco)
- **CI/CD Ready** - Works in interactive mode or fully automated pipelines

## Quick Start

### Prerequisites

- [OpenCode CLI](https://opencode.ai) installed
- Node.js and npm (for skill installation)
- A configured LLM provider

### Installation

**One-liner (Unix/macOS/WSL):**
```bash
curl -fsSL https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.sh | bash
```

**One-liner (Windows PowerShell):**
```powershell
irm https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.ps1 | iex
```

**With options:**
```bash
# Specify target directory
curl -fsSL https://... | bash -s -- /path/to/project

# CI mode (non-interactive)
curl -fsSL https://... | bash -s -- --ci
```

<details>
<summary>Alternative: Clone and install</summary>

```bash
git clone https://github.com/yldgio/opencode-review /tmp/code-review
cd /path/to/your/project
/tmp/code-review/install.sh .
```
</details>

### Usage

```bash
# Review a file
opencode run "@review-coordinator review src/api/users.ts"

# Review a PR diff
git diff main...HEAD | opencode run "@review-coordinator review this diff"

# Interactive mode
opencode
# Then type: @review-coordinator review src/
```

## Agents

| Agent | Purpose |
|-------|---------|
| `review-coordinator` | Main orchestrator, delegates to specialists |
| `review-frontend` | React, Angular, CSS, accessibility |
| `review-backend` | APIs, databases, authentication |
| `review-devops` | Docker, CI/CD, Terraform, Kubernetes |
| `review-setup` | Stack detection and skill installation |

## Supported Stacks

| Category | Technologies |
|----------|--------------|
| Frontend | Next.js, React, Angular |
| Backend | FastAPI, NestJS, .NET |
| DevOps | Docker, Terraform, Bicep, GitHub Actions, Azure DevOps |

## How It Works

1. **Setup**: `@review-setup` scans your project and installs relevant skills
2. **Review**: `@review-coordinator` analyzes code and delegates to specialists
3. **Skills**: Each agent loads stack-specific rules for targeted feedback

```
@review-coordinator
       │
       ├── Loads stack-context.md (detected technologies)
       ├── Loads relevant skills (nextjs, docker, etc.)
       └── Delegates to specialized agents
              │
              ├── @review-frontend
              ├── @review-backend
              └── @review-devops
```

## Configuration

After installation, customize in `.opencode/`:

- `rules/stack-context.md` - Detected stacks and notes
- `opencode.json` - Permissions and settings

See [docs/SETUP.md](docs/SETUP.md) for full documentation.

## CI/CD Integration

### GitHub Actions

```yaml
- name: Install code review agents
  run: curl -fsSL https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.sh | bash -s -- --ci

- name: Run code review
  run: opencode run "@review-coordinator review src/" --ci
```

### Azure DevOps

```yaml
- script: curl -fsSL https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.sh | bash -s -- --ci
  displayName: 'Install code review agents'
```

## Contributing

See [AGENTS.md](AGENTS.md) for contribution guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.
