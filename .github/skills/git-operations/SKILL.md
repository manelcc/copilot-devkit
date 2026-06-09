---
name: "git-operations"
description: >
  Gestiona el flujo git completo del proyecto: creación de ramas, commits atómicos
  semánticos, merge a develop y limpieza. Incluye el guardrail de contaminación entre features.
applyTo:
  - "**/*"
triggers:
  - "crea la rama para la feature"
  - "crea la rama para el fix"
  - "crea la rama para el bugfix"
  - "git push checklist"
  - "push workflow"
  - "pre-push validation"
  - "build before commit"
  - "run tests before push"
  - "haz el commit"
  - "commits atómicos"
  - "integra a develop"
  - "merge a develop"
  - "limpia la rama"
  - "naming de rama"
  - "convención de commits"
nonTriggers:
  - Revisión de calidad de código (usar clean-code-guardian)
  - Generación de pipelines CI/CD (usar gitlab-cicd / github-actions-cicd / azure-pipelines-cicd)
  - Implementación de features (usar kotlin-mcp-expert o feature-lifecycle-agent)
---

# Git Operations

## Propósito

Define y aplica las convenciones git del proyecto MCP Server ShareResources:
naming de ramas, commits atómicos semánticos, merge strategy y limpieza.
También detecta y advierte activamente cuando se mezclan cambios de features distintas.

> Esta skill es la fuente única para workflow git end-to-end. El contenido de `git-workflow`
> ha sido consolidado aquí para evitar solapamientos.

## Cuándo usar esta skill

- Al crear una rama nueva para una feature, fix o bugfix.
- Al preparar y ejecutar commits.
- Al integrar una rama terminada a `develop`.
- Cuando el agente necesita verificar el estado del repositorio.

## Cuándo NO usar esta skill

- Para revisar calidad de código → usar `clean-code-guardian`.
- Para generar pipelines → usar las skills `*-cicd`.
- Para implementar lógica de negocio → usar `kotlin-mcp-expert`.

---

## Setup — instalar security hook

> El repositorio incluye un security hook en `.githooks/pre-commit`.
> **Cualquier desarrollador o agente que clone el repositorio DEBE ejecutar esto antes de cualquier commit:**

```bash
./gradlew installGitHooks --no-daemon
```

Esto configura `git config core.hooksPath .githooks` y activa el hook automáticamente.

**El hook bloquea el commit si:**
1. Hay ficheros `.env`, `.pem`, `.key`, `.p12`, `.jks` staged.
2. Hay credenciales hardcodeadas en el diff staged (`password=`, `secret=`, `api_key=`, etc.).

---

## Rama base

```
develop
```

Todas las ramas de trabajo nacen desde `develop` y se integran de vuelta a `develop`.

---

## 🚫 GUARDRAIL ABSOLUTO — PROHIBIDO ESCRIBIR EN `develop`

> **`develop` es de solo lectura para cualquier agente, skill o usuario.**

**NUNCA está permitido:**
- `git commit` estando en la rama `develop`
- `git push origin develop` con cambios directos
- `git merge` en `develop` sin pasar por una rama de trabajo
- Aplicar `git cherry-pick`, `git revert` o `git reset` directamente sobre `develop`

**El flujo correcto es SIEMPRE:**
```
develop → feature/<ticket>-<slug> → (MR/PR revisado) → develop
```

**Si el agente detecta que está en `develop` con cambios pendientes, DEBE:**
1. Parar inmediatamente.
2. Emitir el mensaje de bloqueo:

```
🚫 BLOQUEADO: Estás intentando escribir directamente en `develop`.
Esta rama es de solo lectura. Todo cambio debe ir en una rama de trabajo.

Acción requerida:
  1. Crea una rama: git checkout -b feature/MCP-<ticket>-<slug>
  2. Lleva tus cambios a esa rama
  3. Abre un MR desde esa rama hacia develop

El agente no continuará hasta que estés en una rama de trabajo.
```

3. No ejecutar ninguna operación de escritura hasta que el usuario confirme que está en una rama de trabajo.

---

---

## Naming de ramas

| Tipo | Formato | Ejemplo |
|---|---|---|
| Feature | `feature/MCP-<ticket>-<slug>` | `feature/MCP-42-add-share-resource-tool` |
| Fix | `fix/MCP-<ticket>-<slug>` | `fix/MCP-17-correct-auth-header` |
| Bugfix | `bugfix/MCP-<ticket>-<slug>` | `bugfix/MCP-55-null-pointer-project-list` |

**Reglas del slug:**
- Minúsculas con guiones (`-`), sin espacios ni caracteres especiales.
- Descriptivo: 2-5 palabras que identifiquen el trabajo.
- Prefijo del proyecto en mayúsculas: `MCP`.

