# Copilot Guidelines: Python — LOW

---

Total rules: **1**

## Liderazgo

### PY_LEAD_001
- **Severity:** LOW
- **Description:** Las decisiones arquitectónicas importantes deben documentarse mediante ADRs (Architectural Decision Records) para evitar el olvido del contexto de los trade-offs [216, 227, 229, 267].
- **Conditions:** process: Leadership
- **Action:** Incluir el contexto, la decisión, las consecuencias y el cumplimiento esperado para cada compromiso arquitectónico [268-270].
- **Source references:** 216, 227, 229, 267, 268, 269, 270
- **Bad example:**
```
Cambiar el estilo de inyección de dependencias sin aviso.
```
- **Good example:**
```
Crear ADR-001 explicando por qué se usa Pydantic en el dominio.
```
