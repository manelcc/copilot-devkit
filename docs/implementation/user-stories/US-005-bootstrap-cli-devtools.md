# US-005 — Bootstrap CLI devtools

## Contexto de la necesidad
Para que los proyectos consumidores puedan sincronizar artefactos y los contributors puedan crear nuevas skills con consistencia, se necesita un CLI Python (`devtools`) con estructura modular, entry points declarados y la base del código migrada desde `bankinter-devtools/cli-tools/`.

## 1. Encabezado y trazabilidad
- **ID US**: US-005
- **Título usuario**: Bootstrap del CLI devtools (estructura Python + migración base)
- **Descripción usuario**: Como desarrollador que usa el repositorio, quiero un comando `devtools` instalable que sirva de base para sync, scaffold y validate, para no depender de scripts bash dispersos.
- **Épica relacionada**: EP-9 — CLI Tools
- **Prioridad sugerida**: Alta (P0)
- **Criterios funcionales trazados**:
  - `cli-tools/pyproject.toml` con entry point `devtools`
  - Subcomandos: `sync`, `scaffold`, `validate`, `list` (stubs aceptados inicialmente)
  - Migración del código base de `bankinter-devtools/cli-tools/` como punto de partida
  - `devtools --help` funcional tras `pip install -e cli-tools/`

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Evidencia/Nota |
|---|---|---|---|---|
| RQ-001 | Python >= 3.11 | Necesario | Técnico | Verificado en setup.sh |
| RQ-002 | Entry point `devtools` declarado en pyproject.toml | Necesario | Funcional | Permite `devtools --help` |
| RQ-003 | Subcomandos sync, scaffold, validate, list registrados | Necesario | Funcional | Stubs aceptados en esta US |

## 2. Cobertura funcional
- **Flujo principal**:
  1. `./setup.sh` ejecuta `pip install -e cli-tools/`
  2. `devtools --help` muestra subcomandos disponibles
  3. `devtools sync --help`, `devtools scaffold --help`, `devtools validate --help` funcionan
- **Entradas**: Instalación via pip desde el repo local
- **Validaciones**: Entry point debe existir y ser ejecutable; `--help` no puede dar ImportError
- **Salidas**: Comando `devtools` disponible en PATH
- **Casos límite**: Si ya existe un `devtools` en PATH de otro paquete, advertir conflicto

## 3. Dependencias y restricciones
- **Dependencias funcionales/técnicas**: US-001 (directorio `cli-tools/` existe); `bankinter-devtools/cli-tools/` como fuente
- **Riesgos aplicables**: Si la estructura de `bankinter-devtools` cambia, la migración puede necesitar adaptación
- **Pendientes de validación**: ¿Se usa `argparse` o `click` como base del CLI?
- **Bloqueantes**: Acceso a `bankinter-devtools/cli-tools/` para migración

## 4. Solución funcional
- **Estructura `cli-tools/`**:
```
cli-tools/
  pyproject.toml
  devtools/
    __init__.py
    cli.py           ← entry point principal
    commands/
      sync.py        ← stub
      scaffold.py    ← stub
      validate.py    ← stub
      list_cmd.py    ← stub
    utils/
      __init__.py
  tests/
    __init__.py
```
- **`pyproject.toml`** entry point:
```toml
[project.scripts]
devtools = "devtools.cli:main"
```
- **Fuente de migración**: `bankinter-devtools/cli-tools/` — patrón de entry points, estructura de módulos, tests base
- **Referencia**: `bankinter-devtools/cli-tools/bin/` y `bankinter-devtools/cli-tools/bankinter/`

## 5. Checklist de calidad
- **CRITICAL**
  - [ ] `pip install -e cli-tools/` sale sin errores
  - [ ] `devtools --help` muestra los 4 subcomandos sin ImportError
- **HIGH**
  - [ ] Cada subcomando tiene `--help` descriptivo
  - [ ] Tests unitarios básicos de CLI pasan (`pytest cli-tools/tests/`)
- **MEDIUM**
  - [ ] Código base de bankinter-devtools migrado (no reescrito desde cero)
- **LOW**
  - [ ] `devtools --version` muestra la versión del pyproject.toml

## 6. Casos de prueba
- **Funcionales**:
  - `pip install -e cli-tools/` → exit 0
  - `devtools --help` → muestra sync, scaffold, validate, list
  - `devtools sync --help` → muestra opciones disponibles
  - `devtools scaffold --help` → muestra opciones disponibles
- **Errores**: `devtools unknown-command` → mensaje claro "comando no reconocido"

## 8. Notas y Definition of Ready
- **Decisiones abiertas**: ¿argparse, click o typer para el CLI?
- **Supuestos**: `bankinter-devtools/cli-tools/` usa Python puro (sin dependencias exóticas)
- **Dependencias previas**: US-001 completada; acceso a `bankinter-devtools/`
- **Definition of Ready**:
  - [ ] US-001 completada
  - [ ] Decisión tomada sobre librería CLI (argparse/click/typer)
  - [ ] Acceso confirmado a `bankinter-devtools/cli-tools/` para migración
