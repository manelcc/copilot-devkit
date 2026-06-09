# Copilot Guidelines: Kotlin Server — HIGH

---

Total rules: **24**

## KTOR

### KTOR_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:KTOR_001`
- **Description:** Las rutas de Ktor deben delegar la lógica de negocio a casos de uso o servicios. La ruta solo debe orquestar (recibir request, llamar servicio, devolver response).
- **Bad example:**
```kotlin
get("/users") { val users = database.getUsersTable().selectAll().map { ... } call.respond(users) }
```
- **Good example:**
```kotlin
get("/users") { val users = getUsersUseCase.execute() call.respond(HttpStatusCode.OK, users) }
```
- **References:**
  - https://ktor.io/docs/routing.html
  - https://medium.com/@gabriel.kabbe/clean-architecture-on-kotlin-with-ktor-9a5493ba7cad
  - https://medium.com/kotlin-and-java/layered-architecture-with-kotlin-and-ktor-a4ebf7ec91ee

---

### KTOR_003
- **Severity:** HIGH
- **Source:** `custom` / `custom:KTOR_003`
- **Description:** Los errores en rutas de Ktor deben manejarse con el plugin StatusPages, no con try-catch genéricos en cada ruta.
- **Bad example:**
```kotlin
get("/users/{id}") { try { val user = getUser(id) call.respond(user) } catch (e: Exception) { call.respond(HttpStatusCode.InternalServerError) } }
```
- **Good example:**
```kotlin
install(StatusPages) { exception<UserNotFoundException> { call, cause -> call.respond(HttpStatusCode.NotFound, ErrorResponse(cause.message)) } }
```
- **References:**
  - https://ktor.io/docs/status-pages.html
  - https://medium.com/kotlin-and-java/exception-handling-in-ktor-468d7e8e6a7f

---

### KTOR_005
- **Severity:** HIGH
- **Source:** `custom` / `custom:KTOR_005`
- **Description:** Las rutas de Ktor deben ser testables. Evitar lógica compleja o acceso directo a recursos globales dentro de las rutas.
- **Bad example:**
```kotlin
get("/config") { call.respond(System.getenv("API_KEY")) }
```
- **Good example:**
```kotlin
get("/config") { call.respond(configService.getPublicConfig()) }
```
- **References:**
  - https://ktor.io/docs/testing.html
  - https://medium.com/kotlin-and-java/unit-testing-ktor-applications-9d5b8e6f1a2c

---

## COROUTINE

### COROUTINE_SERVER_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:COROUTINE_SERVER_001`
- **Description:** Las operaciones IO en servidores (DB, HTTP calls) deben ejecutarse en Dispatchers.IO, no en el dispatcher por defecto que bloquearía el event loop.
- **Bad example:**
```kotlin
suspend fun getUsers() = database.query("SELECT * FROM users")
```
- **Good example:**
```kotlin
suspend fun getUsers() = withContext(Dispatchers.IO) { database.query("SELECT * FROM users") }
```
- **References:**
  - https://kotlinlang.org/docs/coroutine-context-and-dispatchers.html
  - https://medium.com/kotlin-and-java/kotlin-coroutines-dispatchers-explained-d7d4ecratch9d
  - https://medium.com/kotliners/a-deep-dive-into-kotlin-coroutines-dispatchers-4dd8c79e8b5b

---

### COROUTINE_SERVER_002
- **Severity:** HIGH
- **Source:** `custom` / `custom:COROUTINE_SERVER_002`
- **Description:** No capturar CancellationException en bloques try-catch. Esto rompe la cancelación cooperativa de coroutines.
- **Bad example:**
```kotlin
try { delay(1000) } catch (e: Exception) { logger.error(e) }
```
- **Good example:**
```kotlin
try { delay(1000) } catch (e: Exception) { if (e is CancellationException) throw e; logger.error(e) }
```
- **References:**
  - https://kotlinlang.org/docs/cancellation-and-timeouts.html
  - https://medium.com/kotlin-and-java/kotlin-coroutines-cancellation-4c5a4f3e7e8d
  - https://medium.com/kotliners/exception-handling-in-kotlin-coroutines-b1cdf1b25540

---

## DI_SERVER

### DI_SERVER_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:DI_SERVER_001`
- **Description:** La inyección de dependencias debe usarse para proveer servicios, repositorios y casos de uso. Evitar instanciación manual con 'new' o constructores directos.
- **Bad example:**
```kotlin
fun Application.module() { val service = MyService(MyRepository()) }
```
- **Good example:**
```kotlin
// Koin: val service: MyService by inject() // O manual DI: fun Application.module(service: MyService = provideMyService())
```
- **References:**
  - https://insert-koin.io/docs/reference/koin-ktor/ktor
  - https://medium.com/kotlin-and-java/dependency-injection-with-koin-in-kotlin-2c9eef7a3c9e
  - https://medium.com/kotliners/koin-dependency-injection-made-simple-c7d5e8a9f2b1

