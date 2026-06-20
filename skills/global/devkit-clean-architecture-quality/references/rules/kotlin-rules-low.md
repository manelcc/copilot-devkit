# Copilot Guidelines: Android (Kotlin) — LOW

---

Total rules: **20**

## Nomenclatura

### STYLE_001
- **Severity:** LOW
- **Description:** Las variables y funciones deben usar la convención de nomenclatura `camelCase`.
- **Conditions:** language: kotlin, pattern: ^[A-Z][a-zA-Z0-9]*$
- **Action:** Sugerir renombrar variable/función a `camelCase`.
- **Bad example:**
```
val MyVariable = 10
```
- **Good example:**
```
val myVariable = 10
```
- **References:**
  - https://medium.com/@niklas.nilsson/kotlin-coding-conventions-best-practices-2024-guide-31e9766d03d3
  - https://medium.com/@farimarwat/clean-coding-in-kotlin-a-practical-guide-to-best-practices-2-0-a403d6d06173

### STYLE_002
- **Severity:** LOW
- **Description:** Las clases deben usar la convención de nomenclatura `PascalCase`.
- **Conditions:** language: kotlin, pattern: ^[a-z][a-zA-Z0-9]*$
- **Action:** Sugerir renombrar clase a `PascalCase`.
- **Bad example:**
```
class userManager
```
- **Good example:**
```
class UserManager
```
- **References:**
  - https://medium.com/@niklas.nilsson/kotlin-coding-conventions-best-practices-2024-guide-31e9766d03d3
  - https://medium.com/@farimarwat/clean-coding-in-kotlin-a-practical-guide-to-best-practices-2-0-a403d6d06173

### STYLE_003
- **Severity:** LOW
- **Description:** Las constantes deben usar la convención de nomenclatura `UPPERCASE` con guiones bajos.
- **Conditions:** language: kotlin, pattern: .*[a-z].*
- **Action:** Sugerir renombrar constante a `UPPERCASE_SNAKE_CASE`.
- **Bad example:**
```
const val MaxCount = 10
```
- **Good example:**
```
const val MAX_COUNT = 10
```
- **References:**
  - https://medium.com/@niklas.nilsson/kotlin-coding-conventions-best-practices-2024-guide-31e9766d03d3
  - https://medium.com/@farimarwat/clean-coding-in-kotlin-a-practical-guide-to-best-practices-2-0-a403d6d06173

### STYLE_004
- **Severity:** LOW
- **Description:** Los nombres de implementación de interfaces deben ser significativos, usando el prefijo `Default` si no se encuentra un nombre mejor, y `Fake` para implementaciones simuladas.
- **Conditions:** language: kotlin
- **Action:** Asegurar que las implementaciones de interfaces sigan el patrón `[Qualifier]InterfaceNameImpl`.
- **Bad example:**
```
class NewsRepositoryImpl
```
- **Good example:**
```
class OfflineFirstNewsRepository o class FakeNewsRepository
```
- **References:**
  - https://medium.com/@niklas.nilsson/kotlin-coding-conventions-best-practices-2024-guide-31e9766d03d3
  - https://medium.com/@naeem0313/unit-testing-in-android-kotlin-with-mockk-and-coroutines-test-68853610e7b9

### STYLE_005
- **Severity:** LOW
- **Description:** La convención para nombrar Flows, LiveData o streams debe ser `get{model}Stream()`.
- **Conditions:** language: kotlin, framework: Flow/LiveData
- **Action:** Seguir la convención `get{model}Stream()` o `get{model}sStream()` si devuelve una lista.
- **Bad example:**
```
val user: Flow<User>
```
- **Good example:**
```
fun getUserStream(): Flow<User>
```
- **References:**
  - https://medium.com/@niklas.nilsson/kotlin-coding-conventions-best-practices-2024-guide-31e9766d03d3
  - https://medium.com/@farimarwat/clean-coding-in-kotlin-a-practical-guide-to-best-practices-2-0-a403d6d06173

---

## Calidad/Kotlin

### NULL_001
- **Severity:** LOW
- **Description:** Utilizar completamente el sistema de seguridad contra nulos de Kotlin, empleando el operador de llamada segura (`?.`) y el operador Elvis (`?:`) para manejar tipos anulables (`String?`).
- **Conditions:** language: kotlin
- **Action:** Evitar el operador de aserción no nula (`!!`) siempre que sea posible para prevenir `NullPointerException`.
- **Bad example:**
```
val name = user!!.name
```
- **Good example:**
```
val name = user?.name ?: 'Unknown'
```
- **References:**
  - https://medium.com/@niklas.nilsson/kotlin-null-safety-mastering-the-nitty-gritty-e78d91f8c148
  - https://medium.com/@farimarwat/clean-coding-in-kotlin-a-practical-guide-to-best-practices-2-0-a403d6d06173

