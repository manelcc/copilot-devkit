---
name: scrum-master-create-us
description: >
  Use this skill when the user wants to transform functional requirements, business ideas, epics,
  or technical components into atomic, valuable User Stories ready for development (Ready for Development).
  Trigger phrases: "genera historias de usuario", "atomiza este requisito", "convierte en US",
  "crea US para este componente", "redacta historias para el sprint", "escribe las historias del backlog",
  "desglosa esta épica en historias", "necesito User Stories para...".
  Do not use for creating Epics (use scrum-master-create-epics), sprint planning, velocity estimation,
  backlog prioritization, or general Scrum coaching.
applyTo: "**"
---

# scrum-master-create-us

## Propósito

Transformar requisitos funcionales, ideas de negocio o componentes técnicos en **Historias de Usuario
atómicas, valiosas y listas para el desarrollo**, que:

- Cumplan el estándar de calidad **INVEST** (Independiente, Negociable, Valiosa, Estimable, Small, Testeable).
- Estén escritas desde la perspectiva del **usuario o persona beneficiaria**.
- Incluyan **Criterios de Aceptación** numerados, verificables y técnicamente precisos.
- Estén alineadas con la **Definición de Terminado (DoD)** del repositorio.
- Sean **Ready for Development**: el equipo puede comenzar sin necesitar aclaraciones adicionales.

---

## Cuándo usar esta skill

- El usuario aporta un requisito funcional, una idea de negocio, una épica o un componente técnico.
- El equipo necesita historias desglosadas antes de la sesión de refinación o planificación del sprint.
- Se requiere garantizar que cada historia sea independiente y estimable por separado.
- El objetivo es poblar o refinar el **Product Backlog** con ítems de calidad.

## Cuándo NO usar esta skill

- Para crear **Épicas** desde un PRD o visión de producto → usar `scrum-master-create-epics`.
- Para **planificación de sprint**, estimación de velocidad o asignación de puntos de historia.
- Para **priorización de backlog** o construcción del Product Goal.
- Para **generar código fuente** a partir de una historia.
- Para coaching genérico de Scrum o definición de marcos ágiles.

---

## Entradas esperadas

| Campo | Descripción | Requerido |
|---|---|---|
| **Requisito / Épica / Idea** | Texto libre, fragmento de PRD, épica existente o descripción técnica | Sí |
| **Persona / Rol** | Usuario o stakeholder que se beneficia del incremento | Recomendado |
| **Definición de Terminado (DoD)** | Criterios del repo (pruebas, cobertura, lint, revisión de código…) | Recomendado |
| **Contexto técnico** | Stack, arquitectura, restricciones técnicas relevantes | Opcional |
| **Número de historias esperadas** | Rango orientativo si el usuario lo conoce | Opcional |

---

## Restricciones y convenciones

- Cada historia cubre **una sola funcionalidad entregable**; no mezclar múltiples responsabilidades.
- El **título** de la historia es conciso y orientado a la acción: `[Verbo] [Objeto] como [Persona]`.
  - Ejemplo: `Visualizar historial de transacciones como usuario autenticado`.
- El cuerpo sigue el formato estándar:
  > **Como** `[persona]`, **quiero** `[acción]`, **para** `[beneficio de negocio]`.
- Los **Criterios de Aceptación (CA)** son una lista numerada. Cada criterio es:
  - Verificable (puede marcarse como cumplido o fallido sin ambigüedad).
  - Orientado al comportamiento del sistema, no a la implementación interna.
  - Incluye escenarios felices (`Given/When/Then` cuando sea útil) y de error.
- Las historias **no prescriben soluciones técnicas** en el cuerpo; la arquitectura va en notas técnicas.
- Validar siempre contra el checklist **INVEST** antes de entregar. Ver [`references/invest-guide.md`](references/invest-guide.md).

---

## Flujo de ejecución

### Paso 1 — Identificar la Persona

Determina a quién beneficia directamente el incremento de valor:

- Si el usuario la ha indicado, úsala.
- Si no, infiere la persona más probable según el dominio (p.ej. `usuario autenticado`, `administrador`, `agente de soporte`).
- Si hay ambigüedad, pregunta antes de generar.

### Paso 2 — Definir el Valor de Negocio

Explica en una frase la **necesidad estratégica** que cubre la historia:

- ¿Qué problema resuelve o qué oportunidad habilita?
- ¿Qué ocurre si no se implementa? (coste de la omisión)
- Usa esta frase como el campo `para [beneficio]` de la historia.

### Paso 3 — Atomizar el Requisito

Si el requisito es amplio, descomponlo en historias independientes:

1. Identifica los **verbos de acción** del requisito (listar, crear, editar, eliminar, notificar…).
2. Agrupa por **flujo de usuario coherente** (no por capa técnica).
3. Asegúrate de que cada historia pueda desplegarse y probarse de forma aislada.
4. Marca como **dependencias** (no como una misma historia) los ítems que requieran otro ítem previo.

### Paso 4 — Redactar la Historia

Usa el formato:

