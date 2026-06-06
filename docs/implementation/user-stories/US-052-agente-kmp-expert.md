# US-052 — Agente kmp-expert

**Como** desarrollador Kotlin Multiplatform,
**quiero** un agente experto que oriente las decisiones de arquitectura y compartición de código,
**para** crear módulos multiplataforma robustos sin tener que investigar múltiples fuentes.

---

## Criterios de aceptación

1. Existe `agents/multiplatform/kmp/kmp-expert.agent.md` con frontmatter válido.
2. El agente asesora sobre modularización, expect/actual, interop con iOS y pruebas comunes.
3. Referencia las skills `kmp-shared-module-patterns` y `cmp-ui-patterns` para tareas específicas.
4. Describe cuándo usar KMP versus CMP y cómo separar código compartido del platform-specific.
5. Si no puede decidir, sugiere revisar los requisitos técnicos y delegar al agente global orquestador.

---

## Referencias

- `US-050`, `US-051`
- `US-010` — Agente orquestador global

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Agente KMP claramente delimitado |
| Negociable | ✅ | El set de recomendaciones puede ajustarse según el stack |
| Valiosa | ✅ | Reduce riesgo en módulos multiplataforma |
| Estimable | ✅ | Alcance concreto de un agente experto |
| Small | ✅ | Un agente con foco en KMP |
| Testeable | ✅ | CA verificables con revisión de prompts y handoffs |
