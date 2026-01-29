# Agent Instructions

Guidelines for AI agents working on this repository.

## Project Structure

```
code-review-oc/
├── .opencode/
│   ├── agent/           # Review agents (Markdown)
│   ├── tools/           # Custom tools (TypeScript)
│   ├── rules/           # Project rules
│   └── opencode.json    # Configuration
├── templates/           # Config templates for installation
├── docs/                # Documentation
├── install.sh           # Bash installer
└── install.ps1          # PowerShell installer
```

## Conventions

### Commits

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>
```

| Type | Use for |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation |
| `refactor` | Code restructure |
| `chore` | Maintenance |

| Scope | Use for |
|-------|---------|
| `agent` | `.opencode/agent/*` |
| `tools` | `.opencode/tools/*` |
| `rules` | `.opencode/rules/*` |
| `config` | `opencode.json` |
| `installer` | `install.sh`, `install.ps1` |
| `docs` | `docs/*` |

### Agent Files

```yaml
---
description: "Required: what this agent does"
mode: subagent          # or primary
tools:
  read: true
  glob: true
  bash: false           # explicit enable/disable
---

Role definition first.

## Workflow
Steps the agent follows.

## Output Format
Expected output structure.

## Rules
Constraints and edge cases.
```

### Custom Tools

```typescript
import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "What this tool does",
  args: {
    param: tool.schema.string().describe("Parameter description"),
  },
  async execute(args) {
    // Validate dependencies first
    // Return clear success/error messages
    return "result"
  },
})
```

## Key Files

| File | Purpose |
|------|---------|
| `.opencode/agent/review-coordinator.md` | Main orchestrator |
| `.opencode/agent/review-setup.md` | Stack detection |
| `.opencode/tools/install-skill.ts` | Skill installer |
| `templates/stack-context.md` | Stack context template |

## Skills

Skills are hosted at [yldgio/anomalyco](https://github.com/yldgio/anomalyco).

To add a new detectable stack:
1. Add detection pattern to `review-setup.md` detection matrix
2. Create skill in `yldgio/anomalyco/skills/<name>/SKILL.md`

## Testing

Before committing:
- [ ] YAML/JSON syntax valid
- [ ] Agent frontmatter complete
- [ ] No placeholder text (`[TODO]`, `...`)
- [ ] Scripts handle errors gracefully
