# US-083 — Comando devtools sync

**Como** desarrollador de un proyecto consumidor,
**quiero** ejecutar `devtools sync` para importar los artefactos que necesito,
**para** no copiarlos manualmente ni romper actualizaciones futuras.

---

## Criterios de aceptación

1. `devtools sync --manifest devtools.manifest.json` lee el manifest y copia artefactos al destino configurado.
2. Soporta los modos `copy` y `symlink`.
3. Antes de sobreescribir cambios locales pregunta al usuario si no se usa `--force`.
4. Genera o actualiza un archivo `devtools.lock.json` con el estado sincronizado.
5. El comando detecta y reporta versiones incompatibles al comparar metadata de artefactos.
6. En caso de artefacto inexistente en el source emite warning y continúa con el resto.

---

## Referencias

- `BK:cli-tools/sync_skills/`
- `US-006` — Devtools sync copy-on-demand

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Se centra en un subcomando concreto del CLI |
| Negociable | ✅ | El modo de copia y lock puede afinarse después |
| Valiosa | ✅ | Habilita la sincronización de artefactos de consumidor |
| Estimable | ✅ | CA claros y funcionales |
| Small | ✅ | Un subcomando completo pero limitado |
| Testeable | ✅ | CA comprobables con ejecución y manifest de prueba |
