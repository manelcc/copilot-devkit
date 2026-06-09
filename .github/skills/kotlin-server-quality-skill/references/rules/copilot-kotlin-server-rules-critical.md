# Copilot Guidelines: Kotlin Server — CRITICAL

---

Total rules: **54**

## SEC_SERVER

### SEC_SERVER_001
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:SEC_SERVER_001`
- **Description:** Los secretos (API keys, passwords, tokens) NO deben estar hardcodeados. Usar variables de entorno o gestores de secretos.
- **Bad example:**
```kotlin
val apiKey = "sk-1234567890abcdef"
```
- **Good example:**
```kotlin
val apiKey = System.getenv("API_KEY") ?: throw IllegalStateException("API_KEY not configured")"
```
- **References:**
  - https://owasp.org/www-community/vulnerabilities/Use_of_hard-coded_password
  - https://medium.com/kotlin-and-java/managing-secrets-in-kotlin-applications-3e5c6d8a9f1b
  - https://medium.com/kotliners/secure-secrets-management-for-microservices-a7d3e8c1f9b2

---

### SEC_SERVER_002
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:SEC_SERVER_002`
- **Description:** Las contraseñas deben hashearse con algoritmos seguros (bcrypt, argon2) nunca almacenar en texto plano o con hashes débiles (MD5, SHA1).
- **Bad example:**
```kotlin
val hashedPassword = password.hashCode().toString()
```
- **Good example:**
```kotlin
val hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt())
```
- **References:**
  - https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
  - https://medium.com/kotlin-and-java/bcrypt-in-kotlin-secure-password-hashing-2f7a8e5d3c1b

---

