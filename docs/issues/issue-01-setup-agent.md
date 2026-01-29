# Issue 1 - Create Setup Agent for Stack Detection

**Status:** DONE

## Overview

Create a setup subagent that scans a project repository, detects the technology stack, and outputs a list of skills to install for code review.

---

## Subtasks

### 1.1 Create `.opencode/agent/review-setup.md`

**Status:** DONE

**Requirement:**
Add a setup subagent that detects the project stack and produces a list of skills to install.

**Implementation Details:**

1. Create file `.opencode/agent/review-setup.md`
2. Frontmatter configuration:
   ```yaml
   ---
   description: "Detects project stack and recommends skills for code review"
   mode: subagent
   hidden: true
   model: github-copilot/claude-sonnet-4
   temperature: 0.1
   tools:
     edit: false
     write: false
     bash: false
     task: false
     read: true
     glob: true
     grep: true
   ---
   ```
3. Prompt must include:
   - Instructions to scan for stack indicator files
   - Two operational modes:
     - **CI mode**: Fully automatic, no questions, outputs structured result
     - **Interactive mode**: Proposes detected stack, asks for confirmation
   - Mode detection: If prompt contains `--ci` or `mode: ci`, use CI mode; otherwise interactive
   - Structured output format for detected stacks and recommended skills

4. Output format (must be consistent for parsing):
   ```
   ## Detection Result
   
   **Mode:** [CI|Interactive]
   
   **Detected Stacks:**
   - [stack-name]: [evidence file/pattern]
   
   **Recommended Skills:**
   - [skill-name]
   
   **Command to install skills:**
   [instructions or next steps]
   ```

**Acceptance Criteria:**
- [ ] Agent file exists at `.opencode/agent/review-setup.md`
- [ ] Frontmatter has `mode: subagent`, `hidden: true`
- [ ] Tools config: `read: true`, `glob: true`, `grep: true`, all write tools `false`
- [ ] Prompt explicitly defines CI vs interactive behavior
- [ ] Output format is documented and unambiguous

---

### 1.2 Define Detection Matrix Inside the Setup Agent

**Status:** DONE

**Requirement:**
Provide a deterministic mapping between file patterns and stacks embedded in the agent prompt.

**Implementation Details:**

Embed the following detection matrix table in the agent prompt:

| File Pattern | Stack | Skill to Install |
|--------------|-------|------------------|
| `next.config.*` | Next.js | `nextjs` |
| `package.json` contains `"react"` | React | `react` |
| `angular.json` | Angular | `angular` |
| `package.json` contains `"@nestjs/"` | NestJS | `nestjs` |
| `requirements.txt` contains `fastapi` | FastAPI | `fastapi` |
| `pyproject.toml` contains `fastapi` | FastAPI | `fastapi` |
| `*.csproj` or `*.sln` | .NET | `dotnet` |
| `Dockerfile` | Docker | `docker` |
| `.github/workflows/*.yml` | GitHub Actions | `github-actions` |
| `azure-pipelines.yml` | Azure DevOps | `azure-devops` |
| `*.bicep` or `bicepconfig.json` | Bicep | `bicep` |

**Detection algorithm (to include in prompt):**
1. Use `glob` to find indicator files
2. For `package.json`, use `read` + check for dependency names
3. For `requirements.txt`/`pyproject.toml`, use `grep` to find package names
4. Collect all matches, deduplicate skills
5. Output structured result

**Acceptance Criteria:**
- [ ] Detection matrix table is embedded in agent prompt
- [ ] All 10 MVP skills are covered in the matrix
- [ ] Each entry has at least one concrete file pattern
- [ ] Algorithm for detection is described in prompt

---

## Files to Create/Modify

| File | Action |
|------|--------|
| `.opencode/agent/review-setup.md` | CREATE |

---

## Dependencies

- None (this is a foundational issue)

---

## Testing

To verify the agent works:
1. Run `opencode run "@review-setup detect this project --ci"` in a sample project
2. Verify output contains detected stacks and recommended skills
3. Run without `--ci` and verify it asks for confirmation
