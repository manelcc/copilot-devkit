# US-007 — Centralizar skills backend Kotlin/Ktor probadas en producción

**Como** desarrollador backend Kotlin,  
**quiero** encontrar las 6 skills de mycardiochef disponibles en `skills/backend/kotlin-ktor/`,  
**para** reutilizarlas en cualquier proyecto Ktor sin copiarlas manualmente ni mantener versiones paralelas.

---

## Requerimientos de inicio

| ID | Requerimiento | Estado | Tipo | Evidencia/Nota |
|---|---|---|---|---|
| RQ-001 | Acceso a `mycardiochef/middleware/.github/skills/` | Necesario | Funcional | Path: `/Users/manelcc/.../mycardiochef/middleware/.github/skills/` |
| RQ-002 | Skills a migrar identificadas y accesibles | Necesario | Funcional | Ver lista en sección 2 |
| RQ-003 | validate-skill.sh operativo (US-004) | Necesario | Funcional | Para verificar skills migradas |

## Criterios de Aceptación

1. Las 6 skills existen en `skills/backend/kotlin-ktor/`: `kotlin-mcp-server-generator`, `logging-kotlin`, `unit-testing-kotlin`, `postgresql-crud`, `ktor-auth-flow` (renombrada desde `mycardio-middleware-auth-flow`), `webscraping-contract`.
2. Cada skill migrada pasa validación: `./scripts/validate-skill.sh skills/backend/kotlin-ktor/<skill-name>/` devuelve exit code 0.
3. Ningún archivo migrado contiene referencias a paths de mycardiochef (verificable con `grep -r "mycardiochef" skills/backend/kotlin-ktor/` sin resultados).
4. Cada skill tiene `references/overview.md` con bloque Mermaid (si no existía en el origen, se crea uno básico).
5. El frontmatter `name` de cada skill refleja el nuevo nombre (especialmente `ktor-auth-flow`).
6. Los paths relativos internos (links a otros archivos de la misma skill) son válidos en el nuevo namespace.
7. Ejecutar `ls -1 skills/backend/kotlin-ktor/` muestra exactamente 6 directorios.
8. Las skills migradas mantienen el historial de commits (usar `cp -r` o `git mv` según aplique).

---

## Notas Técnicas

**Path fuente**: `/Users/manelcc/.../mycardiochef/middleware/.github/skills/`

**Skills a migrar** (fuente → destino):
1. `kotlin-mcp-server-generator/` → `skills/backend/kotlin-ktor/kotlin-mcp-server-generator/`
2. `logging-kotlin/` → `skills/backend/kotlin-ktor/logging-kotlin/`
3. `unit-testing-kotlin/` → `skills/backend/kotlin-ktor/unit-testing-kotlin/`
4. `postgresql-crud/` → `skills/backend/kotlin-ktor/postgresql-crud/`
5. `mycardio-middleware-auth-flow/` → `skills/backend/kotlin-ktor/ktor-auth-flow/` *(renombrada)*
6. `middleware-webscraping-contract/` → `skills/backend/kotlin-ktor/webscraping-contract/`

**Decisiones abiertas**: ¿Migrar también `mycardio-middleware-user-profile`?

**Supuestos**: Los nombres simplificados son suficientemente descriptivos sin prefijo proyecto.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| **Independiente** | ✅ | Depende de US-001 (namespace existe) y US-004 (validador) |
| **Negociable** | ✅ | Nombres de skills renombradas ajustables |
| **Valiosa** | ✅ | Hace disponibles skills probadas en producción para cualquier proyecto Ktor |
| **Estimable** | ✅ | Migración de 6 directorios + validación: 4-6 horas |
| **Small** | ✅ | 8 CA, cubre migración completa de 6 skills |
| **Testeable** | ✅ | Todos los CA verificables con comandos de validación |

---

## Épica Relacionada

EP-7 — Stack Backend

---

## Prioridad

**P0** (Bloqueante) — Primera población del namespace backend con skills probadas.

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
