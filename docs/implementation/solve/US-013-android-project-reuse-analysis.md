# US-013 - Analisis de reutilizacion desde PRUEBA-TECNICA/ANDROID

Proyecto analizado:
- /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID

## Hallazgos utiles para nuestro proposito

1. Estructura por categorias de patrones ya consolidada
- En `.github/skills/ios-patterns` y `.github/skills/android-patterns` aparece el enfoque por familias (behavioral, creational, structural, concurrency, language-specific).
- Esto confirma que mantener referencias por archivo es una buena decision para trazabilidad y consulta.

2. Flujo operativo de recomendacion reutilizable
- El `android-patterns/SKILL.md` usa un flujo claro: diagnostico -> 2-3 candidatos -> trade-offs -> recomendacion -> checklist de test.
- Este flujo aplica directamente al objetivo de iOS para decidir patron y justificarlo.

3. Marco de calidad por severidad
- `ios-quality-skill` aporta un esquema de severidad CRITICAL/HIGH/MEDIUM/LOW basado en evidencia y regla concreta.
- Este enfoque es util para priorizar antipatrones detectados en revisiones.

4. Orquestacion por capas (prompt-agent-skill)
- `ios/patterns/AI-PATTERNS-SYSTEM.md` documenta bien una arquitectura en capas para consumo guiado.
- Es reutilizable para reforzar adopcion en el equipo (entrypoint claro + especializacion por skill).

## Recomendaciones para este repo

1. Mantener espejo por archivo de referencias (hecho en `skills/ios/swiftui/ios-patterns/references`).
2. Adoptar severidad explicita para antipatrones en salidas del skill:
- CRITICAL: seguridad, concurrencia UI, estado global mutable.
- HIGH: acoplamiento fuerte, navegacion no orquestada, deuda arquitectonica fuerte.
- MEDIUM: sobreabstraccion, uso innecesario de type erasure.
- LOW: inconsistencias de estilo o duplicacion menor.
3. Estandarizar formato de salida en planning/review:
- Patron candidato(s)
- Patron aplicado
- Antipatrones + severidad + remediacion
- Checklist de verificacion

## Decisiones cerradas

1. Mantener la logica de quality de patrones/antipatrones dentro de la skill `ios-patterns` (sin mini skill separada).
2. No crear prompt guiado adicional; el agente experto SwiftUI debe detectar de forma proactiva cuando la solucion requiere patron.
3. La ausencia de evidencia suficiente de patron aplicado se reporta como `hipótesis-no-verificada`, con caracter no bloqueante.
