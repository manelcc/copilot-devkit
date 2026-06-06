# US-070 — Migrar skill clean-code-guardian global

**Como** revisor de código en cualquier stack,
**quiero** la skill `clean-code-guardian` en `skills/global/clean-code-guardian/`,
**para** detectar violaciones de clean code en Kotlin, Java, Swift y Python.

---

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Nota |
|---|---|---|---|---|
| RQ-001 | Acceso a `mycardiochef/.github/skills/clean-code-guardian/` | Necesario | Funcional | Fuente de migración |
| RQ-002 | Estructura de directorios `skills/global/` creada | Necesario | Arquitectura | Parte de US-001 |
| RQ-003 | Script de validación de skills operativo | Necesario | Calidad | US-005 / US-004 |

---

## Criterios de Aceptación

1. La skill `skills/global/clean-code-guardian/` existe con frontmatter válido.
2. Incluye `scripts/check-clean-code.sh` funcional y compatible con macOS bash 3.2+.
3. Incluye catálogos JSON para Kotlin, Java, Swift y Python.
4. Los ejemplos de uso y la documentación describen cómo ejecutar la skill en cada stack.
5. `validate-skill.sh` ejecutado sobre la skill devuelve exit code 0.
6. No hay referencias a `mycardiochef` ni rutas absolutas de origen.

---

## Referencias

- `MC:.github/skills/clean-code-guardian/`

---

## Dependencias y restricciones

- Dependencias: US-001, US-009
- Restricciones: Solo migrar reglas genéricas; no incluir reglas específicas de proyecto.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Es una migración de skill única con valor propio |
| Negociable | ✅ | Se puede ajustar la lista de lenguajes soportados si hace falta |
| Valiosa | ✅ | Cubre revisiones de código en múltiples stacks |
| Estimable | ✅ | Alcance definido por una skill y sus catálogos |
| Small | ✅ | Una skill global bien acotada |
| Testeable | ✅ | CA verificables con `validate-skill.sh` y ejecución de script |
