# Issue 7 - Migrate Skills to skills.sh Registry

**Status:** FUTURE

## Overview

Migrate local skills from `.opencode/skills/` to the [skills.sh](https://skills.sh) registry for easier distribution, updates, and community contributions.

---

## Background

Currently, skills are bundled locally in this repository and copied by the installer. The skills.sh ecosystem provides:

- **Remote installation**: `npx skills add <owner>/<skill-name>`
- **Independent versioning**: Skills can be updated without re-running installer
- **Community contributions**: Others can create and share skills
- **Leaderboard visibility**: Popular skills surface on skills.sh

---

## Proposed Changes

### 7.1 Publish Skills to GitHub

**Status:** TODO

**Requirement:**
Create GitHub repositories for each skill or a monorepo structure.

**Options:**

1. **Monorepo**: `anomalyco/code-review-skills` with subdirectories
2. **Individual repos**: `anomalyco/skill-nextjs`, `anomalyco/skill-react`, etc.

**Deliverable:**
- Skills published and installable via `npx skills add`

---

### 7.2 Update review-setup Agent

**Status:** TODO

**Requirement:**
Modify the setup agent to install skills from skills.sh instead of relying on local copies.

**Changes:**
1. After detecting stack, generate list of skill identifiers
2. Execute `npx skills add <skill>` for each required skill
3. Update `stack-context.md` format to reference remote skills

**New stack-context.md format:**
```markdown
## Skills to Install

- anomalyco/skill-nextjs
- anomalyco/skill-react
- anomalyco/skill-docker
- anomalyco/skill-github-actions
```

---

### 7.3 Simplify Installer

**Status:** TODO

**Requirement:**
Remove local skills from installer payload.

**Changes:**
1. Installer only copies agents and templates
2. Skills are installed on-demand by review-setup agent
3. Smaller installer footprint

---

### 7.4 Update Documentation

**Status:** TODO

**Requirement:**
Document the new skills.sh-based workflow.

---

## Dependencies

- Issue 6 (Documentation) should be complete first
- MVP should be validated before migration
- Requires GitHub organization/account for publishing

---

## Benefits

| Aspect | Current (Local) | Future (skills.sh) |
|--------|-----------------|-------------------|
| Updates | Re-run installer | `npx skills add` |
| Size | All skills bundled | On-demand |
| Community | Fork required | PRs to skill repos |
| Discoverability | None | skills.sh leaderboard |

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| skills.sh service unavailable | Fallback to local skills |
| Breaking changes in skills | Pin versions in stack-context.md |
| Network required for setup | Document offline mode |

---

## Acceptance Criteria

- [ ] All 10 MVP skills published to GitHub
- [ ] Skills installable via `npx skills add`
- [ ] review-setup agent updated to use remote skills
- [ ] Installer simplified (no local skills)
- [ ] Documentation updated
- [ ] Backward compatibility maintained (local skills still work)
