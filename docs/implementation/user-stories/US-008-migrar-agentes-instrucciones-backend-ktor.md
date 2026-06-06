# US-008 — Orquestar tareas Ktor con agentes centralizados

**Como** desarrollador backend Kotlin,  
**quiero** encontrar los agentes especializados de mycardiochef disponibles en `agents/backend/kotlin-ktor/` y las instrucciones Ktor configuradas,  
**para** orquestar tareas Ktor desde cualquier proyecto sin mantener copias locales de agentes probados en producción.

---

## Criterios de Aceptación

1. Los 6 agentes existen en `agents/backend/kotlin-ktor/`: `kotlin-expert-pattern`, `kotlin-server-quality`, `kotlin-mcp-expert`, `payload-logging-trace`, `x-correlation-id-strategy`, `devops-agent`.
2. Cada agente migrado tiene frontmatter válido con `description` y referencias a skills actualizadas (de `skills/kotlin-mcp-server-generator/` a `skills/backend/kotlin-ktor/kotlin-mcp-server-generator/`).
3. El archivo `instructions/backend-kotlin.instructions.md` existe con `applyTo: "**/*.kt"` en frontmatter.
4. Las instrucciones incluyen reglas de: (1) estructura Ktor (Application.kt, routing), (2) HMAC auth, (3) Flyway migrations, (4) Coroutines patterns, (5) documentación Kotlin.
5. Ningún agente contiene referencias específicas al proyecto mycardiochef (DB names, endpoints específicos del proyecto).
6. Los handoffs de agentes referencian otros agentes del namespace `backend/kotlin-ktor/` correctamente.
7. Ejecutar `grep -r "mycardiochef" agents/backend/kotlin-ktor/` no devuelve resultados (0 referencias al proyecto origen).
8. Las instrucciones consolidadas tienen menos de 300 líneas (reglas genéricas, no exhaustivas).

---

## Notas Técnicas

**Path fuente**: `/Users/manelcc/.../mycardiochef/middleware/.github/`

**Fuentes de instrucciones a consolidar**:
- `copilot-instructions.md`
- `copilot-kotlin-server-rules.md`
- `copilot-hmac-auth.md`

**Decisiones abiertas**: ¿Los agentes `project-orchestrator` y `qa-testcase` de mycardiochef se migran aquí o en US-010?

**Supuestos**: Reglas específicas de mycardiochef se omiten; solo reglas genéricas de Ktor.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| **Independiente** | ✅ | Depende de US-001 (namespace existe) |
| **Negociable** | ✅ | Contenido de instrucciones ajustable |
| **Valiosa** | ✅ | Hace disponibles agentes probados en producción para cualquier proyecto Ktor |
| **Estimable** | ✅ | Migración de 6 agentes + consolidación de instrucciones: 6-8 horas |
| **Small** | ✅ | 8 CA, cubre migración de agentes + creación de instrucciones |
| **Testeable** | ✅ | Todos los CA verificables con grep y revisión manual |

---

## Épica Relacionada

EP-7 — Stack Backend

---

## Prioridad

**P0** (Bloqueante) — Junto con US-007, completa el namespace backend Ktor.

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
