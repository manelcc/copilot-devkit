# US-001 — Navegar estructura de directorios sin ambigüedad

**Como** contributor del repositorio DevTools-AI,  
**quiero** encontrar todos los namespaces de stacks creados desde el primer commit,  
**para** añadir artefactos en la ubicación correcta sin necesitar consultar documentación o preguntar al equipo.

---

## Criterios de Aceptación

1. Dado que clono el repositorio vacío, cuando ejecuto `tree .github/ -L 3`, veo los directorios `agents/`, `skills/`, `prompts/` con subdirectorios idénticos para los 9 stacks definidos en `constitution.md`.
2. Cada directorio hoja contiene un archivo `.gitkeep` para ser trackeado por Git desde el primer commit.
3. Los namespaces en `agents/`, `skills/` y `prompts/` son simétricos: si existe `agents/android/compose/`, también existen `skills/android/compose/` y `prompts/android/compose/`.
4. El directorio `cli-tools/` contiene `pyproject.toml` con entry point `devtools` declarado.
5. El archivo `instructions/global.instructions.md` existe (aunque sea un stub con comentario `# TODO: completar en US-XXX`).
6. Ejecutar `git status` después de clonar muestra todos los `.gitkeep` como archivos trackeados.
7. La estructura refleja exactamente los 9 stacks definidos en `constitution.md`: `global`, `android/{compose,legacy,kmp}`, `ios/{swiftui,uikit}`, `multiplatform/{kmp,cmp}`, `backend/{kotlin-ktor,python,spring-java}`.

---

## Notas Técnicas

**Estructura a crear**:
```
.github/
├── agents/
│   ├── global/
│   ├── android/{compose,legacy,kmp}/
│   ├── ios/{swiftui,uikit}/
│   ├── multiplatform/{kmp,cmp}/
│   └── backend/{kotlin-ktor,python,spring-java}/
├── skills/ (misma estructura que agents/)
├── prompts/ (misma estructura que agents/)
├── instructions/
│   └── global.instructions.md (stub)
└── dod.md
cli-tools/
├── pyproject.toml
└── devtools/__init__.py
scripts/
└── validate-skill.sh (stub → US-004)
docs/implementation/
└── user-stories/
```

**Decisiones abiertas**: Si se añaden stacks nuevos en el futuro, ¿se actualizan manualmente o con script de migración?

**Supuestos**: Python 3.11+ está disponible en el entorno del contributor.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| **Independiente** | ✅ | No depende de ninguna otra US; es la primera del backlog |
| **Negociable** | ✅ | El número de namespaces podría ajustarse, pero la simetría no |
| **Valiosa** | ✅ | Reduce tiempo de búsqueda de ubicación correcta de artefactos de ~15 min a 0 |
| **Estimable** | ✅ | Trabajo conocido: crear directorios + `.gitkeep` + stubs |
| **Small** | ✅ | Cabe en 1-2 horas de trabajo |
| **Testeable** | ✅ | Todos los CA son verificables con comandos `tree`, `git status` |

---

## Épica Relacionada

EP-1 — Habilitar contribución colaborativa en el repositorio DevTools-AI

---

## Prioridad

**P0** (Bloqueante) — Sin estructura, ninguna otra US puede comenzar.
flowchart TD
    A[Repo vacío] --> B[Crear árbol agents/]
    A --> C[Crear árbol skills/]
    A --> D[Crear árbol prompts/]
    B --> E{¿Simétrico?}
    C --> E
    D --> E
    E -->|Sí| F[Crear instructions/ cli-tools/ scripts/ .githooks/]
    E -->|No| G[Corregir namespaces faltantes]
    G --> E
    F --> H[git commit: chore: init repo structure]
```

## 8. Notas y Definition of Ready
- **Decisiones abiertas**: ¿`prompts/` es plano o jerárquico?
- **Supuestos**: Los namespaces no cambian durante Sprint 0
- **Dependencias previas**: Ninguna
- **Definition of Ready**:
  - [ ] Repositorio git inicializado con remote configurado
  - [ ] Tabla de namespaces de `constitution.md` ratificada