---

## Pasos de ejecución

### 1. Verificar punto de partida

Antes de crear cualquier rama, verificar que el estado es limpio y estamos en `develop`:

```bash
git status                    # debe mostrar "nothing to commit"
git branch --show-current     # debe ser develop
git pull origin develop       # traer últimos cambios — SOLO lectura
git log --oneline -5          # revisar estado
```

> **⛔ `git pull` en `develop` es la ÚNICA operación de escritura permitida sobre esta rama
> (actualizar el puntero local desde el remoto). Cualquier otra escritura está prohibida.**

Si hay cambios sin commitear en `develop`, el agente **DEBE parar** y aplicar el guardrail absoluto descrito arriba antes de continuar.

### 2. Crear rama de trabajo

```bash
# Feature
git checkout -b feature/MCP-<ticket>-<slug>

# Fix
git checkout -b fix/MCP-<ticket>-<slug>

# Bugfix
git checkout -b bugfix/MCP-<ticket>-<slug>
```

### 3. Guardrail — Detección de contaminación entre features

> **⚠️ REGLA CRÍTICA: Una rama = Un ticket. Nunca mezclar.**

Antes de cada `git add`, el agente **DEBE** revisar `git diff` e identificar si los cambios pertenecen exclusivamente al ticket activo.

**Señales de contaminación a detectar:**
- Cambios en ficheros no relacionados con la tarea actual.
- Implementaciones de otra feature/fix/bugfix mezcladas.
- Imports o dependencias de código que pertenece a otro ticket.

**Acción ante contaminación detectada:**
```
⚠️ ADVERTENCIA: Se han detectado cambios que parecen pertenecer a otro ticket/feature.
Ficheros afectados: [lista de ficheros]
Antes de continuar, debes decidir:
  1. Hacer stash de esos cambios y trabajarlos en su propia rama
  2. Confirmar que esos cambios SÍ pertenecen a este ticket
¿Cómo quieres proceder?
```

El agente **NO continúa** hasta recibir confirmación del usuario.

### 3.5 ⛔ PRE-COMMIT GATE — informe obligatorio de fases

> **Este paso es BLOQUEANTE. Ningún `git add` ni `git commit` puede ejecutarse
> hasta que el agente haya producido este informe y todos los ítems sean ✅.**

Antes de iniciar cualquier commit, el agente DEBE emitir el siguiente informe
completando el estado real de cada fase:

```
╔══════════════════════════════════════════════════════╗
║       PRE-COMMIT GATE — PHASE COMPLETION REPORT      ║
╠══════════════════════════════════════════════════════╣
║  Feature: MCP-<ticket> — <slug>                      ║
║  Branch:  feature/MCP-<ticket>-<slug>                ║
╠══════════════════════════════════════════════════════╣
║  Fase 0 — Pre-flight check              [ ✅ / ❌ ] ║
║  Fase 1 — Branch creation               [ ✅ / ❌ ] ║
║  Fase 2 — Implementación                [ ✅ / ❌ ] ║
║  Fase 3 — Contamination guardrail       [ ✅ / ❌ ] ║
║  Fase 4 — Unit tests (JaCoCo ≥40%)      [ ✅ / ❌ ] ║
║  Fase 5 — clean-code-guardian audit     [ ✅ / ❌ ] ║
║  Fase 5 — Kotlin Server Quality Analyst [ ✅ / ❌ ] ║
╠══════════════════════════════════════════════════════╣
║  GATE STATUS: [ ✅ OPEN — proceed to commits ]       ║
║             / [ ❌ BLOCKED — fix items above ]       ║
╚══════════════════════════════════════════════════════╝
```

**Reglas del gate:**
- Si cualquier ítem es ❌ → parar, corregir la fase, y volver a emitir el informe.
- El agente **NO puede saltarse este gate** aunque el usuario lo pida explícitamente.
- Si `clean-code-guardian` o `Kotlin Server Quality Analyst` no se han ejecutado → ❌ obligatorio.
- El informe debe aparecer en la respuesta al usuario ANTES de cualquier bloque de comandos git.

### 4. Preparar commits atómicos

Un commit atómico = un cambio lógico cohesivo. No agrupar cambios de distintas responsabilidades.

> **⛔ REGLA ABSOLUTA — UN COMMIT POR LLAMADA DE TERMINAL**
>
> Cada `git add` + `git commit` debe ejecutarse en **una única llamada de terminal separada**.
> **NUNCA** encadenar múltiples commits con `&&` en una sola llamada.
> El usuario debe aprobar cada commit individualmente antes de que el agente pase al siguiente.
>
> CORRECTO (una llamada por commit):
> ```
> Turno N:   git add <fichero1> && git commit -m "..."   ← el usuario aprueba
> Turno N+1: git add <fichero2> && git commit -m "..."   ← el usuario aprueba
> ```
>
> INCORRECTO (batch en una sola llamada):
> ```
> git add A && git commit -m "..." && git add B && git commit -m "..."
> ```
>
> Si el agente viola esta regla, el usuario **cancelará** la llamada y el agente
> habrá fallado en su obligación más básica.

