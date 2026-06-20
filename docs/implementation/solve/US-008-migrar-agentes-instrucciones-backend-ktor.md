# US-008 — Migrar agentes e instrucciones backend Ktor

**Status**: ✅ **DONE**  
**Sprint**: 1 | **Epic**: EP-7 | **Priority**: P0

---

## Funcionalidad entregada

Se migraron y dejaron operativos en el namespace backend Kotlin/Ktor los 6 agentes requeridos:

1. `devops-agent`
2. `kotlin-expert-pattern`
3. `kotlin-mcp-expert`
4. `kotlin-server-quality`
5. `payload-logging-trace`
6. `x-correlation-id-strategy`

Ubicacion: `agents/backend/kotlin-ktor/`

Adicionalmente se consolido `instructions/backend-kotlin.instructions.md` con frontmatter `applyTo: "**/*.kt"` y reglas reutilizables para:

- estructura Ktor,
- autenticacion HMAC interna,
- migraciones Flyway,
- patrones de coroutines,
- estandar de documentacion Kotlin.

---

## Ajustes aplicados

- Eliminado placeholder `agents/backend/kotlin-ktor/.gitkeep`.
- Actualizada referencia de skill en `kotlin-mcp-expert.agent.md` hacia el namespace central:
  - `skills/backend/kotlin-ktor/kotlin-mcp-server-generator/SKILL.md`
- Instrucciones backend reescritas en formato agnostico (sin referencias a proyecto origen).

---

## Evidencias de aceptacion

### CA-1 — Existen los 6 agentes en destino

Comprobacion:

```bash
ls -1 agents/backend/kotlin-ktor/*.agent.md
```

Resultado: 6 ficheros `.agent.md`.

### CA-2 — Frontmatter y referencias de skills actualizadas

- Todos los agentes migrados conservan frontmatter con `description`.
- Referencia de `kotlin-mcp-expert` actualizada al namespace `skills/backend/kotlin-ktor/...`.

### CA-3 y CA-4 — Instrucciones backend consolidadas

Comprobaciones:

```bash
grep -n "applyTo" instructions/backend-kotlin.instructions.md
wc -l instructions/backend-kotlin.instructions.md
```

Resultado:

- `applyTo: "**/*.kt"` presente.
- 83 lineas (menor que 300).

### CA-5 y CA-7 — Sin referencias a proyecto origen

Comprobaciones:

```bash
grep -Rin "mycardiochef" agents/backend/kotlin-ktor || true
grep -Rin "mycardio" instructions/backend-kotlin.instructions.md || true
```

Resultado: sin coincidencias.

### CA-6 — Handoffs y referencias entre agentes

Los agentes mantienen handoffs por nombre de agente del dominio backend Kotlin/Ktor y no incluyen rutas ni nombres de proyecto origen.

---

## Nota de alcance

La decision sobre migrar `project-orchestrator` y `qa-testcase-agent` permanece fuera de esta US y se trata en US-010, segun backlog.
