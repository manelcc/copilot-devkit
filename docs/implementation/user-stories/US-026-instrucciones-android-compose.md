# US-026 — Instrucciones Android Compose

**Como** desarrollador Android usando Jetpack Compose,
**quiero** instrucciones Copilot específicas para `android-compose`,
**para** que el asistente genere código que siga las mejores prácticas del stack.

---

## Criterios de aceptación

1. Existe el archivo `instructions/android-compose.instructions.md` con `applyTo: "**/*.kt"`.
2. El contenido cubre las reglas de Composables, state hoisting, Navigation 3, Hilt, Coroutines y Flow.
3. El documento referencia las skills de `skills/android/compose/` para tareas relevantes.
4. El formato es válido para el parser de instrucciones del repositorio.
5. El archivo no contiene reglas específicas de un proyecto ni referencias a nombres de paquete concretos.

---

## Referencias

- `US-020` — Skill migration XML → Compose
- Guía de instrucciones y `DoD` del repositorio

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Se centra en un único artifact: instrucciones Compose |
| Negociable | ✅ | El alcance exacto de las reglas puede afinarse con el equipo |
| Valiosa | ✅ | Mejora la calidad y consistencia de código Compose generado |
| Estimable | ✅ | Alcance claro: un documento de instrucciones |
| Small | ✅ | Una tarea de documentación operativa |
| Testeable | ✅ | CA verificables con parseo y revisión de contenido |