### CODE_001
- **Severity:** LOW
- **Description:** Evitar métodos o funciones que excedan el umbral de longitud (ej: >140 líneas) para mantener la legibilidad y reducir la complejidad.
- **Conditions:** language: kotlin, tool: Detekt
- **Action:** Refactorizar funciones largas en funciones más pequeñas y cohesivas.
- **Bad example:**
```
Función de 200 líneas que maneja 5 responsabilidades.
```
- **Good example:**
```
Delegar lógica secundaria a funciones privadas separadas.
```
- **References:**
  - https://medium.com/@farimarwat/clean-coding-in-kotlin-a-practical-guide-to-best-practices-2-0-a403d6d06173
  - https://medium.com/@niklas.nilsson/kotlin-coding-conventions-best-practices-2024-guide-31e9766d03d3

---

## Accesibilidad

### UI_005
- **Severity:** LOW
- **Description:** Incluir el parámetro `contentDescription` en elementos de Compose como `Icon` o `Image` para mejorar la accesibilidad de los usuarios de lectores de pantalla.
- **Conditions:** language: kotlin, framework: Compose
- **Action:** Asegurar que todos los elementos visuales interactivos o informativos tengan una descripción de contenido.
- **Bad example:**
```
Icon(painter = ..., contentDescription = null)
```
- **Good example:**
```
Icon(painter = ..., contentDescription = 'Favorite icon')
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_006
- **Severity:** LOW
- **Description:** Los elementos táctiles o clicables deben tener un tamaño mínimo de 48dp por 48dp para mejorar la usabilidad y la accesibilidad.
- **Conditions:** language: kotlin, framework: Compose
- **Action:** Asegurar que los botones, iconos clicables y otros objetivos táctiles cumplan con el umbral de tamaño.
- **Bad example:**
```
IconButton(modifier = Modifier.size(24.dp))
```
- **Good example:**
```
IconButton(modifier = Modifier.size(48.dp))
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_006
- **Severity:** LOW
- **Description:** Los elementos táctiles o clicables deben tener un tamaño mínimo de 48dp por 48dp para mejorar la usabilidad y la accesibilidad [1, 2].
- **Conditions:** language: kotlin, framework: Compose
- **Action:** Asegurar que los botones, iconos clicables y otros objetivos táctiles cumplan con el umbral de tamaño [1, 2].
- **Bad example:**
```
IconButton(modifier = Modifier.size(24.dp))
```
- **Good example:**
```
IconButton(modifier = Modifier.size(48.dp))
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### ACC_001
- **Severity:** LOW
- **Description:** Los elementos gráficos interactivos (Icon, Image) deben incluir una `contentDescription` clara para la accesibilidad (TalkBack) [1].
- **Conditions:** language: kotlin, framework: Compose, A11y
- **Action:** Asegurar la presencia del argumento `contentDescription` con una descripción significativa [1].
- **Bad example:**
```
Icon(imageVector = Icons.Default.Menu, contentDescription = null)
```
- **Good example:**
```
Icon(..., contentDescription = stringResource(R.string.menu_button))
```
- **References:**
  - https://medium.com/simform-engineering/android-accessibility-and-talkback-6a79fde05b54
  - https://medium.com/@iamkiruba43/unlocking-android-accessibility-service-the-hidden-superpower-in-your-phone-8763831248f5

### A11Y_003
- **Severity:** LOW
- **Description:** El `merge` de descendientes debe definirse correctamente (ej. usando el modificador `clickable`) para garantizar que TalkBack anuncie el componente como una unidad lógica única [96].
- **Conditions:** language: kotlin, framework: Compose
- **Action:** Asegurar el uso de modificadores apropiados para controlar cómo los elementos de la IU son vistos por los servicios de accesibilidad [96].
- **Bad example:**
```
Row { Icon(); Text() }
```
- **Good example:**
```
Row(modifier = Modifier.clickable { onClick() }) { Icon(); Text() }
```
- **References:**
  - https://medium.com/simform-engineering/android-accessibility-and-talkback-6a79fde05b54
  - https://medium.com/@iamkiruba43/unlocking-android-accessibility-service-the-hidden-superpower-in-your-phone-8763831248f5

---

## Modularización

### MOD_001
- **Severity:** LOW
- **Description:** Usar la modularización para mejorar la velocidad de compilación mediante el almacenamiento en caché de Gradle, dividiendo el código por capas o características.
- **Conditions:** language: all
- **Action:** Estructurar la aplicación en módulos como `:domain`, `:data-repository`, `:feature:chat`.
- **Bad example:**
```
Monolito donde todos los archivos residen en el módulo `:app`.
```
- **Good example:**
```
Estructura con `:app`, `:domain`, `:data`, `:feature:home`.
```
- **References:**
  - https://medium.com/@farimarwat/modular-architecture-in-kotlin-android-a-complete-guide-82c82f9d33a6
  - https://medium.com/@haroldadmin/the-principles-of-package-design-in-android-2024-f7a63740e53a

---

## Estilo/Idomático

### KOTLIN_004
- **Severity:** LOW
- **Description:** Para el manejo seguro de nulos, se debe usar el operador de llamada segura (`?.`) y el operador Elvis (`?:`) en lugar de verificaciones `if (x != null)` explícitas [44].
- **Conditions:** language: kotlin
- **Action:** Simplificar las comprobaciones de nulos a una sintaxis idiomática [44].
- **Bad example:**
```
if (user != null) { return user.name } else { return "" }
```
- **Good example:**
```
return user?.name ?: ""
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

