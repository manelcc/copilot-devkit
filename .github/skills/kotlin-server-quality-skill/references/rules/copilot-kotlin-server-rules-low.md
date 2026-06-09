# Copilot Guidelines: Kotlin Server — LOW

---

Total rules: **32**

## KTOR

### KTOR_002
- **Severity:** LOW
- **Source:** `custom` / `custom:KTOR_002`
- **Description:** Los plugins de Ktor (ContentNegotiation, StatusPages, etc.) deben configurarse en funciones separadas para mejorar testabilidad y separación de responsabilidades.
- **Bad example:**
```kotlin
fun Application.module() { install(ContentNegotiation) { json() }; install(StatusPages) { ... }; routing { ... } }
```
- **Good example:**
```kotlin
fun Application.module() { configureContentNegotiation(); configureStatusPages(); configureRouting() }
```
- **References:**
  - https://ktor.io/docs/plugins.html
  - https://medium.com/kotlin-and-java/ktor-best-practices-for-organizing-your-application-1b1c3eb5d30d

---

### KTOR_004
- **Severity:** LOW
- **Source:** `custom` / `custom:KTOR_004`
- **Description:** Las validaciones de entrada (body, params) deben realizarse antes de llamar a la capa de negocio, idealmente con una capa de validación dedicada.
- **Bad example:**
```kotlin
post("/users") { val user = call.receive<UserDto>(); createUser(user) }
```
- **Good example:**
```kotlin
post("/users") { val dto = call.receive<CreateUserDto>(); dto.validate().fold({ errors -> call.respond(BadRequest, errors) }, { createUserUseCase.execute(it) }) }
```
- **References:**
  - https://ktor.io/docs/request-validation.html
  - https://medium.com/kotlin-and-java/input-validation-in-kotlin-apis-5ff1e8d8c8c3

---

## COROUTINE

### COROUTINE_SERVER_003
- **Severity:** LOW
- **Source:** `custom` / `custom:COROUTINE_SERVER_003`
- **Description:** Los timeouts en operaciones suspendidas deben manejarse explícitamente con withTimeout o withTimeoutOrNull para evitar operaciones colgadas.
- **Bad example:**
```kotlin
suspend fun callExternalApi() = httpClient.get("https://api.example.com")
```
- **Good example:**
```kotlin
suspend fun callExternalApi() = withTimeout(5000) { httpClient.get("https://api.example.com") }
```
- **References:**
  - https://kotlinlang.org/docs/cancellation-and-timeouts.html#timeout
  - https://medium.com/kotlin-and-java/kotlin-coroutines-timeouts-and-delays-cc7f1a5d8e9b
  - https://medium.com/kotliners/managing-timeouts-in-production-services-2a3f5c8e9d1b

---

### SONAR_SEC_024
- **Severity:** LOW
- **Source:** `sonar` / `Kotlin Security Hotspot - Missing timeout on external call`
- **Description:** Missing timeout on external call: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
- **Bad example:**
```kotlin
// configuración insegura o incompleta
```
- **Good example:**
```kotlin
// configuración segura con validación, límites y monitoreo
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_025
- **Severity:** LOW
- **Source:** `sonar` / `Kotlin Security Hotspot - Missing retry backoff strategy`
- **Description:** Missing retry backoff strategy: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
- **Bad example:**
```kotlin
// configuración insegura o incompleta
```
- **Good example:**
```kotlin
// configuración segura con validación, límites y monitoreo
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_049
- **Severity:** LOW
- **Source:** `sonar` / `Kotlin Security Hotspot - Missing circuit breaker on downstream dependency`
- **Description:** Missing circuit breaker on downstream dependency: proteger llamadas externas críticas con apertura de circuito ante fallos continuos.
- **Bad example:**
```kotlin
repeat(3) { httpClient.get(authProviderUrl) }
```
- **Good example:**
```kotlin
circuitBreaker.executeSuspendFunction { httpClient.get(authProviderUrl) }
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_050
- **Severity:** LOW
- **Source:** `sonar` / `Kotlin Security Hotspot - Missing retry jitter strategy`
- **Description:** Missing retry jitter strategy: añadir jitter aleatorio al backoff para evitar reintentos sincronizados y cascadas de carga.
- **Bad example:**
```kotlin
delay(1000); retry()
```
- **Good example:**
```kotlin
delay(baseDelay + Random.nextLong(0, jitterMax)); retry()
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

