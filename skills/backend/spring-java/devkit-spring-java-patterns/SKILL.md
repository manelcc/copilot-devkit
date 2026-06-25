---
name: devkit-spring-java-patterns
description: >
  Skill de patrones Spring Boot Java para servicios backend mantenibles y alineados
  con convenciones corporativas. Cubre controllers REST, servicios, repositorios JPA,
  seguridad, validación, manejo global de excepciones y pruebas con JUnit5 + Mockito.
triggers:
  - "patron spring boot"
  - "spring java controller"
  - "spring service repository"
  - "spring jpa patron"
  - "spring security patron"
  - "spring validacion"
  - "spring exception handler"
  - "spring application properties"
  - "antipatron spring"
  - "spring boot test"
  - "rest controller spring"
  - "spring transactional"
non_triggers:
  - "kotlin ktor (usar backend-kotlin)"
  - "android o ios"
  - "spring reactive webflux (scope distinto)"
  - "infraestructura ci/cd"
---

# Spring Java Patterns

## Purpose

Proporcionar una guía práctica de patrones Spring Boot Java para diseñar, implementar
y mantener servicios backend con buenas prácticas. Cubre la cadena completa
request → Controller → Service → Repository, con configuración de `application.properties`,
validación de entrada, manejo global de excepciones, seguridad y pruebas.

La skill está orientada a equipos que trabajan en proyectos Spring Boot Java y quieren
mantener consistencia arquitectónica y testabilidad.

## When to use

- Estás implementando un endpoint REST en Spring Boot Java.
- Quieres auditar un servicio Spring para detectar antipatrones.
- Necesitas implementar validación de entrada o manejo global de excepciones.
- Quieres configurar seguridad básica con Spring Security.
- Necesitas escribir tests unitarios o de integración con Spring Boot Test.

**Trigger phrases:**
- "¿Cómo estructuro un servicio Spring Boot Java?"
- "¿Cuál es el patrón para el manejo de excepciones en Spring?"
- "¿Cómo implemento seguridad JWT en Spring Boot?"
- "Revisa este Controller, ¿hay antipatrones?"

## When NOT to use

- Backend en Kotlin/Ktor → usar `backend-kotlin-patterns`
- Spring WebFlux / reactivo (scope diferente)
- Frontend, Android o iOS
- Preguntas de infraestructura o CI/CD

## Inputs

**Contexto requerido:**
- `controller_or_service_code`: Fragmento del Controller, Service o Repository a analizar
- `objetivo`: Qué quieres conseguir (nueva feature, refactor, securizar endpoint)

**Contexto opcional:**
- `spring_boot_version`: Versión de Spring Boot (ej. 2.7, 3.x)
- `base_de_datos`: MySQL, PostgreSQL, H2, etc.
- `usa_security`: Si el proyecto tiene Spring Security configurado

## Steps

1. **Clasificar el problema:**
   - Identificar si es capa de Controller (REST), Service (lógica), Repository (datos),
     configuración, seguridad o testing.

2. **Seleccionar patrón candidato:**
   - Evaluar 2-3 opciones con trade-offs.
   - Respetar la regla: Controllers delegan en Services, Services usan Repositories.

3. **Detectar antipatrones:**
   - Lógica de negocio en Controller
   - Llamadas directas al Repository desde Controller
   - Transacciones (`@Transactional`) en Controller en lugar de Service
   - Manejo de excepciones con try-catch disperso (en lugar de `@ControllerAdvice`)
   - Entidades JPA expuestas directamente como DTOs en el API
   - Contraseñas o secrets hardcoded en `application.properties`
   - Tests sin contexto aislado (tests lentos que cargan todo el contexto Spring)

4. **Proponer implementación:**
   - Estructura en capas: `@RestController` → `@Service` → `@Repository`
   - DTOs separados de Entities (nunca exponer `@Entity` en respuestas REST)
   - Validación con Bean Validation (`@Valid`, `@NotNull`, `@Size`)
   - `@ControllerAdvice` para manejo centralizado de excepciones
   - `@Transactional` en la capa de Service

5. **Seguridad (si aplica):**
   - Configurar `SecurityFilterChain` con Spring Security 6.x
   - JWT stateless con `OncePerRequestFilter`
   - Nunca guardar contraseñas en texto plano — siempre `BCryptPasswordEncoder`
   - CORS configurado explícitamente, no con `@CrossOrigin` en producción

6. **Validar con checklist:**
   - Sin lógica en Controllers
   - DTOs separados de Entities
   - `@ControllerAdvice` presente para excepciones comunes
   - Tests unitarios del Service con Mockito (sin levantar contexto Spring)
   - Tests de integración del Controller con `@WebMvcTest`

## Expected outputs

- Patrón recomendado con justificación y trade-offs descartados
- Fragmento de código Java Spring Boot con el patrón aplicado
- Lista de antipatrones detectados con severidad (CRITICAL / HIGH / MEDIUM / LOW)
- Configuración `application.properties` / `application.yml` si aplica
- Plan de refactor incremental si se solicita

## Validation

