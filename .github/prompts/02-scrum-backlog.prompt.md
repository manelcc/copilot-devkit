---
name: scrum-backlog
mode: agent
description: "[02] Genera backlog SCRUM funcional y confirma con el usuario la lista final de US antes de crear ficheros"
tools: ["codebase", "terminal"]
---

Quiero que generes un backlog SCRUM funcional a partir de un fichero generado previamente por la pipeline documental del proyecto.

## Entradas requeridas
- Path del fichero fuente generado por la pipeline anterior: ${input:source_file_path:Escribe el path del fichero fuente, por ejemplo spec_output/enriquecimiento-movimientos.backlog_draft.md o spec_output/enriquecimiento-movimientos.speckit.md}
- Directorio de salida para los ficheros US: ${input:output_dir_path:Escribe el directorio de salida, por ejemplo .github/user-stories o output_data/enriquecimiento/user-stories}

## Regla de preferencia del fichero fuente
- Si el path proporcionado apunta a un `*.speckit.md`, comprueba si existe un fichero con el mismo basename pero extensión `.backlog_draft.md` en el mismo directorio. Si existe, usa ese fichero en su lugar e informa al usuario.
- Usa el `*.speckit.md` solo si no existe el `*.backlog_draft.md` equivalente en ese mismo directorio.

## Objetivo
A partir del contenido del fichero fuente, generar exclusivamente un backlog funcional orientado a producto y SCRUM.

## Restricciones obligatorias
- No generar plan técnico.
- No generar arquitectura.
- No generar data model.
- No generar contracts.
- No generar quickstart.
- No generar research técnico.
- No generar tareas de implementación técnica detalladas.
- Si falta información, registrarla como supuesto, bloqueo o duda abierta.
- Mantener una salida estable, estructurada y determinista.

## Estructura obligatoria de salida

La salida se compone de **dos tipos de artefactos**:

### 1. Fichero índice del backlog
Guardado como `${input:output_dir_path}/backlog-index.md`, con esta estructura:

```md
# Scrum Backlog

## Resumen funcional

## Épicas

## User Stories (índice)

## Definition of Done

## Bloqueos

## Supuestos

## Dudas abiertas
```

### 2. Un fichero por cada User Story
Cada US se guarda como un fichero independiente con el nombre:
```
{output_dir_path}/US-NNN-{slug-del-titulo}.md
```
Donde:
- `NNN` es el número correlativo con ceros a la izquierda (001, 002, ...).
- `{slug-del-titulo}` es el título de la US en minúsculas, sin acentos, con palabras separadas por guiones (máx. 6 palabras significativas).

Ejemplo: `US-001-ver-justificante-detalle-movimiento.md`

Estructura obligatoria de cada fichero US:

```md
# US-NNN — {Título completo de la historia}

## Contexto de la necesidad
{Párrafo explicativo del por qué y el contexto de esta historia.}

## Requerimientos de inicio _(opcional — incluir solo si el documento fuente contiene requerimientos explícitos)_

| ID | Requerimiento | Estado | Tipo | Evidencia/Nota |
|---|---|---|---|---|
| RQ-001 | ... | Necesario / Pendiente | Funcional / UX | Referencia |

## 1. Encabezado y trazabilidad
- **ID US**: US-NNN
- **Título usuario**: ...
- **Descripción usuario**: Como <actor> quiero <capacidad> para <beneficio>.
- **Épica relacionada**: EP-NNN
- **Prioridad sugerida**: Alta | Media | Baja
- **Criterios funcionales trazados**:
  - ...

## 2. Cobertura funcional
- **Flujo principal**:
  1. ...
- **Entradas**: ...
- **Validaciones**: ...
- **Salidas**: ...
- **Casos límite**: ...

## 3. Dependencias y restricciones
- **Dependencias funcionales/técnicas**: ...
- **Riesgos aplicables**: ...
- **Pendientes de validación**: ...
- **Bloqueantes**: ...

## 4. Solución funcional
- **Puntos de entrada/pantallas**: ...
- **Navegación esperada**: ...
- **Pantallas/vistas involucradas**: ...
- **Datos funcionales necesarios**: ...
- **Estados de UI**: ...

## 5. Checklist de calidad
- **CRITICAL**
  - [ ] ...
- **HIGH**
  - [ ] ...
- **MEDIUM**
  - [ ] ...
- **LOW**
  - [ ] ...

## 6. Casos de prueba
- **Funcionales**: ...
- **Reglas de negocio**: ...
- **Estados de pantalla**: ...
- **Errores y conectividad**: ...

## 7. Diagrama de flujo _(opcional — incluir solo cuando el flujo tenga ramificaciones o condiciones no triviales)_
```mermaid
flowchart TD
    A[...] --> B{...}
