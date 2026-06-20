# Detailed Procedure - Git Workflow

## Step 0 - Create branch from updated develop

```bash
git checkout develop
git status
git pull --ff-only origin develop
git checkout -b feature/<descripcion-corta>
```

Naming convention:
- `feature/<descripcion-corta>`
- `fix/<descripcion-corta>`
- `refactor/<descripcion-corta>`
- `chore/<descripcion-corta>`
- `docs/<descripcion-corta>`

If `git pull --ff-only` fails, stop and ask for guidance. Do not auto-merge.

## Step 1 - Atomic commits

```bash
git status
git diff --stat
git diff
git diff --staged
```

Use Conventional Commits:
- `feat(scope): ...`
- `fix(scope): ...`
- `refactor(scope): ...`
- `test(scope): ...`
- `docs(scope): ...`
- `chore(scope): ...`

Example staging:
```bash
git add src/module/api/routes.kt
git add -p src/module/core/service.kt
```

## Step 2 - Quality gates before push

Run repository-specific checks, for example:
```bash
# Option A (Gradle repos)
./gradlew build
./gradlew test

# Option B (Python repos)
pytest

# Optional local review script if available
./scripts/code_review_local.sh
```

## Step 3 - Push

```bash
git branch --show-current
git push -u origin <rama-actual>
```

Rules:
- Never push directly to `main` or `develop`.
- Never use `--force` without explicit user confirmation.

## Step 4 - Prepare MR/PR

```bash
git log origin/develop..HEAD --oneline
git diff origin/develop --stat
```

Use template: `../assets/mr-description-template.md`.