## DI_SERVER

### DI_SERVER_002
- **Severity:** LOW
- **Source:** `custom` / `custom:DI_SERVER_002`
- **Description:** Los módulos de DI deben organizarse por capa (data, domain, presentation) para facilitar testing y modularidad.
- **Bad example:**
```kotlin
val appModule = module { single { Database() }; single { UserService(get()) }; single { AuthService(get()) } }
```
- **Good example:**
```kotlin
val dataModule = module { single { Database() } }; val domainModule = module { factory { UserService(get()) } }
```
- **References:**
  - https://insert-koin.io/docs/reference/koin-core/modules
  - https://medium.com/kotlin-and-java/koin-modules-and-organization-d8a4c5b7e9f2

---

## ARCH_SERVER

### ARCH_SERVER_003
- **Severity:** LOW
- **Source:** `custom` / `custom:ARCH_SERVER_003`
- **Description:** Los casos de uso (use cases) deben tener una única responsabilidad y ser reutilizables. Evitar casos de uso 'god class' con múltiples operaciones.
- **Bad example:**
```kotlin
class UserService { fun createUser() {...}; fun deleteUser() {...}; fun updateUser() {...}; fun findUser() {...} }
```
- **Good example:**
```kotlin
class CreateUserUseCase; class DeleteUserUseCase; class GetUserUseCase; class UpdateUserUseCase
```
- **References:**
  - https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
  - https://medium.com/kotlin-and-java/use-case-pattern-in-clean-architecture-5a2d3f8e1c9b

---

## ERROR_SERVER

### ERROR_SERVER_003
- **Severity:** LOW
- **Source:** `custom` / `custom:ERROR_SERVER_003`
- **Description:** Usar Result<T> o Either<L,R> para operaciones que pueden fallar, en lugar de throwable exceptions para flujo de control.
- **Bad example:**
```kotlin
fun getUser(id: Int): User { if (!exists(id)) throw UserNotFoundException() }
```
- **Good example:**
```kotlin
fun getUser(id: Int): Result<User> = if (exists(id)) Result.success(user) else Result.failure(UserNotFoundException())
```
- **References:**
  - https://kotlinlang.org/api/latest/jvm/stdlib/kotlin/-result/
  - https://medium.com/kotlin-and-java/functional-error-handling-with-result-type-7a3d8e5f1c9b

---

### DETEKT_SEC_031
- **Severity:** LOW
- **Source:** `detekt` / `UnsafeCallOnNullableType`
- **Description:** Evitar !! en datos de request para prevenir NullPointerException explotable.
- **Bad example:**
```kotlin
// implementación vulnerable o frágil
```
- **Good example:**
```kotlin
// implementación defensiva con validación explícita
```
- **References:**
  - https://detekt.dev/docs/rules/potential-bugs/

---

### DETEKT_SEC_032
- **Severity:** LOW
- **Source:** `detekt` / `UnreachableCatchBlock`
- **Description:** Evitar catch inalcanzables que oculten rutas de error de seguridad.
- **Bad example:**
```kotlin
// implementación vulnerable o frágil
```
- **Good example:**
```kotlin
// implementación defensiva con validación explícita
```
- **References:**
  - https://detekt.dev/docs/rules/potential-bugs/

---

### DETEKT_SEC_033
- **Severity:** LOW
- **Source:** `detekt` / `IgnoredReturnValue`
- **Description:** No ignorar retornos de validación/autorización.
- **Bad example:**
```kotlin
// implementación vulnerable o frágil
```
- **Good example:**
```kotlin
// implementación defensiva con validación explícita
```
- **References:**
  - https://detekt.dev/docs/rules/potential-bugs/

---

### DETEKT_SEC_034
- **Severity:** LOW
- **Source:** `detekt` / `MissingUseCall`
- **Description:** Cerrar recursos IO siempre con use para evitar fugas.
- **Bad example:**
```kotlin
// implementación vulnerable o frágil
```
- **Good example:**
```kotlin
// implementación defensiva con validación explícita
```
- **References:**
  - https://detekt.dev/docs/rules/potential-bugs/

---