```

## 8. Notas y Definition of Ready
- **Decisiones abiertas**: ...
- **Supuestos**: ...
- **Dependencias previas**: ...
- **Definition of Ready**:
  - ...
```

## Reglas de contenido

### Resumen funcional
- Resumen breve y neutro del objetivo funcional.

### Épicas
- Agrupar capacidades funcionales en épicas.
- Formato obligatorio:

```md
### EP-001: Nombre de la épica
Descripción: ...
Objetivo: ...
```

### User Stories
- Generar una historia por cada capacidad funcional identificada.
- Cada US debe ser completable en un sprint (1-2 semanas). Si una capacidad funcional es demasiado grande, divídela en varias US. Si es trivial, agrúpala con capacidades relacionadas.
- En el fichero índice (`backlog-index.md`) incluir solo la referencia y el título:

```md
### US-001 — {Título}
Como <actor> quiero <capacidad> para <beneficio>.
Épica: EP-001 | Prioridad: Alta | Fichero: US-001-{slug}.md
```

- Generar además un **fichero individual** `US-NNN-{slug}.md` para cada historia con la estructura completa definida en la sección anterior.

### Criterios de aceptación
- Incluirlos dentro de cada fichero US individual, en la sección de Casos de prueba.
- No duplicarlos en el fichero índice.

### Definition of Done
- Incluir una DoD general aplicable a todas las historias.
- Si el documento lo permite, añadir notas específicas por historia.

Formato obligatorio:

```md
- DOD-001: ...
- DOD-002: ...
```

### Bloqueos
- Registrar dependencias críticas, información faltante o riesgos que impidan avanzar.

Formato obligatorio:

```md
- BLK-001: ...
- BLK-002: ...
```

### Supuestos
- Registrar hipótesis razonables por ausencia de detalle explícito.

Formato obligatorio:

```md
- SUP-001: ...
- SUP-002: ...
```

### Dudas abiertas
- Registrar preguntas que requieren confirmación de negocio o producto.

Formato obligatorio:

```md
- Q-001: ...
- Q-002: ...
```

## Pasos a ejecutar

### REGLA DE ORO
- Antes de generar cualquier fichero US, debes preguntar y confirmar explícitamente con el usuario qué User Stories quiere mantener en la lista final (renombrar, fusionar, eliminar o aceptar tal cual).
- Nunca pasar a generación de ficheros sin esa confirmación explícita.

### Fase 1 — Análisis y propuesta (NO generar ficheros todavía)

