---
name: "Align AI Ecosystem to Project"
description: "Audits and adapts all agents, prompts, and skills in .github/ to the current Kotlin project. Detects redundancies, proposes merges, removes orphaned assets, and updates the project-orchestrator and feature-lifecycle-agent to match project reality."
argument-hint: "Optional: project name, tech stack details (e.g. 'Ktor + Postgres + Swagger', 'KMP + Compose', 'Spring Boot'), CI provider (gitlab|github|azure), extra constraints."
---

# Align AI Ecosystem to Project

## Objetivo
Auditar el ecosistema de agentes, prompts y skills en `.github/` del repositorio actual y alinearlo al stack, convenciones y necesidades reales de **este proyecto Kotlin**. Producir un plan de acción concreto con propuestas de eliminación, fusión, adaptación y creación.

---

## Fase 0 — Reconocimiento del proyecto

### 0.1 Leer el contexto del repositorio
Leer en paralelo:
- `README.md` (descripción del proyecto, stack, features principales)
- `build.gradle.kts` / `settings.gradle.kts` (dependencias, módulos, plugins activos)
- `gradle/libs.versions.toml` si existe (catálogo de versiones)
- `src/main/` estructura de packages (capas arquitectónicas presentes)
- `docker-compose.yml` si existe (servicios externos: DB, cache, broker…)
- `src/main/resources/db/migration/` si existe (Flyway → usa PostgreSQL)
- Buscar `swagger`, `openapi`, `springdoc`, `ktor-swagger` en build files
- `.github/copilot-instructions.md` (instrucciones globales actuales)
- `.github/agents/` — listar todos los `.agent.md`
- `.github/prompts/` — listar todos los `.md`
- `.github/skills/` — listar todas las carpetas de skills

### 0.2 Detectar características clave del proyecto
Inferir y presentar al usuario una tabla de detección:

| Característica | Detectado | Confianza |
|---|---|---|
| Framework principal | Ktor / Spring Boot / KMP / otro | Alta / Media / Baja |
| Base de datos | PostgreSQL / MySQL / MongoDB / ninguna | … |
| ORM / query layer | Exposed / Hibernate / JOOQ / ninguna | … |
| Migraciones DB | Flyway / Liquibase / ninguna | … |
| Autenticación | JWT / OAuth2 / API Key / ninguna | … |
| Swagger / OpenAPI | Sí / No | … |
| CI/CD provider | GitLab CI / GitHub Actions / Azure DevOps / ninguno | … |
| MCP Server | Sí / No | … |
| Testing framework | JUnit5+MockK / Kotest / otro | … |
| Arquitectura | Clean Architecture / Hexagonal / Layered / otra | … |
| Módulos KMP | Sí / No | … |
| Android UI en repo | Sí / No | … |
| HMAC inter-service | Sí / No | … |
| Web scraping integration | Sí / No | … |

Preguntar al usuario: **"¿Confirmas este perfil o hay algo incorrecto/falta?"**
Esperar respuesta antes de continuar.

---

## Fase 1 — Auditoría del ecosistema existente

### 1.1 Inventario completo
Generar tabla de todos los assets encontrados:

```
AGENTS (.github/agents/)
├── project-orchestrator.agent.md
├── feature-lifecycle-agent.agent.md
├── ... (todos los encontrados)

PROMPTS (.github/prompts/)
├── *.prompt.md / *.md

SKILLS (.github/skills/)
├── <nombre>/ → leer descripción del SKILL.md (frontmatter)
```

### 1.2 Matriz de relevancia
Para cada asset, evaluar según el perfil del proyecto detectado en Fase 0:

| Asset | Tipo | Relevante | Motivo |
|---|---|---|---|
| `project-orchestrator` | agent | ✅ Siempre | Orquestador universal |
| `feature-lifecycle-agent` | agent | ✅ Siempre | Ciclo de desarrollo |
| `android-expert-pattern` | agent | ⚠️ Solo si Android en repo | … |
| `kotlin-mcp-expert` | agent | ⚠️ Solo si MCP Server | … |
| `payload-logging-trace` | agent | ✅ / ⚠️ | … |
| `x-correlation-id-strategy` | agent | ✅ / ⚠️ | … |
| `mycardio-middleware-auth-flow` | skill | ❌ Dominio CardioChef | Eliminar/adaptar |
| `mycardio-middleware-user-profile` | skill | ❌ Dominio CardioChef | Eliminar/adaptar |
| `middleware-webscraping-contract` | skill | ⚠️ Solo si HMAC inter-service | … |
| `gitlab-cicd` / `github-actions-cicd` / `azure-pipelines-cicd` | skill | Uno solo | Eliminar los no usados |
| `feature-lifecycle` | skill | ❌ DEPRECATED | Ya reemplazada por agente |
| … | … | … | … |

---

## Fase 2 — Detección de duplicidades y solapamientos

### 2.1 Reglas de detección
Analizar el contenido de los SKILL.md y .agent.md para detectar:

1. **Duplicidad directa**: dos assets describen exactamente la misma responsabilidad.
2. **Solapamiento parcial**: dos assets tienen triggers o responsabilidades que se superponen >50%.
3. **Obsolescencia**: assets marcados `deprecated: true` en frontmatter o que referencian skills/agentes que ya no existen.
4. **Huerfanidad**: skills referenciadas en `copilot-instructions.md` o en agentes que ya no están en `.github/skills/`.
5. **Referencia a dominio específico**: skills/agentes con nombres o contenido ligado al proyecto origen (CardioChef, middleware-webscraping, mycardio-*) que no aplican al nuevo proyecto.

