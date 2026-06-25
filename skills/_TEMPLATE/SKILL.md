---
name: "[Name]"
description: "[Una línea describiendo qué hace esta skill, cuándo se usa y qué produce]"
triggers:
  - "[frase de activación 1]"
  - "[frase de activación 2]"
non_triggers:
  - "[cuándo NO usar esta skill 1]"
  - "[cuándo NO usar esta skill 2]"
---

# [Name]

## Purpose

[Descripción del propósito de la skill en 2-4 frases. Explica qué problema resuelve,
qué produce como salida, y bajo qué restricciones opera.]

## When to use

- [Situación 1 en la que invocar esta skill]
- [Situación 2 en la que invocar esta skill]
- [Situación 3 en la que invocar esta skill]

**Trigger phrases:**
- "[Frase exacta de activación 1]"
- "[Frase exacta de activación 2]"

## When NOT to use

- [Caso 1 en que NO corresponde esta skill → sugerir alternativa]
- [Caso 2 en que NO corresponde esta skill → sugerir alternativa]

## Inputs

**Contexto requerido:**
- `[input_1]`: [Descripción — ejemplo: ruta del fichero a analizar]
- `[input_2]`: [Descripción — ejemplo: stack tecnológico (kotlin, swift, python)]

**Contexto opcional:**
- `[input_opcional]`: [Descripción — valor por defecto si aplica]

## Steps

1. **[Paso 1 — nombre descriptivo]:**
   - [Acción concreta]
   - [Criterio de validación]

2. **[Paso 2 — nombre descriptivo]:**
   - [Acción concreta]
   - [Criterio de validación]

3. **[Paso 3 — nombre descriptivo]:**
   - [Acción concreta]
   - [Salida esperada de este paso]

## Expected outputs

- [Artefacto 1 producido — ejemplo: fichero REPORT.md con hallazgos]
- [Artefacto 2 producido — ejemplo: lista de cambios aplicados]
- [Señal de éxito / señal de fallo]

## Validation

- [ ] [Criterio verificable 1 — ejemplo: el fichero generado existe en la ruta correcta]
- [ ] [Criterio verificable 2 — ejemplo: no hay referencias a proyectos de origen]
- [ ] [Criterio verificable 3 — ejemplo: el script sale con exit 0]

## Examples

### Ejemplo: [caso de uso realista]

**Prompt del usuario:**
> "[Frase real que diría un usuario para activar esta skill]"

**Acción del agente:**
1. [Paso concreto que haría el agente]
2. [Segundo paso]
3. [Resultado entregado]
