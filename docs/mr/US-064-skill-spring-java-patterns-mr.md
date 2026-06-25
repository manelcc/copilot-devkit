# MR — US-064: Skill Spring Java Patterns para stack Backend Spring Java

## Descripción

Añade la skill `spring-java-patterns` al namespace `backend/spring-java`, cubriendo los
patrones Spring Boot Java para diseñar y mantener servicios backend con buenas prácticas:
separación en capas, validación, manejo global de excepciones, seguridad y testing.

## Commits incluidos

| Hash | Tipo | Descripción |
|---|---|---|
| `a7dc553` | `feat` | add spring-java-patterns skill for Spring Boot Java backend stack |

## Artefactos creados

| Artefacto | Ruta |
|---|---|
| Skill principal | `skills/backend/spring-java/spring-java-patterns/SKILL.md` |
| Diagrama Mermaid | `skills/backend/spring-java/spring-java-patterns/references/overview.md` |

## Criterios de aceptación cubiertos

- [x] `skills/backend/spring-java/spring-java-patterns/` creado con SKILL.md válido
- [x] Cubre: controllers REST · servicios · repositorios JPA · seguridad · pruebas Spring Boot
- [x] Incluye configuración `application.properties`, validación Bean Validation y excepciones globales
- [x] `references/overview.md` con diagrama Mermaid del flujo request → Service → Repository
- [x] `devkit-validate-skill.sh` retorna exit code 0 (pre-commit hook pasó)

## Contenido de la skill

**Patrones cubiertos:**
- Arquitectura: Controller → Service → Repository (separación SRP)
- API: DTO separado de Entity JPA
- Validación: Bean Validation con `@Valid`, `@NotBlank`, `@Email`
- Errores: `@RestControllerAdvice` centralizado
- Transacciones: `@Transactional` en Service
- Seguridad: `SecurityFilterChain` + JWT stateless + `BCryptPasswordEncoder`
- Testing: Mockito sin contexto Spring (unitario) + `@WebMvcTest` (Controller)

**Antipatrones detectables:**
- Lógica de negocio en Controller (CRITICAL)
- Entity expuesta en API REST (HIGH)
- `@Transactional` en Controller (HIGH)
- try-catch disperso sin `@ControllerAdvice` (MEDIUM)
- Secrets hardcoded en `application.properties` (CRITICAL)
- `@SpringBootTest` para tests unitarios — tests lentos (MEDIUM)

**Ejemplos incluidos:**
1. CRUD de usuarios con Controller + Service + Repository + DTO (Java records)
2. `@RestControllerAdvice` con handlers para `ResourceNotFoundException`, validación y genérico
3. Test unitario de Service con `@ExtendWith(MockitoExtension.class)` — patrón given/when/then

## Validación

```
[OK] SKILL.md exists
[OK] YAML frontmatter found
[OK] All frontmatter fields present
[OK] All 8 required sections present
[OK] references/overview.md exists
[OK] Mermaid diagram found
[OK] VALIDATION PASSED
```

## Impacto

- Namespace `skills/backend/spring-java/` pasa de vacío a operativo
- Simetría `agents/` · `skills/` · `prompts/` mantenida
- Sin cambios en ficheros existentes

## Rama origen → destino

`feature/US-064-skill-spring-java-patterns` → `develop`
