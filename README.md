# Code Review Multi-Agent System

A multi-agent code review system for [OpenCode](https://opencode.ai) that automatically adapts to your project's technology stack.

## Features

- **Global Installation** - Install once, use on any project
- **Automatic Stack Detection** - Detects your project's technologies (React, Next.js, FastAPI, Docker, etc.)
- **Specialized Agents** - Frontend, backend, and DevOps review specialists
- **Remote Skills** - Installs curated skills from [yldgio/anomalyco](https://github.com/yldgio/anomalyco)
- **Non-Invasive** - Only writes one optional file to your project (`stack-context.md`)

## Quick Start

### Prerequisites

- [OpenCode CLI](https://opencode.ai) installed
- Node.js and npm (for skill installation)
- A configured LLM provider

### Installation

The agents are installed **globally** to `~/.config/opencode/` and work on any project.

**One-liner (Unix/macOS/WSL):**
```bash
curl -fsSL https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.sh | bash
```

**One-liner (Windows PowerShell):**
```powershell
irm https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.ps1 | iex
```

<details>
<summary>Alternative: Clone and install</summary>

```bash
git clone https://github.com/yldgio/opencode-review /tmp/code-review
/tmp/code-review/install.sh
```
</details>

### Usage

Navigate to any project and use the review agents:

```bash
cd /path/to/your/project

# Detect stack and install skills (auto-installs by default)
opencode run --agent review-setup "detect the project stack"

# Or with interactive confirmation (for inside OpenCode sessions)
opencode run --agent review-setup "detect the project stack --interactive"

# Review a file
opencode run --agent review-coordinator "review src/api/users.ts"

# Review a PR diff
git diff main...HEAD | opencode run --agent review-coordinator "review this diff"

# Interactive mode
opencode
# Then type: @review-coordinator review src/
```

## How It Works

```
~/.config/opencode/          Your Project
├── agents/                   (no files installed)
│   ├── review-coordinator       │
│   ├── review-frontend          │
│   ├── review-backend           │
│   ├── review-devops            │
│   └── review-setup             │
└── tools/                       │
    └── install-skill            │
                                 │
         ┌───────────────────────┘
         │ @review-setup creates (optional)
         ▼
   .opencode/rules/stack-context.md
```

1. **Install once** - Agents are installed globally to `~/.config/opencode/`
2. **Run anywhere** - OpenCode loads global agents automatically in any project
3. **Optional setup** - Run `@review-setup` to detect your stack and write `stack-context.md`

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

## Skill Installation

Skills are installed **globally by default** (`~/.config/opencode/rules/`) so they're shared across all projects.

```bash
# Automatic (global - default)
opencode run --agent review-setup "detect the project stack"

# Automatic (project-level, to .opencode/rules/)
opencode run --agent review-setup "detect the project stack --project"

# Manual (global)
npx skills add https://github.com/yldgio/anomalyco --skill nextjs -a opencode -g -y

# Manual (project-level, to .opencode/rules/)
npx skills add https://github.com/yldgio/anomalyco --skill nextjs -a opencode -y
```

For project-specific skills via the `install-skill` tool, use `projectLevel: true`:
```
install-skill({ repo: "yldgio/anomalyco", skills: ["nextjs"], projectLevel: true })
```

## Project Files

After running `@review-setup`, only **one file** is created in your project:

```
your-project/
└── .opencode/
    └── rules/
        └── stack-context.md   ← Detected stacks and notes
```

This file is optional and can be:
- Committed to your repo (recommended for team consistency)
- Added to `.gitignore` if you prefer
- Manually edited to add/remove stacks

## CI/CD Integration

### GitHub Actions

```yaml
- name: Install review agents
  run: curl -fsSL https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.sh | bash

- name: Setup and review
  run: |
    opencode run --agent review-setup "detect the project stack"
    opencode run --agent review-coordinator "review src/"
```

### Azure DevOps

```yaml
- script: curl -fsSL https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.sh | bash
  displayName: 'Install review agents'

- script: opencode run --agent review-coordinator "review src/"
  displayName: 'Run code review'
```

## Uninstall

Remove the agents from your global config:

**Unix/macOS/WSL:**
```bash
rm ~/.config/opencode/agents/review-*.md
rm ~/.config/opencode/tools/install-skill.ts
```

**Windows PowerShell:**
```powershell
Remove-Item $env:USERPROFILE\.config\opencode\agents\review-*.md
Remove-Item $env:USERPROFILE\.config\opencode\tools\install-skill.ts
```

## Documentation

See [docs/SETUP.md](docs/SETUP.md) for full documentation.

## Contributing

See [AGENTS.md](AGENTS.md) for contribution guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.