1. Verifica que exista `${input:source_file_path}`.
2. Si el path apunta a un `*.speckit.md`, comprueba si existe un `*.backlog_draft.md` equivalente y, si existe, informa al usuario y prioriza ese fichero.
3. Lee el contenido completo del fichero fuente finalmente seleccionado.
4. Analiza el contenido solo desde un punto de vista funcional y de producto.
5. Identifica las épicas y user stories candidatas que se pueden extraer del documento.
6. **PAUSA OBLIGATORIA — Presenta al usuario la propuesta de US antes de generar nada.**

   Muestra una tabla con las US sugeridas en este formato exacto:

   ```
   ## Propuesta de User Stories

   A partir del documento he identificado las siguientes User Stories candidatas.
   Puedes renombrarlas, fusionarlas o eliminarlas antes de que genere los ficheros.

   | # | Título propuesto | Épica | Funcionalidades incluidas |
   |---|---|---|---|
   | US-001 | {Título sugerido} | EP-001 | {Resumen de qué cubre} |
   | US-002 | {Título sugerido} | EP-001 | {Resumen de qué cubre} |
   | ... | | | |

   **¿Cómo proceder?**
   - Confirma la lista con "ok" o "adelante" para generar los ficheros tal cual.
   - Dime qué US quieres renombrar: "Renombra US-002 a Detalle de movimiento".
   - Dime qué US quieres fusionar: "Fusiona US-002 y US-003 en una sola: Detalle de movimiento".
   - Dime qué US quieres eliminar: "Elimina US-004".
   - O proporciona directamente tu lista definitiva de US.

   Cuando confirmes la lista final, generaré los ficheros recogiendo todas las funcionalidades en las US que hayas definido.
   ```

7. **Espera la confirmación o instrucciones del usuario. No continues hasta recibir respuesta.**

---

### Fase 2 — Generación de ficheros (solo tras confirmación del usuario)

8. Usa la lista definitiva de US confirmada por el usuario.
   - Si el usuario fusionó varias US candidatas en una, consolida todas sus funcionalidades en esa única US.
   - Si el usuario renombró una US, usa el nuevo título para el slug y el encabezado del fichero.
   - No pierdas ninguna funcionalidad identificada en el análisis: cada función debe quedar recogida en alguna US del listado final.
9. Crea el directorio `${input:output_dir_path}` si no existe.
10. Para cada User Story de la lista definitiva:
    a. Genera el slug del título: minúsculas, sin acentos, palabras separadas por guiones, máximo 6 palabras significativas.
    b. Crea el fichero `${input:output_dir_path}/US-NNN-{slug}.md` con la estructura completa definida.
    c. Incluye diagrama Mermaid cuando el flujo lo permita.
    d. Si la US agrupa varias funcionalidades fusionadas, refléjalas todas en la cobertura funcional y los casos de prueba.
11. Genera el fichero índice `${input:output_dir_path}/backlog-index.md` con referencias a todos los ficheros US creados.
12. Muestra al final un resumen breve con:
    - fichero fuente solicitado,
    - fichero fuente finalmente usado,
    - directorio de salida,
    - lista de ficheros US generados (uno por línea),
    - número de épicas, user stories, bloqueos y dudas abiertas.
13. **PAUSA OBLIGATORIA — Pregunta de valoración**.

  Después del resumen final, y como cierre para iniciar el siguiente prompt del flujo, pregunta exactamente:

   ```
   ¿Quieres que iniciemos ahora la valoración de implementación mobile con /estimate-impl usando estas US?
   ```

14. **Espera respuesta del usuario. No continúes automáticamente.**
15. Si el usuario confirma (ej.: "sí", "ok", "adelante", "valorar"), inicia el prompt `/estimate-impl` usando como alcance por defecto `${input:output_dir_path}`.
  - Si el usuario no confirma, finaliza en ese punto sin lanzar estimación.
  - Si el usuario indica un subconjunto de US o rutas concretas, usa ese alcance en `/estimate-impl`.

## Comportamiento esperado
- Si el fichero fuente no existe, detente y explica exactamente qué falta.
- Si el fichero fuente existe pero está vacío o no contiene contenido funcional parseable, detente e informa al usuario que el fichero no contiene información suficiente para generar un backlog.
- Si el contenido es pobre o ambiguo, no inventes detalles como hechos; trasládalos a supuestos o dudas abiertas.
- Prioriza claridad funcional frente a detalle técnico.
- La salida debe ser apta para revisión por Product Owner o Scrum Master.
- **Nunca generes ficheros US sin haber pasado por la Fase 1 y recibido confirmación explícita del usuario.**
- **En la Fase 2, ninguna funcionalidad identificada en el análisis puede quedar fuera del listado definitivo de US.**
- **Tras completar la Fase 2, siempre debes preguntar si se desea valoración e iniciar `/estimate-impl` solo bajo confirmación explícita.**
