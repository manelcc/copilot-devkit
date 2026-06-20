# US-007 — Migrar skills backend Kotlin/Ktor

**Status**: ✅ **DONE**  
**Sprint**: 1 | **Epic**: EP-7 | **Priority**: P0

---

## Funcionalidad entregada

Se migraron y dejaron operativas en el namespace backend Kotlin/Ktor las 6 skills planificadas:

1. `kotlin-mcp-server-generator`
2. `logging-kotlin`
3. `unit-testing-kotlin`
4. `postgresql-crud`
5. `ktor-auth-flow` (renombrada desde `mycardio-middleware-auth-flow`)
6. `webscraping-contract` (renombrada desde `middleware-webscraping-contract`)

Ubicación: `skills/backend/kotlin-ktor/`

---

## Ajustes aplicados en la migración

- Renombre de skills y actualización de `name` en frontmatter.
- Creación/actualización de `references/overview.md` con bloque Mermaid en las 6 skills.
- Limpieza de referencias específicas de proyecto para dejar el contenido agnóstico.
- Eliminación de referencias a `mycardiochef`, `mycardio` y `CardioChef` en las skills migradas.

---

## Evidencias de aceptación

### CA-1 y CA-7 — Existen exactamente 6 skills

Resultado de `ls -1 skills/backend/kotlin-ktor`:

- `kotlin-mcp-server-generator`
- `ktor-auth-flow`
- `logging-kotlin`
- `postgresql-crud`
- `unit-testing-kotlin`
- `webscraping-contract`

### CA-2 — Todas pasan validación

Ejecución validada:

```bash
for d in skills/backend/kotlin-ktor/*; do
  ./scripts/validate-skill.sh "$d" >/dev/null || exit 1
 done
 echo "ALL_VALID"
```

Resultado: `ALL_VALID`

### CA-3 — Sin referencias a mycardiochef

Ejecución validada:

```bash
grep -R "mycardiochef\|mycardio\|CardioChef" skills/backend/kotlin-ktor || true
```

Resultado: sin coincidencias.

### CA-4 — Mermaid en overview

Las 6 skills contienen `references/overview.md` con bloque ` ```mermaid `.

### CA-5 y CA-6 — Nombres y enlaces internos

- `ktor-auth-flow` y `webscraping-contract` usan nombres de frontmatter coherentes con destino.
- Referencias internas revisadas para mantener consistencia con el nuevo namespace backend.

---

## Nota sobre historial

La migración se realizó con copia estructurada (`cp -r`) desde la fuente identificada en la US, respetando el contenido funcional y ajustando únicamente lo necesario para nomenclatura y neutralidad de proyecto.
