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

## Skills

Skills are hosted at [
yldgio/anomaly-codereview](https://github.com/
yldgio/anomaly-codereview).

To add a new detectable stack:
1. Add detection pattern to `review-setup.md` detection matrix
2. Create skill in `
yldgio/anomaly-codereview/skills/<name>/SKILL.md`

## Architecture Notes

- **Global installation**: Agents install to `~/.config/opencode/` not project directories
- **Non-invasive**: Only `stack-context.md` is written to target projects (by review-setup)
- **Skill loading**: review-coordinator loads skills based on stack-context.md content
- **OpenCode native**: Uses OpenCode's built-in support for global agents directory
- **Documentation learnings**: review-docs subagent captures actionable lessons for AGENTS.md

## Documentation Learnings Protocol

The review system includes a protocol for capturing and preserving learnings from code reviews:

### How It Works

1. **During every review**, the `review-docs` subagent analyzes:
   - Whether documentation aligns with code changes
   - Patterns that should be formally documented
   - Recurring issues that indicate missing guidelines

2. **The review report includes**:
   - A "Documentation Learnings" section when updates are needed
   - Specific suggested text for `AGENTS.md` or `.github/copilot-instructions.md`
   - Discrepancies between code and existing documentation

3. **Target files for learnings**:
   | File | What to Add |
   |------|-------------|
   | `AGENTS.md` | AI agent guidelines, conventions, build/test commands |
   | `.github/copilot-instructions.md` | Coding standards, project-specific patterns |
   | `.github/instructions/*.md` | Language/framework-specific Copilot instructions |

### Learnings Criteria

Proposed learnings must be:
- **Actionable** — Can be turned into a clear guideline
- **General** — Applies beyond the specific code being reviewed
- **Valuable** — Would prevent bugs, improve consistency, or save time
- **Stable** — Unlikely to change frequently

### Example Learning Entry

When a review identifies a pattern worth documenting:

```markdown
## Proposed Learning

**Target:** AGENTS.md
**Section:** Error Handling

**Suggested text:**
"Always wrap external API calls in try-catch with specific error types. 
Log the original error before re-throwing a user-friendly message."

**Rationale:** Found 3 instances of inconsistent error handling in this PR.
```

## Testing

Before committing:
- [ ] YAML/JSON syntax valid
- [ ] Agent frontmatter complete
- [ ] No placeholder text (`[TODO]`, `...`)
- [ ] Scripts handle errors gracefully
- [ ] Test installers on both Unix and Windows
