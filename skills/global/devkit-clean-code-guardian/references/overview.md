# Clean Code Guardian - Diagrama de flujo (Hybrid)

## Workflow

```mermaid
flowchart TD
    A([Usuario solicita\nrevision clean code]) --> B[Copilot activa\nclean-code-guardian skill]
    B --> C[Lee fichero .kt o .java\ncon read_file]
    C --> C1{Lenguaje del fichero}
    C1 -- Kotlin --> C2[Activa rules.md +\nclean-code-kotlin-rules.json]
    C1 -- Java --> C3[Activa rules.md +\nclean-code-java-rules.json]
    C2 --> D[Valida y carga template oficial de COPILOT]
    C3 --> D
    D --> D1{Template accesible}
    D1 -- No --> X[Error y detener sin informe]
    D1 -- Si --> E{Script disponible}
    E -- Si --> F[Ejecuta check-clean-code.sh\nen fichero Kotlin]
    E -- No --> G[Analisis manual\ncon checklist]
    F --> G
    G --> H[Detecta violaciones\nbase + catalogo de lenguaje]
    H --> I[Reporta hallazgos\ncon regla y linea]
    I --> J[Aplica refactor\nsi usuario lo pide]
    J --> K[Valida build del modulo]
    K --> L[Rellena template oficial]
    L --> M[Escribe informe en docs/quality/clean-code-YYYY-MM-DD.md]
```

## Descripcion del flujo

| Paso | Descripcion |
|---|---|
| Activacion | El usuario pide revision clean code o refactor de clase. |
| Lectura | Se lee el fichero .kt/.java completo. |
| Deteccion de lenguaje | Se selecciona catalogo JSON por extension del fichero. |
| Reglas | Se aplican siempre rules.md + catalogo del lenguaje activo. |
| No mezcla | Un fichero Kotlin no usa reglas Java y viceversa. |
| Reporte | Cada hallazgo se informa con id de regla, linea y sugerencia. |
| Template | Se usa obligatoriamente `/Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/onedrive-IA/COPILOT/docs/quality/_TEMPLATE-clean-code-report.md`. |
| Validacion | Se recomienda validar con build/test del modulo afectado. |
