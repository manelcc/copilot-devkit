---
name: feature-lifecycle
description: >
  [DEPRECATED] Esta skill ha sido migrada al agente feature-lifecycle-agent.
  La lógica git vive en la skill git-operations.
  No usar — usar el agente feature-lifecycle-agent en su lugar.
deprecated: true
replacedBy:
  - agent: feature-lifecycle-agent
  - skill: git-operations
---

> ⛔ **DEPRECATED** — Esta skill está obsoleta.
>
> - El ciclo completo de feature/fix/bugfix lo gestiona el **agente `feature-lifecycle-agent`**.
> - Las convenciones git (ramas, commits, merge) están en la **skill `git-operations`**.
>
> No activar esta skill. Redirigir al agente correspondiente.

---

# Skill: Feature Lifecycle (Roadmap de Migración)

## Cuándo activar esta skill

- Al empezar cualquier feature/fase del roadmap (`F0.x`, `F1`, `F2`…)
- Cuando el agente detecte cambios sin commitear al final de una tarea
- Si el usuario dice "seguimos", "siguiente fase", "aplicamos" o similar

---

## Ciclo completo (ejecutar en orden)

### 0. Verificar punto de partida

```bash
git status
git branch --show-current   # debe ser feature/migración/main-develop
git log --oneline -3
```

Si hay cambios sin commitear de sesiones anteriores, clasificarlos antes de
continuar (pertenecen a una feature previa o a la nueva).

---

### 1. Crear rama feature

La rama nace **siempre** desde `feature/migración/main-develop`.

```bash
# Convención de nombre: feature/migracion/F<N.M>-<slug-descriptivo>
git checkout feature/migración/main-develop
git checkout -b feature/migracion/F<N.M>-<slug>
```

Ejemplos de slugs por fase del roadmap:

| Fase | Slug recomendado |
|------|-----------------|
| F0.2 | `F0.2-gcp-secret-manager` |
| F0.3 | `F0.3-deploy-staging-verde` |
| F1   | `F1-jwt-auth` |
| F2   | `F2-project-crud` |
| F3   | `F3-tools-contextuales` |
| F4   | `F4-admin-templates` |
| F5.1 | `F5.1-gitlab-scm-adapter` |
| F6   | `F6-standalone-release` |

---

### 2. Implementar

- Hacer solo los cambios necesarios para la feature indicada.
- No refactorizar ni añadir comentarios en código no tocado.
- Para cambios en `mcpServer`: respetar la arquitectura de capas
  (`application` → `infrastructure` → `entrypoint`).

---

### 3. Validar (OBLIGATORIO antes de commitear)

#### Cambios en `mcpServer` o `build-logic`:

```bash
./gradlew :mcpServer:build --no-daemon
./gradlew :mcpServer:test --no-daemon
```

#### Cambios solo en `build-logic` / `sharedRes`:

```bash
./gradlew clean build --no-daemon
```

#### Cambios solo en infra/scripts/Docker (sin Kotlin):

Verificar sintaxis según el tipo de fichero:
```bash
# docker-compose
docker compose config --quiet

# shell scripts
bash -n <script.sh>
```

No avanzar si hay errores de compilación o tests fallidos.

---

### 4. Code review rápido

Antes del commit, revisar:

- [ ] Solo se stagean ficheros de **esta** feature (no arrastrar cambios de otras)
- [ ] No hay credenciales, tokens ni claves hardcodeadas
- [ ] Los tests cubren el comportamiento nuevo
- [ ] El `docker-compose.yml` / `.env` no se sube con secretos reales

```bash
git diff --staged   # revisar lo que va a entrar en el commit
```

---

### 5. Commit semántico

```bash
git add <solo ficheros de esta feature>
git commit -m "<tipo>(F<N.M>): <descripción corta>

- <bullet con detalle 1>
- <bullet con detalle 2>

Refs roadmap: F<N.M> — <título exacto del roadmap>"
```

**Tipos permitidos:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`

Ejemplos:
```
feat(F1): JWT auth — NimbusJwtTokenVerifier + whoami tool
feat(F2): project CRUD — list_my_projects + create_project tools
fix(F0.3): corregir env vars de deploy_staging en Cloud Run
```

---

### 6. Merge a `feature/migración/main-develop`

```bash
git checkout "feature/migración/main-develop"
git merge --no-ff feature/migracion/F<N.M>-<slug> \
  -m "merge(F<N.M>): <descripción corta>"
```

`--no-ff` es obligatorio para preservar el historial de cada feature.

---

### 7. Limpiar rama

```bash
git branch -d feature/migracion/F<N.M>-<slug>
```

---

### 8. Actualizar el roadmap (si procede)

Si la feature completa una entrada del roadmap, marcarla como hecha en
[doc/migracion/ROADMAP_FEATURES_PENDIENTES.md](../../doc/migracion/ROADMAP_FEATURES_PENDIENTES.md).

---

## Resumen visual

```
feature/migración/main-develop
  │
  └── git checkout -b feature/migracion/FX.Y-slug
        │
        ├── implementar cambios
        ├── ./gradlew :mcpServer:build + test  ← OBLIGATORIO
        ├── git diff --staged  (code review)
        ├── git add <solo ficheros de la feature>
        └── git commit -m "feat(FX.Y): ..."
              │
              └── git checkout feature/migración/main-develop
                    └── git merge --no-ff feature/migracion/FX.Y-slug
                          └── git branch -d feature/migracion/FX.Y-slug
```

---

## Errores frecuentes a evitar

| Error | Corrección |
|-------|-----------|
| Crear la rama desde `develop` o `main` | Siempre desde `feature/migración/main-develop` |
| `git add .` sin revisar | Usar `git add <ficheros>` + `git diff --staged` |
| Merge con `--ff` (fast-forward) | Usar siempre `--no-ff` |
| Commitear `.env` con secrets reales | `.env` está en `.gitignore`; commitear solo `.env.local.example` |
| Saltar el build/test antes del commit | Si el build falla, no avanzar |
