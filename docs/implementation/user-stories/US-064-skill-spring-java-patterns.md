# US-064 — Skill spring-java-patterns

**Como** desarrollador backend Java,
**quiero** una skill para patrones Spring Java,
**para** escribir servicios mantenibles y alineados con las convenciones corporativas.

---

## Criterios de aceptación

1. Existe `skills/backend/spring-java/spring-java-patterns/` con `SKILL.md` válido.
2. La skill cubre controllers, servicios, repositorios, seguridad y pruebas con Spring Boot.
3. Incluye ejemplos de configuración de `application.properties`, validación y excepciones globales.
4. Contiene `references/overview.md` con diagrama Mermaid del flujo request → service → repositorio.
5. `validate-skill.sh` ejecutado sobre la skill devuelve exit code 0.

---

## Referencias

- `EP-7` — Stack Backend
- Guía de `DoD` y `US-003`

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Skill Spring Java independiente |
| Negociable | ✅ | Los detalles de seguridad y estructura pueden ajustarse |
| Valiosa | ✅ | Facilita desarrollo Spring coherente |
| Estimable | ✅ | Alcance definido de patrones Spring |
| Small | ✅ | Tarea específica de backend Java |
| Testeable | ✅ | CA revisables con validación |