- [ ] La separación Controller / Service / Repository está clara
- [ ] Los DTOs están separados de las Entities JPA
- [ ] `@ControllerAdvice` cubre al menos `Exception` genérica y `MethodArgumentNotValidException`
- [ ] `@Transactional` está en la capa Service, no en Controller
- [ ] Si hay seguridad, no hay secretos hardcoded — se usan variables de entorno
- [ ] Los antipatrones detectados tienen nivel de severidad asignado
- [ ] Los tests unitarios del Service usan Mockito sin levantar contexto Spring

## Examples

### Ejemplo 1 — Controller + Service + Repository con DTO

**Prompt del usuario:**
> "¿Cómo estructuro correctamente un CRUD de usuarios en Spring Boot?"

**Acción del agente:**
1. Separación en 3 capas con DTO:
   ```java
   // DTO — nunca exponer @Entity
   public record UserResponseDto(Long id, String name, String email) {}
   public record CreateUserDto(@NotBlank String name, @Email String email) {}

   // Controller — solo enrutamiento y validación de entrada
   @RestController
   @RequestMapping("/api/users")
   public class UserController {
       private final UserService userService;

       public UserController(UserService userService) {
           this.userService = userService;
       }

       @PostMapping
       public ResponseEntity<UserResponseDto> create(@Valid @RequestBody CreateUserDto dto) {
           return ResponseEntity.status(HttpStatus.CREATED)
               .body(userService.create(dto));
       }

       @GetMapping("/{id}")
       public ResponseEntity<UserResponseDto> getById(@PathVariable Long id) {
           return ResponseEntity.ok(userService.findById(id));
       }
   }

   // Service — lógica de negocio + @Transactional
   @Service
   public class UserService {
       private final UserRepository userRepository;

       public UserService(UserRepository userRepository) {
           this.userRepository = userRepository;
       }

       @Transactional
       public UserResponseDto create(CreateUserDto dto) {
           User user = new User(dto.name(), dto.email());
           User saved = userRepository.save(user);
           return new UserResponseDto(saved.getId(), saved.getName(), saved.getEmail());
       }

       public UserResponseDto findById(Long id) {
           User user = userRepository.findById(id)
               .orElseThrow(() -> new ResourceNotFoundException("User not found: " + id));
           return new UserResponseDto(user.getId(), user.getName(), user.getEmail());
       }
   }

   // Repository — solo acceso a datos
   @Repository
   public interface UserRepository extends JpaRepository<User, Long> {
       Optional<User> findByEmail(String email);
   }
   ```

---

### Ejemplo 2 — Manejo global de excepciones

**Prompt del usuario:**
> "¿Cómo centralizo el manejo de errores en Spring Boot?"

**Acción del agente:**
1. Antipatrón detectado: try-catch disperso en Controllers (MEDIUM)
2. Solución con `@ControllerAdvice`:
   ```java
   @RestControllerAdvice
   public class GlobalExceptionHandler {

       @ExceptionHandler(ResourceNotFoundException.class)
       public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
           return ResponseEntity.status(HttpStatus.NOT_FOUND)
               .body(new ErrorResponse("NOT_FOUND", ex.getMessage()));
       }

       @ExceptionHandler(MethodArgumentNotValidException.class)
       public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
           String message = ex.getBindingResult().getFieldErrors().stream()
               .map(e -> e.getField() + ": " + e.getDefaultMessage())
               .collect(Collectors.joining(", "));
           return ResponseEntity.status(HttpStatus.BAD_REQUEST)
               .body(new ErrorResponse("VALIDATION_ERROR", message));
       }

       @ExceptionHandler(Exception.class)
       public ResponseEntity<ErrorResponse> handleGeneric(Exception ex) {
           return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
               .body(new ErrorResponse("INTERNAL_ERROR", "An unexpected error occurred"));
       }
   }

   public record ErrorResponse(String code, String message) {}
   ```

---

### Ejemplo 3 — Test unitario de Service con Mockito

**Prompt del usuario:**
> "¿Cómo testeo el Service sin levantar el contexto de Spring?"

**Acción del agente:**
1. Test unitario aislado sin `@SpringBootTest`:
   ```java
   @ExtendWith(MockitoExtension.class)
   class UserServiceTest {

       @Mock
       private UserRepository userRepository;

       @InjectMocks
       private UserService userService;

       @Test
       void givenValidDto_whenCreate_thenReturnResponseDto() {
           // Given
           CreateUserDto dto = new CreateUserDto("Alice", "alice@example.com");
           User savedUser = new User(1L, "Alice", "alice@example.com");
           when(userRepository.save(any(User.class))).thenReturn(savedUser);

           // When
           UserResponseDto result = userService.create(dto);

           // Then
           assertThat(result.name()).isEqualTo("Alice");
           assertThat(result.email()).isEqualTo("alice@example.com");
           verify(userRepository).save(any(User.class));
       }

       @Test
       void givenUnknownId_whenFindById_thenThrowNotFoundException() {
           // Given
           when(userRepository.findById(99L)).thenReturn(Optional.empty());

           // When / Then
           assertThatThrownBy(() -> userService.findById(99L))
               .isInstanceOf(ResourceNotFoundException.class)
               .hasMessageContaining("99");
       }
   }
   ```
2. Para tests del Controller usar `@WebMvcTest` — carga solo el contexto web
