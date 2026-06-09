# Copilot Guidelines: Kotlin Server — MEDIUM

---

Total rules: **22**

## SEC_SERVER

### SEC_SERVER_005
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:SEC_SERVER_005`
- **Description:** Los mensajes de error NO deben exponer detalles internos (stack traces, queries SQL, rutas de archivos) a usuarios finales.
- **Bad example:**
```kotlin
catch (e: SQLException) { call.respond(HttpStatusCode.InternalServerError, e.message) }
```
- **Good example:**
```kotlin
catch (e: SQLException) { logger.error("DB error", e); call.respond(HttpStatusCode.InternalServerError, "Internal server error") }
```
- **References:**
  - https://owasp.org/www-community/Improper_Error_Handling
  - https://medium.com/kotlin-and-java/secure-error-handling-and-logging-7f3a8e5c2d1b

---

### DETEKT_SEC_021
- **Severity:** MEDIUM
- **Source:** `detekt` / `ForbiddenImport:SunMisc`
- **Description:** Evitar import sun.misc.* en capa de servidor sin justificación explícita de seguridad.
- **Bad example:**
```kotlin
import sun.misc.*
```
- **Good example:**
```kotlin
// usar wrapper interno revisado y testeado
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenimport

---

### DETEKT_SEC_022
- **Severity:** MEDIUM
- **Source:** `detekt` / `ForbiddenImport:GlobalScope`
- **Description:** Evitar import kotlinx.coroutines.GlobalScope en capa de servidor sin justificación explícita de seguridad.
- **Bad example:**
```kotlin
import kotlinx.coroutines.GlobalScope
```
- **Good example:**
```kotlin
// usar wrapper interno revisado y testeado
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenimport

---

### DETEKT_SEC_023
- **Severity:** MEDIUM
- **Source:** `detekt` / `ForbiddenImport:JavaUtilRandom`
- **Description:** Evitar import java.util.Random en capa de servidor sin justificación explícita de seguridad.
- **Bad example:**
```kotlin
import java.util.Random
```
- **Good example:**
```kotlin
// usar wrapper interno revisado y testeado
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenimport

---

### DETEKT_SEC_024
- **Severity:** MEDIUM
- **Source:** `detekt` / `ForbiddenImport:JavaNetWildcard`
- **Description:** Evitar import java.net.* en capa de servidor sin justificación explícita de seguridad.
- **Bad example:**
```kotlin
import java.net.*
```
- **Good example:**
```kotlin
// usar wrapper interno revisado y testeado
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenimport

---

### DETEKT_SEC_025
- **Severity:** MEDIUM
- **Source:** `detekt` / `ForbiddenImport:FileInputStream`
- **Description:** Evitar import java.io.FileInputStream en capa de servidor sin justificación explícita de seguridad.
- **Bad example:**
```kotlin
import java.io.FileInputStream
```
- **Good example:**
```kotlin
// usar wrapper interno revisado y testeado
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenimport

---

### DETEKT_SEC_026
- **Severity:** MEDIUM
- **Source:** `detekt` / `ForbiddenImport:SqlStatement`
- **Description:** Evitar import java.sql.Statement en capa de servidor sin justificación explícita de seguridad.
- **Bad example:**
```kotlin
import java.sql.Statement
```
- **Good example:**
```kotlin
// usar wrapper interno revisado y testeado
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenimport

---

### DETEKT_SEC_027
- **Severity:** MEDIUM
- **Source:** `detekt` / `ForbiddenImport:ApacheHttpWildcard`
- **Description:** Evitar import org.apache.http.* en capa de servidor sin justificación explícita de seguridad.
- **Bad example:**
```kotlin
import org.apache.http.*
```
- **Good example:**
```kotlin
// usar wrapper interno revisado y testeado
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenimport

---

### DETEKT_SEC_028
- **Severity:** MEDIUM
- **Source:** `detekt` / `ForbiddenImport:JavaxXmlParsers`
- **Description:** Evitar import javax.xml.parsers.* en capa de servidor sin justificación explícita de seguridad.
- **Bad example:**
```kotlin
import javax.xml.parsers.*
```
- **Good example:**
```kotlin
// usar wrapper interno revisado y testeado
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenimport

---

### DETEKT_SEC_029
- **Severity:** MEDIUM
- **Source:** `detekt` / `ForbiddenImport:JavaLangReflect`
- **Description:** Evitar import java.lang.reflect.* en capa de servidor sin justificación explícita de seguridad.
- **Bad example:**
```kotlin
import java.lang.reflect.*
```
- **Good example:**
```kotlin
// usar wrapper interno revisado y testeado
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenimport

