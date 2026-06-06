# US-044 — Agente ios-uikit-expert

**Como** desarrollador iOS UIKit,
**quiero** un agente experto que me oriente en patrones legacy de UIKit,
**para** resolver dudas de diseño, arquitectura y migración sin perder tiempo en búsquedas dispersas.

---

## Criterios de aceptación

1. Existe `agents/ios/uikit/ios-uikit-expert.agent.md` con frontmatter válido.
2. El agente puede asesorar sobre ViewControllers, Auto Layout, UITableView, UICollectionView y persistencia.
3. Referencia la skill `uikit-patterns` para patrones detallados.
4. Incluye instrucciones claras de cuándo usar el agente y cuándo usar el agente global orquestador.
5. No incluye reglas específicas de SwiftUI o de arquitecturas modernas fuera de UIKit.

---

## Referencias

- `US-042` — Skill uikit-patterns
- `US-010` — Agente orquestador global

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Agente UIKit con ámbito definido |
| Negociable | ✅ | El conjunto de temas puede ajustarse según el stack legacy |
| Valiosa | ✅ | Acelera soporte de apps iOS legacy |
| Estimable | ✅ | Alcance claro de un agente experto |
| Small | ✅ | Tarea limitada al agente UIKit |
| Testeable | ✅ | CA verificables con revisión de handoffs y prompts |
