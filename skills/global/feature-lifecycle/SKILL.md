---
name: feature-lifecycle
description: >
  Generic feature lifecycle orchestration from branch start to ready-for-review state.
  Uses git-workflow as the baseline for git operations and quality gates.
triggers:
  - "run feature lifecycle"
  - "start next user story"
  - "prepare feature end to end"
  - "close user story"
non_triggers:
  - "single lint fix only"
  - "release-only operation"
  - "pure architecture review"
---

# Feature Lifecycle

## Purpose
Execute a complete feature cycle consistently: prepare branch, implement scoped changes, validate quality, and leave branch ready for MR/PR.

## When to use
- User asks for end-to-end delivery of a user story.
- Work requires branch creation, implementation and quality gates.
- Team wants a repeatable closure flow before MR/PR.

## When NOT to use
- Small one-file edits that do not require lifecycle orchestration.
- Release management tasks without feature development.
- Standalone architecture assessments.

## Inputs
- User story identifier and acceptance criteria.
- Current git status and active branch.
- Project-specific validation commands.

## Steps
1. Start from updated `develop` and create feature branch.
2. Implement only the scoped feature changes.
3. Produce atomic commits grouped by responsibility.
4. Run mandatory quality checks for the repository.
5. Prepare MR/PR description and verify acceptance criteria.
6. Keep branch ready for review.

Note: Git commands, branch conventions and push safety rules are inherited from `../git-workflow/SKILL.md`.

## Expected outputs
- Feature branch with cohesive commits and validated changes.
- Acceptance criteria traceability in documentation.
- MR/PR package ready for reviewer handoff.

## Validation
- Ensure no cross-feature contamination in commits.
- Ensure quality gates pass before MR/PR.
- Ensure workflow references `git-workflow` as the source of git rules.

## Examples
- "Execute the feature lifecycle for US-009."
- "Prepare this feature end to end and leave it MR-ready."
