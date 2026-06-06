# US-074 — Crear agente project-orchestrator global

**Como** usuario del repositorio en cualquier stack,
**quiero** un agente orquestador que detecte mi stack y delegue al agente o skill correcto,
**para** no necesitar memorizar qué skill invocar manualmente.

---

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Nota |
|---|---|---|---|---|
| RQ-001 | `agents/global/` existe | Necesario | Arquitectura | Parte de US-001 |
| RQ-002 | Lista de agentes de stack disponibles documentada | Necesario | Diseño | Referencia US-010 |
| RQ-003 | Reglas de detección de stack aprobadas | Necesario | Calidad | Heurísticas del agente |

---

## Criterios de Aceptación

1. El archivo `agents/global/project-orchestrator.agent.md` existe.
2. Detecta el stack del proyecto activo mediante heurísticas: Android Compose, iOS SwiftUI, Kotlin Multiplatform, Backend Kotlin, Python.
3. Contiene handoffs explícitos a los agentes de stack correspondientes.
4. Si no puede detectar el stack con certeza, pregunta al usuario y registra la preferencia.
5. El agente describe cómo usarlo con el trigger `@project-orchestrator` o equivalente.
6. No contiene referencias a proyectos origen como `mycardiochef`.

---

## Referencias

- `MC:.github/agents/project-orchestrator.agent.md`
- `MC:.github/agents/qa-testcase-agent.agent.md`
- `MC:.github/agents/android-compose-expert.agent.md`

---

## Dependencias y restricciones

- Dependencias: US-001, US-010, US-061
- Restricciones: El agente debe ser genérico y no incluir reglas específicas del dominio de negocio.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Es un agente orquestador autónomo |
| Negociable | ✅ | Las heurísticas de detección pueden ajustarse |
| Valiosa | ✅ | Reduce fricción para usuarios de cualquier stack |
| Estimable | ✅ | Alcance definido en un solo agente |
| Small | ✅ | Una funcionalidad de orquestación concreta |
| Testeable | ✅ | CA verificables con revisión de handoffs y heurísticas |
