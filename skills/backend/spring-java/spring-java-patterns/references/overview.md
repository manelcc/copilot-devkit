# Spring Java Patterns — Overview

## Workflow

```mermaid
flowchart TD
    A["Objetivo: nueva feature / refactor / securizar"] --> B["Clasificar capa\n(Controller · Service · Repository · Config)"]
    B --> C["Seleccionar patrón\n(REST · Service · Repository · Exception Handler)"]
    C --> D["Detectar antipatrones\n(lógica en Controller · Entity expuesto · @Transactional en Controller)"]
    D --> E{"¿Seguridad\nrequerida?"}
    E -- Sí --> F["Spring Security 6\nJWT · BCrypt · SecurityFilterChain"]
    E -- No --> G["Implementar patrón\nController→Service→Repository"]
    F --> H["Validar:\nDTO separado · @ControllerAdvice · tests aislados"]
    G --> H
    H --> I["Entrega: código · antipatrones · configuración"]
```

## Flujo request → respuesta

```mermaid
sequenceDiagram
    participant C as Client
    participant RC as @RestController
    participant S as @Service
    participant R as @Repository
    participant DB as Database

    C->>RC: HTTP Request + @Valid DTO
    RC->>S: dto (validado)
    S->>R: entidad / query
    R->>DB: SQL via JPA
    DB-->>R: resultado
    R-->>S: Optional<Entity>
    S-->>RC: ResponseDto
    RC-->>C: ResponseEntity<ResponseDto>

    Note over RC: Solo enrutamiento + validación
    Note over S: Lógica de negocio + @Transactional
    Note over R: Solo acceso a datos
```

## Patrones cubiertos

| Categoría | Patrón | Uso principal |
|---|---|---|
| Arquitectura | Controller → Service → Repository | Separación de responsabilidades |
| API | DTO separado de Entity | No exponer modelo de datos interno |
| Validación | Bean Validation + @Valid | Validar entrada en Controller |
| Errores | @RestControllerAdvice | Centralizar manejo de excepciones |
| Persistencia | Spring Data JPA + @Repository | Acceso tipado con JpaRepository |
| Transacciones | @Transactional en Service | Consistencia en operaciones compuestas |
| Seguridad | SecurityFilterChain + JWT | Autenticación stateless |
| Testing | Mockito sin contexto Spring | Tests unitarios rápidos del Service |
| Testing | @WebMvcTest | Tests del Controller con contexto web mínimo |

## Antipatrones detectables

- **Lógica en Controller** (CRITICAL) — violar SRP, dificulta tests
- **Entity expuesta en API** (HIGH) — acopla BD con contrato público
- **@Transactional en Controller** (HIGH) — debe estar en Service
- **try-catch disperso** (MEDIUM) — usar `@ControllerAdvice`
- **Secrets hardcoded** (CRITICAL) — usar variables de entorno
- **@SpringBootTest para tests unitarios** (MEDIUM) — tests lentos innecesarios