```
## [Título orientado a la acción]

**Como** [persona],
**quiero** [acción concreta],
**para** [beneficio de negocio medible o percibido].
```

### Paso 5 — Escribir los Criterios de Aceptación

Lista numerada. Incluye obligatoriamente:

1. **Escenario principal (happy path)**: la funcionalidad trabaja según lo esperado.
2. **Validaciones de entrada**: qué ocurre con datos incorrectos o vacíos.
3. **Escenarios de error / excepción**: timeouts, errores de red, permisos insuficientes.
4. **Criterios técnicos de la DoD**: pruebas unitarias, cobertura mínima, análisis estático, revisión de código.

> Si el repositorio contiene una DoD explícita (`.github/`, `docs/`, `README`), consúltala e incorpora
> sus criterios técnicos en los CA de cada historia.

### Paso 6 — Validar contra INVEST

Antes de entregar, recorre el checklist INVEST para cada historia generada.
Ver [`references/invest-guide.md`](references/invest-guide.md) para la guía completa y los ejemplos few-shot.

| Criterio | Pregunta de validación |
|---|---|
| **I**ndependiente | ¿Puede desarrollarse sin depender de otra historia del mismo sprint? |
| **N**egociable | ¿El equipo puede ajustar el alcance sin cambiar el valor? |
| **V**aliosa | ¿Aporta valor directo al usuario o al negocio por sí sola? |
| **E**stimable | ¿El equipo puede estimar el esfuerzo con la información disponible? |
| **S**mall | ¿Cabe en un sprint (≤ la mitad de la capacidad del equipo)? |
| **T**esteable | ¿Todos los CA son verificables sin interpretación subjetiva? |

Si algún criterio falla, **refactoriza** la historia antes de entregarla.

### Paso 7 — Alineación con la DoD

Consulta la Definición de Terminado del repositorio e incorpora los criterios relevantes:

- Pruebas unitarias automatizadas (cobertura mínima si está definida).
- Análisis estático de código (`detekt`, `SwiftLint`, `ESLint`…).
- Revisión de código (número mínimo de aprobaciones).
- Documentación de API si la historia expone endpoints.
- Criterios de accesibilidad o rendimiento si aplica.

---

## Salidas esperadas

Para cada requisito procesado, entregar:

```markdown
## US-XXX — [Título orientado a la acción]

**Como** [persona],
**quiero** [acción concreta],
**para** [beneficio de negocio medible].

### Criterios de Aceptación

1. Dado [contexto], cuando [acción], entonces [resultado esperado].
2. Si [entrada inválida], el sistema muestra [mensaje de error concreto].
3. El componente incluye pruebas unitarias con cobertura ≥ [X]% (según DoD).
4. El código pasa el análisis estático sin warnings de nivel error.
5. ...

### Notas técnicas *(opcional)*

- [Restricción arquitectónica, deuda técnica conocida, decisión de diseño relevante]

### Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | — |
| Negociable | ✅ | — |
| Valiosa | ✅ | — |
| Estimable | ✅ | — |
| Small | ✅ | — |
| Testeable | ✅ | — |
```

---

## Ejemplos few-shot

Ver [`references/invest-guide.md`](references/invest-guide.md) para ejemplos completos bien vs. mal redactados.

### Ejemplo rápido — Historia bien redactada

```markdown
## US-042 — Recuperar contraseña por correo electrónico

**Como** usuario registrado,
**quiero** recibir un enlace de recuperación de contraseña en mi correo,
**para** poder acceder a mi cuenta sin necesitar soporte humano.

### Criterios de Aceptación

1. Dado un correo registrado, cuando solicito recuperación, recibo el email en menos de 2 minutos.
2. El enlace caduca a las 24 horas de su generación.
3. Si el correo no existe, el sistema responde con el mismo mensaje genérico (sin revelar si existe).
4. El enlace es de un solo uso; un segundo acceso muestra error 410.
5. Pruebas unitarias cubren los casos: correo válido, correo no registrado, token expirado, token ya usado.
6. El código pasa `detekt` sin warnings de nivel error.
```

### Ejemplo rápido — Historia mal redactada ❌

```markdown
## Hacer el módulo de login

Hay que hacer todo el login: pantalla, backend, base de datos y recuperar contraseña.
El diseño lo decide el equipo cuando llegue.

Criterios:
- Que funcione
- Que sea seguro
```

**Problemas detectados:**
- No sigue el formato `Como/quiero/para`.
- Mezcla múltiples responsabilidades (viola **S**mall e **I**ndependiente).
- CA vagos y no verificables (viola **T**esteable).
- Sin persona identificada (viola **V**aliosa).
- Sin información suficiente para estimar (viola **E**stimable).

---

## Herramientas de gestión compatibles

Las historias generadas pueden copiarse directamente a:

- `Jira` — pegar el cuerpo como descripción, los CA como checklist.
- `Azure DevOps` — crear como Work Item tipo "User Story"; CA como criterios de aceptación.
- `GitHub Issues` — pegar en markdown; etiquetar con `user-story`, `ready`.
- Archivos Markdown del repositorio (p.ej. `docs/user-stories/US-XXX.md`).
