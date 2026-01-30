# Agent Instructions

Guidelines for AI agents working on this repository.

## Project Structure

```
opencode-review/
├── .opencode/
│   ├── agent/           # Review agents (Markdown)
│   ├── tools/           # Custom tools (TypeScript)
│   └── opencode.json    # Configuration (for development)
├── docs/                # Documentation
├── install.sh           # Bash installer (global)
├── install.ps1          # PowerShell installer (global)
├── install-remote.sh    # Remote bash installer
└── install-remote.ps1   # Remote PowerShell installer
```

**Installation target:**
```
~/.config/opencode/      (Global OpenCode config)
├── agents/              # Review agents installed here
└── tools/               # Custom tools installed here
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
| `installer` | `install.sh`, `install.ps1`, `install-remote.*` |
| `docs` | `docs/*`, `README.md` |

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
| `.opencode/agent/review-setup.md` | Stack detection, writes stack-context.md |
| `.opencode/agent/review-docs.md` | Documentation alignment and learnings capture |
| `.opencode/tools/install-skill.ts` | Skill installer |
| `.opencode/tools/discover-skills.ts` | Skill discovery from remote repos |

## Skills

Skills are hosted at [yldgio/codereview-skills](https://github.com/yldgio/codereview-skills).

To add a new detectable stack:
1. Add detection pattern to `review-setup.md` detection matrix
2. Create skill in `yldgio/codereview-skills/skills/<name>/SKILL.md`

## Architecture Notes

- **Global installation**: Agents install to `~/.config/opencode/` not project directories
- **Non-invasive**: Only `stack-context.md` is written to target projects (by review-setup)
- **Skill loading**: review-coordinator loads skills based on stack-context.md content
- **OpenCode native**: Uses OpenCode's built-in support for global agents directory
- **Documentation learnings**: review-docs subagent captures actionable lessons for AGENTS.md

## Documentation Learnings Protocol

The `review-docs` subagent captures learnings from reviews and proposes updates to documentation.

**Target files:**

| File | What to Add |
|------|-------------|
| `AGENTS.md` | AI agent guidelines, conventions |
| `.github/copilot-instructions.md` | Coding standards, patterns |

**Learnings criteria:** Actionable, general, not already documented, valuable, stable.

## Testing

Before committing:
- [ ] YAML/JSON syntax valid
- [ ] Agent frontmatter complete
- [ ] No placeholder text (`[TODO]`, `...`)
- [ ] Scripts handle errors gracefully
- [ ] Test installers on both Unix and Windows

## Important: Installer Updates

**When adding or modifying files in `.opencode/agent/` or `.opencode/tools/`, you MUST update the installers:**

- `install.sh` — Bash installer for Unix/macOS/WSL
- `install.ps1` — PowerShell installer for Windows

New agents or tools will NOT be available to users unless they are explicitly copied in both installer scripts. Always verify that any new file is included in the installation process.