```bash
# Revisar qué ha cambiado
git diff
git status

# Añadir solo los ficheros del cambio atómico actual
git add <fichero1> <fichero2>

# NUNCA usar git add . sin revisar primero
git diff --staged   # verificar exactamente qué entra
```

### 5. Commit semántico

**Formato obligatorio:**
```
<tipo>(MCP-<ticket>): <descripción corta en imperativo>

- <detalle opcional 1>
- <detalle opcional 2>
```

**Tipos permitidos:**

| Tipo | Cuándo usarlo |
|---|---|
| `feat` | Nueva funcionalidad visible para el usuario/cliente |
| `fix` | Corrección de un bug |
| `refactor` | Cambio de código sin alterar comportamiento observable |
| `test` | Añadir o corregir tests |
| `chore` | Tareas de mantenimiento, dependencias, config |
| `ci` | Cambios en pipelines CI/CD |
| `docs` | Solo documentación |

**Ejemplos correctos:**
```bash
git commit -m "feat(MCP-42): add share-resource tool with PostgreSQL persistence

- RegisterResourceUseCase created in application layer
- ResourceRepository interface in domain layer
- ExposedResourceRepository implementation in infrastructure"

git commit -m "test(MCP-42): add unit tests for RegisterResourceUseCase

- Given valid input, resource is persisted correctly
- Given duplicate name, DomainException is thrown"

git commit -m "fix(MCP-17): correct missing Authorization header in MCP tool response"
```

**Ejemplos incorrectos:**
```bash
# ❌ Sin scope
git commit -m "feat: add tool"

# ❌ Sin tipo semántico
git commit -m "MCP-42 stuff done"

# ❌ Mezcla de responsabilidades
git commit -m "feat(MCP-42): add tool and fix bug and update deps"
```

### 6. Verificación pre-merge

Antes de integrar a `develop`, verificar:

- [ ] Build pasa: `./gradlew build --no-daemon`
- [ ] Tests pasan: `./gradlew test --no-daemon`
- [ ] No hay credenciales hardcodeadas en los ficheros staged
- [ ] El `.env` o ficheros de secretos NO están incluidos
- [ ] Todos los cambios pertenecen al ticket activo

```bash
git diff develop...HEAD --stat   # resumen de cambios vs develop
git log develop..HEAD --oneline  # commits que se van a mergear
```

### 7. Merge a develop

> **⛔ El merge a `develop` lo ejecuta el pipeline de GitLab CI/CD tras la aprobación del MR,
> NO el agente ni el desarrollador de forma manual.**

Si por excepción se hace de forma local (entorno sin CI):

```bash
git checkout develop
git pull origin develop          # actualizar develop antes del merge
git merge --no-ff <nombre-rama> -m "merge(MCP-<ticket>): <descripción corta>"
git push origin develop
```

`--no-ff` es **obligatorio** para preservar el historial de cada feature como unidad.

### 8. Limpieza de rama

```bash
# Borrar rama local
git branch -d feature/MCP-<ticket>-<slug>

# Borrar rama remota (si se hizo push)
git push origin --delete feature/MCP-<ticket>-<slug>
```

---

## Outputs esperados

- Rama creada con naming correcto desde `develop`.
- Commits atómicos semánticos con scope obligatorio.
- Merge a `develop` con `--no-ff` y mensaje de merge.
- Rama de trabajo eliminada (local y remota).
- Advertencia activa si se detecta contaminación entre features.

---

## Errores frecuentes

| Error | Corrección |
|---|---|
| **Hacer commit/push directamente en `develop`** | **🚫 PROHIBIDO — ver Guardrail Absoluto arriba** |
| Crear rama desde `main` o `master` | Siempre desde `develop` |
| `git add .` sin revisar | Usar `git add <ficheros>` + `git diff --staged` |
| Merge con `--ff` (fast-forward) | Usar siempre `--no-ff` |
| Commit con mensaje sin tipo ni scope | Formato `tipo(MCP-XX): descripción` obligatorio |
| Commitear `.env` con secretos reales | `.env` en `.gitignore`; solo commitear `.env.example` |
| Mezclar cambios de distintos tickets | Un commit / rama = un ticket |

---

## Referencias

- [references/branching-flow.md](references/branching-flow.md) — Diagrama del flujo de ramas
