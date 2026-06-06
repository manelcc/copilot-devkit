# US-023 — Skill android-hilt-injection

**Como** desarrollador Android Compose,
**quiero** una skill que describa el uso correcto de Hilt,
**para** configurar inyección de dependencias limpia y moderna en apps Compose.

---

## Criterios de aceptación

1. Existe `skills/android/compose/android-hilt-injection/` con `SKILL.md` válido.
2. La skill cubre módulos, `@HiltViewModel`, `@InstallIn`, `@EntryPoint` y pruebas con Hilt.
3. Incluye ejemplos para ViewModels Compose y componentes Android compatibles.
4. Contiene `references/overview.md` con diagrama Mermaid del flujo de DI.
5. `validate-skill.sh` ejecutado sobre la skill devuelve exit code 0.

---

## Referencias

- `EP-3` — Stack Android Compose
- `US-026` — Instrucciones Android Compose

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Skill enfocada solo en Hilt |
| Negociable | ✅ | Las convenciones de módulos pueden ajustarse |
| Valiosa | ✅ | Mejora la inyección de dependencias en Compose |
| Estimable | ✅ | Alcance claro y limitado |
| Small | ✅ | Solo patrón de DI, no todo el stack |
| Testeable | ✅ | CA comprobables con revisión de archivos |
