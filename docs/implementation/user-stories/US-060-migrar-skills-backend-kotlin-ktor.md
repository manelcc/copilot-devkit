# US-060 — Migrar skills backend Kotlin/Ktor

**Como** desarrollador backend Kotlin,
**quiero** encontrar todas las skills de mycardiochef disponibles en `skills/backend/kotlin-ktor/`,
**para** usarlas en cualquier proyecto Ktor sin copiarlas manualmente.

---

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Nota |
|---|---|---|---|---|
| RQ-001 | Acceso a `mycardiochef/.github/skills/` | Necesario | Funcional | Fuente de la migración |
| RQ-002 | Estructura de directorios `skills/backend/kotlin-ktor/` creada | Necesario | Arquitectura | Parte de US-001 |
| RQ-003 | Script de validación de skills operativo | Necesario | Calidad | US-005 / US-004 |

---

## Criterios de Aceptación

1. Las siguientes skills existen en `skills/backend/kotlin-ktor/` y tienen `references/overview.md`:
   - `kotlin-mcp-server-generator/`
   - `logging-kotlin/`
   - `unit-testing-kotlin/`
   - `postgresql-crud/`
   - `ktor-auth-flow/` (renombrada desde `mycardio-middleware-auth-flow/`)
   - `middleware-webscraping-contract/`
2. Cada skill tiene frontmatter válido y actualizado con nombre y namespace correctos.
3. Las referencias internas y rutas relativas dentro de cada skill son correctas y no rotas.
4. No hay referencias a `mycardiochef` o rutas absolutas de origen dentro de las skills migradas.
5. `validate-skill.sh` ejecutado sobre cada skill devuelve exit code 0.
6. Todos los `references/overview.md` contienen un diagrama Mermaid que describe el flujo principal de la skill.

---

## Referencias

- `MC:.github/skills/kotlin-mcp-server-generator/`
- `MC:.github/skills/logging-kotlin/`
- `MC:.github/skills/unit-testing-kotlin/`
- `MC:.github/skills/postgresql-crud/`
- `MC:.github/skills/mycardio-middleware-auth-flow/`
- `MC:.github/skills/middleware-webscraping-contract/`

---

## Dependencias y restricciones

- Dependencias: US-001, US-003, US-005
- Restricciones: Solo migrar lógica genérica; eliminar adaptaciones específicas de mycardiochef
- Nota: Esta US no incluye la migración de agentes ni instrucciones.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Depende de infraestructura, pero la migración es un trabajo unitario claro |
| Negociable | ✅ | El nombre final de `ktor-auth-flow` puede ajustarse si es necesario |
| Valiosa | ✅ | Habilita la reutilización de skills Ktor sin duplicación |
| Estimable | ✅ | Alcance tangible: 6 skills y validación |
| Small | ✅ | Se limita a un conjunto concreto de skills |
| Testeable | ✅ | CA verificables con `validate-skill.sh` y grep de referencias |
