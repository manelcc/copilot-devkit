---
name: clean-code-guardian
description: >
  Revisa y corrige violaciones de Clean Code en clases Kotlin/Java/Python del repositorio.
  Detecta clases >500 lineas, funciones >30 lineas, anidamiento >3 niveles,
  magic numbers, nombres poco descriptivos y violaciones del SRP.
  Puede ejecutar un script de analisis estatico como apoyo.
applyTo:
  - "**/*.kt"
  - "**/*.java"
  - "**/*.py"
triggers:
  - "revisa el clean code"
  - "aplica clean code"
  - "esta clase tiene demasiadas lineas"
  - "refactoriza siguiendo clean code"
  - "detecta violaciones de clean code"
  - "clean code review"
  - "la clase es demasiado grande"
  - "demasiadas responsabilidades"
nonTriggers:
  - Generacion de tests unitarios
  - Revision de arquitectura de modulos o dependencias Gradle
  - Configuracion de CI/CD
  - Cambios en ficheros de build o configuracion
---

# Clean Code Guardian - Kotlin/Java/Python (Hybrid)

## Proposito

Guiar a Copilot para detectar y corregir violaciones de Clean Code en clases Kotlin/Java,
aplicando modo hibrido:

1. Reglas base en [references/rules.md](references/rules.md)
2. Reglas ampliadas por lenguaje en:
- [references/catalog/clean-code-kotlin-rules.json](references/catalog/clean-code-kotlin-rules.json)
- [references/catalog/clean-code-java-rules.json](references/catalog/clean-code-java-rules.json)
- [references/catalog/clean-code-python-rules.json](references/catalog/clean-code-python-rules.json)

## Cuando usar esta skill

- El usuario pide revisar o refactorizar una clase Kotlin, Java o Python.
- Se menciona que una clase tiene demasiadas lineas o demasiadas responsabilidades.
- Se pide aplicar buenas practicas, clean code o reducir complejidad.
- Code review en el que se detectan ficheros .kt, .java o .py con mas de 500 lineas.

## Cuando NO usar esta skill

- Generacion de mocks o tests (usar unit-testing-kotlin).
- Revision de arquitectura de capas o dependencias entre modulos (usar clean-architecture).
- Revision de dependencias o configuracion Gradle.
- Auditoria de seguridad.
- Configuracion de CI/CD.

## Inputs

- Archivo activo: clase .kt, .java o .py abierta en el editor o proporcionada por el usuario.
- Contexto adicional (opcional): descripcion del dominio o responsabilidad esperada de la clase.

## Carga de reglas (modo hibrido)

1. Cargar siempre reglas base desde [references/rules.md](references/rules.md).
2. Detectar lenguaje por extension del archivo objetivo:
- .kt -> usar catalogo Kotlin (clean-code-kotlin-rules.json)
- .java -> usar catalogo Java (clean-code-java-rules.json)
- .py -> usar catalogo Python (clean-code-python-rules.json)
3. No mezclar reglas entre lenguajes en el mismo archivo analizado.
4. Si el input incluye varios ficheros de distintos lenguajes, evaluar cada archivo con su catalogo correspondiente.

## Constraints

| Regla | Limite |
|---|---|
| Lineas por clase | <= 500 |
| Lineas por funcion/metodo | <= 30 |
| Parametros por funcion | <= 4 |
| Niveles de anidamiento | <= 3 |
| Magic numbers inline | 0 (usar const val o constant) |
| Abreviaturas cripticas en nombres | 0 |
| Clases con multiples responsabilidades (SRP) | 0 |

## Pasos de ejecucion

### 1. Deteccion de lenguaje y reglas activas

Antes de analizar:

- Identificar lenguaje por extension del fichero.
- Activar reglas base de rules.md.
- Activar solo el catalogo JSON del mismo lenguaje.

### 2. Analisis estatico (opcional)

Si el usuario tiene script disponible y el fichero es Kotlin, ejecutar:

```bash
.github/skills/clean-code-guardian/scripts/check-clean-code.sh <ruta-al-fichero.kt>
```

Para Java (o si no hay script), continuar con revision manual.

### 3. Revision manual del archivo

Leer el archivo completo con read_file y aplicar checklist de reglas base + catalogo del lenguaje.

### 4. Reporte de violaciones

Para cada violacion:

```text
[CC-XX | CC-KT-XXX | CC-JV-XXX] <Descripcion de la regla>
  -> Linea: <N>
  -> Problema: <descripcion concreta>
  -> Sugerencia: <refactor recomendado>
```

### 5. Aplicar correcciones

- Si clase > 500 lineas: proponer extraccion de responsabilidades.
- Si funcion > 30 lineas: Extract Function con nombre descriptivo.
- Si hay magic numbers: definir constantes nombradas.
- Si anidamiento > 3: Guard Clauses o extraccion de funciones.
- Si nombre ambiguo: renombrado con intencion.

### 6. Validacion post-refactor

1. Verificar limites de clase/funcion.
2. Verificar comportamiento equivalente.
3. Ejecutar build del modulo afectado.

## Outputs esperados

- Lista numerada de violaciones con localizacion exacta.
- Codigo refactorizado o sugerencias concretas.
- Evidencia de reglas aplicadas (base + catalogo de lenguaje).

## Referencias

- [references/overview.md](references/overview.md)
- [references/rules.md](references/rules.md)
- [references/catalog/clean-code-kotlin-rules.json](references/catalog/clean-code-kotlin-rules.json)
- [references/catalog/clean-code-java-rules.json](references/catalog/clean-code-java-rules.json)
- [references/catalog/clean-code-rule.schema.json](references/catalog/clean-code-rule.schema.json)
