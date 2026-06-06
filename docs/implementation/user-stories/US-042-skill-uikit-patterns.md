# US-042 — Skill uikit-patterns

**Como** desarrollador iOS UIKit,
**quiero** una skill con patrones UIKit clásicos,
**para** desarrollar y mantener apps legacy siguiendo buenas prácticas.

---

## Criterios de aceptación

1. Existe `skills/ios/uikit/uikit-patterns/` con `SKILL.md` válido.
2. La skill cubre storyboard, Auto Layout, ViewControllers, networking y persistencia.
3. Incluye ejemplos de migración incremental hacia SwiftUI cuando aplique.
4. Contiene `references/overview.md` con diagrama Mermaid del flujo UIKit.
5. `validate-skill.sh` ejecutado sobre la skill devuelve exit code 0.

---

## Referencias

- `EP-5` — Stack iOS
- `US-045` — Instrucciones iOS SwiftUI

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Skill UIKit autónoma |
| Negociable | ✅ | Pueden ajustarse los patrones legacy incluidos |
| Valiosa | ✅ | Ayuda a mantener apps industriales iOS legacy |
| Estimable | ✅ | Alcance concreto de patrones UIKit |
| Small | ✅ | Un único dominio de habilidad |
| Testeable | ✅ | CA revisables con validación automática |
