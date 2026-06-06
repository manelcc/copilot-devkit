# US-024 — Skill android-unit-testing-compose

**Como** desarrollador Android Compose,
**quiero** una skill que cubra pruebas unitarias y de UI para Compose,
**para** asegurar que mis componentes se comporten correctamente antes de entregarlos.

---

## Criterios de aceptación

1. Existe `skills/android/compose/android-unit-testing-compose/` con `SKILL.md` válido.
2. La skill cubre pruebas con JUnit, Espresso y Compose Testing APIs.
3. Incluye ejemplos de pruebas de Composables, ViewModels y flujos de UI.
4. Contiene `references/overview.md` con diagrama Mermaid del flujo de pruebas.
5. `validate-skill.sh` ejecutado sobre la skill devuelve exit code 0.

---

## Referencias

- `EP-3` — Stack Android Compose
- `US-026` — Instrucciones Android Compose

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Skill centrada en testing Compose |
| Negociable | ✅ | El conjunto de frameworks puede ajustarse |
| Valiosa | ✅ | Facilita pruebas de calidad en Compose |
| Estimable | ✅ | Alcance definido de pruebas |
| Small | ✅ | Solo un área de testing |
| Testeable | ✅ | CA verificables con revisión de contenido |
