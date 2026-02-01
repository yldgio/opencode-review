# Code Review Multi-Agent Setup

A multi-agent code review system that automatically adapts to your project's technology stack.

## Architecture Overview

This system uses **global installation**: agents are installed to `~/.config/opencode/` and are available in all your projects without copying files.

```
~/.config/opencode/              (Global - installed once)
├── agents/
│   ├── review-coordinator.md    ← Main orchestrator
│   ├── review-setup.md          ← Stack detection
│   ├── review-frontend.md       ← Frontend specialist
│   ├── review-backend.md        ← Backend specialist
│   ├── review-devops.md         ← DevOps specialist
│   └── review-docs.md           ← Documentation & learnings
└── tools/
    └── install-skill.ts         ← Skill installer

Your Project/                    (No files installed by default)
└── .opencode/
    └── rules/
        └── stack-context.md     ← Created by @review-setup (optional)
```

## Quick Start

### Prerequisites

- [OpenCode CLI](https://opencode.ai) installed
- A configured LLM provider (e.g., GitHub Copilot, Anthropic, OpenAI)
- Node.js and npm (for installing skills)

### Installation

#### Option 1: One-liner (Recommended)

**Unix/macOS/WSL:**
```bash
curl -fsSL https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.sh | bash
```

**Windows PowerShell:**
```powershell
irm https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.ps1 | iex
```

#### Option 2: Clone and Install

```bash
git clone https://github.com/yldgio/opencode-review /tmp/code-review
/tmp/code-review/install.sh
```

#### Option 3: Manual Copy

Copy the agent and tool files to your global OpenCode config:

```bash
# Create directories
mkdir -p ~/.config/opencode/agents
mkdir -p ~/.config/opencode/tools

# Copy agents
cp .opencode/agent/*.md ~/.config/opencode/agents/

# Copy tools
cp .opencode/tools/*.ts ~/.config/opencode/tools/
```

### Usage

Navigate to any project and use the review agents:

```bash
cd /path/to/your/project

# Run stack detection (optional but recommended)
opencode run --agent review-setup "detect the project stack"

# Review a specific file
opencode run --agent review-coordinator "review src/api/users.ts"

# Review changes in a PR
git diff main...HEAD | opencode run --agent review-coordinator "review this diff"

# Interactive mode
opencode
# Then type: @review-coordinator review src/api/users.ts
```

---

## Stack Detection

The `@review-setup` agent scans your project to detect technologies and install relevant skills.

### Detection Matrix

| File Pattern | Stack | Skill |
|--------------|-------|-------|
| `next.config.*` | Next.js | `nextjs` |
| `package.json` with `"react"` | React | `react` |
| `angular.json` | Angular | `angular` |
| `package.json` with `"@nestjs/*"` | NestJS | `nestjs` |
| `requirements.txt` with `fastapi` | FastAPI | `fastapi` |
| `pyproject.toml` with `fastapi` | FastAPI | `fastapi` |
| `*.csproj` or `*.sln` | .NET | `dotnet` |
| `Dockerfile` | Docker | `docker` |
| `.github/workflows/*.yml` | GitHub Actions | `github-actions` |
| `azure-pipelines.yml` | Azure DevOps | `azure-devops` |
| `*.bicep` | Bicep | `bicep` |
| `*.tf` | Terraform | `terraform` |

### Stack Context File

After detection, `@review-setup` creates `.opencode/rules/stack-context.md` in your project:

```markdown
# Stack Context

## Detected Stacks

- .NET: Found `*.csproj` files
- Docker: Found `Dockerfile`

## Skills to Load

- dotnet
- docker

## Detection Timestamp

Generated: 2025-01-29T10:30:00Z

## Notes

.NET 8 Web API with Docker containerization.
```

This file:
- Is the **only file** added to your project
- Can be committed to version control for team consistency
- Can be manually edited to add/remove stacks
- Is **optional** - review agents work without it (using generic rules)

---

## Skill Discovery (Optional)

By default, `@review-setup` installs skills from hardcoded repository list without checking if they exist. This is fast but may fail if a skill doesn't exist in the repository.

### Enable Discovery Mode

Add `--discovery` flag to verify skill availability before installation:

```bash
# Check which skills are available, then install only those found
opencode run --agent review-setup "detect the project stack --discovery"

# CI mode with discovery
opencode run --agent review-setup "--discovery --ci"

# Interactive mode with discovery
opencode run --agent review-setup "--interactive --discovery"
```

### What Discovery Does

1. Detects your project's tech stack (same as normal mode)
2. Searches configured GitHub repositories to find matching skills
3. Installs only skills that were actually found
4. Reports which stacks have no available skill

### Configure Skill Repositories

Set the `SKILL_REPOS` environment variable to customize where skills are searched. **Only include repositories that are explicitly authorized** (see allowlist rules below):

```bash
# Unix/macOS
export SKILL_REPOS="my-org/approved-skills,yldgio/codereview-skills"

# Windows PowerShell
$env:SKILL_REPOS = "my-org/approved-skills,yldgio/codereview-skills"
```

**Default repositories** (searched in order, first match wins):

1. `yldgio/codereview-skills`
2. `github/awesome-copilot`
3. `vercel/agent-skills`
4. `anthropics/skills`

### Authorized Repositories (Allowlist)

Skills **must** be loaded **only** from repositories in the official allowlist. Do **not** load skills from arbitrary or user-provided repositories, and do **not** accept external repo lists without explicit maintainer/user approval.

**Where the allowlist lives:**
- Default allowlist: `.opencode/tools/discover-skills.ts` → `DEFAULT_REPOS`
- Documentation: this section (and README "Configure Skill Repositories")

**How to update the allowlist:**
1. Open a PR that updates `DEFAULT_REPOS` in `.opencode/tools/discover-skills.ts`.
2. Update the default repository list in `docs/SETUP.md` and `README.md` to match.
3. Require maintainer review and release a new version of the setup instructions.

For organization-specific allowlists, set `SKILL_REPOS` in your shell/CI to your approved repos only. No automation should add skills from external sources without explicit maintainer or user approval.

### Secure Configuration Examples

```bash
# CI: fixed allowlist, discovery enabled
export SKILL_REPOS="yldgio/codereview-skills,github/awesome-copilot"
opencode run --agent review-setup "detect the project stack --discovery --ci"
```

```bash
# Local: interactive confirmation + discovery
export SKILL_REPOS="yldgio/codereview-skills"
opencode run --agent review-setup "detect the project stack --interactive --discovery"
```

**Best practices:**
- Require maintainer review before adding a new repo to the allowlist.
- Verify repository ownership and **signed tags/commits** before approving.
- Prefer pinned releases/tags when installing skills manually.
- Keep `SKILL_REPOS` fixed in CI (do not allow PRs to override it).
- Review skill content before installation.

### GitHub API Rate Limits

The discovery tool uses GitHub's public API which has rate limits:
- **Unauthenticated:** 60 requests/hour
- **Authenticated:** 5,000 requests/hour

To increase the limit, set a GitHub token:

```bash
export GITHUB_TOKEN="ghp_your_token_here"
```

### Fallback Behavior

If discovery fails (due to rate limiting, network errors, etc.), the system automatically falls back to default behavior: installing required skills from the **default skill repository**. This ensures the setup process never completely fails due to discovery issues, while still avoiding unapproved sources.

---

## Agents

### review-coordinator

The main orchestrator. Analyzes code and delegates to specialized sub-agents.

```bash
# Review a file or directory
@review-coordinator review <file-or-directory>

# Review latest commit
@review-coordinator review the latest commit

# Review last N commits
@review-coordinator review the last 3 commits

# Review changes since main
@review-coordinator review changes since main
```

**Capabilities:**
- Reads stack context to understand your project
- Loads relevant skills for stack-specific feedback
- Delegates to frontend, backend, or devops agents
- Synthesizes findings into a unified report
- Reviews commits and branches using git

### review-frontend

Specializes in frontend code.

**Focus areas:**
- React, Angular, Vue components
- CSS and styling
- Accessibility (a11y)
- Client-side performance

### review-backend

Specializes in backend code.

**Focus areas:**
- API design and implementation
- Database queries and data access
- Business logic
- Authentication and authorization

### review-devops

Specializes in infrastructure.

**Focus areas:**
- Docker and containerization
- CI/CD pipelines
- Infrastructure as Code (Terraform, Bicep)
- Kubernetes configurations

### review-setup

Detects project stack and installs skills.

```bash
@review-setup                    # Interactive mode
@review-setup detect --ci        # CI mode (no prompts)
```

### review-docs

Verifies documentation alignment and captures learnings from reviews.

**Focus areas:**
- Documentation completeness and accuracy
- Convention alignment between code and docs
- Identifying actionable lessons from reviews
- Proposing updates to AGENTS.md, .github/copilot-instructions.md, or .github/instructions/*.md

**Output includes:**
- Documentation verification status
- Proposed learnings with suggested text
- Discrepancies found between code and documentation
- Action items for documentation updates

---

## Skills

Skills are specialized review rules for specific technologies. They're installed from remote repositories.

### Skill Sources

| Repository | Description |
|------------|-------------|
| [

yldgio/codereview-skills](https://github.com/

yldgio/codereview-skills) | Curated skills (15 skills) |
| [github/awesome-copilot](https://github.com/github/awesome-copilot) | Community skills (optional) |

### Available Skills

**Core:**
- `nextjs` - Next.js App Router patterns
- `react` - React best practices
- `angular` - Angular style guide
- `fastapi` - FastAPI patterns
- `nestjs` - NestJS architecture
- `dotnet` - .NET conventions

**DevOps:**
- `docker` - Container best practices
- `terraform` - IaC patterns
- `bicep` - Azure Bicep
- `github-actions` - GitHub Actions
- `azure-devops` - Azure Pipelines

**Additional:**
- `vercel-react-best-practices` - React performance
- `vercel-composition-patterns` - Component patterns
- `web-design-guidelines` - Accessibility
- `webapp-testing` - Playwright testing

### Manual Skill Installation

Skills can be installed globally (shared across projects) or at project level.

```bash
# Automatic detection and installation (global by default)
opencode run --agent review-setup "detect the project stack"

# Manual installation via npx (global)
npx skills add https://github.com/

yldgio/codereview-skills --skill nextjs -a opencode -g -y

# Manual installation via npx (project-level)
npx skills add https://github.com/

yldgio/codereview-skills --skill nextjs -a opencode -y
```

#### Using the install-skill tool directly

When calling the `install-skill` tool from an agent or prompt:

```
# Global installation (default)
install-skill({ repo: "

yldgio/codereview-skills", skills: ["nextjs", "react"] })

# Project-level installation
install-skill({ repo: "

yldgio/codereview-skills", skills: ["nextjs"], projectLevel: true })
```

| Scope | Location | Use case |
|-------|----------|----------|
| **Global** (default) | `~/.config/opencode/rules/` | Skills shared across all projects |
| Project-level | `.opencode/rules/` | Project-specific skills |

---

## CI/CD Integration

### GitHub Actions

```yaml
name: Code Review
on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install OpenCode
        run: npm install -g opencode-ai
      
      - name: Install review agents
        run: curl -fsSL https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.sh | bash
      
      - name: Detect stack
        run: opencode run --agent review-setup "detect the project stack"
      
      - name: Review code
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: opencode run --agent review-coordinator "review src/"
```

### Azure DevOps

```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - checkout: self
  
  - script: npm install -g opencode-ai
    displayName: 'Install OpenCode'
  
  - script: curl -fsSL https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.sh | bash
    displayName: 'Install review agents'
  
  - script: opencode run --agent review-coordinator "review src/"
    displayName: 'Run code review'
```

---

## Customization

### Changing the Model

By default, all review agents use `opencode/gpt-5-nano` (free, fast). You can override this in several ways:

#### Option 1: Project-level override (recommended)

Create `opencode.json` in your project root:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "review-coordinator": { "model": "opencode/claude-sonnet-4" },
    "review-frontend": { "model": "opencode/claude-sonnet-4" },
    "review-backend": { "model": "opencode/claude-sonnet-4" },
    "review-devops": { "model": "opencode/claude-sonnet-4" },
    "review-docs": { "model": "opencode/claude-sonnet-4" },
    "review-setup": { "model": "opencode/claude-sonnet-4" }
  }
}
```

You can copy `opencode.example.json` from this repo as a starting point.

#### Option 2: CI/CD with environment variable

Use `OPENCODE_CONFIG_CONTENT` for runtime override:

```yaml
# GitHub Actions example
env:
  OPENCODE_CONFIG_CONTENT: |
    {
      "agent": {
        "review-coordinator": { "model": "opencode/gpt-5-nano" },
        "review-frontend": { "model": "opencode/gpt-5-nano" },
        "review-backend": { "model": "opencode/gpt-5-nano" },
        "review-devops": { "model": "opencode/gpt-5-nano" }
      }
    }
```

#### Option 3: Edit global agents directly

Modify the agents in `~/.config/opencode/agents/`:

```bash
# Change model for all review agents
sed -i 's/model: opencode\/gpt-5-nano/model: opencode\/claude-sonnet-4/' ~/.config/opencode/agents/review-*.md
```

#### Recommended Models

| Model | Speed | Cost | Best for |
|-------|-------|------|----------|
| `opencode/gpt-5-nano` | Fast | Free | Quick reviews, CI/CD |
| `opencode/kimi-k2.5-free` | Fast | Free | Alternative free option |
| `opencode/glm-4.7-free` | Fast | Free | Alternative free option |
| `opencode/claude-sonnet-4` | Medium | Paid | Thorough reviews |
| `opencode/claude-opus-4-5` | Slow | Paid | Deep analysis |

### Adding Custom Rules

Create rule files in your project:

```markdown
# your-project/.opencode/rules/team-conventions.md

## Our Conventions

- All API responses must include `requestId`
- Database queries must use repository pattern
```

Then add to your project's `.opencode/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    ".opencode/rules/stack-context.md",
    ".opencode/rules/team-conventions.md"
  ]
}
```

### Custom Config Directory

Use `OPENCODE_CONFIG_DIR` to specify a different location for global agents:

```bash
export OPENCODE_CONFIG_DIR=/path/to/my/config
./install.sh
```

---

## Troubleshooting

### Agents not found

1. Check agents are installed globally:
   ```bash
   ls ~/.config/opencode/agents/
   ```

2. Verify OpenCode loads global agents:
   ```bash
   opencode agent list
   ```

### Stack not detected

1. Run detection manually:
   ```bash
   opencode run --agent review-setup "detect the project stack"
   ```

2. Check if your stack's indicator files exist (see detection matrix)

3. Manually add the stack to `stack-context.md`

### Skills not loading

1. Verify Node.js and npm are installed:
   ```bash
   node --version && npm --version
   ```

2. Check stack-context.md exists and lists skills

3. Run detection again to reinstall skills

### Skill installation failed

1. Check network connectivity to GitHub

2. Install skills manually:
   ```bash
   npx skills add https://github.com/

yldgio/codereview-skills --skill <name> -a opencode -y
   ```

---

## Uninstall

Remove the agents and tools from your global config:

```bash
rm ~/.config/opencode/agents/review-*.md
rm ~/.config/opencode/tools/install-skill.ts
```

On Windows PowerShell:

```powershell
Remove-Item ~/.config/opencode/agents/review-*.md
Remove-Item ~/.config/opencode/tools/install-skill.ts
```

---

## Agent Flow Diagram

```
User: @review-coordinator review src/api/users.ts
                │
                ▼
┌───────────────────────────┐
│   review-coordinator      │
│   (Primary orchestrator)  │
├───────────────────────────┤
│ 1. Load stack-context.md  │
│ 2. Load relevant skills   │
│ 3. Analyze code type      │
│ 4. Delegate to sub-agents │
└───────────────────────────┘
                │
   ┌────────────┼────────────┬────────────┐
   ▼            ▼            ▼            ▼
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ frontend │ │ backend  │ │ devops   │ │  docs    │
│  agent   │ │  agent   │ │  agent   │ │  agent   │
└──────────┘ └──────────┘ └──────────┘ └──────────┘
   │            │            │            │
   └────────────┼────────────┴────────────┘
                │
                ▼
┌───────────────────────────┐
│   Unified Review Report   │
│   - Critical findings     │
│   - Major findings        │
│   - Minor findings        │
│   - Documentation learnings│
│   - Verdict               │
└───────────────────────────┘
```

## Custom Tool: install-skill

**Location**: `~/.config/opencode/tools/install-skill.ts`

**Purpose**: Install skills from GitHub repositories with dependency checking.

**Arguments**:

| Argument | Type | Description |
|----------|------|-------------|
| `repo` | string | GitHub repo (`owner/repo` or full URL) |
| `skills` | string \| string[] | Skill name(s) to install |

**Example**:
```typescript
install-skill({
  repo: "

yldgio/codereview-skills",
  skills: ["nextjs", "react", "docker"]
})
```
