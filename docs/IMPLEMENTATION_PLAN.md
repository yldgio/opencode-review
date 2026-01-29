# Code Review Multi-Agent Setup - Implementation Plan

## Scope

This plan defines the minimal MVP to install a multi-agent code review configuration that detects project stack, installs stack-specific skills/rules, and supports CI/CD and interactive setup modes.

## Conventions

- Status values: `TODO`, `IN_PROGRESS`, `DONE`
- Update status in this file AND in the corresponding issue file when completed.
- Each issue has a detailed file in `docs/issues/` with full implementation specs.

---

## Issues Overview

| Issue | Title | Status | Details |
|-------|-------|--------|---------|
| 1 | Create setup agent for stack detection | DONE | [issue-01-setup-agent.md](issues/issue-01-setup-agent.md) |
| 2 | Add stack-specific skills (MVP set) | TODO | [issue-02-skills.md](issues/issue-02-skills.md) |
| 3 | Coordinator integrates stack skills | TODO | [issue-03-coordinator-integration.md](issues/issue-03-coordinator-integration.md) |
| 4 | Project rules/config for stack context | TODO | [issue-04-rules-config.md](issues/issue-04-rules-config.md) |
| 5 | Minimal installer script | TODO | [issue-05-installer.md](issues/issue-05-installer.md) |
| 6 | Documentation for adopters | TODO | [issue-06-documentation.md](issues/issue-06-documentation.md) |

---

## Dependency Graph

```
Issue 1 (setup agent)
    │
    ├──► Issue 2 (skills) ──────────┐
    │                               │
    └──► Issue 4 (rules/config) ────┼──► Issue 3 (coordinator integration)
                                    │
                                    └──► Issue 5 (installer)
                                              │
                                              └──► Issue 6 (documentation)
```

**Execution Order:**
1. Issue 1 - Setup agent (foundational)
2. Issue 2 - Skills (can parallel with Issue 4)
3. Issue 4 - Rules/config (can parallel with Issue 2)
4. Issue 3 - Coordinator integration (depends on 2, 4)
5. Issue 5 - Installer (depends on 1, 4)
6. Issue 6 - Documentation (depends on all)

---

## Files Summary

### Agents (`.opencode/agent/`)
| File | Issue | Status |
|------|-------|--------|
| `review-setup.md` | 1 | DONE |
| `review-coordinator.md` | 3 | TODO (modify existing) |

### Skills (`.opencode/skills/`)
| File | Issue | Status |
|------|-------|--------|
| `nextjs/SKILL.md` | 2.1 | TODO |
| `react/SKILL.md` | 2.2 | TODO |
| `angular/SKILL.md` | 2.3 | TODO |
| `fastapi/SKILL.md` | 2.4 | TODO |
| `nestjs/SKILL.md` | 2.5 | TODO |
| `dotnet/SKILL.md` | 2.6 | TODO |
| `docker/SKILL.md` | 2.7 | TODO |
| `github-actions/SKILL.md` | 2.8 | TODO |
| `azure-devops/SKILL.md` | 2.9 | TODO |
| `bicep/SKILL.md` | 2.10 | TODO |

### Rules/Config (`.opencode/`)
| File | Issue | Status |
|------|-------|--------|
| `rules/stack-context.md` | 4.1 | TODO |
| `opencode.json` | 4.2 | TODO |

### Scripts (root)
| File | Issue | Status |
|------|-------|--------|
| `install.sh` | 5.1 | TODO |
| `install.ps1` | 5.1 | TODO |

### Documentation (`docs/`)
| File | Issue | Status |
|------|-------|--------|
| `SETUP.md` | 6.1 | TODO |
