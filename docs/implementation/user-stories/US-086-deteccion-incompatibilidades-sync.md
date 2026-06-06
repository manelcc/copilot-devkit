# US-086 — Detectar y reportar incompatibilidades de sincronización

**Como** desarrollador de un proyecto consumidor,
**quiero** que el comando de sincronización detecte incompatibilidades antes de aplicar cambios,
**para** evitar que `devtools sync` rompa dependencias o sobrescriba artefactos incompatibles.

---

## Criterios de aceptación

1. El comando `devtools sync` compara metadatos de la fuente y el lock antes de copiar artefactos.
2. Si detecta incompatibilidades de versión o dependencias, muestra un mensaje claro y no aplica los cambios.
3. El comando permite continuar con `--force` cuando el usuario confirma conscientemente la sobrescritura.
4. El mecanismo reporta qué artefactos son incompatibles y por qué (versión, checksum, dependencia faltante).
5. El archivo `devtools.lock.json` almacena el estado sincronizado y se usa como base para la comparación.
6. Si el manifest contiene un `source` inválido, el comando falla con un error descriptivo.
7. Se documenta el comportamiento en `docs/implementation/sync-strategy.md` y en la ayuda `devtools sync --help`.

---

## Referencias

- `docs/implementation/sync-strategy.md`
- `US-083` — Comando devtools sync
- `US-006` — Devtools sync copy-on-demand

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Enfocado en la detección de incompatibilidades del sync |
| Negociable | ✅ | El formato exacto del reporte puede ajustarse |
| Valiosa | ✅ | Evita sincronizaciones destructivas en consumidores |
| Estimable | ✅ | Alcance definido en el comando sync y la comparación de lock |
| Small | ✅ | Centrado en un problema de compatibilidad concreto |
| Testeable | ✅ | CA comprobables con pruebas de manifest y lock |
