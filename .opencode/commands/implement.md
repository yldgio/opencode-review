---
description: Start implementation session for code-review-oc project
---
Implement the next pending issue from the code-review-oc project.

## Context Files
- Plan overview: @docs/IMPLEMENTATION_PLAN.md
- Session rules: @.opencode/rules/implementation-session.md

## Workflow
1. Read `docs/IMPLEMENTATION_PLAN.md` to find the first issue with status `TODO` (respect dependency order)
2. Read the corresponding `docs/issues/issue-*.md` for full implementation details
3. Set status to `IN_PROGRESS` in both files
4. Implement exactly as specified in the issue file
5. Verify against acceptance criteria checklist
6. Set status to `DONE` in both files
7. Create atomic commit following conventional commits format
8. Report completion and ask if you should continue with next issue

## Rules
- Follow `.opencode/rules/implementation-session.md` strictly
- One issue per session unless instructed otherwise
- Commits: `<type>(<scope>): <description>` format
- Update status in BOTH `IMPLEMENTATION_PLAN.md` AND issue file

## Arguments
$ARGUMENTS

If no arguments provided, implement the next TODO issue.
If argument is an issue number (e.g., "2.1"), implement that specific sub-issue.
If argument is "status", show current implementation progress.