### 2.2 Propuestas de fusión
Para cada par detectado en 2.1 categoría 1 o 2:

```
FUSIÓN PROPUESTA: <asset-A> + <asset-B>
Motivo: [descripción del solapamiento]
Nombre sugerido para el resultado: <nombre-fusionado>
Contenido a preservar de A: [lista]
Contenido a preservar de B: [lista]
Contenido a descartar: [lista]
Acción recomendada: FUSIONAR / ELIMINAR-A / ELIMINAR-B
```

---

## Fase 3 — Adaptaciones requeridas al feature-lifecycle

### 3.1 Checklist de adaptación del feature-lifecycle-agent
Verificar y proponer cambios en `.github/agents/feature-lifecycle-agent.agent.md` según el perfil:

| Condición | Acción sobre feature-lifecycle-agent |
|---|---|
| Swagger/OpenAPI presente | Añadir Phase "Swagger spec actualizado" al gate pre-commit |
| No MCP Server | Eliminar sección "Prueba con cliente Claude Desktop" del bloque E2E |
| Spring Boot (no Ktor) | Adaptar comandos de arranque local (no `docker compose up --build` con shadow jar) |
| GitHub Actions (no GitLab) | Actualizar referencias de pipeline en checklist |
| Sin Flyway | Eliminar verificación de migraciones del gate |
| Sin PostgreSQL | Eliminar tests H2 del gate de unit testing |
| KMP presente | Añadir phase de validación multiplataforma |
| Android en repo | Añadir agente `android-expert-pattern` al routing del orchestrator |
| Sin autenticación JWT | Eliminar gate de validación de tokens del lifecycle |

### 3.2 Adaptaciones al project-orchestrator
Verificar la tabla de routing en `project-orchestrator.agent.md`:
- Eliminar filas que referencian agentes/skills que se van a eliminar
- Añadir filas para nuevos agentes/skills detectados en el proyecto destino
- Actualizar el bloque PRE-COMMIT GATE para reflejar las fases reales del proyecto

---

## Fase 4 — Plan de acción ejecutable

Generar el plan en tres secciones:

### 4.1 Eliminaciones (requieren confirmación)
```
ELIMINAR:
□ .github/skills/mycardio-middleware-auth-flow/   → dominio CardioChef, no aplica
□ .github/skills/mycardio-middleware-user-profile/ → dominio CardioChef, no aplica
□ .github/skills/feature-lifecycle/               → DEPRECATED, reemplazada
□ .github/skills/gitlab-cicd/                     → si el proyecto usa GitHub Actions
□ .github/agents/android-expert-pattern.agent.md  → si no hay Android en el repo
□ .github/agents/kotlin-mcp-expert.agent.md       → si no es un MCP Server
□ ... (lista completa según análisis)
```

### 4.2 Fusiones propuestas
```
FUSIONAR:
□ <asset-A> + <asset-B> → <nombre-resultado>
  Contenido final: [descripción]
□ ...
```

### 4.3 Adaptaciones a aplicar
```
ADAPTAR:
□ feature-lifecycle-agent.agent.md → [cambios específicos]
□ project-orchestrator.agent.md   → [cambios específicos]
□ copilot-instructions.md          → [cambios específicos]
□ ...
```

### 4.4 Creaciones necesarias (si aplica)
```
CREAR:
□ .github/skills/<nueva-skill>/SKILL.md → [justificación: cubre gap X no cubierto]
□ ...
```

---

## Fase 5 — Confirmación y ejecución

Presentar el plan completo al usuario y preguntar:

> "He analizado el ecosistema. Aquí tienes el plan de acción con **X eliminaciones**, **Y fusiones** y **Z adaptaciones**.
>
> ¿Quieres que:
> a) ejecute el plan completo automáticamente,
> b) aplique solo las eliminaciones seguras (deprecated + dominio ajeno),
> c) aplique todo excepto las fusiones (requieren revisión manual),
> d) revises cada cambio uno a uno antes de aplicarlo?
>
> También puedes excluir elementos específicos del plan antes de ejecutar."

**Esperar confirmación explícita antes de modificar o eliminar cualquier fichero.**

### 5.1 Ejecución
Una vez confirmado, aplicar los cambios en este orden:
1. Eliminaciones (mover a `.github/_archived/` en lugar de borrar, para poder recuperar)
2. Fusiones
3. Adaptaciones de agentes/orchestrator
4. Creaciones

### 5.2 Verificación final
Tras aplicar:
- Verificar que `copilot-instructions.md` referencia correctamente todos los assets activos
- Verificar que el routing table del `project-orchestrator` es coherente
- Confirmar que no hay referencias rotas entre skills/agentes
- Emitir resumen de cambios aplicados

---

## Reglas operativas

1. **Nunca eliminar directamente**: mover a `.github/_archived/<nombre>` con fecha.
2. **No modificar skills de `.copilot/` ni `~/.claude/skills/`**: son globales del usuario, no del proyecto.
3. **Prioridad de referencia**: si `copilot-instructions.md` define una convención, no proponer un cambio contrario sin RFC explícito del usuario.
4. **Assets marcados `deprecated: true`** en frontmatter → proponer eliminación directa sin preguntar por fusión.
5. **Responder siempre en el idioma del usuario**.
6. **No sobreescribir**: si dos assets tienen el mismo nombre en origin y destino, presentar diff antes de fusionar.
