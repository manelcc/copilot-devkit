# US-002 — Entender el repositorio sin consultar documentación externa

**Como** consumidor o contributor del repositorio DevTools-AI,  
**quiero** un README que explique el propósito, estructura y cómo empezar en menos de 5 minutos,  
**para** usar o contribuir al repo sin buscar documentación dispersa o preguntar al equipo.

---

## Criterios de Aceptación

1. Dado que abro el repositorio en GitHub, cuando leo el README completo, entiendo el propósito, los stacks cubiertos y cómo empezar en menos de 5 minutos.
2. El README contiene una tabla con los 9 stacks definidos en `constitution.md` (columnas: Stack, Lenguaje, Frameworks clave).
3. El README incluye un árbol de estructura del repositorio hasta nivel 2 de profundidad.
4. El README tiene sección "Quick-start para consumidores" con comando exacto: `pip install -e cli-tools/ && devtools sync`.
5. El README tiene sección "Quick-start para contributors" con comando exacto: `./setup.sh && devtools scaffold skill my-skill global`.
6. Ningún link en README apunta a archivo inexistente (verificable con `markdown-link-check` o manualmente).
7. El archivo `.github/copilot-instructions.md` existe y referencia: `constitution.md`, `epics.md`, template de skills en `skills/_TEMPLATE/SKILL.md`.
8. Los comandos del quick-start ejecutan sin error en entorno con Python 3.11+ y Git configurado.
9. El README tiene menos de 200 líneas y usa encabezados Markdown (`#`, `##`) para navegación.

---

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

## Notas Técnicas

**Secciones del README**:
1. Título + descripción (2-3 líneas)
2. Tabla de stacks cubiertos
3. Estructura del repositorio (árbol a 2 niveles)
4. Quick-start para consumidores
5. Quick-start para contributors
6. Link a governance (`docs/implementation/constitution.md`)
7. Link a backlog y roadmap (`docs/implementation/epics.md`)

**Decisiones abiertas**: ¿Incluir badges de CI en README desde el inicio?

**Supuestos**: Quick-start asume Python 3.11+ instalado.

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| **Independiente** | ✅ | Depende de US-001 (estructura existe), pero no bloquea otras US |
| **Negociable** | ✅ | Número de secciones del README ajustable; comandos no |
| **Valiosa** | ✅ | Reduce tiempo de onboarding de 2h a <10 min |
| **Estimable** | ✅ | Redacción + validación de links: 3-4 horas |
| **Small** | ✅ | 9 CA, cubre un flujo (lectura → comprensión) |
| **Testeable** | ✅ | Todos los CA verificables con ejecución de comandos o inspección manual |

---

## Épica Relacionada

EP-1 — Habilitar contribución colaborativa en el repositorio DevTools-AI

---

## Prioridad

**P0** (Bloqueante) — Sin README, consumidores no saben cómo usar el repo.
