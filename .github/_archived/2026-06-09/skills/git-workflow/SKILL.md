---
name: git-workflow
description: "Git commit and push workflow for Kotlin/Ktor projects. Use when: preparing commits, pushing changes, creating MR, merge request, pull request, git push checklist, atomic commits, pre-push validation, code review before push, build before commit, run tests before push, new feature branch, start feature, crear rama feature, iniciar feature."
argument-hint: "Optional: branch name or MR title"
---

# Git Workflow — Feature Branch, Atomic Commits, Build, Test, Push & MR

Flujo completo de git para este proyecto: desde la creación de la rama de feature hasta el MR con descripción detallada.

## Cuándo usar este skill

- El usuario quiere iniciar una nueva feature o crear una rama de feature
- El usuario quiere hacer commit y push de cambios
- El usuario dice "prepara el MR", "haz push", "crea el merge request", "inicio feature", "crear rama"
- Hay cambios staged/unstaged pendientes de commitar
- Se necesita validar la calidad antes de subir código

## Procedimiento obligatorio

Sigue los pasos en este orden. **No omitas ninguno.**

### PASO 0 — Crear rama de feature desde `develop` actualizado

> **Obligatorio al iniciar cualquier feature nueva.** Si ya estás en una rama de feature existente con trabajo en curso, salta al Paso 1.

```bash
# 1. Ir a develop
git checkout develop

# 2. Actualizar desde origin (solo fast-forward, nunca merge automático)
git pull --ff-only origin develop

# 3. Crear y cambiar a la nueva rama de feature
git checkout -b feature/<nombre-descriptivo>
```

**Convención de nombres de rama:**
- `feature/<descripcion-corta>` — nueva funcionalidad
- `fix/<descripcion-corta>` — corrección de bug
- `refactor/<descripcion-corta>` — refactorización
- `chore/<descripcion-corta>` — tareas de mantenimiento

Si `git pull --ff-only` falla (divergencia), **no hacer merge ni rebase automático**. Informar al usuario y analizar la situación antes de actuar.

### PASO 1 — Commits atómicos

Consulta el procedimiento completo en [./references/procedure.md](./references/procedure.md#paso-1--commits-atómicos).

Resumen:
1. `git status` + `git diff --stat` para ver el estado actual.
2. Agrupa los cambios por responsabilidad lógica (un commit = un cambio cohesivo).
3. Para cada grupo: `git add <archivos>` → `git commit -m "tipo(scope): descripción"`.
4. Usa Conventional Commits: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`.
5. Nunca mezcles cambios de features con fixes o refactors en el mismo commit.

### PASO 2 — Build

```bash
./gradlew build
```

- Si hay **errores**: detener. Arreglar antes de continuar.
- Si hay **warnings**: evaluarlos. Si se pueden arreglar sin romper nada, arreglarlos y volver al Paso 1 con un commit `fix:` o `chore:`.
- Si los warnings son aceptables (deprecaciones de terceros, etc.): documentar el motivo y continuar.

### PASO 3 — Tests

```bash
./gradlew test
```

- Si falla algún test: **detener**. Arreglar el test o el código y volver al Paso 1.
- Verificar que la cobertura no baja (revisar reporte en `build/reports/jacoco/`).

### PASO 4 — Code Review Local

```bash
./scripts/code_review_local.sh
```

- Si hay **errores críticos**: arreglar antes de continuar. Volver al Paso 1 con commit `fix:`.
- Si hay **warnings del linter**: intentar arreglarlos si no rompen nada. Commit `style:` o `chore:`.
- Si el RAG API no está disponible: advertir al usuario y continuar con revisión manual.

### PASO 5 — Push

Solo si los pasos 2, 3 y 4 están en verde:

```bash
git push origin <rama-actual>
```

- Si la rama no existe en remoto: `git push -u origin <rama-actual>`.
- **Nunca** hacer `--force` a menos que el usuario lo pida explícitamente y confirme el impacto.

### PASO 6 — Crear MR con descripción detallada

Genera la descripción del MR siguiendo la plantilla en [./assets/mr-description-template.md](./assets/mr-description-template.md).

La descripción debe incluir:
- **Qué** se cambió (resumen ejecutivo)
- **Por qué** (motivación / problema resuelto)
- **Cómo** (enfoque técnico)
- **Testing** (qué se probó y cómo)
- **Checklist** de validaciones completadas

Destino por defecto del MR: `develop`.

## Reglas inamovibles

| Regla | Detalle |
|-------|---------|
| Inicio de feature | Siempre: `checkout develop` → `pull --ff-only` → crear rama nueva |
| Base de feature | Siempre partir de `develop` actualizada en origin, nunca desde rama desactualizada |
| Commits atómicos | Un commit = un cambio lógico cohesivo |
| Build antes de push | `./gradlew build` sin errores |
| Tests antes de push | `./gradlew test` sin fallos |
| Code review antes de push | `./scripts/code_review_local.sh` sin errores críticos |
| No `--force` sin confirmación | Nunca reescribir historia sin pedir aprobación explícita |

## Checklist de salida (verificar antes del push)

- [ ] Rama de feature creada desde `develop` actualizado (`pull --ff-only`)
- [ ] Commits atómicos y bien nombrados (Conventional Commits)
- [ ] `./gradlew build` — sin errores, warnings evaluados
- [ ] `./gradlew test` — todos los tests en verde
- [ ] `./scripts/code_review_local.sh` — sin errores críticos
- [ ] Variables nuevas subidas a GitLab/CI (si aplica)
- [ ] `git push` ejecutado correctamente
- [ ] MR creado con descripción completa
