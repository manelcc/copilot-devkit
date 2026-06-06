# US-084 — Comando devtools list

**Como** developer o maintainer,
**quiero** listar los artefactos disponibles en el repo con `devtools list`,
**para** saber qué skills, agentes e instrucciones existen sin buscar manualmente.

---

## Criterios de aceptación

1. El comando `devtools list` muestra un inventario de skills, agentes, prompts e instrucciones del repo.
2. La salida incluye categoría, namespace y estado básico (disponible / en progreso / pendiente).
3. Soporta filtros por tipo (`--type skill|agent|instructions`) y por namespace.
4. La salida se puede consumir en formato tabular o JSON con `--format json`.
5. El comando no falla si el repo contiene artefactos con frontmatter parcial; muestra advertencia en lugar de error.

---

## Referencias

- `US-080` — Estructura CLI devtools
- `US-083` — devtools sync

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Subcomando listado separado del sync/scaffold/validate |
| Negociable | ✅ | Los formatos de salida pueden ajustarse según necesidad |
| Valiosa | ✅ | Ayuda a explorar el repo sin abrir carpetas manualmente |
| Estimable | ✅ | Requisitos claros de salida y filtros |
| Small | ✅ | Un comando utilitario específico |
| Testeable | ✅ | CA comprobables con ejecución y formato de salida |
