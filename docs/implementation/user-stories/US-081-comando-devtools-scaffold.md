# US-081 — Comando devtools scaffold

**Como** contributor del repositorio,
**quiero** que `devtools scaffold skill <name> <namespace>` genere la estructura completa desde el template,
**para** crear nuevas skills coherentes sin tener que copiar manualmente archivos o recordar la plantilla exacta.

---

## Criterios de aceptación

1. El comando `devtools scaffold skill <name> <namespace>` crea la carpeta objetivo con la estructura de template.
2. Reemplaza placeholders en `SKILL.md` y `references/overview.md` con el nombre y namespace especificados.
3. Si el editor está disponible, el comando abre el archivo generado; de lo contrario imprime el path.
4. El comando valida el artefacto generado y muestra advertencias si faltan secciones obligatorias.
5. El template base existe en `skills/_TEMPLATE/` y es la fuente utilizada por el comando.

---

## Referencias

- `US-003` — Template base para skills
- `US-005` — Bootstrap CLI devtools

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Subcomando específico de scaffold |
| Negociable | ✅ | La apertura en editor es opcional según entorno |
| Valiosa | ✅ | Reduce errores de onboarding para nuevos skills |
| Estimable | ✅ | Flujo definido de generación de archivo |
| Small | ✅ | Subcomando con un único propósito |
| Testeable | ✅ | CA verificables con tests de generación y placeholders |
