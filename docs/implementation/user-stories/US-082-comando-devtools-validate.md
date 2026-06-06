# US-082 — Comando devtools validate

**Como** contributor del repositorio,
**quiero** validar una skill desde el CLI con `devtools validate skill <path>`,
**para** asegurarme de que cumple las reglas de frontmatter, estructura y documentación antes de enviar un PR.

---

## Criterios de aceptación

1. `devtools validate skill <path>` comprueba frontmatter YAML, secciones obligatorias y `references/overview.md`.
2. La salida muestra una tabla con ✓/✗ por criterio de validación.
3. El comando soporta `--fix` para corregir automáticamente problemas simples de frontmatter faltante.
4. El comando devuelve código 0 si la skill es válida y 1 si falla.
5. El comando muestra mensajes de error claros para secciones faltantes o malformadas.

---

## Referencias

- `US-005` — Bootstrap CLI devtools
- `US-004` — Pre-commit y validación de skills

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Subcomando específico de validación |
| Negociable | ✅ | El modo exacto de reporte puede evolucionar |
| Valiosa | ✅ | Previene PRs con skills inválidas |
| Estimable | ✅ | Requisitos claros para CLI y formato de salida |
| Small | ✅ | Tarea limitada al validador del CLI |
| Testeable | ✅ | CA comprobables con casos de skill válidos e inválidos |
