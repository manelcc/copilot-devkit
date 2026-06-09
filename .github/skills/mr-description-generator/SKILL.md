---
name: "mr-description-generator"
description: >
  Genera la descripción de una MR en Markdown a partir de los commits atómicos de la rama
  actual, crea doc/mr/<branch-slug>-mr.md y marca la US como completada en doc/implementation/.
applyTo:
  - "**/*"
triggers:
  - "genera la MR"
  - "crea la descripción de la MR"
  - "quiero abrir MR"
  - "prepara el merge request"
  - "cierra la US"
  - "descripción del merge request"
  - "abre la MR"
  - "crear MR"
nonTriggers:
  - Hacer el merge efectivo en GitLab/GitHub (usar git-operations)
  - Revisar calidad de código (usar Kotlin Server Quality Analyst)
  - Hacer commits atómicos (usar git-operations)
  - Crear o actualizar pipelines CI/CD
---

# MR Description Generator

## Propósito

Cuando el usuario solicita abrir una MR, esta skill:
1. Lee los commits atómicos de la rama actual (desde el punto de divergencia con `develop`)
2. Detecta la US activa por el nombre de la rama
3. Genera el fichero `doc/mr/<branch-slug>-mr.md` con la descripción completa de la MR
4. Actualiza `doc/implementation/<us>.md` añadiendo el bloque de cierre con los checks completados

Produce artefactos listos para copiar/pegar en GitLab al abrir la MR.

## Cuándo usar esta skill

- Justo antes de abrir una MR en GitLab (último paso del ciclo de vida de una feature)
- Cuando el agente orquestador o `feature-lifecycle-agent` indican que la US está lista para merge
- Cuando el usuario dice explícitamente que quiere cerrar la US o preparar la MR

## Cuándo NO usar esta skill

- Para hacer el merge en sí → usar `git-operations`
- Para revisar calidad antes de la MR → usar `Kotlin Server Quality Analyst`
- Para hacer commits → usar `git-operations`

---

## Inputs

| Input | Fuente | Descripción |
|---|---|---|
| Rama actual | `git branch --show-current` | Identifica la US y el slug de la MR |
| Commits desde develop | `git log origin/develop..HEAD` | Lista de commits atómicos a incluir |
| Doc de la US | `doc/implementation/US-<id>-*.md` | Criterios de aceptación y descripción funcional |
| Fecha de hoy | Sistema | Para la cabecera del fichero MR |

## Outputs

| Output | Ruta | Descripción |
|---|---|---|
| Descripción MR | `doc/mr/<branch-slug>-mr.md` | Fichero Markdown listo para GitLab |
| US actualizada | `doc/implementation/US-<id>-*.md` | Bloque de cierre añadido al final |

## Constraints

| Regla | Valor |
|---|---|
| Nunca hacer push ni abrir la MR | Solo genera artefactos locales |
| Nunca modificar commits existentes | La skill es de solo lectura en git |
| MR siempre apunta a `develop` | Target branch fijo por convención |
| El bloque de cierre en la US es idempotente | No duplicar si ya existe |

---

## Pasos de ejecución

### 1. Detectar contexto de la rama

```bash
BRANCH=$(git branch --show-current)
# Ejemplo: feature/MCP-1.1-health-check
```

Extraer el ID de US del nombre de la rama:
- Patrón: `feature/MCP-<épica>.<us>-<slug>` → ID = `<épica>.<us>`
- Ejemplo: `feature/MCP-1.1-health-check` → US ID = `1.1`

- [ ] **CHECK-01** La rama sigue el patrón `feature/MCP-<X.Y>-<slug>` o `fix/MCP-<X.Y>-<slug>`

### 2. Obtener commits desde develop

```bash
git log origin/develop..HEAD --pretty=format:"%s" --reverse
```

Agrupar los commits por tipo semántico (feat, fix, test, refactor, docs, ci, chore).

- [ ] **CHECK-02** Hay al menos 1 commit en la rama (no está vacía)

### 3. Localizar el doc de la US

Buscar en `doc/implementation/` el fichero que empiece por `US-<id>-`:

```bash
find doc/implementation -name "US-<id>-*.md" | head -1
```

