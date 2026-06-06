# US-040 — Migrar skills iOS de bankinter-devtools

**Como** desarrollador iOS,
**quiero** las skills de `bankinter-devtools/skills/ios/` disponibles en `skills/ios/`,
**para** usarlas en cualquier proyecto sin depender del repositorio externo.

---

## Criterios de aceptación

1. Las skills de `bankinter-devtools/skills/ios/` migradas existen en el namespace `skills/ios/{swiftui,uikit}/`.
2. Cada skill migrada tiene frontmatter válido y `references/overview.md` con un diagrama de flujo.
3. Las rutas internas y referencias de ejemplo se actualizan al nuevo repo.
4. Los agentes iOS relevantes migrados a `agents/ios/` son documentados como dependencias.
5. `validate-skill.sh` sobre las skills migradas devuelve exit code 0.
6. No hay referencias a `bankinter-devtools` ni a repositorios de origen dentro de las skills.

---

## Referencias

- `BK:skills/ios/`
- `BK:agents/ios/`
- Guía de DoD del repositorio

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Se centra en la migración iOS global |
| Negociable | ✅ | El orden de migración puede ajustarse por prioridad de skill |
| Valiosa | ✅ | Hace reusable el contenido iOS sin dependencia externa |
| Estimable | ✅ | Alcance definido por skills iOS conocidas |
| Small | ✅ | El objetivo es una migración de skills específica |
| Testeable | ✅ | CA verificables con revisión de frontmatter y grep |
