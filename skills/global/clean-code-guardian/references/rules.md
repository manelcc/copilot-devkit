# Clean Code Guardian — Catálogo de Reglas Kotlin

## CC-01 — Clase ≤ 500 líneas

**Límite:** 500 líneas por fichero `.kt` (incluyendo comentarios y líneas en blanco).

**Por qué:** Las clases grandes suelen tener múltiples responsabilidades. Si supera 500 líneas es una señal de que debe dividirse.

**Mal:**
```kotlin
// UserManager.kt — 800 líneas con lógica de auth, perfil, preferencias y red
class UserManager(
    private val api: UserApi,
    private val db: UserDatabase,
    private val prefs: SharedPreferences
) {
    fun login(email: String, password: String): Result<User> { ... }
    fun updateProfile(user: User) { ... }
    fun savePreferences(prefs: UserPreferences) { ... }
    fun fetchRemoteData(): List<User> { ... }
    // ... 750 líneas más
}
```

**Bien:**
```kotlin
// AuthRepository.kt (~100 líneas)
class AuthRepository(private val api: UserApi) {
    fun login(email: String, password: String): Result<User> { ... }
}

// UserProfileRepository.kt (~120 líneas)
class UserProfileRepository(private val db: UserDatabase) {
    fun updateProfile(user: User) { ... }
}

// UserPreferencesRepository.kt (~80 líneas)
class UserPreferencesRepository(private val prefs: SharedPreferences) {
    fun savePreferences(prefs: UserPreferences) { ... }
}
```

---

## CC-02 — Función ≤ 30 líneas

**Límite:** 30 líneas por función o método (sin contar la firma).

**Por qué:** Las funciones largas mezclan niveles de abstracción y son difíciles de testear.

**Mal:**
```kotlin
fun processOrder(order: Order): OrderResult {
    // Validación — 10 líneas
    if (order.items.isEmpty()) return OrderResult.Error("Empty order")
    if (order.customerId == null) return OrderResult.Error("No customer")
    val customer = customerRepo.find(order.customerId)
        ?: return OrderResult.Error("Customer not found")

    // Cálculo de precio — 15 líneas
    var total = 0.0
    for (item in order.items) {
        val product = productRepo.find(item.productId) ?: continue
        val price = if (customer.isPremium) product.price * 0.9 else product.price
        total += price * item.quantity
    }

    // Persistencia — 10 líneas
    val savedOrder = orderRepo.save(order.copy(total = total))
    notificationService.notify(customer, savedOrder)
    analyticsService.track("order_placed", mapOf("total" to total))
    return OrderResult.Success(savedOrder)
}
```

**Bien:**
```kotlin
fun processOrder(order: Order): OrderResult {
    val customer = validateOrder(order) ?: return OrderResult.Error("Invalid order")
    val total = calculateTotal(order.items, customer)
    return persistAndNotify(order, customer, total)
}

private fun validateOrder(order: Order): Customer? { ... }       // ≤ 12 líneas
private fun calculateTotal(items: List<OrderItem>, customer: Customer): Double { ... }  // ≤ 12 líneas
private fun persistAndNotify(order: Order, customer: Customer, total: Double): OrderResult { ... }  // ≤ 10 líneas
```

---

## CC-03 — SRP: una sola responsabilidad por clase

**Principio:** Una clase debe tener una única razón para cambiar.

**Señales de violación:**
- El nombre de la clase usa "And", "Manager", "Helper", "Util" genérico.
- La clase importa más de 3 dominios diferentes (e.g., red + BD + UI).
- Los métodos públicos pertenecen a más de un caso de uso distinto.

**Mal:**
```kotlin
// Hace autenticación Y envía emails Y gestiona sesiones
class UserAuthAndEmailManager {
    fun login(email: String, password: String): User { ... }
    fun sendWelcomeEmail(user: User) { ... }
    fun sendPasswordResetEmail(email: String) { ... }
    fun expireSession(userId: String) { ... }
    fun refreshToken(token: String): String { ... }
}
```

**Bien:**
```kotlin
class AuthenticationService {
    fun login(email: String, password: String): User { ... }
    fun refreshToken(token: String): String { ... }
}

class SessionManager {
    fun expireSession(userId: String) { ... }
}

class UserEmailNotifier {
    fun sendWelcomeEmail(user: User) { ... }
    fun sendPasswordResetEmail(email: String) { ... }
}
```

---

## CC-04 — Sin magic numbers

**Regla:** Los literales numéricos fuera de `const val` están prohibidos salvo `0`, `1` y `-1` en contextos idiomáticos.