---

### DETEKT_SEC_030
- **Severity:** MEDIUM
- **Source:** `detekt` / `ForbiddenImport:JsonElement`
- **Description:** Evitar import kotlinx.serialization.json.JsonElement en capa de servidor sin justificación explícita de seguridad.
- **Bad example:**
```kotlin
import kotlinx.serialization.json.JsonElement
```
- **Good example:**
```kotlin
// usar wrapper interno revisado y testeado
```
- **References:**
  - https://detekt.dev/docs/rules/style/#forbiddenimport

---

### DETEKT_SEC_042
- **Severity:** MEDIUM
- **Source:** `detekt` / `ForbiddenMethodCall:DetektSec42`
- **Description:** Regla defensiva Detekt #42: reforzar controles de secretos, sanitización y observabilidad segura.
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

### DETEKT_SEC_048
- **Severity:** MEDIUM
- **Source:** `detekt` / `ForbiddenMethodCall:DetektSec48`
- **Description:** Regla defensiva Detekt #48: reforzar controles de secretos, sanitización y observabilidad segura.
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

### SONAR_SEC_012
- **Severity:** MEDIUM
- **Source:** `sonar` / `Kotlin Security Hotspot - Open redirect risk`
- **Description:** Open redirect risk: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_013
- **Severity:** MEDIUM
- **Source:** `sonar` / `Kotlin Security Hotspot - Cookie without secure flags`
- **Description:** Cookie without secure flags: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_014
- **Severity:** MEDIUM
- **Source:** `sonar` / `Kotlin Security Hotspot - CORS policy too permissive`
- **Description:** CORS policy too permissive: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_015
- **Severity:** MEDIUM
- **Source:** `sonar` / `Kotlin Security Hotspot - Missing rate limiting`
- **Description:** Missing rate limiting: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_016
- **Severity:** MEDIUM
- **Source:** `sonar` / `Kotlin Security Hotspot - Missing brute-force protection`
- **Description:** Missing brute-force protection: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_017
- **Severity:** MEDIUM
- **Source:** `sonar` / `Kotlin Security Hotspot - Session fixation risk`
- **Description:** Session fixation risk: implementar control preventivo y evidencia de prueba automatizada en backend Kotlin.
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

### SONAR_SEC_038
- **Severity:** MEDIUM
- **Source:** `sonar` / `Kotlin Security Hotspot - Cookie missing SameSite flag`
- **Description:** Cookie missing SameSite flag: cookies de sesión deben definir SameSite apropiado para reducir CSRF.
- **Bad example:**
```kotlin
call.response.cookies.append(Cookie("sid", sid, secure = true, httpOnly = true))
```
- **Good example:**
```kotlin
call.response.cookies.append(Cookie("sid", sid, secure = true, httpOnly = true, extensions = mapOf("SameSite" to "Lax")))
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_040
- **Severity:** MEDIUM
- **Source:** `sonar` / `Kotlin Security Hotspot - Missing idempotency key validation`
- **Description:** Missing idempotency key validation: endpoints de operaciones sensibles deben validar claves de idempotencia para evitar re-ejecuciones.
- **Bad example:**
```kotlin
post("/payments") { processPayment(call.receive()) }
```
- **Good example:**
```kotlin
requireNotNull(call.request.header("Idempotency-Key")); idempotencyStore.checkOrStore(key)
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---

### SONAR_SEC_042
- **Severity:** MEDIUM
- **Source:** `sonar` / `Kotlin Security Hotspot - Missing session inactivity timeout`
- **Description:** Missing session inactivity timeout: expirar sesiones inactivas para reducir ventana de compromiso.
- **Bad example:**
```kotlin
session.maxAge = null
```
- **Good example:**
```kotlin
session.maxAge = 15.minutes.inWholeSeconds.toInt()
```
- **References:**
  - https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/languages/kotlin/

---