---

## ARCH_SERVER

### ARCH_SERVER_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:ARCH_SERVER_001`
- **Description:** La capa de presentación (routes/controllers) NO debe acceder directamente a repositorios o bases de datos. Debe usar casos de uso o servicios (domain layer).
- **Bad example:**
```kotlin
get("/users") { val users = userRepository.findAll(); call.respond(users) }
```
- **Good example:**
```kotlin
get("/users") { val users = getUsersUseCase.execute(); call.respond(users) }
```
- **References:**
  - https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
  - https://medium.com/kotlin-and-java/clean-architecture-with-kotlin-8ae50d2b8a19
  - https://medium.com/kotliners/modern-clean-architecture-for-microservices-c8e6b5d9f3a2

---

### ARCH_SERVER_002
- **Severity:** HIGH
- **Source:** `custom` / `custom:ARCH_SERVER_002`
- **Description:** Los DTOs de API deben ser diferentes de las entidades de dominio. No exponer entidades de base de datos directamente en las APIs.
- **Bad example:**
```kotlin
@Serializable data class User(val id: Int, val password: String); get("/users") { call.respond(userRepository.findAll()) }
```
- **Good example:**
```kotlin
@Serializable data class UserResponse(val id: Int, val username: String); get("/users") { call.respond(users.map { it.toResponse() }) }
```
- **References:**
  - https://martinfowler.com/eaaCatalog/dataTransferObject.html
  - https://medium.com/kotlin-and-java/dto-pattern-in-kotlin-rest-apis-1a8e4c5d7f9b

---

## ERROR_SERVER

### ERROR_SERVER_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:ERROR_SERVER_001`
- **Description:** Las excepciones de negocio deben ser específicas (DomainException) no genéricas (Exception, RuntimeException).
- **Bad example:**
```kotlin
if (user == null) throw Exception("User not found")
```
- **Good example:**
```kotlin
if (user == null) throw UserNotFoundException(userId)
```
- **References:**
  - https://docs.oracle.com/javase/tutorial/essential/exceptions/creating.html
  - https://medium.com/kotlin-and-java/custom-exceptions-in-kotlin-bd4c7e9f8a3d

---

### ERROR_SERVER_002
- **Severity:** HIGH
- **Source:** `custom` / `custom:ERROR_SERVER_002`
- **Description:** NO capturar excepciones genéricas (Exception, Throwable) sin re-lanzarlas o manejarlas apropiadamente. Esto oculta errores críticos.
- **Bad example:**
```kotlin
try { processRequest() } catch (e: Exception) { logger.error(e.message) }
```
- **Good example:**
```kotlin
try { processRequest() } catch (e: BusinessException) { handleBusinessError(e) } catch (e: Exception) { logger.error("Unexpected error", e); throw e }
```
- **References:**
  - https://kotlinlang.org/docs/exceptions.html
  - https://medium.com/kotlin-and-java/custom-exceptions-in-kotlin-bd4c7e9f8a3d

---

## DB_SERVER

### DB_SERVER_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:DB_SERVER_001`
- **Description:** Las operaciones de base de datos deben usar transacciones para garantizar consistencia. Especialmente en operaciones múltiples.
- **Bad example:**
```kotlin
fun transferMoney(from: Int, to: Int, amount: Double) { debit(from, amount); credit(to, amount) }
```
- **Good example:**
```kotlin
suspend fun transferMoney(from: Int, to: Int, amount: Double) = transaction { debit(from, amount); credit(to, amount) }
```
- **References:**
  - https://en.wikipedia.org/wiki/Database_transaction
  - https://medium.com/kotlin-and-java/database-transactions-with-exposed-and-kotlinx-3d7a5e8f2c1b

---

### DB_SERVER_002
- **Severity:** HIGH
- **Source:** `custom` / `custom:DB_SERVER_002`
- **Description:** Usar prepared statements o query builders (Exposed, jOOQ) para prevenir SQL injection. Nunca concatenar strings para queries.
- **Bad example:**
```kotlin
val sql = "SELECT * FROM users WHERE id = $userId"; database.execute(sql)
```
- **Good example:**
```kotlin
Users.select { Users.id eq userId }
```
- **References:**
  - https://www.owasp.org/index.php/SQL_Injection
  - https://medium.com/kotlin-and-java/sql-injection-prevention-with-prepared-statements-5b2e7f4d9c3a

---

