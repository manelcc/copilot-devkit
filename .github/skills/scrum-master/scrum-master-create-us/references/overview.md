# scrum-master-create-us — Workflow Overview

## Descripción

Esta skill transforma requisitos funcionales, ideas de negocio o épicas en Historias de Usuario
atómicas y listas para el desarrollo, validadas contra el estándar INVEST y alineadas con la
Definición de Terminado (DoD) del repositorio.

---

## Diagrama de flujo

```mermaid
flowchart TD
    A([Input: Requisito / Épica / Idea]) --> B[Paso 1: Identificar Persona]
    B --> C[Paso 2: Definir Valor de Negocio]
    C --> D{¿Requisito amplio?}
    D -- Sí --> E[Paso 3: Atomizar en historias independientes]
    D -- No --> F[Paso 4: Redactar historia\nComo / quiero / para]
    E --> F
    F --> G[Paso 5: Escribir Criterios de Aceptación\nnumerados y verificables]
    G --> H[Paso 6: Validar INVEST\nI · N · V · E · S · T]
    H --> I{¿Pasa todos\nlos criterios?}
    I -- No --> J[Refactorizar historia]
    J --> F
    I -- Sí --> K[Paso 7: Alinear con DoD del repo\npruebas, lint, revisión de código]
    K --> L([Output: US lista para desarrollo\ncon tabla INVEST + CA técnicos])
```

---

## Flujo resumido

| Paso | Acción | Salida |
|---|---|---|
| 1 | Identificar persona beneficiaria | `Como [persona]` |
| 2 | Definir valor de negocio | `para [beneficio]` |
| 3 | Atomizar si el requisito es amplio | Lista de historias independientes |
| 4 | Redactar en formato estándar | Cuerpo de la historia |
| 5 | Escribir CA numerados y verificables | Criterios de aceptación |
| 6 | Validar contra INVEST | Tabla INVEST por historia |
| 7 | Alinear con DoD del repositorio | CA técnicos añadidos |

---

## Relación con otras skills

```mermaid
flowchart LR
    PRD([PRD / Visión]) --> EPM[scrum-master-create-epics\nGenera Épicas]
    EPM --> USW[scrum-master-create-us\nGenera Historias de Usuario]
    USW --> DEV([Desarrollo / Sprint])
```

- **`scrum-master-create-epics`**: skill upstream — transforma visión de producto en Épicas.
- **`scrum-master-create-us`**: esta skill — desglosa Épicas o requisitos en Historias de Usuario.
- El output de `scrum-master-create-epics` es un input válido para `scrum-master-create-us`.
