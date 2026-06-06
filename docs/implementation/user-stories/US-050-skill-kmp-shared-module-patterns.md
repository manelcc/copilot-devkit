# US-050 — Skill KMP shared module patterns

**Como** desarrollador Kotlin Multiplatform,
**quiero** una skill que cubra patrones para módulos compartidos KMP,
**para** aplicar buenas prácticas en Android e iOS con una sola base de código compartida.

---

## Criterios de aceptación

1. Existe `skills/multiplatform/kmp/kmp-shared-module-patterns/` con `SKILL.md` válido.
2. La skill cubre expect/actual, ktor-client, SQLDelight y shared ViewModels.
3. Incluye ejemplos de uso para Android y iOS desde el mismo módulo compartido.
4. Contiene `references/overview.md` con un diagrama Mermaid del flujo de trabajo multiplataforma.
5. `validate-skill.sh` ejecutado sobre la skill devuelve exit code 0.

---

## Referencias

- `EP-6` — Stack Multiplatform KMP/CMP
- Guía de `US-003` y `DoD`

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Skill multiplataforma autónoma |
| Negociable | ✅ | El diseño de ejemplos puede ajustarse según KMP actual |
| Valiosa | ✅ | Facilita la adopción de KMP en ambos clientes |
| Estimable | ✅ | Alcance claro de patrones de módulo compartido |
| Small | ✅ | Una skill, no un conjunto completo de stacks |
| Testeable | ✅ | CA comprobables con revisión de contenido y validación |
