# US-080 — Estructura CLI devtools

**Como** desarrollador que opera el repo,
**quiero** una estructura Python consistente para el comando `devtools`,
**para** disponer de un CLI instalable y extensible con subcomandos claros.

---

## Criterios de aceptación

1. Existe el paquete Python `cli-tools/devtools/` con `__init__.py` y archivos base.
2. `pyproject.toml` registra entry points para el comando `devtools`.
3. `devtools --help` muestra los subcomandos `sync`, `scaffold`, `validate` y `list`.
4. Hay tests unitarios básicos que validan la invocación de `devtools --help` y un subcomando simulador.
5. La documentación de quick-start en `README.md` referencia el comando de instalación y uso básico.

---

## Referencias

- `BK:cli-tools/` estructura y patrones de entry points
- `US-005` — Bootstrap CLI del repositorio

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Tiene alcance propio dentro del CLI |
| Negociable | ✅ | El detalle de la implementación Python es negociable |
| Valiosa | ✅ | Habilita todas las operaciones CLI del repo |
| Estimable | ✅ | Alcance bien delimitado |
| Small | ✅ | Estructura base de CLI, no comportamiento completo |
| Testeable | ✅ | CA verificables con tests y salida `--help` |
