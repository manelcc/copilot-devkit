---
name: devkit-ktor-auth-flow
description: >
    Fuente de verdad del sistema de autenticación para middleware Ktor: Argon2id password hashing,
  JWT dual (access 50min + refresh 30d con rotación y detección de reutilización), endpoints REST
  /auth/login|guest|refresh|logout y convenciones Koin DI. Usar cuando se toque auth, JWT, contraseñas,
  roles o sesiones en el middleware Ktor.
applyTo:
  - "src/**/*.kt"
triggers:
    - "auth flow"
    - "jwt"
    - "refresh token"
    - "login endpoint"
    - "ktor authentication"
non_triggers:
    - "perfil de usuario"
    - "integración hmac entre servicios"
    - "lógica de recetas"
---

# devkit-ktor-auth-flow

Fuente de verdad del sistema de autenticación implementado en middleware Ktor.
Aplica cuando el usuario toca JWT, login, contraseñas, roles, sesiones o cualquier endpoint bajo `/auth`.

## Cuándo usar esta skill

**Triggers:**
- Añadir o modificar endpoints bajo `/auth`
- Trabajar con JWT, claims, `JwtPrincipal`, `TokenService`, `PasswordService`
- Implementar rutas protegidas con `authenticate("bearer")`
- Tocar `refresh_tokens`, rotación de tokens, detección de reutilización
- Preguntar por roles (`USER`, `GUEST`, `PREMIUM`), permisos o quota
- Añadir nuevos use cases de auth (`LoginUseCase`, `GuestUserUseCase`, etc.)

**No triggers:**
- Endpoints de dominio no relacionados con autenticación
- Perfil de usuario (usar la skill de user-profile del proyecto)
- Auth entre servicios internos HMAC (usar la skill de contrato webscraping/HMAC del proyecto)

---

## Arquitectura de autenticación

```
POST /auth/login
POST /auth/guest
POST /auth/refresh       ─────►  TokenService (Koin single)
POST /auth/logout                      │
                                       ▼
                               refresh_tokens (BD)
                               + JWT HS256 (in-memory)
```

### Stack

| Componente | Implementación |
|---|---|
| Hash de contraseñas | Argon2id via Bouncy Castle |
| JWT | `com.auth0:java-jwt`, algoritmo HS256 |
| Serializacion | `kotlinx.serialization` |
| DI | Koin (`domainModule`) |
| Framework HTTP | Ktor `Authentication` plugin (`bearer`) |

---

## Contraseñas — Argon2id

### Value Objects

```kotlin
// PlainPassword — solo existe en memoria, no se serializa
// Requisitos: min 12 chars, mayúsculas, minúsculas, números, símbolos
data class PlainPassword(val value: String)

// HashedPassword — formato Argon2id
// $argon2id$v=19$m=65536,t=3,p=2$<salt>$<hash>
data class HashedPassword(val value: String)
```

**Parámetros Argon2id**: memoria=64MB (`m=65536`), iteraciones=3 (`t=3`), paralelismo=2 (`p=2`).

### PasswordService

```kotlin
interface PasswordService {
    suspend fun hash(plainPassword: PlainPassword): HashedPassword
    suspend fun verify(plainPassword: PlainPassword, hashedPassword: HashedPassword): Boolean
}
```

### Excepciones

```kotlin
WeakPasswordException          // contraseña no cumple requisitos
PasswordVerificationException  // error durante verificación
```

---

## JWT — Token Strategy

### Access Token (JWT HS256)

- Duración: **50 minutos** (3000 segundos)
- Header: `Authorization: Bearer <token>`
- Sin consulta a BD en cada request — stateless

```json
{
  "sub": "user@example.com",
  "id": 123,
  "roles": ["USER"],
  "iat": 1708114400,
  "exp": 1708117400
}
```

### Refresh Token (Opaque)

- Duración: **30 días**
- Tipo: string hexadecimal aleatorio
- Almacenado en BD: tabla `refresh_tokens` (hash SHA256)
- Rotación automática en cada `/auth/refresh`
- **Detección de reutilización**: si un token ya usado vuelve a llegar → revocación inmediata de todas las sesiones del usuario

```
Table: refresh_tokens
├── id: UUID (PK)
├── user_id: Long (FK → users)
├── token_hash: String (SHA256)
├── expires_at: OffsetDateTime
├── is_revoked: Boolean
├── revocation_reason: String?
├── reuse_detected: Boolean
├── created_at / updated_at: OffsetDateTime
```

### TokenService

```kotlin
interface TokenService {
    suspend fun generateTokenPair(userId: Long, email: String, roles: Set<UserRole>): TokenPair
    suspend fun refreshAccessToken(refreshToken: String): TokenPair
    suspend fun revokeRefreshToken(refreshToken: String): Boolean
    fun validateAndDecodeAccessToken(token: String): JwtPayload?
}

data class TokenPair(
    val accessToken: String,
    val refreshToken: String,
    val expiresIn: Int = 3000,
    val tokenType: String = "Bearer"
)
```

