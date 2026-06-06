# US-030 — Skill Android XML+Java patterns

**Como** desarrollador Android legacy,
**quiero** una skill con patrones XML y Java,
**para** mantener y evolucionar aplicaciones antiguas con buenas prácticas sin inventar soluciones cada vez.

---

## Criterios de aceptación

1. Existe `skills/android/legacy/android-xml-java-patterns/` con `SKILL.md` válido.
2. La skill cubre ViewBinding, Retrofit, Room y patrón MVVM legacy.
3. Incluye ejemplos de código y recomendaciones para migrar gradualmente a Compose.
4. Contiene `references/overview.md` con diagrama Mermaid del flujo de soporte legacy.
5. `validate-skill.sh` ejecutado sobre la skill devuelve exit code 0.

---

## Referencias

- `EP-4` — Stack Android Legacy
- Guía de `US-003` y `DoD`

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Skill legacy claramente delimitada |
| Negociable | ✅ | El conjunto exacto de patrones puede ajustarse según proyecto |
| Valiosa | ✅ | Provee orientación para mantenimiento de apps legacy |
| Estimable | ✅ | Alcance bien definido |
| Small | ✅ | Una skill, no un portafolio completo de legacy |
| Testeable | ✅ | CA comprobables con revisión y validación |