Leer de ese fichero:
- Sección `## Objetivo funcional` → resumen de la US
- Sección `## Criterios de aceptación → verificación técnica` → tabla de criterios
- Sección `## Estrategia de tests` → información de cobertura

- [ ] **CHECK-03** El fichero `doc/implementation/US-<id>-*.md` existe

### 4. Generar `doc/mr/<branch-slug>-mr.md`

Usar la plantilla de `references/mr-template.md` e inyectar:
- `{{BRANCH}}` → nombre de la rama actual
- `{{US_ID}}` → ID de la US (ej. `1.1`)
- `{{US_TITLE}}` → título extraído del doc de la US (primera línea `# `)
- `{{DATE}}` → fecha actual ISO-8601
- `{{COMMITS_FEAT}}` → lista de commits tipo `feat:`
- `{{COMMITS_FIX}}` → lista de commits tipo `fix:`
- `{{COMMITS_TEST}}` → lista de commits tipo `test:`
- `{{COMMITS_OTHER}}` → resto de commits (refactor, docs, ci, chore)
- `{{ACCEPTANCE_CRITERIA}}` → tabla de criterios del doc de la US
- `{{HOW_TO_TEST}}` → bloque "Cómo probar en local" (ver paso 5)

Guardar en `doc/mr/<branch-slug>-mr.md`.

- [ ] **CHECK-04** El fichero generado contiene todas las secciones de la plantilla

### 5. Construir el bloque "Cómo probar en local"

El bloque debe incluir siempre (guardrail del orquestador):

```markdown
## 🧪 Cómo probar en local

### Precondiciones
- Docker Desktop corriendo
- Puerto 8080 libre

### Pasos
1. `docker-compose up -d`
2. Esperar a que el servicio esté `healthy`: `docker-compose ps`
3. Ejecutar: `curl -s http://localhost:8080/health`

### Resultado esperado
- HTTP 200 con body `ok`
```

Adaptar los pasos al contenido real de la US activa.

- [ ] **CHECK-05** El bloque "Cómo probar en local" tiene precondiciones, pasos y resultado esperado

### 6. Actualizar el doc de la US con el bloque de cierre

Añadir al **final** del fichero `doc/implementation/US-<id>-*.md` el siguiente bloque
(solo si no existe ya la sección `## ✅ Cierre de la US`):

```markdown

---

## ✅ Cierre de la US

| Campo | Valor |
|---|---|
| **Fecha de cierre** | <DATE> |
| **Rama** | `<BRANCH>` |
| **MR doc** | `doc/mr/<branch-slug>-mr.md` |

### Checks de completado

- [x] Implementación completa según arquitectura técnica definida
- [x] Tests unitarios implementados y pasando (`./gradlew test`)
- [x] Cobertura JaCoCo ≥ 40% verificada
- [x] Código revisado (clean code, sin magic numbers, SRP respetado)
- [x] Commits atómicos semánticos realizados
- [x] Descripción de MR generada en `doc/mr/<branch-slug>-mr.md`
- [x] Pruebas manuales verificadas en local (ver sección en MR doc)
- [x] Pipeline CI/CD pasa en la rama (build + test)
```

- [ ] **CHECK-06** El bloque de cierre se ha añadido al doc de la US sin duplicados

### 7. Confirmar al usuario

Mostrar al usuario:

```
✅ MR Description generada: doc/mr/<branch-slug>-mr.md
✅ US <id> marcada como completada en doc/implementation/US-<id>-*.md

Próximos pasos:
1. Revisa doc/mr/<branch-slug>-mr.md
2. Abre la MR en GitLab desde la rama `<BRANCH>` hacia `develop`
3. Copia el contenido del .md como descripción de la MR
```

---

## Ejemplo

**Entrada:**
- Rama: `feature/MCP-1.1-health-check`
- Commits: 12 commits atómicos (feat, test, fix, refactor, docs, ci, chore)

**Salida:**
- `doc/mr/MCP-1.1-health-check-mr.md` generado con descripción completa
- `doc/implementation/US-1.1-salud-disponibilidad-mcp.md` actualizado con bloque `## ✅ Cierre de la US`

---

## Referencia

- Plantilla MR: `references/mr-template.md`
- Diagrama de flujo: `references/overview.md`
- Convención de commits: skill `git-operations`
