# Procedimiento Detallado — Git Workflow

## PASO 0 — Crear rama de feature desde `develop` actualizado

### Cuándo aplica
**Siempre que se inicie una feature nueva.** Si ya estás en una rama de feature con trabajo en curso, este paso no aplica.

### Comandos
```bash
# 1. Ir a develop
git checkout develop

# 2. Verificar que no hay cambios locales sin commitear en develop
git status

# 3. Actualizar desde origin estrictamente en fast-forward
git pull --ff-only origin develop

# 4. Crear la rama desde develop ya actualizado
git checkout -b feature/<nombre-descriptivo>
```

### Convención de nombres de rama
| Prefijo | Uso |
|---------|-----|
| `feature/` | Nueva funcionalidad |
| `fix/` | Corrección de bug |
| `refactor/` | Refactorización sin cambio de comportamiento |
| `chore/` | Mantenimiento, dependencias, CI |
| `docs/` | Solo documentación |

**Formato:** `<prefijo>/<kebab-case-descriptivo>` — corto pero legible.
Ejemplos: `feature/jsoup-recipe-client`, `fix/hmac-query-params`, `chore/bump-ktor-2.3.12`

### Árbol de decisión

```
git pull --ff-only
├── OK → git checkout -b feature/<nombre> → continuar al Paso 1
└── FALLO (divergencia)
    ├── Analizar con: git log develop..origin/develop --oneline
    ├── Informar al usuario sobre los commits que divergen
    └── NO hacer merge/rebase automáticamente — esperar instrucción del usuario
```

### Por qué `--ff-only`
`--force-forward-only` garantiza que `develop` local nunca crea un merge commit accidental al actualizar. Si hay divergencia real, falla explícitamente en lugar de silenciarla con un merge automático, lo que obliga a tratar la situación conscientemente.

---

## PASO 1 — Commits atómicos

### Principio
Un commit debe representar **exactamente un cambio lógico cohesivo**. El lector debe entender qué y por qué con solo leer el mensaje.

### Inspección de cambios
```bash
git status                    # Ver archivos modificados/sin seguimiento
git diff --stat               # Resumen de qué cambió en cada archivo
git diff                      # Ver el diff completo (antes de staging)
git diff --staged             # Ver lo que ya está en staging
```

### Agrupación lógica
Agrupa por **responsabilidad**, no por archivo. Ejemplos:

| Tipo de cambio | Commit separado |
|----------------|-----------------|
| Nueva feature + tests de esa feature | Un solo commit `feat:` |
| Fix de bug encontrado durante la feature | Commit `fix:` separado |
| Refactor de código preexistente | Commit `refactor:` separado |
| Actualización de dependencias | Commit `chore(deps):` separado |
| Cambios de documentación | Commit `docs:` separado |

### Conventional Commits — formato obligatorio
```
tipo(scope): descripción corta en imperativo

[cuerpo opcional — qué y por qué, no cómo]

[trailers opcionales: Breaking-Change, Closes #issue]
```

**Tipos permitidos:**
- `feat` — nueva funcionalidad
- `fix` — corrección de bug
- `refactor` — cambio de estructura sin alterar comportamiento
- `test` — añadir o corregir tests
- `docs` — solo documentación
- `chore` — tareas de mantenimiento (deps, config, CI)
- `style` — formato, linting (sin cambio de lógica)
- `perf` — mejoras de rendimiento

**Scopes sugeridos para este proyecto:**
- `api` — rutas Ktor / plugins
- `usecase` — casos de uso de aplicación
- `client` — clientes HTTP / scraping
- `infra` — infraestructura, configuración
- `auth` — autenticación HMAC
- `ci` — pipelines GitLab CI
- `deps` — dependencias

### Ejemplos de commits bien formados
```
feat(client): add JsoupRecipeClient retry on timeout

fix(auth): correct HMAC signature for query params with special chars

test(usecase): add ParseRecipeUseCase edge case for empty ingredient list

chore(deps): bump ktor to 2.3.12

refactor(api): extract route handlers to dedicated functions
```

