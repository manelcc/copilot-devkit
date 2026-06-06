# US-061 — Migrar agentes backend Kotlin/Ktor

**Como** desarrollador backend,
**quiero** encontrar los agentes especializados de mycardiochef en `agents/backend/kotlin-ktor/`,
**para** orquestar tareas Ktor sin mantener copias locales en cada proyecto.

---

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Nota |
|---|---|---|---|---|
| RQ-001 | Acceso a `mycardiochef/.github/agents/` | Necesario | Funcional | Fuente principal |
| RQ-002 | Estructura de directorios `agents/backend/kotlin-ktor/` creada | Necesario | Arquitectura | Parte de US-001 |
| RQ-003 | `project-orchestrator.agent.md` y `qa-testcase-agent.agent.md` se ubican en global | Necesario | Diseño | Base para US-074 |

---

## Criterios de Aceptación

1. Los siguientes agentes existen en `agents/backend/kotlin-ktor/`:
   - `kotlin-expert-pattern.agent.md`
   - `kotlin-server-quality.agent.md`
   - `kotlin-mcp-expert.agent.md`
   - `payload-logging-trace.agent.md`
   - `x-correlation-id-strategy.agent.md`
   - `devops-agent.agent.md`
2. El agente `project-orchestrator.agent.md` se ubica en `agents/global/` y su contenido está actualizado para redirigir al nuevo namespace.
3. El agente `qa-testcase-agent.agent.md` se ubica en `agents/global/` y su descripción cubre pruebas para backend Kotlin.
4. Todos los agentes migrados tienen `frontmatter` válido y parseable.
5. Los handoffs dentro de los agentes referencian rutas actualizadas y no contienen rutas rotas.
6. No hay referencias a `mycardiochef` en los agentes migrados.

---

## Referencias

- `MC:.github/agents/kotlin-expert-pattern.agent.md`
- `MC:.github/agents/kotlin-server-quality.agent.md`
- `MC:.github/agents/kotlin-mcp-expert.agent.md`
- `MC:.github/agents/payload-logging-trace.agent.md`
- `MC:.github/agents/x-correlation-id-strategy.agent.md`
- `MC:.github/agents/project-orchestrator.agent.md`
- `MC:.github/agents/qa-testcase-agent.agent.md`

---

## Dependencias y restricciones

- Dependencias: US-001, US-054, US-074
- Restricciones: Mantener solo lógica genérica y no migrar agentes específicos de proyecto sin generalización.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | El trabajo es una migración autónoma y no mezcla con instrucciones |
| Negociable | ✅ | Se puede ajustar la ubicación exacta de agentes globales |
| Valiosa | ✅ | Hace disponibles agentes backend Ktor reutilizables |
| Estimable | ✅ | Alcance definido por 6 agentes |
| Small | ✅ | Un dominio claro de agentes backend |
| Testeable | ✅ | CA verificables con parseo YAML y revisión de rutas |