### SONAR_SEC_008
- **Severity:** HIGH
- **Source:** `sonar` / `Kotlin Security Hotspot - SQL injection risk`
- **Description:** SQL injection risk: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_033
- **Severity:** HIGH
- **Source:** `sonar` / `Kotlin Security Hotspot - Dynamic ORDER BY injection`
- **Description:** Dynamic ORDER BY injection: los campos de ordenación deben salir de una allowlist y no de entrada arbitraria del cliente.
- **Bad example:**
```kotlin
val sql = "SELECT * FROM users ORDER BY ${'$'}sort"
```
- **Good example:**
```kotlin
val sortColumn = allowedSorts[sort] ?: "created_at"
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

## LOGGING

### LOGGING_002
- **Severity:** HIGH
- **Source:** `custom` / `custom:LOGGING_002`
- **Description:** NO loguear información sensible (passwords, tokens, PII) ni siquiera en nivel DEBUG.
- **Bad example:**
```kotlin
logger.debug("User login: username=$username, password=$password")
```
- **Good example:**
```kotlin
logger.debug("User login attempt: username=$username")
```
- **References:**
  - https://gdpr-info.eu/
  - https://medium.com/kotlin-and-java/protecting-pii-in-logs-and-responses-2c5e8d7f9a3b

---

### DETEKT_SEC_041
- **Severity:** HIGH
- **Source:** `detekt` / `ForbiddenComment:DetektSec41`
- **Description:** Regla defensiva Detekt #41: reforzar controles de secretos, sanitización y observabilidad segura.
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

### DETEKT_SEC_043
- **Severity:** HIGH
- **Source:** `detekt` / `ForbiddenComment:DetektSec43`
- **Description:** Regla defensiva Detekt #43: reforzar controles de secretos, sanitización y observabilidad segura.
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

### DETEKT_SEC_047
- **Severity:** HIGH
- **Source:** `detekt` / `ForbiddenComment:DetektSec47`
- **Description:** Regla defensiva Detekt #47: reforzar controles de secretos, sanitización y observabilidad segura.
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

### DETEKT_SEC_049
- **Severity:** HIGH
- **Source:** `detekt` / `ForbiddenComment:DetektSec49`
- **Description:** Regla defensiva Detekt #49: reforzar controles de secretos, sanitización y observabilidad segura.
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

### SONAR_SEC_005
- **Severity:** HIGH
- **Source:** `sonar` / `Kotlin Security Hotspot - Sensitive data exposure in logs`
- **Description:** Sensitive data exposure in logs: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
- **Bad example:**
```kotlin
val password = "admin123"
```
- **Good example:**
```kotlin
val password = config.property("auth.password").getString()
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_030
- **Severity:** HIGH
- **Source:** `sonar` / `Kotlin Security Hotspot - Authorization header leakage in logs`
- **Description:** Authorization header leakage in logs: no registrar tokens Bearer ni valores de cabeceras sensibles.
- **Bad example:**
```kotlin
logger.info("headers=${'$'}{call.request.headers}")
```
- **Good example:**
```kotlin
logger.info("request headers sanitized")
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

## CONFIG

### CONFIG_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:CONFIG_001`
- **Description:** La configuración (DB URLs, ports, feature flags) debe externalizarse en archivos de configuración o variables de entorno, no hardcodeada.
- **Bad example:**
```kotlin
val dbUrl = "jdbc:postgresql://localhost:5432/mydb"
```
- **Good example:**
```kotlin
val dbUrl = config.property("database.url").getString()
```
- **References:**
  - https://12factor.net/config
  - https://medium.com/kotlin-and-java/externalized-configuration-in-kotlin-8a4f7e5d3c1b

---

### SONAR_SEC_046
- **Severity:** HIGH
- **Source:** `sonar` / `Kotlin Security Hotspot - Sensitive config exposed via diagnostics`
- **Description:** Sensitive config exposed via diagnostics: evitar exponer variables sensibles en endpoints de health/info/env.
- **Bad example:**
```kotlin
get("/env") { call.respond(System.getenv()) }
```
- **Good example:**
```kotlin
get("/env") { call.respond(maskSensitive(envSnapshot())) }
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_048
- **Severity:** HIGH
- **Source:** `sonar` / `Kotlin Security Hotspot - Missing multipart part-count limits`
- **Description:** Missing multipart part-count limits: limitar número de partes y tamaño total en cargas multipart para evitar abuso de recursos.
- **Bad example:**
```kotlin
call.receiveMultipart().forEachPart { ... } // sin límites
```
- **Good example:**
```kotlin
multipartConfig { maxParts = 20; maxPartSize = 5 * 1024 * 1024 }
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---