### KOTLIN_007
- **Severity:** LOW
- **Description:** Las funciones que exponen una secuencia de `Flow` deben seguir la convención de nombres `get{model}Stream()` o `getAuthorsStream()` [5, 6].
- **Conditions:** language: kotlin
- **Action:** Usar la convención `Stream` para indicar un flujo de datos continuo [5, 6].
- **Bad example:**
```
fun getAuthors(): Flow<List<Author>>
```
- **Good example:**
```
fun getAuthorsStream(): Flow<List<Author>>
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

### KOTLIN_008
- **Severity:** LOW
- **Description:** Los nombres de las funciones de prueba deben ser claros y descriptivos, siguiendo la convención `given_condition_when_action_then_result` [60].
- **Conditions:** language: kotlin, framework: Testing
- **Action:** Asegurar que el nombre del test describa el escenario cubierto de manera concisa [60].
- **Bad example:**
```
testViewModel()
```
- **Good example:**
```
givenUserNotLoggedIn_whenLoadingNews_thenEmitAuthenticationError()
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

### KOTLIN_013
- **Severity:** LOW
- **Description:** El código debe adherirse a las convenciones de codificación de Kotlin (ej. `camelCase` para variables/funciones, `PascalCase` para clases) [44].
- **Conditions:** language: kotlin
- **Action:** Usar herramientas de linteo para hacer cumplir las convenciones de nomenclatura estándar [44].
- **Bad example:**
```
fun Get_User_Name()
```
- **Good example:**
```
fun getUserName()
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

### KOTLIN_014
- **Severity:** LOW
- **Description:** Evitar el encadenamiento excesivo de funciones de alcance (`let`, `run`, `apply`, `also`) si compromete la legibilidad [44].
- **Conditions:** language: kotlin
- **Action:** Simplificar el encadenamiento de funciones de alcance si excede dos o tres llamadas consecutivas [44].
- **Bad example:**
```
user?.let { it.apply { ... }.run { ... } }
```
- **Good example:**
```
user?.let { user -> user.apply { ... } }
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

### KOTLIN_017
- **Severity:** LOW
- **Description:** Las funciones o métodos que exceden un umbral de longitud (ej. >140 líneas) deben ser refactorizados para aumentar la legibilidad y reducir la complejidad (`LongMethod` issue) [1].
- **Conditions:** language: kotlin
- **Action:** Dividir la lógica interna en funciones privadas más pequeñas que tengan una única responsabilidad [1].
- **Bad example:**
```
fun processUserInteraction() (300 líneas)
```
- **Good example:**
```
fun processUserInteraction() (delega a 5 funciones internas de 30 líneas).
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

---

## Red

### NETWORK_005
- **Severity:** LOW
- **Description:** Se recomienda usar `Chucker` para la depuración de red en *debug builds*, ya que proporciona una interfaz de usuario clara para inspeccionar solicitudes y respuestas HTTP/HTTPS [171, 172].
- **Conditions:** language: kotlin, framework: Debugging
- **Action:** Asegurar que `Chucker` se añada solo a `debugImplementation` para aislarlo de las compilaciones de lanzamiento [173].
- **Bad example:**
```
Usar Logcat manualmente para debuggear HTTP
```
- **Good example:**
```
debugImplementation("com.github.chuckerteam.chucker:library:3.5.2")\\n\\nval client = OkHttpClient.Builder()\\n    .addInterceptor(ChuckerInterceptor(context))\\n    .build()
```
- **References:**
  - https://medium.com/@za7922997/mastering-networking-web-services-in-android-development-retrofit-rest-apis-json-services-c8201f8771bb
  - https://devharshmittal.medium.com/why-retrofit-3-0-0-matters-even-if-2-9-0-still-works-77d7bd817061