### SEC_SERVER_003
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:SEC_SERVER_003`
- **Description:** Los endpoints deben validar y sanitizar toda entrada del usuario (body, query params, path params) para prevenir injection attacks.
- **Bad example:**
```kotlin
get("/search") { val query = call.parameters["q"]; database.execute("SELECT * FROM users WHERE name = '$query'") }
```
- **Good example:**
```kotlin
get("/search") { val query = call.parameters["q"]?.sanitize() ?: ""; userRepository.search(query) // usando prepared statements }
```
- **References:**
  - https://owasp.org/www-community/attacks/SQL_Injection
  - https://medium.com/kotlin-and-java/input-validation-and-sanitization-in-kotlin-4a6e7f3c8d1b

---

### SEC_SERVER_004
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:SEC_SERVER_004`
- **Description:** Los tokens JWT deben validarse correctamente (signature, expiration, issuer) antes de confiar en su contenido.
- **Bad example:**
```kotlin
val token = call.request.header("Authorization"); val userId = JWT.decode(token).getClaim("user_id")
```
- **Good example:**
```kotlin
val token = call.request.header("Authorization"); val jwt = jwtVerifier.verify(token); val userId = jwt.getClaim("user_id")
```
- **References:**
  - https://jwt.io/introduction
  - https://medium.com/kotlin-and-java/jwt-authentication-in-ktor-7c5d3e8f1a9b

---

### SEC_SERVER_006
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:SEC_SERVER_006`
- **Description:** Las APIs deben implementar rate limiting para prevenir abuso y ataques de denegación de servicio (DoS).
- **Bad example:**
```kotlin
post("/login") { authenticateUser(call.receive<Credentials>()) }
```
- **Good example:**
```kotlin
install(RateLimiter) { register(RateLimitName("login")) { rateLimiter(10, 1.minutes) } }
```
- **References:**
  - https://ktor.io/docs/rate-limit.html
  - https://medium.com/kotlin-and-java/rate-limiting-strategies-in-kotlin-apis-1a5d7e8c3f2b

---

### DETEKT_SEC_001
- **Severity:** CRITICAL
- **Source:** `detekt` / `HardcodedApiKey`
- **Description:** No hardcodear API_KEY en código Kotlin. Debe inyectarse desde configuración segura o secret manager.
- **Bad example:**
```kotlin
val api_key = "hardcoded-value"
```
- **Good example:**
```kotlin
val api_key = environment.config.propertyOrNull("API_KEY")?.getString() ?: error("API_KEY missing")
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddencomment

---

### DETEKT_SEC_002
- **Severity:** CRITICAL
- **Source:** `detekt` / `HardcodedSecret`
- **Description:** No hardcodear SECRET en código Kotlin. Debe inyectarse desde configuración segura o secret manager.
- **Bad example:**
```kotlin
val secret = "hardcoded-value"
```
- **Good example:**
```kotlin
val secret = environment.config.propertyOrNull("SECRET")?.getString() ?: error("SECRET missing")
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddencomment

---

### DETEKT_SEC_003
- **Severity:** CRITICAL
- **Source:** `detekt` / `HardcodedJwtSecret`
- **Description:** No hardcodear JWT_SECRET en código Kotlin. Debe inyectarse desde configuración segura o secret manager.
- **Bad example:**
```kotlin
val jwt_secret = "hardcoded-value"
```
- **Good example:**
```kotlin
val jwt_secret = environment.config.propertyOrNull("JWT_SECRET")?.getString() ?: error("JWT_SECRET missing")
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddencomment

---

### DETEKT_SEC_004
- **Severity:** CRITICAL
- **Source:** `detekt` / `HardcodedDbPassword`
- **Description:** No hardcodear DB_PASSWORD en código Kotlin. Debe inyectarse desde configuración segura o secret manager.
- **Bad example:**
```kotlin
val db_password = "hardcoded-value"
```
- **Good example:**
```kotlin
val db_password = environment.config.propertyOrNull("DB_PASSWORD")?.getString() ?: error("DB_PASSWORD missing")
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddencomment

---

### DETEKT_SEC_005
- **Severity:** CRITICAL
- **Source:** `detekt` / `HardcodedAwsSecretKey`
- **Description:** No hardcodear AWS_SECRET_ACCESS_KEY en código Kotlin. Debe inyectarse desde configuración segura o secret manager.
- **Bad example:**
```kotlin
val aws_secret_access_key = "hardcoded-value"
```
- **Good example:**
```kotlin
val aws_secret_access_key = environment.config.propertyOrNull("AWS_SECRET_ACCESS_KEY")?.getString() ?: error("AWS_SECRET_ACCESS_KEY missing")
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddencomment

---

### DETEKT_SEC_006
- **Severity:** CRITICAL
- **Source:** `detekt` / `HardcodedPrivateKey`
- **Description:** No hardcodear PRIVATE_KEY en código Kotlin. Debe inyectarse desde configuración segura o secret manager.
- **Bad example:**
```kotlin
val private_key = "hardcoded-value"
```
- **Good example:**
```kotlin
val private_key = environment.config.propertyOrNull("PRIVATE_KEY")?.getString() ?: error("PRIVATE_KEY missing")
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddencomment

---

### DETEKT_SEC_007
- **Severity:** CRITICAL
- **Source:** `detekt` / `HardcodedClientSecret`
- **Description:** No hardcodear CLIENT_SECRET en código Kotlin. Debe inyectarse desde configuración segura o secret manager.
- **Bad example:**
```kotlin
val client_secret = "hardcoded-value"
```
- **Good example:**
```kotlin
val client_secret = environment.config.propertyOrNull("CLIENT_SECRET")?.getString() ?: error("CLIENT_SECRET missing")
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddencomment

---

### DETEKT_SEC_008
- **Severity:** CRITICAL
- **Source:** `detekt` / `HardcodedToken`
- **Description:** No hardcodear TOKEN en código Kotlin. Debe inyectarse desde configuración segura o secret manager.
- **Bad example:**
```kotlin
val token = "hardcoded-value"
```
- **Good example:**
```kotlin
val token = environment.config.propertyOrNull("TOKEN")?.getString() ?: error("TOKEN missing")
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddencomment

---

### DETEKT_SEC_009
- **Severity:** CRITICAL
- **Source:** `detekt` / `HardcodedEncryptionKey`
- **Description:** No hardcodear ENCRYPTION_KEY en código Kotlin. Debe inyectarse desde configuración segura o secret manager.
- **Bad example:**
```kotlin
val encryption_key = "hardcoded-value"
```
- **Good example:**
```kotlin
val encryption_key = environment.config.propertyOrNull("ENCRYPTION_KEY")?.getString() ?: error("ENCRYPTION_KEY missing")
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddencomment

---

### DETEKT_SEC_010
- **Severity:** CRITICAL
- **Source:** `detekt` / `HardcodedSalt`
- **Description:** No hardcodear SALT en código Kotlin. Debe inyectarse desde configuración segura o secret manager.
- **Bad example:**
```kotlin
val salt = "hardcoded-value"
```
- **Good example:**
```kotlin
val salt = environment.config.propertyOrNull("SALT")?.getString() ?: error("SALT missing")
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddencomment

---

### DETEKT_SEC_011
- **Severity:** CRITICAL
- **Source:** `detekt` / `ForbiddenMethodCall:RuntimeExec`
- **Description:** Restringir el uso de java.lang.Runtime.getRuntime().exec por RCE risk; encapsular mediante un servicio seguro auditable.
- **Bad example:**
```kotlin
java.lang.Runtime.getRuntime().exec(...)
```
- **Good example:**
```kotlin
securityGateway.safeOperation(...)
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenmethodcall

---

### DETEKT_SEC_012
- **Severity:** CRITICAL
- **Source:** `detekt` / `ForbiddenMethodCall:PrintlnLeakage`
- **Description:** Restringir el uso de kotlin.io.println por possible secret leakage; encapsular mediante un servicio seguro auditable.
- **Bad example:**
```kotlin
kotlin.io.println(...)
```
- **Good example:**
```kotlin
securityGateway.safeOperation(...)
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenmethodcall

---

### DETEKT_SEC_013
- **Severity:** CRITICAL
- **Source:** `detekt` / `ForbiddenMethodCall:SqlStatementExecute`
- **Description:** Restringir el uso de java.sql.Statement.execute por SQL injection risk; encapsular mediante un servicio seguro auditable.
- **Bad example:**
```kotlin
java.sql.Statement.execute(...)
```
- **Good example:**
```kotlin
securityGateway.safeOperation(...)
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenmethodcall

---

### DETEKT_SEC_014
- **Severity:** CRITICAL
- **Source:** `detekt` / `ForbiddenMethodCall:UrlOpenStream`
- **Description:** Restringir el uso de java.net.URL.openStream por SSRF risk; encapsular mediante un servicio seguro auditable.
- **Bad example:**
```kotlin
java.net.URL.openStream(...)
```
- **Good example:**
```kotlin
securityGateway.safeOperation(...)
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenmethodcall

---

### DETEKT_SEC_015
- **Severity:** CRITICAL
- **Source:** `detekt` / `ForbiddenMethodCall:HostnameVerifierBypass`
- **Description:** Restringir el uso de javax.net.ssl.HttpsURLConnection.setHostnameVerifier por TLS validation bypass; encapsular mediante un servicio seguro auditable.
- **Bad example:**
```kotlin
javax.net.ssl.HttpsURLConnection.setHostnameVerifier(...)
```
- **Good example:**
```kotlin
securityGateway.safeOperation(...)
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenmethodcall

---

### DETEKT_SEC_016
- **Severity:** CRITICAL
- **Source:** `detekt` / `ForbiddenMethodCall:SecureRandomSetSeed`
- **Description:** Restringir el uso de java.security.SecureRandom.setSeed por predictable randomness risk; encapsular mediante un servicio seguro auditable.
- **Bad example:**
```kotlin
java.security.SecureRandom.setSeed(...)
```
- **Good example:**
```kotlin
securityGateway.safeOperation(...)
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenmethodcall

---

### DETEKT_SEC_017
- **Severity:** CRITICAL
- **Source:** `detekt` / `ForbiddenMethodCall:MessageDigestMD5`
- **Description:** Restringir el uso de java.security.MessageDigest.getInstance("MD5") por weak hash; encapsular mediante un servicio seguro auditable.
- **Bad example:**
```kotlin
java.security.MessageDigest.getInstance("MD5")(...)
```
- **Good example:**
```kotlin
securityGateway.safeOperation(...)
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenmethodcall

---

### DETEKT_SEC_018
- **Severity:** CRITICAL
- **Source:** `detekt` / `ForbiddenMethodCall:MessageDigestSHA1`
- **Description:** Restringir el uso de java.security.MessageDigest.getInstance("SHA-1") por weak hash; encapsular mediante un servicio seguro auditable.
- **Bad example:**
```kotlin
java.security.MessageDigest.getInstance("SHA-1")(...)
```
- **Good example:**
```kotlin
securityGateway.safeOperation(...)
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenmethodcall

---

### DETEKT_SEC_019
- **Severity:** CRITICAL
- **Source:** `detekt` / `ForbiddenMethodCall:ExitProcess`
- **Description:** Restringir el uso de kotlin.system.exitProcess por DoS risk from forced exit; encapsular mediante un servicio seguro auditable.
- **Bad example:**
```kotlin
kotlin.system.exitProcess(...)
```
- **Good example:**
```kotlin
securityGateway.safeOperation(...)
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenmethodcall

---

### DETEKT_SEC_020
- **Severity:** CRITICAL
- **Source:** `detekt` / `ForbiddenMethodCall:SystemGetenv`
- **Description:** Restringir el uso de java.lang.System.getenv por direct secret exfiltration surface; encapsular mediante un servicio seguro auditable.
- **Bad example:**
```kotlin
java.lang.System.getenv(...)
```
- **Good example:**
```kotlin
securityGateway.safeOperation(...)
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenmethodcall

---

### DETEKT_SEC_044
- **Severity:** CRITICAL
- **Source:** `detekt` / `ForbiddenMethodCall:DetektSec44`
- **Description:** Regla defensiva Detekt #44: reforzar controles de secretos, sanitización y observabilidad segura.
- **Bad example:**
```kotlin
logger.debug("token=$token")
```
- **Good example:**
```kotlin
logger.debug("token present: {}", token != null)
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenmethodcall

---

### DETEKT_SEC_046
- **Severity:** CRITICAL
- **Source:** `detekt` / `ForbiddenMethodCall:DetektSec46`
- **Description:** Regla defensiva Detekt #46: reforzar controles de secretos, sanitización y observabilidad segura.
- **Bad example:**
```kotlin
logger.debug("token=$token")
```
- **Good example:**
```kotlin
logger.debug("token present: {}", token != null)
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenmethodcall

---

### DETEKT_SEC_050
- **Severity:** CRITICAL
- **Source:** `detekt` / `ForbiddenMethodCall:DetektSec50`
- **Description:** Regla defensiva Detekt #50: reforzar controles de secretos, sanitización y observabilidad segura.
- **Bad example:**
```kotlin
logger.debug("token=$token")
```
- **Good example:**
```kotlin
logger.debug("token present: {}", token != null)
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenmethodcall

---

### SONAR_SEC_001
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Hardcoded credentials`
- **Description:** Hardcoded credentials: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_002
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Weak cryptographic algorithm`
- **Description:** Weak cryptographic algorithm: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_003
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Insufficient TLS validation`
- **Description:** Insufficient TLS validation: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_004
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - JWT validation incomplete`
- **Description:** JWT validation incomplete: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_006
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Path traversal risk`
- **Description:** Path traversal risk: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_007
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Command injection risk`
- **Description:** Command injection risk: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_010
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - XML External Entity risk`
- **Description:** XML External Entity risk: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_011
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Server-Side Request Forgery risk`
- **Description:** Server-Side Request Forgery risk: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_018
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Insecure randomness`
- **Description:** Insecure randomness: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_019
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Insecure deserialization`
- **Description:** Insecure deserialization: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_022
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Unsigned webhook requests`
- **Description:** Unsigned webhook requests: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_026
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Missing HSTS header`
- **Description:** Missing HSTS header: las respuestas HTTPS deben incluir Strict-Transport-Security para prevenir downgrade attacks.
- **Bad example:**
```kotlin
call.respondText("ok") // sin cabecera HSTS
```
- **Good example:**
```kotlin
call.response.header("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_027
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Missing CSP header`
- **Description:** Missing CSP header: definir Content-Security-Policy en respuestas HTML para mitigar XSS y carga de recursos no confiables.
- **Bad example:**
```kotlin
call.respondHtml { body { script { +"alert(1)" } } }
```
- **Good example:**
```kotlin
call.response.header("Content-Security-Policy", "default-src 'self'")
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_028
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Missing clickjacking protection`
- **Description:** Missing clickjacking protection: configurar X-Frame-Options o frame-ancestors para evitar embebido no autorizado.
- **Bad example:**
```kotlin
call.respondText("dashboard") // sin protección contra iframe embedding
```
- **Good example:**
```kotlin
call.response.header("X-Frame-Options", "DENY")
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_029
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Missing JWT audience validation`
- **Description:** Missing JWT audience validation: validar el claim aud contra la audiencia esperada antes de autorizar la petición.
- **Bad example:**
```kotlin
val principal = verifier.verify(token) // sin comprobar aud
```
- **Good example:**
```kotlin
require(jwt.getAudience().contains(expectedAudience)) { "invalid audience" }
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_031
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Missing malware scanning on uploads`
- **Description:** Missing malware scanning on uploads: los ficheros subidos deben analizarse antes de persistirse o procesarse.
- **Bad example:**
```kotlin
val bytes = part.streamProvider().readBytes(); storage.save(bytes)
```
- **Good example:**
```kotlin
val bytes = part.streamProvider().readBytes(); antivirus.scan(bytes); storage.save(bytes)
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_032
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Zip Slip extraction risk`
- **Description:** Zip Slip extraction risk: validar rutas de entrada al descomprimir archivos para impedir escritura fuera del directorio destino.
- **Bad example:**
```kotlin
ZipInputStream(input).use { unzipTo(targetDir) }
```
- **Good example:**
```kotlin
require(entryPath.normalize().startsWith(targetDir.normalize()))
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_034
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Regex DoS risk`
- **Description:** Regex DoS risk: evitar regex complejas controladas por el usuario y aplicar límites de tiempo/longitud.
- **Bad example:**
```kotlin
Regex(userPattern).matches(input)
```
- **Good example:**
```kotlin
require(userPattern in SAFE_PATTERNS); require(input.length <= 256)
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_035
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Unsafe YAML deserialization`
- **Description:** Unsafe YAML deserialization: no deserializar YAML no confiable con loaders que permitan tipos arbitrarios.
- **Bad example:**
```kotlin
Yaml().load<UserInput>(payload)
```
- **Good example:**
```kotlin
Yaml(SafeConstructor()).load<Map<String, Any>>(payload)
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_036
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Cloud metadata endpoint exposure`
- **Description:** Cloud metadata endpoint exposure: bloquear salidas a endpoints de metadata interna (por ejemplo 169.254.169.254).
- **Bad example:**
```kotlin
httpClient.get(userProvidedUrl)
```
- **Good example:**
```kotlin
require(!resolvedIp.isLinkLocalAddress); outboundAllowlist.enforce(host)
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_037
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Host header poisoning`
- **Description:** Host header poisoning: no construir URLs absolutas ni decisiones de seguridad usando Host sin validación explícita.
- **Bad example:**
```kotlin
val resetUrl = "https://${'$'}{call.request.host()}/reset?token=${'$'}token"
```
- **Good example:**
```kotlin
val resetUrl = "https://${'$'}trustedDomain/reset?token=${'$'}token"
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_039
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Invalid CORS credentials policy`
- **Description:** Invalid CORS credentials policy: no combinar credenciales con orígenes amplios o dinámicos sin allowlist estricta.
- **Bad example:**
```kotlin
allowCredentials = true; anyHost()
```
- **Good example:**
```kotlin
allowCredentials = true; allowHost("app.example.com", schemes = listOf("https"))
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_041
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Reusable password reset token`
- **Description:** Reusable password reset token: invalidar tokens tras su uso y aplicar expiración corta.
- **Bad example:**
```kotlin
if (tokenRepo.isValid(token)) resetPassword(userId)
```
- **Good example:**
```kotlin
if (tokenRepo.consume(token)) resetPassword(userId)
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_043
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Weak password hashing parameters`
- **Description:** Weak password hashing parameters: configurar coste mínimo recomendado para bcrypt/argon2 en entorno de producción.
- **Bad example:**
```kotlin
BCrypt.hashpw(password, BCrypt.gensalt(4))
```
- **Good example:**
```kotlin
BCrypt.hashpw(password, BCrypt.gensalt(12))
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_044
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Insecure temporary file permissions`
- **Description:** Insecure temporary file permissions: crear archivos temporales con permisos mínimos y ubicación controlada.
- **Bad example:**
```kotlin
val tmp = File.createTempFile("upload", ".tmp")
```
- **Good example:**
```kotlin
val tmp = Files.createTempFile(tempDir, "upload", ".tmp", PosixFilePermissions.asFileAttribute(PosixFilePermissions.fromString("rw-------")))
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_047
- **Severity:** CRITICAL
- **Source:** `sonar` / `Kotlin Security Hotspot - Webhook replay attack risk`
- **Description:** Webhook replay attack risk: validar timestamp/nonce y rechazar eventos repetidos aunque tengan firma válida.
- **Bad example:**
```kotlin
if (signatureIsValid) process(event)
```
- **Good example:**
```kotlin
if (signatureIsValid && isFresh(ts) && nonceStore.registerOnce(nonce)) process(event)
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---
