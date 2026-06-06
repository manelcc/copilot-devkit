# US-075 — Agente qa-testcase global

**Como** equipo de calidad,
**quiero** un agente global que genere casos de prueba para cualquier stack,
**para** asegurar que las funcionalidades nuevas se prueben con escenarios completos y edge cases.

---

## Criterios de aceptación

1. Existe `agents/global/qa-testcase.agent.md` con frontmatter válido.
2. El agente genera casos de prueba para frameworks de cada stack: JUnit, XCTest, pytest, y pruebas de UI cuando aplica.
3. Incluye escenarios de happy path, validaciones de entrada, errores y condiciones límite.
4. Describe cómo usar los casos generados en el ciclo de desarrollo y su relación con la DoD.
5. Si el stack es específico, el agente sugiere adaptaciones a las herramientas de testing del stack.

---

## Referencias

- `US-010` — Agente orquestador global
- `DoD` — Criterios de pruebas y cobertura

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Agente QA global independiente |
| Negociable | ✅ | El formato de casos de prueba puede ajustarse |
| Valiosa | ✅ | Mejora la cobertura de pruebas en cualquier stack |
| Estimable | ✅ | Alcance concreto de un agente generador de casos |
| Small | ✅ | Focus en QA y casos de prueba |
| Testeable | ✅ | CA revisables con contenido del agente |
