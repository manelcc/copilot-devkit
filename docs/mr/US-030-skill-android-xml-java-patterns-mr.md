# MR — US-030: Skill Android XML+Java Patterns para stack Android Legacy

## Descripción

Añade la skill `android-xml-java-patterns` al namespace `android/legacy`, cubriendo los
patrones Android legacy con Java + XML necesarios para mantener y evolucionar apps existentes
con buenas prácticas y una hoja de ruta de migración incremental a Kotlin/Compose.

## Commits incluidos

| Hash | Tipo | Descripción |
|---|---|---|
| `9c1b5e0` | `feat` | add android-xml-java-patterns skill for Android legacy stack |

## Artefactos creados

| Artefacto | Ruta |
|---|---|
| Skill principal | `skills/android/legacy/android-xml-java-patterns/SKILL.md` |
| Diagrama Mermaid | `skills/android/legacy/android-xml-java-patterns/references/overview.md` |

## Criterios de aceptación cubiertos

- [x] `skills/android/legacy/android-xml-java-patterns/` creado con SKILL.md válido
- [x] Cubre: ViewBinding · Retrofit · Room · MVVM legacy con LiveData
- [x] Incluye ejemplos de migración incremental Java → Kotlin → Compose
- [x] `references/overview.md` con diagrama Mermaid del flujo legacy y hoja de ruta migración
- [x] `devkit-validate-skill.sh` retorna exit code 0 (pre-commit hook pasó)

## Contenido de la skill

**Patrones cubiertos:**
- Arquitectura: MVVM + LiveData, Repository
- UI: ViewBinding, RecyclerView + ListAdapter con DiffUtil
- Red: Retrofit + OkHttp
- Persistencia: Room + DAO + LiveData
- Concurrencia: ExecutorService (alternativa a AsyncTask deprecado)
- Migración: ComposeView en layouts XML existentes

**Antipatrones detectables:**
- God Activity (CRITICAL)
- AsyncTask (CRITICAL) — deprecated API 30
- Red en hilo UI (CRITICAL) — NetworkOnMainThreadException
- SQLite directo sin Room (HIGH)
- Singleton Context con Activity (HIGH) — memory leak
- `findViewById` sin ViewBinding (MEDIUM)

**Ejemplos incluidos:**
1. Refactorizar God Activity con MVVM + Repository
2. Configurar Room correctamente con Entity, DAO y Database singleton
3. Hoja de ruta incremental Java → Kotlin → Compose (5 pasos)

## Validación

```
[OK] SKILL.md exists
[OK] YAML frontmatter found
[OK] All frontmatter fields present
[OK] All 8 required sections present
[OK] references/overview.md exists
[OK] Mermaid diagram found
[OK] VALIDATION PASSED
```

## Impacto

- Namespace `skills/android/legacy/` pasa de vacío a operativo
- Simetría `agents/` · `skills/` · `prompts/` mantenida
- Sin cambios en ficheros existentes

## Rama origen → destino

`feature/US-030-skill-android-xml-java-patterns` → `develop`
