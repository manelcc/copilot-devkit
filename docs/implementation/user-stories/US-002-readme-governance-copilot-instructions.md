# US-002 — README, governance y copilot-instructions

## Contexto de la necesidad
Para que cualquier consumidor o contributor entienda el repositorio en menos de 5 minutos, necesita un README claro y un `.github/copilot-instructions.md` que configure Copilot. La `constitution.md` ya existe; esta US la expone y conecta con el punto de entrada.

## 1. Encabezado y trazabilidad
- **ID US**: US-002
- **Título usuario**: README principal, governance visible y configuración Copilot
- **Descripción usuario**: Como consumidor o contributor del repositorio, quiero un README que explique el propósito, la estructura y cómo empezar en menos de 5 minutos, para poder usar o contribuir al repo sin buscar documentación dispersa.
- **Épica relacionada**: EP-1 — Fundamentos e Inicialización
- **Prioridad sugerida**: Alta (P0)
- **Criterios funcionales trazados**:
  - README con propósito, tabla de stacks, mapa de estructura y quick-start
  - `.github/copilot-instructions.md` que referencia documentos clave
  - `constitution.md` ya existe — enlazar desde README

## 2. Cobertura funcional
- **Flujo principal**:
  1. Contributor abre el repositorio por primera vez
  2. Lee README → entiende propósito y estructura en < 5 min
  3. Sigue quick-start → ejecuta `./setup.sh` y `devtools sync`
- **Entradas**: `constitution.md`, `epics.md`, `sync-strategy.md` (existentes)
- **Validaciones**: README no puede tener links rotos; copilot-instructions.md debe referenciar rutas relativas válidas
- **Salidas**: `README.md` navegable, `.github/copilot-instructions.md` funcional
- **Casos límite**: Si se añaden stacks nuevos, README se actualiza en la misma PR

## 3. Dependencias y restricciones
- **Dependencias funcionales/técnicas**: US-001 (estructura de directorios debe existir para que los links sean válidos)
- **Riesgos aplicables**: README desactualizado genera confusión en consumidores
- **Pendientes de validación**: ¿Se necesita README por cada namespace o solo el raíz?
- **Bloqueantes**: Ninguno si US-001 está completada

## 4. Solución funcional
- **Secciones del README**:
  1. Título + descripción (2-3 líneas)
  2. Tabla de stacks cubiertos (Stack | Lenguaje | Frameworks)
  3. Estructura del repositorio (árbol a 2 niveles)
  4. Quick-start para proyectos consumidores (`pip install`, `devtools sync`)
  5. Quick-start para contributors (`./setup.sh`, `devtools scaffold skill`)
  6. Governance → link a `docs/implementation/constitution.md`
  7. Backlog y roadmap → link a `docs/implementation/epics.md`
- **`.github/copilot-instructions.md`**:
  - Propósito del repo
  - Cómo activar skills: referencia `skills/_TEMPLATE/SKILL.md`
  - Cómo activar agentes: referencia `agents/_TEMPLATE.agent.md`
  - Links a constitution, epics, sync-strategy

## 5. Checklist de calidad
- **CRITICAL**
  - [ ] Ningún link en README apunta a fichero inexistente
  - [ ] `.github/copilot-instructions.md` existe con contenido no vacío
- **HIGH**
  - [ ] Quick-start de consumidor tiene comandos exactos y funcionales
  - [ ] Quick-start de contributor tiene comandos exactos y funcionales
- **MEDIUM**
  - [ ] Tabla de stacks coincide con la de `constitution.md` (9 stacks)
- **LOW**
  - [ ] README tiene menos de 200 líneas

## 6. Casos de prueba
- **Funcionales**:
  - Todos los links del README resuelven correctamente en GitHub/GitLab
  - Comando `pip install -e cli-tools/` del quick-start ejecuta sin error
- **Reglas de negocio**:
  - Tabla de stacks debe tener los mismos 9 stacks que `constitution.md`
- **Errores**: Skills no existentes aún se indican como "(próximamente)" sin link roto

## 8. Notas y Definition of Ready
- **Decisiones abiertas**: ¿Incluir badges de CI en README desde el inicio?
- **Supuestos**: Quick-start asume Python 3.11+ instalado
- **Dependencias previas**: US-001 completada
- **Definition of Ready**:
  - [ ] US-001 completada (estructura existe)
  - [ ] Tabla de stacks definitiva aprobada en `constitution.md`
  - [ ] Comandos de quick-start verificados manualmente