---

## Plugin Ktor — autenticación Bearer

```kotlin
install(Authentication) {
    bearer("bearer") {
        authenticate { token ->
            val payload = tokenService.validateAndDecodeAccessToken(token.token)
            if (payload != null) JwtPrincipal(payload) else null
        }
    }
}
```

**Extracción de claims en handlers:**

```kotlin
authenticate("bearer") {
    get("/protected") {
        val principal = call.principal<JwtPrincipal>()
        val userId = principal?.payload?.userId
        val roles  = principal?.payload?.roles
    }
}
```

---

## Endpoints REST — `/auth`

Ubicación: `src/main/kotlin/.../api/routes/AuthRoutes.kt`

| Método | Endpoint | Use Case | Request | Response |
|---|---|---|---|---|
| POST | `/auth/login` | `LoginUseCase` | `LoginRequest(email, password)` | `LoginResponse` |
| POST | `/auth/guest` | `GuestUserUseCase` | `GuestRequest()` | `GuestResponse(guestId, ...)` |
| POST | `/auth/refresh` | `RefreshTokenUseCase` | `RefreshRequest(refreshToken)` | `RefreshResponse` |
| POST | `/auth/logout` | `LogoutUseCase` | `LogoutRequest(refreshToken)` | `LogoutResponse` |

**Guest flow**: genera email técnico único `guest_<UUID>@example.local`, crea usuario con rol `GUEST`, devuelve `TokenPair`.

---

## Use Cases — firma y excepciones

```kotlin
// LoginUseCase
suspend fun invoke(email: String, password: String): TokenPair
// throws: UserNotFoundException, InvalidCredentialsException

// GuestUserUseCase
suspend fun invoke(): TokenPair
// throws: UserCreationException

// RefreshTokenUseCase
suspend fun invoke(refreshToken: String): TokenPair
// throws: InvalidTokenException, ExpiredTokenException, RevokedTokenException

// LogoutUseCase
suspend fun invoke(refreshToken: String): Unit
suspend fun logoutAllSessions(userId: Long): Int
```

Ubicación: `src/main/kotlin/.../application/usecase/auth/`

---

## DI — Koin

```kotlin
// KoinModules.kt — domainModule
single { LoginUseCase(get(), get(), get()) }
single { GuestUserUseCase(get(), get()) }
single { RefreshTokenUseCase(get()) }
single { LogoutUseCase(get(), get()) }
```

---

## Manejo de excepciones → HTTP

El plugin `ErrorHandling` mapea automáticamente:

| Excepción | HTTP |
|---|---|
| `InvalidCredentialsException` | 401 |
| `UserNotFoundException` | 404 |
| `InvalidTokenException` | 401 |
| `ExpiredTokenException` | 401 |
| `RevokedTokenException` | 401 |
| `WeakPasswordException` | 400 |

---

## Roles de usuario

| Rol | Descripción | Quota diaria |
|---|---|---|
| `GUEST` | Invitado sin cuenta permanente | Limitada |
| `USER` | Registrado gratuito | 10 recetas/día |
| `PREMIUM` | Suscriptor premium | 50 recetas/día |

---

## Convenciones de testing

- Framework: **Kotest FreeSpec** (evita incompatibilidades con `suspend`)
- 4 tests mínimos por use case: happy path + excepciones
- No usar `@Test` de JUnit5 en use cases async

```kotlin
class LoginUseCaseTest : FreeSpec({
    "given valid credentials" - {
        "should return TokenPair" { ... }
    }
    "given wrong password" - {
        "should throw InvalidCredentialsException" { ... }
    }
})
```

---

## Guardrails

- **No almacenar contraseñas en texto plano** — siempre `PasswordService.hash()`
- **No exponer `HashedPassword` en DTOs de respuesta**
- **No reducir parámetros Argon2id** sin RFC aprobado
- **No cambiar duración de tokens** sin revisar impacto en cliente móvil
- JWT secret debe venir de variable de entorno `JWT_SECRET` — nunca hardcodeado

## Purpose
Provide reusable guidance for this backend Kotlin/Ktor capability.

## When to use
- Use this skill when the request matches this skill domain.

## When NOT to use
- Do not use this skill for unrelated domains.

## Inputs
- Current repository context
- User requirement and expected outcome

## Steps
1. Identify the scope and impacted files.
2. Apply the recommended implementation pattern.
3. Validate with project checks and conventions.

## Expected outputs
- Updated files aligned with this skill guidelines.

## Validation
- Skill structure and frontmatter are valid.
- Changes are consistent with repository standards.

## Examples
- Example request: "apply this skill workflow to implement the requested change".
