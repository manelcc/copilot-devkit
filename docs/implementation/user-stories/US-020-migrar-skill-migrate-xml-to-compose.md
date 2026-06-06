# US-020 — Migrar skill migrate-xml-to-compose

**Como** desarrollador Android migrando de XML a Jetpack Compose,
**quiero** que la skill de migración esté disponible en `skills/android/compose/`,
**para** obtener guía paso a paso sin buscarla en awesome-copilot.

---

## Criterios de aceptación

1. La skill `skills/android/compose/migrate-xml-to-compose/` existe y tiene `SKILL.md` con frontmatter válido.
2. La skill incluye `references/overview.md` con diagrama Mermaid que describe el flujo de migración.
3. La skill documenta las dependencias origen de awesome-copilot en `references/` y cómo se adaptaron.
4. Los triggers y ejemplos de uso están actualizados al contexto del repo y no dependen de rutas externas.
5. `validate-skill.sh` ejecutado sobre la skill devuelve exit code 0.
6. No hay referencias a rutas absolutas ni a proyectos externos en la skill migrada.

---

## Referencias

- Skill `migrate-xml-views-to-jetpack-compose` de awesome-copilot
- Guía de `SKILL.md` en `docs/implementation/user-stories/US-003-templates-base-skills-agentes.md`

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Es una migración de una skill específica |
| Negociable | ✅ | El nombre y los detalles de la skill pueden ajustarse si se descubre mejor enfoque |
| Valiosa | ✅ | Facilita migraciones Android con guía estructurada |
| Estimable | ✅ | Alcance delimitado a una skill concreta |
| Small | ✅ | Solo una skill, no un bundle completo de migraciones |
| Testeable | ✅ | CA comprobables con revisión de archivos y validación automática |
