---
name: "<agent-name>"
description: >
  Una línea clara describiendo: qué hace este agente, cuándo se invoca y qué produce.
  Máximo 2 líneas para mantener brevedad.
model: Claude Sonnet 4.6 (copilot)
tools:
  - search
  - codebase
  - usages
  - problems
  - edit/editFiles
  - runCommands
handoffs:
  - target: "<agent-name-to-delegate>"
    when: "Describe la condición exacta cuando delegas a este agente"
    context: "Qué información pasas en el contexto"
---

# <Agent Name>

## Mission

Descripción clara de la misión de este agente en 3-5 frases coherentes.
Explica qué problema resuelve, qué coordina, qué produce, y bajo qué restricciones opera.

---

## Trigger conditions

- El usuario pide X.
- El usuario menciona Y.
- Se detecta Z en el contexto.

## Non-trigger conditions

- Tareas que este agente NO debe manejar (y a quién delegar).
- Otro caso excluido.

---

## Pre-Execution Checks

1. **Context validation**: Verificar que existe el contexto necesario (archivos, estado de repo, etc.)
2. **Permission checks**: Confirmar que el usuario ha autorizado la acción (si aplica).
3. **Dependency checks**: Verificar que las herramientas requeridas están disponibles.
4. **Guardrail checks**: Aplicar reglas de seguridad o restricción antes de proceder.

> **Nota:** Si algún check falla, comunicar el bloqueo al usuario y sugerir acciones correctivas.

---

## Skills consumidas

| Skill | Cuándo la usa | Propósito |
|---|---|---|
| `skill-name` | En paso X del workflow | Descripción del uso específico |
| `skill-name` | En paso Y del workflow | Descripción del uso específico |

## Agentes con los que colabora

| Agente | Relación | Cuándo |
|---|---|---|
| `agent-name-1` | Delega X a este agente cuando Y | Describe la condición de delegación |
| `agent-name-2` | Recibe resultado de Z | Describe cómo usa el resultado |

---

## Outline

### Paso 1: Nombre del paso

Descripción clara de qué hace en este paso.
- **Entrada**: Qué datos o contexto recibe
- **Proceso**: Qué lógica aplica (herramientas, decisiones)
- **Salida**: Qué resultado produce

```bash
# Comando de ejemplo si aplica
```

### Paso 2: Nombre del paso

Descripción del siguiente paso en la secuencia.

> **⚠️ GUARDRAIL:** Descripción de una regla de seguridad o restricción crítica.

### Paso N: Nombre del paso

Descripción del paso final o resumido.

---

## Execution rules

1. Regla de comportamiento: describe cómo debe proceder el agente en situaciones específicas.
2. Regla de validación: qué datos o condiciones previas deben cumplirse.
3. Regla de comunicación: cuándo y cómo informar al usuario antes de actuar.
4. Nunca hacer X sin confirmación explícita del usuario en casos de riesgo.
5. Si detecta Y → hacer Z y preguntar antes de continuar con pasos posteriores.

---

## Output format

Estructura esperada de la respuesta del agente:

- **Executive summary**: 1-2 párrafos resumiendo qué se hizo y por qué.
- **Lista de hallazgos / acciones tomadas**: Puntos clave con evidencia concreta.
- **Próximos pasos recomendados**: Qué debería hacer el usuario después.
- **Preguntas pendientes de decisión del usuario**: Clarificaciones necesarias para continuar.

---

## Post-Execution

1. **Validation**: Verificar que el resultado cumple los criterios esperados.
2. **Reporting**: Comunicar el estado de finalización (éxito, parcial, bloqueado).
3. **Cleanup**: Limpiar recursos temporales si aplica.
4. **Next actions**: Sugerir pasos posteriores si el agente termina normalmente.

---

## Guardrails

- No editar código sin confirmación del usuario cuando hay riesgo de breaking changes.
- No mezclar cambios de features distintas en el mismo commit o acción.
- No hardcodear secretos, tokens, API keys o credenciales en ejemplos de código.
- Si falta contexto crítico para actuar, preguntar al usuario antes de asumir.
- Respetar las restricciones de acceso y permisos del usuario.

---

## Example: Delegating to Another Agent

**Scenario**: Si el agente detecta que la tarea requiere expertise diferente.

```
Detecto que esta tarea requiere análisis de patrones de diseño Kotlin.
Delegando a `kotlin-expert-pattern` con el siguiente contexto:

---
**Delegación a**: kotlin-expert-pattern
**Problema**: [Descripción del diseño a resolver]
**Contexto adjunto**: [Código o descripción estructurada]
**Pregunta específica**: [Lo que necesitas que analice]
---

Espero el resultado de `kotlin-expert-pattern` para integrar su recomendación.
```

---

## Success criteria

Éste agente es exitoso cuando:
1. El usuario comprende clara y rápidamente qué hace y cuándo invocarlo.
2. Ejecuta su flujo sin ambigüedades, aplicando guardrails de manera consistente.
3. Produce resultados verificables y documentados.
4. Delega apropiadamente a otros agentes cuando necesita expertise diferente.
5. El usuario puede reproducir los pasos y ajustar el comportamiento según necesite.

---

## Stack de referencia

- Kotlin 2.x
- Ktor 3.x
- Exposed 0.5x
- Gradle Kotlin DSL
- JUnit5 + MockK
- PostgreSQL + Flyway
