# US-008 — Migrar agentes e instrucciones backend Ktor

## Contexto de la necesidad
El proyecto `mycardiochef/middleware` tiene 6 agentes especializados en Kotlin/Ktor y documentos de instrucciones probados en producción. Migrarlos al repo central los hace disponibles para cualquier proyecto Ktor, eliminando la dependencia de mantenerlos en cada proyecto por separado.

## 1. Encabezado y trazabilidad
- **ID US**: US-008
- **Título usuario**: Migrar agentes Kotlin/Ktor e instrucciones backend desde mycardiochef
- **Descripción usuario**: Como desarrollador backend Kotlin, quiero encontrar los agentes especializados de mycardiochef en `agents/backend/kotlin-ktor/`, para orquestar tareas Ktor desde cualquier proyecto sin mantener copias locales.
- **Épica relacionada**: EP-7 — Stack Backend
- **Prioridad sugerida**: Alta (P0)
- **Criterios funcionales trazados**:
  - 6 agentes migrados con frontmatter y handoffs actualizados
  - `instructions/backend-kotlin.instructions.md` creada con reglas Ktor
  - Referencias internas actualizadas a nuevas rutas del repo central
  - Fuente: `mycardiochef/.github/agents/` + `mycardiochef/.github/copilot-instructions.md`

## 2. Cobertura funcional
- **Agentes a migrar** (fuente → destino):
  1. `MC:agents/kotlin-expert-pattern.agent.md` → `agents/backend/kotlin-ktor/`
  2. `MC:agents/kotlin-server-quality.agent.md` → `agents/backend/kotlin-ktor/`
  3. `MC:agents/kotlin-mcp-expert.agent.md` → `agents/backend/kotlin-ktor/`
  4. `MC:agents/payload-logging-trace.agent.md` → `agents/backend/kotlin-ktor/`
  5. `MC:agents/x-correlation-id-strategy.agent.md` → `agents/backend/kotlin-ktor/`
  6. `MC:agents/devops-agent.agent.md` → `agents/backend/kotlin-ktor/`

- **Instrucciones a crear**:
  - `instructions/backend-kotlin.instructions.md` con `applyTo: "**/*.kt"` (en proyectos backend)
  - Contenido: reglas de estructura Ktor, HMAC auth, Flyway, Coroutines, documentación Kotlin
  - Fuente: `MC:.github/copilot-instructions.md` + `MC:.github/copilot-kotlin-server-rules.md` + `MC:.github/copilot-hmac-auth.md`

## 3. Dependencias y restricciones
- **Dependencias funcionales/técnicas**: US-001 (namespaces existen)
- **Riesgos aplicables**: Los agentes pueden tener referencias a skills de mycardiochef que ahora están en `backend/kotlin-ktor/`; deben actualizarse
- **Pendientes de validación**: ¿Los agentes `project-orchestrator` y `qa-testcase` de mycardiochef se migran aquí o en US-010?
- **Bloqueantes**: Ninguno (acceso a mycardiochef)

## 4. Solución funcional
- **Por cada agente**:
  1. Copiar fichero `.agent.md` al destino
  2. Actualizar referencias a skills: `skills/kotlin-mcp-server-generator/` → `skills/backend/kotlin-ktor/kotlin-mcp-server-generator/`
  3. Actualizar handoffs si referencian otros agentes por nombre
  4. Verificar que frontmatter `description` es claro y sin referencias a mycardiochef

- **`instructions/backend-kotlin.instructions.md`**:
  - Consolida `copilot-instructions.md`, `copilot-kotlin-server-rules.md`, `copilot-hmac-auth.md` de mycardiochef
  - Elimina referencias específicas al proyecto mycardiochef (DB names, endpoints específicos)
  - Mantiene las reglas genéricas de Ktor aplicables a cualquier proyecto

## 5. Checklist de calidad
- **CRITICAL**
  - [ ] 6 agentes existen en `agents/backend/kotlin-ktor/`
  - [ ] `instructions/backend-kotlin.instructions.md` existe y tiene contenido
  - [ ] Ningún agente referencia paths de mycardiochef
- **HIGH**
  - [ ] Referencias a skills actualizadas a rutas del repo central
  - [ ] `instructions/backend-kotlin.instructions.md` consolida las 3 fuentes
- **MEDIUM**
  - [ ] Handoffs entre agentes funcionan con nuevos nombres
- **LOW**
  - [ ] Nota de migración en frontmatter indica origen

## 6. Casos de prueba
- **Funcionales**:
  - `ls agents/backend/kotlin-ktor/` → 6 ficheros .agent.md
  - `instructions/backend-kotlin.instructions.md` existe con contenido no vacío
  - `grep -r "mycardiochef" agents/backend/kotlin-ktor/` → sin resultados
  - `grep -r "mycardio" instructions/backend-kotlin.instructions.md` → sin resultados

## 8. Notas y Definition of Ready
- **Decisiones abiertas**: ¿`project-orchestrator` y `qa-testcase` de mycardiochef van aquí o en US-010?
- **Supuestos**: Las reglas genéricas de Ktor son separables de las específicas de mycardiochef
- **Dependencias previas**: US-001 completada; idealmente US-007 completada (para que las referencias a skills sean válidas)
- **Fuentes**:
  - `mycardiochef/.github/agents/` — 6 agentes
  - `mycardiochef/.github/copilot-instructions.md`
  - `mycardiochef/.github/copilot-kotlin-server-rules.md`
  - `mycardiochef/.github/copilot-hmac-auth.md`
- **Definition of Ready**:
  - [ ] US-001 completada; US-007 completada o en progreso
  - [ ] Lista definitiva de agentes a migrar aprobada
  - [ ] Decisión sobre project-orchestrator/qa-testcase tomada