**Mal:**
```kotlin
fun isSessionExpired(createdAt: Long): Boolean {
    return System.currentTimeMillis() - createdAt > 3600000
}

fun paginate(items: List<Item>): List<List<Item>> {
    return items.chunked(25)
}
```

**Bien:**
```kotlin
private const val SESSION_TIMEOUT_MS = 3_600_000L   // 1 hora
private const val PAGE_SIZE = 25

fun isSessionExpired(createdAt: Long): Boolean {
    return System.currentTimeMillis() - createdAt > SESSION_TIMEOUT_MS
}

fun paginate(items: List<Item>): List<List<Item>> {
    return items.chunked(PAGE_SIZE)
}
```

**Dónde colocar las constantes:**
- En el `companion object` si son privadas a la clase.
- En un fichero `Constants.kt` o `<Dominio>Config.kt` si son compartidas.

---

## CC-05 — Nombres descriptivos

**Regla:** Los nombres deben expresar la intención sin necesidad de comentario.

**Criterios:**
- Mínimo 3 caracteres (excepto índices de bucle `i`, `j`, `k` en bucles cortos).
- Sin abreviaturas crípticas: `mgr`, `tmp`, `ctx` (usar `manager`, `temporary`, `context`).
- Verbos para funciones (`calculateTotal`, `fetchUser`, `validateInput`).
- Sustantivos para clases (`OrderRepository`, `UserProfile`, `SessionToken`).
- Evitar prefijos genéricos: `data`, `info`, `stuff`, `object`.

**Mal:**
```kotlin
val d = Date()
val mgr = UserManager()
fun proc(u: User): Boolean { ... }
class DataHelper { ... }
```

**Bien:**
```kotlin
val creationDate = Date()
val userManager = UserManager()
fun isUserActive(user: User): Boolean { ... }
class UserActivityValidator { ... }
```

---

## CC-06 — Anidamiento máximo 3 niveles

**Regla:** El código no debe tener más de 3 niveles de indentación anidada.

**Señales de violación:**
- Bloques `if` dentro de `for` dentro de `when` dentro de `try`.
- Callbacks anidados (en código legacy o callbacks de red).

**Mal:**
```kotlin
fun processUsers(users: List<User>) {
    for (user in users) {              // nivel 1
        if (user.isActive) {           // nivel 2
            for (role in user.roles) { // nivel 3
                if (role.isAdmin) {    // nivel 4 ❌
                    grantAccess(user)
                }
            }
        }
    }
}
```

**Bien — Guard Clause + función extraída:**
```kotlin
fun processUsers(users: List<User>) {
    users.filter { it.isActive }.forEach { processActiveUser(it) }
}

private fun processActiveUser(user: User) {
    user.roles
        .filter { it.isAdmin }
        .forEach { grantAccess(user) }
}
```

**Técnicas para reducir anidamiento:**
1. **Guard Clause (early return):** retornar pronto si la condición no se cumple.
2. **Extract Function:** mover el bloque anidado a una función privada.
3. **Functional operators:** `filter`, `map`, `forEach` en lugar de bucles anidados.
4. **`when` en lugar de `if-else if-else if`**.

---

## CC-07 — Máximo 4 parámetros por función

**Regla:** Las funciones con más de 4 parámetros son difíciles de leer y suelen indicar que falta una abstracción.

**Mal:**
```kotlin
fun createUser(
    name: String,
    email: String,
    password: String,
    role: String,
    isActive: Boolean,
    createdAt: Long
): User { ... }
```

**Bien — Data class como parámetro:**
```kotlin
data class CreateUserRequest(
    val name: String,
    val email: String,
    val password: String,
    val role: String,
    val isActive: Boolean = true,
    val createdAt: Long = System.currentTimeMillis()
)

fun createUser(request: CreateUserRequest): User { ... }
```

---

## Resumen rápido de reglas

| ID | Regla | Límite | Técnica de corrección |
|---|---|---|---|
| CC-01 | Líneas por clase | ≤ 500 | Extraer clase (SRP) |
| CC-02 | Líneas por función | ≤ 30 | Extract Function |
| CC-03 | SRP | 1 responsabilidad | Separar en clases por dominio |
| CC-04 | Magic numbers | 0 | `const val` con nombre descriptivo |
| CC-05 | Nombres descriptivos | ≥ 3 chars, sin abreviaturas | Renombrar con intención clara |
| CC-06 | Anidamiento | ≤ 3 niveles | Guard Clause / Extract Function |
| CC-07 | Parámetros por función | ≤ 4 | Data class / Builder |