### Staging selectivo (cuando hay mezcla de cambios)
```bash
# Añadir archivos completos
git add src/main/kotlin/com/mycardiochef/scraping/api/RecipeRoutes.kt

# Añadir solo partes de un archivo (modo interactivo)
git add -p src/main/kotlin/com/mycardiochef/scraping/infrastructure/client/JsoupRecipeClient.kt
```

---

## PASO 2 — Build

### Comando
```bash
./gradlew build
```

### Árbol de decisión post-build

```
Build resultado
├── ERROR (fallo de compilación)
│   └── Detener. Arreglar. Commit fix:. Repetir paso 2.
├── WARNING — linter (ktlint)
│   ├── Arreglable sin riesgo → arreglar → commit style: o chore: → repetir
│   └── No arreglable (deprecated de tercero) → documentar en commit body → continuar
└── SUCCESS (limpio)
    └── Continuar al Paso 3
```

### Ejecutar solo el linter
```bash
./gradlew ktlintCheck          # Verificar
./gradlew ktlintFormat         # Auto-corregir
```

---

## PASO 3 — Tests

### Comando
```bash
./gradlew test
```

### Con reporte de cobertura
```bash
./gradlew test jacocoTestReport
# Reporte en: build/reports/jacoco/test/html/index.html
```

### Árbol de decisión post-test

```
Tests resultado
├── FALLO
│   ├── Test unitario → arreglar código o test → commit fix: o test: → repetir
│   └── Test de integración → verificar dependencias externas → arreglar → repetir
└── SUCCESS
    ├── Cobertura bajó → evaluar si es aceptable → documentar o añadir tests
    └── Cobertura OK → continuar al Paso 4
```

---

## PASO 4 — Code Review Local

### Comando
```bash
./scripts/code_review_local.sh
```

### Prerrequisito: RAG API
El script conecta a `http://localhost:8000/api/v1`. Si no está disponible:
```bash
# Verificar disponibilidad
curl -sf http://localhost:8000/api/v1/health
```
Si el servicio no responde, advertir al usuario. El script intentará fallbacks automáticamente (`localhost`, `127.0.0.1`, `rag-api`).

### Árbol de decisión post-review

```
Code Review resultado
├── ERRORES CRÍTICOS (lógica incorrecta, seguridad, violación de arquitectura)
│   └── Arreglar obligatoriamente → commit fix: → Volver a Paso 2
├── WARNINGS (estilo, mejoras opcionales)
│   ├── Se pueden arreglar sin riesgo → arreglar → commit style:/chore: → Volver a Paso 2
│   └── No prioritarios → documentar en MR description → continuar
└── LIMPIO
    └── Continuar al Paso 5
```

---

## PASO 5 — Push

### Verificar rama actual
```bash
git branch --show-current
git log --oneline -5           # Revisar los últimos commits antes de push
```

### Push
```bash
# Si la rama ya existe en remoto
git push origin <rama>

# Si es primera vez (crea tracking)
git push -u origin <rama>
```

### Reglas de push
- **Nunca** `--force` sin confirmación explícita del usuario.
- **Nunca** push directo a `main` o `develop`.
- Si el push falla por divergencia: analizar con `git log origin/<rama>..HEAD` y proponer estrategia (rebase limpio o merge) antes de actuar.

---

## PASO 6 — Crear MR

### Información necesaria para el MR
Antes de redactar, recopilar:
```bash
git log origin/develop..HEAD --oneline    # Lista de commits del MR
git diff origin/develop --stat            # Resumen de archivos cambiados
git log origin/develop..HEAD --format="%s%n%b"  # Mensajes completos
```

### Destino
- Base: `develop` (siempre, salvo indicación explícita del usuario)
- Rama fuente: rama de feature actual

### Redacción
Usar la plantilla en [../assets/mr-description-template.md](../assets/mr-description-template.md).

### Labels sugeridos (si el proyecto los usa)
- `feature`, `bug`, `refactor`, `chore`, `security`, `breaking-change`
