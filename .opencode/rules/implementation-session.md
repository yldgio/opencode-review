# Implementation Session Rules

These rules govern the implementation of the code-review-oc project. All agents working on this project must follow these guidelines.

---

## 1. Version Control

### Conventional Commits

All commits MUST follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Types:**
| Type | Description |
|------|-------------|
| `feat` | New feature (agent, skill, script) |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `chore` | Maintenance tasks (dependencies, configs) |
| `test` | Adding or updating tests |

**Scopes:**
| Scope | Description |
|-------|-------------|
| `agent` | Changes to `.opencode/agent/*.md` |
| `skill` | Changes to `.opencode/skills/*` |
| `rules` | Changes to `.opencode/rules/*` |
| `config` | Changes to `.opencode/opencode.json` |
| `installer` | Changes to `install.sh`, `install.ps1` |
| `docs` | Changes to `docs/*` |

**Examples:**
```
feat(agent): add review-setup agent for stack detection
feat(skill): add nextjs skill with App Router rules
fix(agent): correct detection pattern for Angular projects
docs(docs): add SETUP.md with installation instructions
chore(config): update opencode.json with skill permissions
```

### Atomic Commits

Each completed **issue or sub-issue** MUST result in a commit:

1. Complete the work for one issue/sub-issue
2. Update the status in `docs/IMPLEMENTATION_PLAN.md` to `DONE`
3. Update the status in the corresponding `docs/issues/issue-*.md` file
4. Stage all related changes
5. Commit with conventional commit message
6. Do NOT batch multiple issues into one commit

**Commit workflow:**
```bash
# After completing issue 2.1 (nextjs skill)
git add .opencode/skills/nextjs/SKILL.md
git add docs/IMPLEMENTATION_PLAN.md
git add docs/issues/issue-02-skills.md
git commit -m "feat(skill): add nextjs skill with App Router rules

Closes sub-issue 2.1"
```

---

## 2. Code Quality

### Markdown Files

- Use consistent heading hierarchy (no skipped levels)
- Use fenced code blocks with language specifiers
- Tables must have header row and alignment
- No trailing whitespace
- End files with single newline
- Use relative links for internal references

### YAML Frontmatter

- Valid YAML syntax (validate before commit)
- Required fields present per OpenCode spec
- Consistent indentation (2 spaces)
- No trailing commas

### Agent Prompts

- Clear, unambiguous instructions
- Structured sections with headings
- Explicit behavior for edge cases
- No placeholder text (e.g., `[TODO]`, `...`)

### Shell Scripts

- Use `set -e` for error handling (bash)
- Use `$ErrorActionPreference = "Stop"` (PowerShell)
- Quote variables to handle spaces
- Provide usage information
- Handle missing dependencies gracefully

---

## 3. Security

### Secrets

- NEVER hardcode secrets, API keys, or tokens
- Use environment variables or secure parameter references
- Check for accidental secret commits before pushing

### File Permissions

- Scripts must be executable: `chmod +x install.sh`
- No world-writable permissions

### Input Validation

- Agent prompts must validate/sanitize user input
- Scripts must validate arguments before use

### Dependency Security

- Pin versions where applicable
- Avoid unnecessary dependencies

---

## 4. Best Practices for This Stack

### OpenCode Agents (Markdown)

- Frontmatter must include all required fields:
  - `description` (required)
  - `mode` (required for non-default)
  - `tools` (explicit enable/disable)
- Prompt structure:
  - Role definition first
  - Workflow/process steps
  - Output format specification
  - Rules/constraints last
- Use `hidden: true` for sub-agents not user-invokable

### OpenCode Skills

- Folder name MUST match `name` in frontmatter
- Name format: lowercase alphanumeric with hyphens only
- Description: specific enough for agent to choose correctly
- Content: actionable checklists, not vague guidelines

### OpenCode Config (opencode.json)

- Always include `$schema` for validation
- Use explicit permissions (don't rely on defaults)
- Document non-obvious configuration choices

---

## 5. Testing Checklist

Before marking an issue as `DONE`:

- [ ] File(s) created at correct path(s)
- [ ] YAML/JSON syntax valid
- [ ] Frontmatter has required fields
- [ ] No placeholder text remaining
- [ ] Cross-references correct (file paths, skill names)
- [ ] Status updated in `IMPLEMENTATION_PLAN.md`
- [ ] Status updated in corresponding issue file
- [ ] Commit follows conventional commits format

---

## 6. Issue Workflow

1. **Start issue**: Set status to `IN_PROGRESS` in both files
2. **Implement**: Follow specs in issue file exactly
3. **Verify**: Run through testing checklist
4. **Update status**: Set to `DONE` in both files
5. **Commit**: Atomic commit with conventional message
6. **Next**: Move to next issue respecting dependencies
