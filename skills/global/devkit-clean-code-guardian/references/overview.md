# Clean Code Guardian - Diagrama de flujo (Hybrid)

## Workflow

```mermaid
flowchart TD
    A([Usuario solicita\nrevision clean code]) --> B[Copilot activa\nclean-code-guardian skill]
    B --> C[Lee fichero .kt o .java\ncon read_file]
    C --> C1{Lenguaje del fichero}
    C1 -- Kotlin --> C2[Activa rules.md +\nclean-code-kotlin-rules.json]
    C1 -- Java --> C3[Activa rules.md +\nclean-code-java-rules.json]
    C2 --> D{Script disponible}
    C3 --> F[Analisis manual\ncon checklist]
    D -- Si --> E[Ejecuta check-clean-code.sh\nen fichero Kotlin]
    D -- No --> F
    E --> F
    F --> G[Detecta violaciones\nbase + catalogo de lenguaje]
    G --> H[Reporta hallazgos\ncon regla y linea]
    H --> I[Aplica refactor\nsi usuario lo pide]
    I --> J[Valida build del modulo]
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
| Validacion | Se recomienda validar con build/test del modulo afectado. |
