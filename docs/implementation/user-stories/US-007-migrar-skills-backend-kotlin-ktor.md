# US-007 — Migrar skills backend Kotlin/Ktor

## Contexto de la necesidad
El proyecto `mycardiochef/middleware` contiene 6 skills de backend Kotlin/Ktor probadas en producción. Migrarlas al namespace centralizado `skills/backend/kotlin-ktor/` las hace disponibles para cualquier proyecto Ktor sin duplicación ni mantenimiento paralelo.

## 1. Encabezado y trazabilidad
- **ID US**: US-007
- **Título usuario**: Migrar skills backend Kotlin/Ktor desde mycardiochef
- **Descripción usuario**: Como desarrollador backend Kotlin, quiero encontrar las skills de mycardiochef disponibles en `skills/backend/kotlin-ktor/`, para usarlas en cualquier proyecto Ktor sin copiarlas manualmente.
- **Épica relacionada**: EP-7 — Stack Backend
- **Prioridad sugerida**: Alta (P0)
- **Criterios funcionales trazados**:
  - 6 skills migradas con frontmatter actualizado y paths relativos válidos
  - Cada skill tiene `references/overview.md` con Mermaid
  - Skills pasan `validate-skill.sh` sin errores

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Evidencia/Nota |
|---|---|---|---|---|
| RQ-001 | Acceso a `mycardiochef/middleware/.github/skills/` | Necesario | Funcional | Path: `/Users/manelcc/.../mycardiochef/middleware/.github/skills/` |
| RQ-002 | Skills a migrar identificadas y accesibles | Necesario | Funcional | Ver lista en sección 2 |
| RQ-003 | validate-skill.sh operativo (US-004) | Necesario | Funcional | Para verificar skills migradas |

## 2. Cobertura funcional
- **Skills a migrar** (fuente → destino):
  1. `MC:skills/kotlin-mcp-server-generator/` → `skills/backend/kotlin-ktor/kotlin-mcp-server-generator/`
  2. `MC:skills/logging-kotlin/` → `skills/backend/kotlin-ktor/logging-kotlin/`
  3. `MC:skills/unit-testing-kotlin/` → `skills/backend/kotlin-ktor/unit-testing-kotlin/`
  4. `MC:skills/postgresql-crud/` → `skills/backend/kotlin-ktor/postgresql-crud/`
  5. `MC:skills/mycardio-middleware-auth-flow/` → `skills/backend/kotlin-ktor/ktor-auth-flow/` *(renombrada: elimina referencia a mycardiochef)*
  6. `MC:skills/middleware-webscraping-contract/` → `skills/backend/kotlin-ktor/webscraping-contract/`

- **Por cada skill migrada**:
  1. Copiar todos los ficheros del directorio fuente
  2. Actualizar frontmatter `name` al nuevo nombre si cambió
  3. Verificar y actualizar paths relativos internos
  4. Crear `references/overview.md` si no existe
  5. Ejecutar `validate-skill.sh` sobre el destino

- **Salidas**: 6 directorios en `skills/backend/kotlin-ktor/` con estructura válida

## 3. Dependencias y restricciones
- **Dependencias funcionales/técnicas**: US-001 (namespace existe), US-004 (validador disponible)
- **Riesgos aplicables**: Referencias internas a paths de mycardiochef deben actualizarse; riesgo de links rotos
- **Pendientes de validación**: ¿La skill `mycardio-middleware-user-profile` también se migra? (no estaba en el plan original)
- **Bloqueantes**: Acceso al path de mycardiochef

## 4. Solución funcional
- **Proceso de migración por skill**:
  1. `cp -r <source>/ <dest>/`
  2. Editar frontmatter: actualizar `name` si cambió
  3. Revisar referencias internas (paths relativos a otros ficheros del mismo repo)
  4. Si no existe `references/overview.md`: crear con Mermaid básico del workflow
  5. `./scripts/validate-skill.sh <dest>/` → debe salir exit 0

## 5. Checklist de calidad
- **CRITICAL**
  - [ ] Las 6 skills existen en `skills/backend/kotlin-ktor/`
  - [ ] Ningún fichero referencia paths de mycardiochef (`/mycardiochef/`)
  - [ ] Todas pasan `validate-skill.sh` exit 0
- **HIGH**
  - [ ] `mycardio-middleware-auth-flow` renombrada a `ktor-auth-flow`
  - [ ] Cada skill tiene `references/overview.md` con diagrama Mermaid
- **MEDIUM**
  - [ ] Frontmatter `name` actualizado donde cambió el nombre
- **LOW**
  - [ ] Añadir nota en frontmatter indicando el origen de la migración

## 6. Casos de prueba
- **Funcionales**:
  - `ls skills/backend/kotlin-ktor/` → 6 directorios
  - `./scripts/validate-skill.sh skills/backend/kotlin-ktor/logging-kotlin/` → exit 0
  - `grep -r "mycardiochef" skills/backend/kotlin-ktor/` → sin resultados
- **Errores**: Si una skill fuente no tiene `references/overview.md`, la migración la crea automáticamente

## 8. Notas y Definition of Ready
- **Decisiones abiertas**: ¿Migrar también `mycardio-middleware-user-profile`?
- **Supuestos**: Los nombres simplificados (sin prefijo `mycardio-`) son suficientemente descriptivos
- **Dependencias previas**: US-001, US-004 completadas
- **Fuentes**:
  - `mycardiochef/.github/skills/kotlin-mcp-server-generator/`
  - `mycardiochef/.github/skills/logging-kotlin/`
  - `mycardiochef/.github/skills/unit-testing-kotlin/`
  - `mycardiochef/.github/skills/postgresql-crud/`
  - `mycardiochef/.github/skills/mycardio-middleware-auth-flow/`
  - `mycardiochef/.github/skills/middleware-webscraping-contract/`
- **Definition of Ready**:
  - [ ] US-001 y US-004 completadas
  - [ ] Acceso confirmado al path de mycardiochef
  - [ ] Lista definitiva de skills a migrar aprobada
