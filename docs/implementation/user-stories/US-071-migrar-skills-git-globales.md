# US-071 — Migrar skills git y workflow globales

**Como** desarrollador en cualquier proyecto,
**quiero** las skills `git-workflow`, `mr-description-generator` y `feature-lifecycle` en `skills/global/`,
**para** seguir convenciones de branching, commits y MR sin duplicar definiciones en cada stack.

---

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Nota |
|---|---|---|---|---|
| RQ-001 | Acceso a `mycardiochef/.github/skills/git-workflow/` | Necesario | Funcional | Fuente primaria |
| RQ-002 | Acceso a `mycardiochef/.github/skills/mr-description-generator/` | Necesario | Funcional | Fuente primaria |
| RQ-003 | Estructura de directorios `skills/global/` creada | Necesario | Arquitectura | Parte de US-001 |

---

## Criterios de Aceptación

1. Las skills `skills/global/git-workflow/`, `skills/global/mr-description-generator/` y `skills/global/feature-lifecycle/` existen.
2. `feature-lifecycle` no contiene `deprecated: true` en su frontmatter y está reescrita como una skill activa.
3. `mr-description-generator` tiene un template MR genérico con secciones: Qué hace, Por qué, Cómo probar y Checklist.
4. `git-workflow` no contiene referencias a ramas específicas de mycardiochef; usa convenciones genéricas como `feature/<tipo>/<descripción>`.
5. `validate-skill.sh` ejecutado sobre las tres skills devuelve exit code 0.
6. No hay referencias a `mycardiochef`, `mycardio` ni rutas absolutas en los archivos migrados.

---

## Referencias

- `MC:.github/skills/git-workflow/`
- `MC:.github/skills/mr-description-generator/`
- `MC:.github/skills/feature-lifecycle/`

---

## Dependencias y restricciones

- Dependencias: US-001, US-009
- Restricciones: Mantener el contenido genérico y aplicable a GitHub/GitLab.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Migración de skills globales sin dependencia directa de otras US |
| Negociable | ✅ | Se puede ajustar cómo se describen las convenciones git |
| Valiosa | ✅ | Ofrece consistencia de workflow a todos los stacks |
| Estimable | ✅ | Alcance de 3 skills y validación |
| Small | ✅ | Una unidad de migración centrada en el workflow git |
| Testeable | ✅ | CA verificables con grep y validación de frontmatter |
