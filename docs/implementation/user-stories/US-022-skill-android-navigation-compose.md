# US-022 — Skill android-navigation-compose

**Como** desarrollador Android Compose,
**quiero** una skill que cubra patrones de Navigation 3,
**para** estructurar navegaciones complejas con las mejores prácticas del ecosistema.

---

## Criterios de aceptación

1. Existe `skills/android/compose/android-navigation-compose/` con `SKILL.md` válido.
2. La skill describe cómo usar `NavHost`, `NavController`, argumentos y deep links.
3. Incluye ejemplos de rutas anidadas y navegación condicional basado en estados.
4. Contiene `references/overview.md` con un diagrama Mermaid del flujo de navegación.
5. `validate-skill.sh` ejecutado sobre la skill devuelve exit code 0.

---

## Referencias

- `EP-3` — Stack Android Compose
- `US-026` — Instrucciones Android Compose

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Skill de navegación separada de otras patterns |
| Negociable | ✅ | El estilo de navegación exacto puede ajustarse |
| Valiosa | ✅ | Reduce errores en arquitecturas de navegación Compose |
| Estimable | ✅ | Alcance acotado a Navigation 3 |
| Small | ✅ | Un área de dominio concreta |
| Testeable | ✅ | CA verificables con revisión de contenido y validación |
