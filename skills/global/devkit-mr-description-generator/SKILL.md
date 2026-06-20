---
name: devkit-mr-description-generator
description: >
  Generate a generic MR/PR description markdown file from branch commits
  and user-story context. Produces reusable sections for any stack.
triggers:
  - "generate mr description"
  - "prepare merge request"
  - "open pull request"
  - "close user story"
non_triggers:
  - "merge branch"
  - "create commits"
  - "run architecture audit"
applyTo:
  - "**/*"
---

# MR Description Generator

## Purpose
Create a reusable MR/PR description from branch history and implementation docs, using a project-agnostic template.

## When to use
- Just before opening an MR/PR.
- When the branch has atomic commits ready for review.
- When user asks to prepare closure documentation for a US.

## When NOT to use
- To merge branches automatically.
- To generate commits.
- To run code quality gates.

## Inputs
- Active branch name.
- Commits since `origin/develop`.
- User story implementation document (if available).

## Steps
1. Detect branch and infer US identifier if present.
2. Read commit list from `origin/develop..HEAD`.
3. Build grouped changes section.
4. Fill template at `references/mr-template.md`.
5. Save output under `docs/mr/<branch-slug>-mr.md`.

## Expected outputs
- A markdown MR/PR description with clear, generic review sections.
- Traceability between branch, commits and implementation notes.

## Validation
- Output includes sections: "Que hace", "Por que", "Como probar", "Checklist".
- No project-specific paths or fixed platform assumptions.
- File renders correctly in markdown viewers.

## Examples
- "Generate MR description for current branch."
- "Prepare PR summary from commits and US notes."
