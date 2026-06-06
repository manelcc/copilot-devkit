# US-065 — Agente backend-python-expert

**Como** desarrollador backend Python,
**quiero** un agente experto que me guíe en mejores prácticas de Python y FastAPI,
**para** reducir la fricción en el desarrollo de servicios robustos.

---

## Criterios de aceptación

1. Existe `agents/backend/python/backend-python-expert.agent.md` con frontmatter válido.
2. El agente cubre diseño de APIs, validación con Pydantic, autenticación y pruebas pytest.
3. Referencia la skill `backend-python-fastapi-patterns` para recomendaciones detalladas.
4. Incluye ejemplos de prompts para revisar endpoints, esquemas y manejo de errores.
5. Si el stack no es Python, sugiere usar el agente orquestador global.

---

## Referencias

- `US-063`
- `US-010` — Agente orquestador global

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Agente Python con alcance definido |
| Negociable | ✅ | El detalle de la experiencia (FastAPI, pytest) puede ajustarse |
| Valiosa | ✅ | Mejora la velocidad de desarrollo de servicios Python |
| Estimable | ✅ | Alcance claro de un agente experto |
| Small | ✅ | Un agente específico de backend Python |
| Testeable | ✅ | CA comprobables con revisión de prompts y handoffs |
