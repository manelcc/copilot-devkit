# US-063 — Skill Python FastAPI patterns

**Como** desarrollador backend Python,
**quiero** una skill para patrones FastAPI,
**para** escribir servicios web consistentes con Pydantic, SQLAlchemy async y pytest.

---

## Criterios de aceptación

1. Existe `skills/backend/python/backend-python-fastapi-patterns/` con `SKILL.md` válido.
2. La skill cubre routers, Pydantic models, SQLAlchemy async y pruebas pytest.
3. Incluye ejemplos de estructura de proyecto y endpoints CRUD.
4. Contiene `references/overview.md` con diagrama Mermaid del flujo request → response.
5. `validate-skill.sh` ejecutado sobre la skill devuelve exit code 0.

---

## Referencias

- `EP-7` — Stack Backend
- Guía de `US-003` y `DoD`

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Skill backend Python autónoma |
| Negociable | ✅ | Los frameworks de testing y ORM pueden ajustarse si hay preferencia |
| Valiosa | ✅ | Facilita el desarrollo de servicios FastAPI consistentes |
| Estimable | ✅ | Alcance concreto de patrones FastAPI |
| Small | ✅ | Una skill específica de backend Python |
| Testeable | ✅ | CA comprobables con revisión de archivos y validación |
