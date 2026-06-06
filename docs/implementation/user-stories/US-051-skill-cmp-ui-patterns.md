# US-051 — Skill cmp-ui-patterns

**Como** desarrollador Compose Multiplatform,
**quiero** una skill que cubra patrones UI para CMP,
**para** construir interfaces compartidas que funcionen en Android y escritorio con el mismo código.

---

## Criterios de aceptación

1. Existe `skills/multiplatform/cmp/cmp-ui-patterns/` con `SKILL.md` válido.
2. La skill cubre layouts Compose Multiplatform, adaptative UI y componentes compartidos.
3. Incluye ejemplos de uso para Android y una plataforma de escritorio o multiplatform.
4. Contiene `references/overview.md` con diagrama Mermaid del flujo UI compartida.
5. `validate-skill.sh` ejecutado sobre la skill devuelve exit code 0.

---

## Referencias

- `EP-6` — Stack Multiplatform KMP/CMP
- `US-050` — Skill KMP shared module patterns

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Skill CMP autónoma |
| Negociable | ✅ | El alcance de plataformas puede ajustarse |
| Valiosa | ✅ | Facilita experiencia UI multiplataforma coherente |
| Estimable | ✅ | Alcance bien definido |
| Small | ✅ | Solo cubre patrones UI CMP |
| Testeable | ✅ | CA comprobables con revisión y validación |