### DETEKT_SEC_035
- **Severity:** LOW
- **Source:** `detekt` / `MapGetWithNotNullAssertionOperator`
- **Description:** No usar map[key]!! sobre claims/cabeceras no confiables.
- **Bad example:**
```kotlin
// implementación vulnerable o frágil
```
- **Good example:**
```kotlin
// implementación defensiva con validación explícita
```
- **References:**
  - https://detekt.dev/docs/rules/potential-bugs/

---

### DETEKT_SEC_036
- **Severity:** LOW
- **Source:** `detekt` / `CastNullableToNonNullableType`
- **Description:** No castear nullable a non-null sin validación previa.
- **Bad example:**
```kotlin
// implementación vulnerable o frágil
```
- **Good example:**
```kotlin
// implementación defensiva con validación explícita
```
- **References:**
  - https://detekt.dev/docs/rules/potential-bugs/

---

### DETEKT_SEC_037
- **Severity:** LOW
- **Source:** `detekt` / `UnnecessaryNotNullOperator`
- **Description:** Eliminar !! innecesario que fragiliza flujos defensivos.
- **Bad example:**
```kotlin
// implementación vulnerable o frágil
```
- **Good example:**
```kotlin
// implementación defensiva con validación explícita
```
- **References:**
  - https://detekt.dev/docs/rules/potential-bugs/

---

### DETEKT_SEC_038
- **Severity:** LOW
- **Source:** `detekt` / `UnsafeCast`
- **Description:** Evitar casts inseguros en payloads deserializados.
- **Bad example:**
```kotlin
// implementación vulnerable o frágil
```
- **Good example:**
```kotlin
// implementación defensiva con validación explícita
```
- **References:**
  - https://detekt.dev/docs/rules/potential-bugs/

---

### DETEKT_SEC_039
- **Severity:** LOW
- **Source:** `detekt` / `HasPlatformType`
- **Description:** Declarar tipos explícitos en API pública para evitar errores de nullabilidad.
- **Bad example:**
```kotlin
// implementación vulnerable o frágil
```
- **Good example:**
```kotlin
// implementación defensiva con validación explícita
```
- **References:**
  - https://detekt.dev/docs/rules/potential-bugs/

---

### DETEKT_SEC_040
- **Severity:** LOW
- **Source:** `detekt` / `ImplicitDefaultLocale`
- **Description:** Forzar Locale en formato de datos de máquina.
- **Bad example:**
```kotlin
// implementación vulnerable o frágil
```
- **Good example:**
```kotlin
// implementación defensiva con validación explícita
```
- **References:**
  - https://detekt.dev/docs/rules/potential-bugs/

---

### SONAR_SEC_020
- **Severity:** LOW
- **Source:** `sonar` / `Kotlin Security Hotspot - Error message leaks internals`
- **Description:** Error message leaks internals: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
- **Bad example:**
```kotlin
// configuración insegura o incompleta
```
- **Good example:**
```kotlin
// configuración segura con validación, límites y monitoreo
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

## DB_SERVER

### DB_SERVER_003
- **Severity:** LOW
- **Source:** `custom` / `custom:DB_SERVER_003`
- **Description:** Implementar paginación en queries que pueden devolver grandes volúmenes de datos para evitar problemas de memoria y performance.
- **Bad example:**
```kotlin
fun getAllUsers() = Users.selectAll().toList()
```
- **Good example:**
```kotlin
fun getUsers(page: Int, size: Int) = Users.selectAll().limit(size, offset = (page * size).toLong())
```
- **References:**
  - https://en.wikipedia.org/wiki/Pagination
  - https://medium.com/kotlin-and-java/efficient-pagination-in-kotlin-rest-apis-8d5c6e9f3b1a

---

### SONAR_SEC_009
- **Severity:** LOW
- **Source:** `sonar` / `Kotlin Security Hotspot - NoSQL injection risk`
- **Description:** NoSQL injection risk: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
- **Bad example:**
```kotlin
// configuración insegura o incompleta
```
- **Good example:**
```kotlin
// configuración segura con validación, límites y monitoreo
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_021
- **Severity:** LOW
- **Source:** `sonar` / `Kotlin Security Hotspot - Excessive privileges in DB user`
- **Description:** Excessive privileges in DB user: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
- **Bad example:**
```kotlin
// configuración insegura o incompleta
```
- **Good example:**
```kotlin
// configuración segura con validación, límites y monitoreo
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

## LOGGING

### LOGGING_001
- **Severity:** LOW
- **Source:** `custom` / `custom:LOGGING_001`
- **Description:** Usar niveles de log apropiados: ERROR para errores, WARN para advertencias, INFO para eventos importantes, DEBUG para debugging.
- **Bad example:**
```kotlin
logger.info("Exception occurred: ${e.stackTrace}")
```
- **Good example:**
```kotlin
logger.error("Failed to process request", e); logger.debug("Request details: $request")
```
- **References:**
  - https://www.baeldung.com/kotlin/logging
  - https://medium.com/kotlin-and-java/structured-logging-in-kotlin-with-slf4j-logback-4d7a9e8f5c2b

---

### LOGGING_003
- **Severity:** LOW
- **Source:** `custom` / `custom:LOGGING_003`
- **Description:** Incluir contexto útil en los logs (request ID, user ID, operation) para facilitar debugging y troubleshooting.
- **Bad example:**
```kotlin
logger.error("Error occurred")
```
- **Good example:**
```kotlin
logger.error("Failed to create user", mapOf("userId" to userId, "operation" to "createUser", "requestId" to requestId))
```
- **References:**
  - https://www.loggly.com/blog/contextual-logging/
  - https://medium.com/kotlin-and-java/contextual-logging-with-mapped-diagnostic-context-6f3d8e5c9a1b

---

### DETEKT_SEC_045
- **Severity:** LOW
- **Source:** `detekt` / `ForbiddenComment:DetektSec45`
- **Description:** Regla defensiva Detekt #45: reforzar controles de secretos, sanitización y observabilidad segura.
- **Bad example:**
```kotlin
logger.debug("token=$token")
```
- **Good example:**
```kotlin
logger.debug("token present: {}", token != null)
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddencomment

---

## CONFIG

### CONFIG_002
- **Severity:** LOW
- **Source:** `custom` / `custom:CONFIG_002`
- **Description:** Validar la configuración al inicio de la aplicación para detectar errores de configuración temprano (fail-fast).
- **Bad example:**
```kotlin
fun Application.module() { routing { ... } }
```
- **Good example:**
```kotlin
fun Application.module() { validateConfig(); routing { ... } }
```
- **References:**
  - https://github.com/lightbend/config
  - https://medium.com/kotlin-and-java/application-configuration-validation-and-defaults-4c5d7e8f3a2b

---

### SONAR_SEC_023
- **Severity:** LOW
- **Source:** `sonar` / `Kotlin Security Hotspot - Missing request size limits`
- **Description:** Missing request size limits: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
- **Bad example:**
```kotlin
// configuración insegura o incompleta
```
- **Good example:**
```kotlin
// configuración segura con validación, límites y monitoreo
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_045
- **Severity:** LOW
- **Source:** `sonar` / `Kotlin Security Hotspot - GraphQL introspection enabled in production`
- **Description:** GraphQL introspection enabled in production: restringir introspection y playground fuera de entornos controlados.
- **Bad example:**
```kotlin
graphql { playground = true; introspection = true }
```
- **Good example:**
```kotlin
graphql { playground = isDev; introspection = isDev }
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

## TEST_SERVER

### TEST_SERVER_001
- **Severity:** LOW
- **Source:** `custom` / `custom:TEST_SERVER_001`
- **Description:** Los endpoints deben tener tests de integración que validen el comportamiento completo (request → response).
- **Bad example:**
```kotlin
// Sin tests
```
- **Good example:**
```kotlin
@Test fun testGetUsers() = testApplication { client.get("/users").apply { assertEquals(HttpStatusCode.OK, status) } }
```
- **References:**
  - https://ktor.io/docs/testing.html
  - https://medium.com/kotlin-and-java/integration-testing-ktor-applications-with-testcontainers-5a6d7e8f9c2b

---

### TEST_SERVER_002
- **Severity:** LOW
- **Source:** `custom` / `custom:TEST_SERVER_002`
- **Description:** Los casos de uso/servicios deben tener unit tests con mocks de dependencias (repositories, external APIs).
- **Bad example:**
```kotlin
// Sin tests unitarios
```
- **Good example:**
```kotlin
@Test fun testCreateUser() { val repo = mockk<UserRepository>(); every { repo.save(any()) } returns user; val useCase = CreateUserUseCase(repo) }
```
- **References:**
  - https://junit.org/junit5/
  - https://medium.com/kotlin-and-java/unit-testing-strategies-for-kotlin-backend-8f2e7d5c9a3b

---
