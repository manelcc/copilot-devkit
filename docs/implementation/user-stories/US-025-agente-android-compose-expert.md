# US-025 — Agente android-compose-expert

**Como** desarrollador Android Compose,
**quiero** un agente experto que pueda asistirme en decisiones de UI, navegación y arquitectura,
**para** no tener que buscar múltiples skills manualmente.

---

## Criterios de aceptación

1. Existe `agents/android/compose/android-compose-expert.agent.md` con frontmatter válido.
2. El agente referencia y delega a las skills `android-navigation-compose`, `android-hilt-injection` y `android-unit-testing-compose`.
3. Incluye prompts claros para revisar diseño de Compose, manejar estados y optimizar rendimiento.
4. Describe cuándo no usarlo (por ejemplo, migraciones legacy o iOS).
5. Si el agente no puede decidir, sugiere usar el agente orquestador global.

---

## Referencias

- `US-022`, `US-023`, `US-024`
- `US-010` — Agente orquestador global

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Agente especializado claro |
| Negociable | ✅ | El set de skills referenciadas puede crecer |
| Valiosa | ✅ | Reduce fricción en el flujo Compose |
| Estimable | ✅ | Alcance definido de un agente experto |
| Small | ✅ | Agente focalizado en Compose |
| Testeable | ✅ | CA verificables con revisión de handoffs y prompts |
