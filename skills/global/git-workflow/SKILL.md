---
name: git-workflow
description: >
  End-to-end git workflow for feature delivery: create branch from updated develop,
  make atomic commits, run quality gates, push safely and prepare MR/PR.
triggers:
  - "create feature branch"
  - "prepare commit and push"
  - "open merge request"
  - "git workflow"
non_triggers:
  - "implement business logic"
  - "design architecture"
  - "write ci pipeline from scratch"
argument-hint: "Optional: branch name or MR title"
---

# Git Workflow

## Purpose
Provide a safe, repeatable git flow from branch creation to MR/PR preparation, with quality checks before push.

## When to use
- Starting a new feature/fix/refactor branch.
- Preparing atomic commits and commit messages.
- Running pre-push checks and creating MR/PR description.

## When NOT to use
- Implementing product features.
- Deep code quality audit of a module.
- Infrastructure provisioning.

## Inputs
- Current repository state (`git status`, active branch, diffs).
- Optional target branch and MR/PR title.
- Project-specific build/test/lint commands.

## Steps
1. Update base branch and create working branch:
   - `git checkout develop`
   - `git pull --ff-only origin develop`
   - `git checkout -b feature/<descripcion-corta>`
2. Split changes into atomic commits using Conventional Commits.
3. Run project quality gates (build, test, lint/review script).
4. Push branch with upstream:
   - `git push -u origin <rama-actual>`
5. Generate MR/PR description using `assets/mr-description-template.md`.

## Expected outputs
- Clean branch created from updated `develop`.
- Atomic commits with clear intent.
- Green quality gates before push.
- MR/PR description ready for review.

## Validation
- No merge/rebase auto-resolution when `pull --ff-only` fails.
- No force push unless explicitly requested.
- Branch naming follows generic pattern: `feature/`, `fix/`, `refactor/`, `chore/`.

## Examples
- "Create a branch for US-015 and leave it ready to push."
- "Prepare atomic commits and a MR description for this branch."
