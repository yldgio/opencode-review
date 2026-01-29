# Code Review Multi-Agent Setup

A multi-agent code review system that automatically adapts to your project's technology stack.

## Quick Start

### Prerequisites

- [OpenCode CLI](https://opencode.ai) installed
- A configured LLM provider (e.g., GitHub Copilot, Anthropic, OpenAI)

### Installation

#### Option 1: Clone and Install

```bash
# Clone this repository
git clone https://github.com/your-org/code-review-oc /tmp/code-review

# Install into your project
cd /path/to/your/project
/tmp/code-review/install.sh .
```

#### Option 2: Manual Copy

1. Copy the `.opencode/` folder to your project root
2. Run stack detection:
   ```bash
   opencode run "@review-setup detect this project"
   ```

### Running a Code Review

```bash
# Review a specific file
opencode run "@review-coordinator review src/api/users.ts"

# Review changes in a PR (provide diff)
git diff main...HEAD | opencode run "@review-coordinator review this diff"

# Interactive mode (in TUI)
opencode
# Then type: @review-coordinator review src/api/users.ts
```

---

## Modes

### Interactive Mode

Default mode. The setup agent proposes detected stacks and asks for confirmation.

```bash
./install.sh /path/to/project
```

The agent will:
1. Scan your project files
2. Show detected technologies
3. Ask you to confirm or modify the detection
4. Generate the stack context file

### CI Mode

Non-interactive mode for automated pipelines.

```bash
./install.sh /path/to/project --ci
```

The agent will:
1. Scan your project files
2. Automatically select all detected stacks
3. Generate the stack context file without prompts

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
      
      - name: Install code review agents
        run: |
          git clone https://github.com/your-org/code-review-oc /tmp/code-review
          /tmp/code-review/install.sh . --ci
      
      - name: Run code review
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          # Get changed files
          CHANGED_FILES=$(gh pr view ${{ github.event.pull_request.number }} --json files -q '.files[].path')
          
          # Review each file
          for file in $CHANGED_FILES; do
            opencode run "@review-coordinator review $file" --ci
          done
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
  
  - script: |
      git clone https://github.com/your-org/code-review-oc /tmp/code-review
      /tmp/code-review/install.sh . --ci
    displayName: 'Install code review agents'
  
  - script: |
      opencode run "@review-coordinator review src/" --ci
    displayName: 'Run code review'
```

---

## Configuration

### Stack Context

After installation, the detected stack is stored in:
```
.opencode/rules/stack-context.md
```

You can edit this file to:
- Add stacks that weren't detected
- Remove stacks you don't want reviewed
- Add custom notes for reviewers

### Available Skills

| Skill | Stack | Detection Pattern |
|-------|-------|-------------------|
| `nextjs` | Next.js | `next.config.*` |
| `react` | React | `package.json` with `react` |
| `angular` | Angular | `angular.json` |
| `fastapi` | FastAPI | `requirements.txt` with `fastapi` |
| `nestjs` | NestJS | `package.json` with `@nestjs/*` |
| `dotnet` | .NET | `*.csproj`, `*.sln` |
| `docker` | Docker | `Dockerfile` |
| `github-actions` | GitHub Actions | `.github/workflows/*.yml` |
| `azure-devops` | Azure DevOps | `azure-pipelines.yml` |
| `bicep` | Bicep | `*.bicep` |

---

## Agents

### review-coordinator

The main orchestrator. Analyzes code and delegates to specialized sub-agents.

```bash
@review-coordinator review <file-or-directory>
```

### review-frontend

Specializes in frontend code: React, Angular, Vue, CSS, accessibility.

### review-backend

Specializes in backend code: APIs, databases, business logic, authentication.

### review-devops

Specializes in infrastructure: Docker, CI/CD, Terraform, Kubernetes.

### review-setup

Detects project stack and configures skills. Run automatically during installation.

```bash
@review-setup detect this project [--ci]
```

---

## Customization

### Adding Custom Rules

Create additional rule files in `.opencode/rules/`:

```markdown
# .opencode/rules/team-conventions.md

## Our Conventions

- All API responses must include `requestId`
- Database queries must use repository pattern
- ...
```

Then add to `.opencode/opencode.json`:

```json
{
  "instructions": [
    ".opencode/rules/stack-context.md",
    ".opencode/rules/team-conventions.md"
  ]
}
```

### Disabling Skills

Edit `.opencode/opencode.json`:

```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "angular": "deny"
    }
  }
}
```

---

## Troubleshooting

### Skills not loading

1. Check `.opencode/rules/stack-context.md` exists and lists skills
2. Verify skill files exist in `.opencode/skills/<name>/SKILL.md`
3. Check `opencode.json` has `"skill": { "*": "allow" }`

### Stack not detected

1. Run detection manually: `opencode run "@review-setup detect this project"`
2. Check if your stack's indicator files exist (see detection patterns above)
3. Manually add the stack to `stack-context.md`

### Agent not found

Ensure `.opencode/agent/` contains the agent files and OpenCode is run from the project root.
