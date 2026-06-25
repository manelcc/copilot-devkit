---
applyTo: "**"
---

# Devkit Global Instructions

## 1. Naming convention devkit-

- All project artifacts must use `devkit-` prefix.
- Applies to agents, skills, instructions, prompts, scripts, and CLI naming.
- Use kebab-case for slugs and avoid spaces in identifiers.
- New artifacts without `devkit-` are non-compliant unless explicitly approved.

## 2. Commit naming

- Use Conventional Commits: `type(scope): summary`.
- Allowed types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`.
- Keep commits atomic and scoped to one concern.
- Avoid mixing unrelated stacks in one commit.

## 3. MR/PR conventions

- PR title format: `[US-XXX] short summary`.
- Include summary, scope, risks, validation evidence, and rollback note.
- Link related user story and affected stacks.
- Run required checks before opening PR.

## 4. Stack to orchestrator routing

| Stack | Orchestrator |
|---|---|
| Android | `devkit-android-project-orchestrator` |
| iOS | `devkit-ios-project-orchestrator` |
| Backend Kotlin/Ktor | `devkit-backend-kotlin-project-orchestrator` |
| Backend Python | `devkit-backend-python-project-orchestrator` |
| Backend Java/Spring | `devkit-backend-java-project-orchestrator` |
| Kotlin Multiplatform | `devkit-kmp-project-orchestrator` |
| Compose Multiplatform | `devkit-cmp-project-orchestrator` |

If stack detection is ambiguous, ask the user before delegating.

## 5. Quality routing policy (mandatory)

- Use `skills/global/devkit-clean-architecture-quality/` when the request is architecture quality, design boundaries, concurrency safety, security, reliability, or systemic technical risk.
- Use `skills/global/devkit-clean-code-guardian/` when the request is readability/maintainability only (naming, SRP, function length, nesting, magic numbers).
- If both apply, run `devkit-clean-architecture-quality` first and then `devkit-clean-code-guardian` for local refactor hygiene.

## 6. Global skills reference

- `skills/global/devkit-clean-architecture-quality/`
- `skills/global/devkit-clean-code-guardian/`
- `skills/global/devkit-development-lifecycle/` — ciclo completo guiado por defecto (soporta config custom via `.github/devkit-project.config.md`)
- `skills/global/devkit-git-workflow/`
- `skills/global/devkit-mr-description-generator/`
