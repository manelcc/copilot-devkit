# Copilot Guidelines: Android (Kotlin) — MEDIUM

---

Total rules: **83**

## Capas de Datos

### DATA_002
- **Severity:** MEDIUM
- **Description:** Los datos expuestos por la capa de datos deben ser **inmutables** para evitar la manipulación externa y garantizar la seguridad de subprocesos (Thread-safe).
- **Conditions:** language: kotlin
- **Action:** Utilizar `data class` sin `var` para los modelos de dominio y usar colecciones inmutables (`List`, en lugar de `MutableList`).
- **Bad example:**
```
data class User(var name: String)
```
- **Good example:**
```
data class User(val name: String)
```
- **References:**
  - https://medium.com/@niklas.nilsson/kotlin-immutability-and-data-classes-a-deep-dive-into-thread-safe-programming-3a72669e4f3a
  - https://medium.com/@yohanes-sutrisno/kotlin-data-class-and-immutability-a-deep-dive-b5e1553c483a

### DATA_003
- **Severity:** MEDIUM
- **Description:** En aplicaciones complejas, implementar modelos separados para cada capa o componente para adaptar los tipos de datos externos a los tipos internos y reducir la sobrecarga de datos.
- **Conditions:** language: kotlin
- **Action:** El Repositorio debe mapear los modelos de las fuentes de datos (ej: `PostApiModel`, `UserEntity`) a modelos de Dominio/UI (`Post`, `User`).
- **Bad example:**
```
Usar el mismo modelo JSON (`PostApi`) en la base de datos y en la UI.
```
- **Good example:**
```
Crear `PostApiData`, mapear a `Post` (Dominio), que se incluye en `PostUiState` (UI).
```
- **References:**
  - https://medium.com/@naeem0313/android-clean-architecture-fcf69a0bf033
  - https://medium.com/@vivekbansal19/android-viewmodels-best-practices-part-1-35ebec871655

### DATA_004
- **Severity:** MEDIUM
- **Description:** Los Repositorios deben crearse incluso si inicialmente solo contienen una única fuente de datos.
- **Conditions:** language: kotlin
- **Action:** Anticipar la necesidad de escalabilidad o cambiar la fuente de datos. Fusionar responsabilidades de fuente de datos y repositorio solo si la aplicación es muy pequeña.
- **Bad example:**
```
Exponer Flows directamente desde la red sin sincronizar con la base de datos local
```
- **Good example:**
```
fun getArticles(): Flow<List<Article>> = articleDao.getAll()
```
- **References:**
  - https://medium.com/@naeem0313/android-clean-architecture-fcf69a0bf033
  - https://medium.com/@marceloemanoel/android-jetpack-compose-state-management-and-lifecycles-1e6498f3b610

---

## ViewModel

### VM_004
- **Severity:** MEDIUM
- **Description:** Evitar el anti-patrón de enviar eventos únicos (navegación, Snackbar) desde el ViewModel a la UI a través de Canales o Streams transitorios.
- **Conditions:** language: kotlin, framework: Coroutines/Flow
- **Action:** Modelar todos los eventos de ViewModel como **actualizaciones de estado de la UI** para que sean reproducibles tras cambios de configuración y evitar pérdidas.
- **Bad example:**
```
ViewModel.channel.send(NavigateToHomeScreen)
```
- **Good example:**
```
ViewModel expone `uiState.isLoggedIn` y la UI reacciona a ese estado.
```
- **References:**
  - https://medium.com/@debora.deotti/managing-one-time-events-in-android-architecture-a-guide-to-avoiding-common-pitfalls-9226f1c4e16d
  - https://medium.com/androiddevelopers/viewmodel-one-off-events-navigation-95d733989c72

### VM_005
- **Severity:** MEDIUM
- **Description:** El ViewModel debe manejar la **lógica empresarial** (el 'qué hacer'), no la **lógica de la IU/comportamiento** (el 'cómo mostrar', ej: navegación, Toast, Snackbar).
- **Conditions:** language: kotlin, source_type: ViewModel
- **Action:** La lógica de navegación y la presentación de mensajes al usuario deben residir en la capa de UI (Activity/Composable).
- **Bad example:**
```
ViewModel contiene `navController.navigate(...)`.
```
- **Good example:**
```
ViewModel expone un estado que indica la necesidad de navegar, y la UI realiza la navegación.
```
- **References:**
  - https://medium.com/@vivekbansal19/android-viewmodels-best-practices-part-2-4798d3291199
  - https://medium.com/@debora.deotti/mvvm-mvi-a-practical-guide-to-unidirectional-data-flow-in-android-bf4f61390204

### VM_006
- **Severity:** MEDIUM
- **Description:** Usar la clase `ViewModel` estándar de AAC. Evitar `AndroidViewModel` y, en su lugar, mover cualquier dependencia de `Application` o `Context` a la capa de UI o Data.
- **Conditions:** language: kotlin
- **Action:** Reevaluar por qué se necesita `Context` en el ViewModel; si es para acceder a recursos, la UI debe manejarlo.
- **Bad example:**
```
class MyViewModel(app: Application): AndroidViewModel(app)
```
- **Good example:**
```
class MyViewModel(...): ViewModel()
```
- **References:**
  - https://medium.com/@vontonnie/context-in-viewmodel-debate-239485108cfb
  - https://medium.com/@vivekbansal19/android-viewmodels-best-practices-part-1-35ebec871655

### UI_005
- **Severity:** MEDIUM
- **Description:** El ViewModel debe exponer datos a la IU a través de una única propiedad llamada `uiState` (o múltiples si son datos no relacionados) [35, 36].
- **Conditions:** language: kotlin, framework: MVVM, State Flow
- **Action:** Consolidar múltiples `StateFlows` en una única clase de datos `UiState` que puede incluir datos, indicadores de carga y errores [35].
- **Bad example:**
```
val user: StateFlow<User>; val isLoading: StateFlow<Boolean>
```
- **Good example:**
```
val uiState: StateFlow<UserUiState>
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_007
- **Severity:** MEDIUM
- **Description:** Los `ViewModels` deben ser creados y usados a nivel de pantalla (destino de navegación), **no** en piezas de IU reutilizables [37, 38].
- **Conditions:** language: kotlin, framework: MVVM
- **Action:** Usar `ViewModels` solo en `Composable` de nivel de pantalla o destinos de navegación. Para componentes reutilizables, usar clases contenedoras de estado sin formato (`plain state holder classes`) [38, 39].
- **Bad example:**
```
fun ReusableButton(@HiltViewModel viewModel: ButtonViewModel)
```
- **Good example:**
```
fun LoginScreen(viewModel: LoginViewModel = hiltViewModel())
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### VIEWMODEL_001
- **Severity:** MEDIUM
- **Description:** Los `ViewModels` deben ser independientes del ciclo de vida de Android. Se prohíbe pasar `Activity`, `Fragment`, `Context` o `Resources` como dependencia [53, 54].
- **Conditions:** language: kotlin, framework: MVVM
- **Action:** Mover la dependencia del `Context` a la Capa de Datos o de IU si es necesario, o usar `Application Context` de forma inyectada en caso de necesidad absoluta [53, 54].
- **Bad example:**
```
class MyViewModel(private val context: Context)
```
- **Good example:**
```
class MyViewModel(private val repository: MyRepository)
```
- **References:**
  - https://medium.com/@sehajkahlon437/complete-deep-dive-how-viewmodel-works-survives-configuration-changes-17d6c4fcf5d3
  - https://proandroiddev.com/viewmodelscope-internals-a-deep-dive-into-androids-threading-magic-260aa42cd4c1

---

## Compose

### UI_003
- **Severity:** MEDIUM
- **Description:** Evitar pasar instancias de ViewModel a funciones Componibles que no son de nivel de pantalla, ya que esto acopla fuertemente el código y oscurece la Fuente Única de Verdad (SSOT).
- **Conditions:** language: kotlin, framework: Compose
- **Action:** Pasar solo el estado necesario (o el contenedor de estado del elemento de UI) y los callbacks de eventos a los Componibles hijos.
- **Bad example:**
```
Composable(viewModel: MyViewModel)
```
- **Good example:**
```
Composable(state: MyUiState, onAction: () -> Unit)
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_004
- **Severity:** MEDIUM
- **Description:** Evitar la sobrecarga de parámetros al pasar modelos de datos completos a componentes en lugar de solo los datos necesarios (String, Int, etc.).
- **Conditions:** language: kotlin, framework: Compose
- **Action:** Pasar solo las propiedades primitivas o las clases de modelo mínimas necesarias a los Componibles para reducir las recomposiciones innecesarias.
- **Bad example:**
```
Header(news: News)
```
- **Good example:**
```
Header(title: String, subtitle: String)
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_008
- **Severity:** MEDIUM
- **Description:** Para la lógica de la IU de menor duración o en componentes reutilizables, se deben usar **clases contenedoras de estados sin formato** en lugar de `ViewModels` [39, 40].
- **Conditions:** language: kotlin, framework: Compose
- **Action:** Implementar `MyAppState` o similar como una clase sin formato con `remember` [39, 40].
- **Bad example:**
```
Usar un `ViewModel` para gestionar el estado de un grupo de chips.
```
- **Good example:**
```
Usar una clase `ChipGroupState` recordada en el Composable padre.
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_012
- **Severity:** MEDIUM
- **Description:** Usar `rememberSaveable` para preservar el estado de la IU relevante (ej. scroll position, estado de entrada) en los Componibles durante los cambios de configuración y la destrucción del proceso [97, 98].
- **Conditions:** language: kotlin, framework: Compose, State
- **Action:** Delegar a `rememberSaveable` el estado de elementos componibles creados con funciones `remembered` [98].
- **Bad example:**
```
var text by remember { mutableStateOf("") }
```
- **Good example:**
```
var text by rememberSaveable { mutableStateOf("") }
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_014
- **Severity:** MEDIUM
- **Description:** Para contenedores de estado de lógica de IU de menor duración, usar clases sin formato con el mismo ciclo de vida que la IU, instanciadas con `remember` [40].
- **Conditions:** language: kotlin, framework: Compose, State
- **Action:** Usar clases contenedoras de estado sin formato (`NiaAppState` o similar) para la lógica que depende de fuentes de datos con alcance de IU (ej. `Resources`, `NavController`) [100].
- **Bad example:**
```
Usar ViewModel para estado efímero de UI
```
- **Good example:**
```
@Composable fun rememberAppState() = remember { NiaAppState(navController, snackbarHostState) }
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_019
- **Severity:** MEDIUM
- **Description:** Los parámetros en los componentes `@Composable` deben seguir un orden canónico: estado/datos requeridos, lambdas de eventos, y finalmente el `Modifier` [96].
- **Conditions:** language: kotlin, framework: Compose, Style
- **Action:** Asegurar que la firma de la función mantenga esta convención para mejorar la legibilidad [96].
- **Bad example:**
```
fun Button(modifier: Modifier, onClick: () -> Unit, text: String)
```
- **Good example:**
```
fun Button(text: String, onClick: () -> Unit, modifier: Modifier)
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_020
- **Severity:** MEDIUM
- **Description:** Se debe usar el `Modifier` como el primer parámetro de las funciones Composable (por convención de Jetpack Compose) [96].
- **Conditions:** language: kotlin, framework: Compose, Style
- **Action:** Asegurar que todas las funciones Composable reutilizables sigan la convención `fun Component(modifier: Modifier = Modifier, ...)` [96].
- **Bad example:**
```
fun UserAvatar(size: Dp, modifier: Modifier)
```
- **Good example:**
```
fun UserAvatar(modifier: Modifier = Modifier, size: Dp)
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_023
- **Severity:** MEDIUM
- **Description:** El uso de `remember` es obligatorio para cachear resultados de cálculos costosos o el estado que debe persistir a través de recomposiciones (ej. posición de scroll, objetos estables) [33].
- **Conditions:** language: kotlin, framework: Compose, Performance
- **Action:** Identificar cálculos costosos que se repiten con cada recomposición y encapsularlos en `remember` [33].
- **Bad example:**
```
val formattedDate = calculateExpensiveFormat(date)
```
- **Good example:**
```
val formattedDate by remember { derivedStateOf { calculateExpensiveFormat(date) } }
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_024
- **Severity:** MEDIUM
- **Description:** Se requiere documentación `KDoc` clara para todos los componentes `@Composable` reutilizables, explicando su propósito, parámetros de estado y los eventos que emiten [96].
- **Conditions:** language: kotlin, framework: Compose, Documentation
- **Action:** Añadir KDoc que siga las convenciones de Compose para mejorar la mantenibilidad y la incorporación de nuevos desarrolladores [96].
- **Bad example:**
```
@Composable fun UserCard() { ... }
```
- **Good example:**
```
/** Displays a user card with avatar and name. @param user The user to display */
@Composable fun UserCard(user: User, onClick: () -> Unit) { ... }
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_025
- **Severity:** MEDIUM
- **Description:** Se recomienda usar `Layout` canónicos para asegurar la coherencia visual y de interacción en toda la aplicación [106].
- **Conditions:** language: kotlin, framework: Compose, Design
- **Action:** Adherirse a los patrones de diseño de Material Design 3 y a los componentes estándar de Compose [106, 131].
- **Bad example:**
```
Implementar un botón personalizado que no cumpla con los estándares de accesibilidad/tamaño.
```
- **Good example:**
```
Utilizar `Button` o `OutlinedButton` de Material 3 [132].
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

---

## Dominio

### DOMAIN_001
- **Severity:** MEDIUM
- **Description:** Usar la Capa de Dominio (Casos de Uso/Interactores) solo cuando se requiera lógica empresarial compleja o lógica reutilizable en múltiples ViewModels.
- **Conditions:** language: kotlin
- **Action:** Si la lógica es simple o solo se usa en un ViewModel, se puede omitir la capa de Dominio, aunque es recomendada en apps grandes.
- **Bad example:**
```
Crear un UseCase para una simple llamada a un Repositorio (ej. `GetUsersUseCase` que solo llama a `UserRepository.getUsers()`) sin lógica de negocio adicional.
```
- **Good example:**
```
Crear `GetLatestNewsWithAuthorsUseCase` que combina datos de dos repositorios y realiza un mapeo complejo.
```
- **References:**
  - https://medium.com/@ys.yogendra22/mvvm-with-clean-architecture-851262ccd919
  - https://medium.com/@sivavishnu0705/mvvm-coordinator-in-android-building-a-clean-and-scalable-architecture-201cb0a321bf

### DOMAIN_002
- **Severity:** MEDIUM
- **Description:** Nombrar los Casos de Uso con el formato: *verbo en tiempo presente* + *sustantivo/qué (opcional)* + *UseCase*.
- **Conditions:** language: kotlin
- **Action:** Seguir la convención para mejorar la legibilidad y el descubrimiento de la funcionalidad.
- **Bad example:**
```
class DateFormatter
```
- **Good example:**
```
class FormatDateUseCase
```
- **References:**
  - https://medium.com/@ys.yogendra22/mvvm-with-clean-architecture-851262ccd919
  - https://medium.com/@sivavishnu0705/mvvm-coordinator-in-android-building-a-clean-and-scalable-architecture-201cb0a321bf

### DOMAIN_004
- **Severity:** MEDIUM
- **Description:** La capa de Dominio es **opcional**; solo debe usarse si se necesita reutilizar la lógica empresarial en varios ViewModels o si la complejidad es alta [84, 85].
- **Conditions:** language: kotlin, framework: Use Cases
- **Action:** Evaluar si los requisitos justifican la creación de `Use Cases`; en aplicaciones simples, el `ViewModel` puede llamar directamente al `Repository` [84].
- **Bad example:**
```
class GetUserUseCase { fun execute(id: String) = repository.getUser(id) }
```
- **Good example:**
```
Solo usar Use Cases cuando hay lógica compleja o reutilización en múltiples ViewModels
```
- **References:**
  - https://medium.com/@ys.yogendra22/mvvm-with-clean-architecture-851262ccd919
  - https://medium.com/@sivavishnu0705/mvvm-coordinator-in-android-building-a-clean-and-scalable-architecture-201cb0a321bf

### DOMAIN_005
- **Severity:** MEDIUM
- **Description:** Los `Use Cases` en Kotlin deben definirse con la función `invoke()` y el modificador `operator` para ser llamados como funciones [86].
- **Conditions:** language: kotlin, framework: Idiomatic Kotlin
- **Action:** Implementar `operator fun invoke()` en la clase `Use Case` [86].
- **Bad example:**
```
useCase.execute(request)
```
- **Good example:**
```
useCase(request)
```
- **References:**
  - https://medium.com/@ys.yogendra22/mvvm-with-clean-architecture-851262ccd919
  - https://medium.com/@sivavishnu0705/mvvm-coordinator-in-android-building-a-clean-and-scalable-architecture-201cb0a321bf

---

## Pruebas

### TEST_001
- **Severity:** MEDIUM
- **Description:** Utilizar dobles de prueba (simulaciones/fakes) en lugar de las implementaciones reales para la prueba de unidades y las pruebas instrumentadas, especialmente para dependencias volátiles (red, base de datos).
- **Conditions:** language: kotlin
- **Action:** Inyectar implementaciones 'Fake' de Repositorios o Fuentes de Datos durante las pruebas para garantizar resultados deterministas.
- **Bad example:**
```
La prueba unitaria de ViewModel realiza llamadas a la red.
```
- **Good example:**
```
ViewModel se inicializa con `FakeUserRepository`.
```
- **References:**
  - https://medium.com/@naeem0313/unit-testing-in-android-kotlin-with-mockk-and-coroutines-test-68853610e7b9
  - https://medium.com/@supsabhi/testing-kotlin-flows-in-android-a-comprehensive-guide-f8876e938f38

---

## Infraestructura

### BUILD_001
- **Severity:** MEDIUM
- **Description:** Usar el lenguaje Kotlin Gradle DSL (`.kts`) para los archivos Gradle.
- **Conditions:** language: kotlin
- **Action:** Migrar a Kotlin DSL para obtener autocompletado, seguridad de tipos y evitar errores en tiempo de ejecución de Gradle.
- **Bad example:**
```
Archivo `build.gradle` (Groovy)
```
- **Good example:**
```
Archivo `build.gradle.kts` (Kotlin DSL)
```
- **References:**
  - https://medium.com/@vivekbansal19/the-shift-to-kotlin-dsl-gradle-s-modern-approach-to-build-scripts-86f56e9c2017
  - https://medium.com/@haroldadmin/understanding-the-kotlin-gradle-dsl-in-android-2024-e91060cc7247

### BUILD_002
- **Severity:** MEDIUM
- **Description:** Centralizar la gestión de dependencias y versiones utilizando Version Catalogs (archivos `libs.versions.toml`).
- **Conditions:** language: kotlin
- **Action:** Definir todas las versiones de librerías en el catálogo para simplificar actualizaciones y minimizar errores de discrepancia de versiones.
- **Bad example:**
```
Definir la versión de Compose en cada módulo individualmente.
```
- **Good example:**
```
Usar `libs.versions.toml` y referenciar `libs.compose.bom`.
```
- **References:**
  - https://medium.com/@abhisharma.tech/dependency-management-with-gradle-version-catalogs-56b9c782723c
  - https://medium.com/@haroldadmin/understanding-the-kotlin-gradle-dsl-in-android-2024-e91060cc7247

---

## SOLID

### SRP_001
- **Severity:** MEDIUM
- **Description:** Evitar acoplamiento fuerte por violación del Principio de Responsabilidad Única (SRP): un componente debe tener una sola responsabilidad o una única razón para cambiar.
- **Conditions:** language: kotlin, principle: SRP
- **Action:** Delegar responsabilidades a diferentes clases o refactorizar si un cambio en una parte del código afecta a actores no relacionados.
- **Bad example:**
```
ViewModel gestiona fetching de red, persistencia local y estado de UI.
```
- **Good example:**
```
ViewModel usa UseCases/Repositories, los cuales manejan la red/persistencia, liberando al VM para enfocarse en el estado de UI.
```
- **References:**
  - https://medium.com/@farimarwat/solid-principles-in-kotlin-a-practical-guide-6d0016e78873
  - https://medium.com/@scripturesintech/%EF%B8%8F-state-hoisting-in-android-jetpack-compose-how-it-follows-solid-principles-2a76dc13db3c

---

## Componentes

### COMP_001
- **Severity:** MEDIUM
- **Description:** Los módulos deben seguir el Principio de Clausura Común (CCP): agrupar clases en un componente que tengan una sola razón para cambiar, aplicando el SRP a nivel de módulo.
- **Conditions:** language: all, principle: CCP
- **Action:** Asegurar que las clases relacionadas que cambian juntas se agrupen en el mismo módulo.
- **Bad example:**
```
Dividir la implementación de una característica en 5 módulos que siempre se cambian juntos.
```
- **Good example:**
```
Agrupar la lógica de la característica en un solo módulo :feature:name.
```
- **References:**
  - https://medium.com/@haroldadmin/the-principles-of-package-design-in-android-2024-f7a63740e53a
  - https://medium.com/@farimarwat/modular-architecture-in-kotlin-android-a-complete-guide-82c82f9d33a6

---

## Testabilidad

### TEST_004
- **Severity:** MEDIUM
- **Description:** Las implementaciones de interfaces de Repositorio o Fuentes de Datos utilizadas únicamente para pruebas (Mocks/Fakes) deben seguir la convención de nomenclatura, utilizando el prefijo `Fake` [5, 6].
- **Conditions:** language: kotlin, framework: Testing, DI
- **Action:** Renombrar la clase de simulación para que contenga el prefijo `Fake` (ej. `FakeAuthorsRepository`) [5, 6].
- **Bad example:**
```
AuthorsRepositoryImplTest
```
- **Good example:**
```
FakeAuthorsRepository
```
- **References:**
  - https://medium.com/@naeem0313/unit-testing-in-android-kotlin-with-mockk-and-coroutines-test-68853610e7b9
  - https://medium.com/@supsabhi/testing-kotlin-flows-in-android-a-comprehensive-guide-f8876e938f38

### TEST_007
- **Severity:** MEDIUM
- **Description:** Usar `AndroidX Test Orchestrator` para garantizar que cada prueba de instrumentación se ejecute en una aplicación recién instalada, eliminando datos y estados persistentes entre pruebas [61, 62].
- **Conditions:** language: kotlin, framework: Instrumentation Testing
- **Action:** Configurar el `testInstrumentationRunnerArguments` con `clearPackageData: 'true'` y usar la dependencia `androidx.test:orchestrator` [62, 63].
- **Bad example:**
```
No usar orchestrator, las pruebas comparten estado
```
- **Good example:**
```
android { testOptions { execution 'ANDROIDX_TEST_ORCHESTRATOR' }; androidTestUtil 'androidx.test:orchestrator:1.4.2' }}
```
- **References:**
  - https://medium.com/@tojosphine/android-espresso-testing-best-practices-and-patterns-796b165bfef8
  - https://medium.com/@tojosphine/native-android-automation-with-espresso-for-fast-and-stable-tests-bad9ff7108e1

### TEST_010
- **Severity:** MEDIUM
- **Description:** Para usar librerías de mocking (como Mockito) con clases Kotlin no abiertas (`final` por defecto), se debe habilitar el plugin `mock-maker-inline` [65].
- **Conditions:** language: kotlin, framework: Mockito
- **Action:** Crear el archivo `org.mockito.plugins.MockMaker` con el texto `mock-maker-inline` en la carpeta `mockito-extensions` de `test/resources` [65].
- **Bad example:**
```
No configurar mockito para clases Kotlin finales
```
- **Good example:**
```
Crear archivo test/resources/mockito-extensions/org.mockito.plugins.MockMaker con contenido: mock-maker-inline
```
- **References:**
  - https://medium.com/@tojosphine/android-espresso-testing-best-practices-and-patterns-796b165bfef8
  - https://medium.com/@tojosphine/native-android-automation-with-espresso-for-fast-and-stable-tests-bad9ff7108e1

### TEST_011
- **Severity:** MEDIUM
- **Description:** Los nombres de los tests unitarios deben seguir una convención descriptiva clara (ej. `given_when_then`) [60].
- **Conditions:** language: kotlin, framework: Testing
- **Action:** Usar guiones bajos y la estructura Given-When-Then para describir el escenario y el resultado esperado [60].
- **Bad example:**
```
testLoginError()
```
- **Good example:**
```
givenInvalidCredentials_whenLoginClicked_thenEmitAuthError()
```
- **References:**
  - https://medium.com/@tojosphine/android-espresso-testing-best-practices-and-patterns-796b165bfef8
  - https://medium.com/@tojosphine/native-android-automation-with-espresso-for-fast-and-stable-tests-bad9ff7108e1

---

## Capa de Datos

### DATA_001
- **Severity:** MEDIUM
- **Description:** Las clases de Fuentes de Datos no deben nombrarse según los detalles de la implementación (ej. `UserSharedPreferencesDataSource`) para permitir el intercambio de implementaciones [9].
- **Conditions:** language: kotlin, framework: Data Layer
- **Action:** Usar nombres que reflejen el tipo de datos o la ubicación (ej. `UserLocalDataSource`, `UserRemoteDataSource`) [10].
- **Bad example:**
```
NewsRetrofitSource
```
- **Good example:**
```
NewsRemoteDataSource
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### DATA_003
- **Severity:** MEDIUM
- **Description:** La lógica para la persistencia de datos orientada a la empresa (operaciones que deben sobrevivir al cierre del proceso) debe usar `WorkManager` [13, 14].
- **Conditions:** language: kotlin, framework: WorkManager
- **Action:** Asegurar que las operaciones no cancelables estén programadas con `WorkManager` [13].
- **Bad example:**
```
Iniciar una `Coroutine` de larga duración en `viewModelScope` para una tarea empresarial.
```
- **Good example:**
```
Usar `OneTimeWorkRequest` para tareas de carga de archivos.
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### DATA_006
- **Severity:** MEDIUM
- **Description:** El `DataStore` debe usarse para almacenar **conjuntos de datos pequeños** de pares clave-valor (preferencias) sin necesidad de consultas o integridad referencial [20, 21].
- **Conditions:** language: kotlin, framework: DataStore
- **Action:** Revertir el uso de `DataStore` a `Room` si la complejidad de datos o la necesidad de consultas aumenta [20].
- **Bad example:**
```
Almacenar una lista grande de usuarios que requieren búsqueda en `DataStore`.
```
- **Good example:**
```
Almacenar el formato de hora preferido en `DataStore`.
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### DATA_007
- **Severity:** MEDIUM
- **Description:** Las preferencias relacionadas deben almacenarse en el mismo `DataStore` para limitar el alcance de las actualizaciones, ya que las lecturas se exponen como un `Flow` que se emite con cada cambio de valor [22].
- **Conditions:** language: kotlin, framework: DataStore
- **Action:** Crear `DataStore` por ámbito de funcionalidad (ej. `NotificationsDataStore`, `NewsPreferencesDataStore`) [22].
- **Bad example:**
```
Usar un único GeneralPreferencesDataStore para toda la app
```
- **Good example:**
```
val Context.userPrefsDataStore by preferencesDataStore('user')\nval Context.appSettingsDataStore by preferencesDataStore('settings')
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### DATA_011
- **Severity:** MEDIUM
- **Description:** La interacción con fuentes de datos externas debe realizarse a través de **interfaces** para hacer las implementaciones de la API intercambiables en las pruebas y en producción [71, 72].
- **Conditions:** language: kotlin, framework: Abstraction
- **Action:** Definir interfaces (`UserService`) y usar la Inyección de Dependencias para inyectar la implementación concreta (`UserServiceImpl`) [71].
- **Bad example:**
```
class MyRepository(retrofit: Retrofit)
```
- **Good example:**
```
class MyRepository(service: UserService)
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

---

## Concurrencia

### COROUTINE_002
- **Severity:** MEDIUM
- **Description:** Los Datasources deben exponer funciones suspend simples sin `withContext`. Es responsabilidad del Repository o UseCase aplicar `.flowOn(Dispatchers.IO)` para asegurar que las operaciones sean main-safe según Clean Architecture.
- **Conditions:** language: kotlin, framework: Coroutines, layer: Repository
- **Action:** En el Repository, usar `.flowOn(Dispatchers.IO)` para cambiar el contexto de ejecución del Flow. Los Datasources solo deben declarar funciones suspend.
- **Bad example:**
```
// Repository\nfun getUsers(): Flow<List<User>> = datasource.getUsers() // ❌ Sin flowOn
```
- **Good example:**
```
// Repository\nfun getUsers(): Flow<List<User>> = datasource.getUsers().flowOn(Dispatchers.IO) // ✅ Con flowOn
```
- **References:**
  - https://medium.com/@kumarsamy19792/optimizing-android-app-performance-with-kotlin-coroutines-449249f5c676
  - https://medium.com/@zabiirana27/the-coroutine-secret-even-10-year-android-developers-dont-know-02d21c3285c7

### COROUTINE_005
- **Severity:** MEDIUM
- **Description:** Las excepciones no controladas en corrutinas pueden causar fallos. Las llamadas a `suspend fun` deben envolverse en manejo de errores (`try/catch` o `CoroutineExceptionHandler`) [13, 32].
- **Conditions:** language: kotlin, framework: Coroutines
- **Action:** Envolver las llamadas a `suspend fun` que puedan lanzar errores con manejo de excepciones explícito en el `ViewModel` o `Use Case` [32].
- **Bad example:**
```
viewModelScope.launch { repository.fetchData() } sin try-catch.
```
- **Good example:**
```
try { ... } catch (e: Exception) { ... }
```
- **References:**
  - https://medium.com/@kumarsamy19792/optimizing-android-app-performance-with-kotlin-coroutines-449249f5c676
  - https://medium.com/@zabiirana27/the-coroutine-secret-even-10-year-android-developers-dont-know-02d21c3285c7

---

## Estilo/Idomático

### KOTLIN_001
- **Severity:** MEDIUM
- **Description:** Se requiere que todas las clases cuyo propósito principal sea la representación simple de datos (`DTOs`, `Domain Models`, `UI State`) se definan como `data class` [44, 45].
- **Conditions:** language: kotlin
- **Action:** Definir los modelos de datos como `data class` y usar `val` (inmutable) para promover la previsibilidad del estado [44, 45].
- **Bad example:**
```
class User(var name: String, var age: Int)
```
- **Good example:**
```
data class User(val name: String, val age: Int)
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

### KOTLIN_002
- **Severity:** MEDIUM
- **Description:** Se impone una preferencia estricta por `val` sobre `var` (Inmutabilidad por Defecto) [44].
- **Conditions:** language: kotlin
- **Action:** Las variables mutables (`var`) solo deben utilizarse cuando la mutabilidad es esencial y debe justificarse explícitamente [44].
- **Bad example:**
```
private var userName: String = ""
```
- **Good example:**
```
private val userName: String
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

### KOTLIN_003
- **Severity:** MEDIUM
- **Description:** Se recomienda usar `sealed classes` o `sealed interfaces` para representar jerarquías de clases restringidas, especialmente en `UiState` (Loading, Success, Error) [35].
- **Conditions:** language: kotlin
- **Action:** Asegurar que los estados de la IU usen un `sealed class` para un manejo exhaustivo con `when` [35, 46].
- **Bad example:**
```
Usar una jerarquía de clases abstractas o interfaces simples para modelar estados.
```
- **Good example:**
```
sealed class Result { data class Success(...) : Result() }
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

### KOTLIN_009
- **Severity:** MEDIUM
- **Description:** Si una función o constructor tiene un número excesivo de parámetros (umbral recomendado: >8), deben agruparse en una clase de datos [1].
- **Conditions:** language: kotlin
- **Action:** Refactorizar para pasar un objeto en lugar de argumentos individuales [1].
- **Bad example:**
```
fun createUser(name: String, email: String, address: String, city: String, zip: String, ...)
```
- **Good example:**
```
fun createUser(userProfile: UserProfileData)
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

### KOTLIN_011
- **Severity:** MEDIUM
- **Description:** Se debe imponer una preferencia estricta por `val` sobre `var` (Inmutabilidad por Defecto) [44].
- **Conditions:** language: kotlin
- **Action:** Las variables mutables solo deben utilizarse cuando la mutabilidad es esencial y debe justificarse [44].
- **Bad example:**
```
private var counter = 0
```
- **Good example:**
```
private val counter: Int
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

### KOTLIN_012
- **Severity:** MEDIUM
- **Description:** Todas las clases que representan estructuras de datos simples (`DTOs`, `Models`, `UI State`) deben definirse como `data class` [44, 45].
- **Conditions:** language: kotlin
- **Action:** Asegurar que los modelos de datos utilicen `data class` y `val` para promover la inmutabilidad [44, 45].
- **Bad example:**
```
class UserDTO(var id: String, var name: String)
```
- **Good example:**
```
data class UserDTO(val id: String, val name: String)
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

### KOTLIN_016
- **Severity:** MEDIUM
- **Description:** Las funciones o constructores con un número excesivo de parámetros (umbral: >8) deben refactorizarse [1].
- **Conditions:** language: kotlin
- **Action:** Agrupar los parámetros relacionados en una `data class` [1].
- **Bad example:**
```
Constructor con 9+ parámetros.
```
- **Good example:**
```
Constructor con un objeto de configuración (`Configuration`) [32].
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

---

## Estilo/Herramientas

### KOTLIN_005
- **Severity:** MEDIUM
- **Description:** Se deben usar herramientas de análisis estático como `Ktlint` y `Detekt` para formatear, lintear y detectar `code smells` [47].
- **Conditions:** language: kotlin
- **Action:** Asegurar que el proyecto tenga configuraciones de Gradle para ejecutar análisis estático antes de la revisión humana [47].
- **Bad example:**
```
Confiar solo en la revisión manual para la calidad del código.
```
- **Good example:**
```
Implementación de la tarea `check` de Gradle para Detekt y Ktlint.
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

---

## Manejo Errores

### ERROR_004
- **Severity:** MEDIUM
- **Description:** La capa de datos debe exponer errores específicos mediante **excepciones personalizadas** (ej., `UserNotAuthenticatedException`) [49].
- **Conditions:** language: kotlin, framework: Error Handling
- **Action:** Definir y utilizar clases de excepción que reflejen el error específico de la aplicación o dominio en lugar de lanzar excepciones genéricas [49, 50].
- **Bad example:**
```
Lanzar `IOException` para un error de lógica de negocio.
```
- **Good example:**
```
Lanzar `UseCaseException.UserNotFound`.
```
- **References:**
  - https://medium.com/@yoonjoynow/%EC%BD%94%ED%8B%80%EB%A6%B0%EC%97%90%EC%84%9C-%ED%83%80%EC%9E%85%EC%9C%BC%EB%A1%9C-%EC%98%88%EC%99%B8-%EC%B2%98%EB%A6%AC-%ED%91%9C%ED%98%84%ED%95%98%EA%B8%B0-060bfe86f6b5
  - https://medium.com/@Adele_michael/handling-exceptions-in-kotlin-ff95cab44a3b

---

## Performance

### PERF_001
- **Severity:** MEDIUM
- **Description:** Minimizar el número de parámetros de un `Composable`, pasando solo la información necesaria (`String`, `Int`) en lugar del modelo de datos completo [1, 52].
- **Conditions:** language: kotlin, framework: Compose, Performance
- **Action:** Desestructurar los modelos de datos en propiedades individuales antes de pasarlos al Composable para reducir la recomposición innecesaria [1, 52].
- **Bad example:**
```
Header(news: News)
```
- **Good example:**
```
Header(title: String, date: String)
```
- **References:**
  - https://medium.com/@ahmadrazaofficial159/optimising-android-performance-129897406a76
  - https://medium.com/@sivavishnu0705/the-blueprint-for-speed-a-deep-dive-into-android-baseline-profiles-d968f085ba16

### PERF_003
- **Severity:** MEDIUM
- **Description:** El `ViewModel` debe usar el operador `stateIn` con `SharingStarted.WhileSubscribed(5000)` para exponer `StateFlow` desde flujos subyacentes, optimizando la suscripción [35].
- **Conditions:** language: kotlin, framework: State Flow
- **Action:** Utilizar `stateIn` para convertir un `Flow` de capas inferiores en un `StateFlow` de UI, con un `timeout` para la cancelación [35].
- **Bad example:**
```
val uiState = repository.data.stateIn(viewModelScope, SharingStarted.Eagerly, initial)
```
- **Good example:**
```
val uiState = repository.data.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), initialValue)
```
- **References:**
  - https://medium.com/@ahmadrazaofficial159/optimising-android-performance-129897406a76
  - https://medium.com/@sivavishnu0705/the-blueprint-for-speed-a-deep-dive-into-android-baseline-profiles-d968f085ba16

---

## Flows

### FLOW_001
- **Severity:** MEDIUM
- **Description:** Los ViewModels deben exponer el estado de la IU utilizando tipos inmutables como `StateFlow<UiState>`, nunca exponiendo `MutableStateFlow` [55, 56].
- **Conditions:** language: kotlin, framework: Flows, UDF
- **Action:** Asegurar que la propiedad expuesta sea de tipo inmutable (e.g., `val uiState: StateFlow<UiState> = _uiState`) [55, 56].
- **Bad example:**
```
val uiState = MutableStateFlow(Loading) (expuesta públicamente).
```
- **Good example:**
```
val uiState: StateFlow<UiState>
```
- **References:**
  - https://medium.com/androiddevelopers/a-safer-way-to-collect-flows-from-android-uis-23080b1f8bda
  - https://medium.com/androiddevelopers/migrating-from-livedata-to-kotlins-flow-379292f419fb

### FLOW_002
- **Severity:** MEDIUM
- **Description:** Los flujos de datos deben ser consumidos en la Capa de IU usando compiladores optimizados para ciclos de vida, como `collectAsStateWithLifecycle` en Jetpack Compose [57-59].
- **Conditions:** language: kotlin, framework: Compose, Flows
- **Action:** Usar la API de ciclo de vida para recopilar flujos, previniendo fugas de memoria y optimizando recursos [57, 59].
- **Bad example:**
```
val uiState by viewModel.uiState.collectAsState()
```
- **Good example:**
```
val uiState by viewModel.uiState.collectAsStateWithLifecycle()
```
- **References:**
  - https://medium.com/@daniyalidrees/kotlin-flow-crash-course-f4e7482d994b
  - https://medium.com/@manishrana366/fundamentals-of-kotlin-flow-part-1-6b6545b0a3ca

### FLOW_003
- **Severity:** MEDIUM
- **Description:** Se debe usar `flowOn(Dispatchers.IO)` o el operador de flujo apropiado para cambiar el `Dispatcher` para procesamiento intensivo dentro del `Flow` [32].
- **Conditions:** language: kotlin, framework: Flows
- **Action:** Aplicar `flowOn` justo antes de las operaciones pesadas o de I/O en la Capa de Dominio/Datos [32].
- **Bad example:**
```
Realizar un mapeo pesado en el `Dispatcher` del colector (típicamente Main).
```
- **Good example:**
```
repository.getPosts().map { heavy_mapping(it) }.flowOn(Dispatchers.Default)
```
- **References:**
  - https://medium.com/@daniyalidrees/kotlin-flow-crash-course-f4e7482d994b
  - https://medium.com/@manishrana366/fundamentals-of-kotlin-flow-part-1-6b6545b0a3ca

---

## Persistencia

### DATA_016
- **Severity:** MEDIUM
- **Description:** Si un `Repository` solo contiene una única fuente de datos y no depende de otros repositorios, se pueden fusionar las responsabilidades del repositorio y la fuente de datos [68].
- **Conditions:** language: kotlin, framework: Repository Pattern
- **Action:** Si se fusionan, planificar la división de funcionalidades si el repositorio debe manejar una fuente de datos adicional en el futuro [68].
- **Bad example:**
```
Crear Repository y DataSource separados cuando solo hay una única fuente
```
- **Good example:**
```
class ArticlesRepository @Inject constructor(private val api: ApiService) { suspend fun getArticles() = api.fetchArticles() }
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### DATA_017
- **Severity:** MEDIUM
- **Description:** Se debe implementar el manejo de corrupción de archivos al configurar `DataStore`, especialmente con Proto DataStore [23, 75].
- **Conditions:** language: kotlin, framework: DataStore
- **Action:** Proporcionar un `corruptionHandler` al crear la instancia de `DataStore` para recuperar el archivo a un valor predefinido por defecto [75].
- **Bad example:**
```
No manejar corrupción de archivos en Proto DataStore
```
- **Good example:**
```
DataStoreFactory.create(serializer = SettingsSerializer, corruptionHandler = ReplaceFileCorruptionHandler { Settings(lastUpdate = 0) })
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### DATA_020
- **Severity:** MEDIUM
- **Description:** Los archivos de datos grandes (JSON, bitmaps) deben manejarse usando objetos `File` y el manejo de subprocesos adecuado [14, 20].
- **Conditions:** language: kotlin, framework: I/O
- **Action:** Asegurarse de que las operaciones de archivo se realicen en `Dispatchers.IO` [20].
- **Bad example:**
```
val bitmap = BitmapFactory.decodeFile(largePath)
```
- **Good example:**
```
suspend fun loadLargeFile(path: String) = withContext(Dispatchers.IO) { File(path).readBytes() }
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### ROOM_004
- **Severity:** MEDIUM
- **Description:** Se recomienda usar `AutoMigration` en `Room` para manejar la adición o eliminación de columnas en migraciones simples [147, 148].
- **Conditions:** language: kotlin, framework: Room
- **Action:** Configurar el `Database` con `autoMigrations` especificando las versiones de origen y destino [147].
- **Bad example:**
```
Escribir Migration manualmente para cada cambio
```
- **Good example:**
```
@Database(version = 2, autoMigrations = [AutoMigration(from = 1, to = 2)]) abstract class AppDatabase : RoomDatabase()
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### ROOM_005
- **Severity:** MEDIUM
- **Description:** Utilizar `TypeConverters` de Room para la persistencia de tipos de datos complejos (ej. `List<String>`) [149, 150].
- **Conditions:** language: kotlin, framework: Room
- **Action:** Definir un `TypeConverter` y anotarlo con `@TypeConverter` para el mapeo a y desde tipos de base de datos (`String`) [149, 150].
- **Bad example:**
```
@Entity data class Event(val date: String)
```
- **Good example:**
```
@TypeConverters(Converters::class) @Database(...) abstract class AppDatabase : RoomDatabase()
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

---

## Mapeo

### DATA_019
- **Severity:** MEDIUM
- **Description:** Se recomienda usar **DTOs separados** e inmutables para cada caso de uso (ej., `UserCreationDTO`, `UserResponseDTO`) para evitar la sobrecarga de un único DTO [69].
- **Conditions:** language: kotlin, framework: DTO
- **Action:** Evitar la sobrecarga de un DTO con campos innecesarios para una operación particular, cumpliendo el SRP a nivel de modelos [69].
- **Bad example:**
```
Usar un `UserApiModel` masivo para todas las operaciones.
```
- **Good example:**
```
Usar `LoginRequest` y `AuthToken` separados [78, 79].
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

---

## Navegación

### UI_018
- **Severity:** MEDIUM
- **Description:** Para pasar datos complejos entre destinos de navegación, se recomienda serializar el objeto a una cadena (`String`) utilizando `Kotlinx Serialization` y pasarlo como argumento de la URL [104, 105].
- **Conditions:** language: kotlin, framework: Navigation Compose
- **Action:** Usar `Json.encodeToString(object)` y `Json.decodeFromString(string)` en el origen y destino de la navegación [43, 105].
- **Bad example:**
```
navController.navigate("details/${complexObject}")
```
- **Good example:**
```
navController.navigate("details/${Json.encodeToString(cat)}")
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

---

## Modularización

### ARCH_003
- **Severity:** MEDIUM
- **Description:** Se deben establecer módulos de Gradle separados para las capas principales (`:domain`, `:data`, `:presentation` o `:feature`) para forzar la Regla de Dependencia [106, 107].
- **Conditions:** language: kotlin, framework: Modularization
- **Action:** Auditar el grafo de dependencias para verificar que las capas internas no dependan de las externas [106].
- **Bad example:**
```
:domain implementa :data-remote
```
- **Good example:**
```
:data-repository implementa :domain
```
- **References:**
  - https://medium.com/@sivavishnu0705/mvvm-coordinator-in-android-building-a-clean-and-scalable-architecture-201cb0a321bf
  - https://medium.com/@sandeepkella23/what-top-1-android-engineers-know-about-android-architecture-that-others-dont-34164c7fad0a

### ARCH_004
- **Severity:** MEDIUM
- **Description:** Los módulos deben usar `implementation` para dependencias siempre que sea posible. `api` solo debe usarse si una dependencia es pública para los consumidores del módulo [108].
- **Conditions:** language: kotlin, framework: Modularization
- **Action:** Evitar el uso de `api` para librerías de implementación interna (ej. Hilt, Coroutines) para prevenir la fuga de dependencias [108].
- **Bad example:**
```
api(libs.di.hilt)
```
- **Good example:**
```
implementation(libs.di.hilt)
```
- **References:**
  - https://medium.com/@sivavishnu0705/mvvm-coordinator-in-android-building-a-clean-and-scalable-architecture-201cb0a321bf
  - https://medium.com/@sandeepkella23/what-top-1-android-engineers-know-about-android-architecture-that-others-dont-34164c7fad0a

---

## Seguridad/Persistencia

### SEC_002
- **Severity:** MEDIUM
- **Description:** Solo los datos **no sensibles** que pueden ser recreados fácilmente (ej. caché de imágenes) deben almacenarse en archivos de caché [114, 117].
- **Conditions:** language: kotlin
- **Action:** Implementar políticas de expiración claras y usar `getCacheDir()` o `getExternalCacheDir()` para datos temporales [117].
- **Bad example:**
```
Almacenar información de PII en la caché.
```
- **Good example:**
```
Archivos de caché de imágenes descargadas [117].
```
- **References:**
  - https://proandroiddev.com/ci-cd-secrets-leaks-how-to-secure-your-android-build-pipeline-4f430796eb60
  - https://medium.com/@weevanssord/tips-to-ensure-app-security-on-android-platform-32951994337f

### SEC_006
- **Severity:** MEDIUM
- **Description:** Si se mantiene un uso legado de `SharedPreferences`, debe usarse obligatoriamente en `MODE_PRIVATE` [114, 125].
- **Conditions:** language: kotlin, framework: Legacy
- **Action:** Asegurar el uso de `Context.MODE_PRIVATE` y evitar `SharedPreferences` para compartir datos [125].
- **Bad example:**
```
context.getSharedPreferences(name, MODE_WORLD_READABLE)
```
- **Good example:**
```
context.getSharedPreferences(fileName, Context.MODE_PRIVATE)
```
- **References:**
  - https://proandroiddev.com/ci-cd-secrets-leaks-how-to-secure-your-android-build-pipeline-4f430796eb60
  - https://medium.com/@weevanssord/tips-to-ensure-app-security-on-android-platform-32951994337f

---

## Seguridad

### SEC_008
- **Severity:** MEDIUM
- **Description:** Los mensajes de error mostrados a los usuarios finales no deben revelar información técnica interna (ej., IDs de base de datos, `stack traces`) [122].
- **Conditions:** language: kotlin
- **Action:** Implementar el manejo de errores para mostrar mensajes de usuario genéricos, sin revelar detalles de infraestructura [122].
- **Bad example:**
```
No validar certificados SSL
```
- **Good example:**
```
val certificatePinner = CertificatePinner.Builder().add("api.example.com", "sha256/AAAA...").build(); OkHttpClient.Builder().certificatePinner(certificatePinner).build()
```
- **References:**
  - https://proandroiddev.com/ci-cd-secrets-leaks-how-to-secure-your-android-build-pipeline-4f430796eb60
  - https://medium.com/@weevanssord/tips-to-ensure-app-security-on-android-platform-32951994337f

---

## DI

### DI_003
- **Severity:** MEDIUM
- **Description:** Las dependencias que contienen lógica empresarial y estado global deben tener un alcance `Singleton` (ej. `UserRepository`, `Database`) [110, 133].
- **Conditions:** language: kotlin, framework: Hilt, Koin
- **Action:** Utilizar el alcance `SingletonComponent::class` con la anotación `@Singleton` para dependencias de larga duración [133, 138].
- **Bad example:**
```
@Provides fun provideRepository(): Repository
```
- **Good example:**
```
@Provides @Singleton fun provideRepository(): Repository
```
- **References:**
  - https://medium.com/@sauravsushant58_66393/complete-guide-dependency-injection-in-android-4f5017c2ed93
  - https://renan-costaalencar.medium.com/from-zero-to-hero-with-hilt-c0eadfb89f85

---

## Lógica Negocio

### LOGIC_002
- **Severity:** MEDIUM
- **Description:** La capa de dominio puede reutilizarse en otras clases además de la IU (ej. `Services` y la clase `Application`) [144].
- **Conditions:** language: kotlin, framework: Domain
- **Action:** Diseñar los `Use Cases` para que sean independientes de la plataforma móvil, permitiendo la reutilización en TV, Wear, o servicios en segundo plano [144].
- **Bad example:**
```
Duplicar lógica de negocio en ViewModel y Fragment
```
- **Good example:**
```
class CalculatePriceUseCase { fun execute(items: List<Item>) = items.sumOf { it.price } }
```
- **References:**
  - https://medium.com/@sivavishnu0705/the-single-constructor-rule-why-your-android-fragment-needs-a-default-327a8f468410
  - https://blog.stackademic.com/android-memory-leaks-common-causes-and-how-to-fix-them-69e36696e2ae

### LOGIC_003
- **Severity:** MEDIUM
- **Description:** Se recomienda usar `sealed classes` para modelar el resultado de las interacciones (`Result<T>`) con la capa de datos/dominio, encapsulando el éxito y el error [49, 145].
- **Conditions:** language: kotlin, framework: Error Handling
- **Action:** Definir un `sealed class Result` con subclases `Success` y `Error` para propagar fallos controlados [46, 145].
- **Bad example:**
```
try { result = api.call() } catch (e: Exception) { error = e }
```
- **Good example:**
```
sealed class Result<out T> { data class Success<T>(val data: T): Result<T>(); data class Error(val exception: Throwable): Result<Nothing>() }
```
- **References:**
  - https://medium.com/@sivavishnu0705/the-single-constructor-rule-why-your-android-fragment-needs-a-default-327a8f468410
  - https://blog.stackademic.com/android-memory-leaks-common-causes-and-how-to-fix-them-69e36696e2ae

---

## I/O

### DATA_021
- **Severity:** MEDIUM
- **Description:** Los Repositorios deben implementar un mecanismo de **almacenamiento en caché en memoria** (in-memory caching) para resultados de solicitudes recientes (operaciones orientadas a la app) [153, 154].
- **Conditions:** language: kotlin
- **Action:** Usar una variable mutable protegida con `Mutex` o `StateFlow` dentro del Repositorio para mantener los datos en memoria [155].
- **Bad example:**
```
Siempre hacer llamadas a la red sin cachear
```
- **Good example:**
```
suspend fun getData(): Flow<List<Item>> = flow {\n    emit(database.getAll())\n    val fresh = api.fetchData()\n    database.insertAll(fresh)\n}
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

---

## WorkManager

### WORKER_001
- **Severity:** MEDIUM
- **Description:** Las tareas de `WorkManager` deben encapsular la lógica empresarial en clases separadas (`NewsTasksDataSource`), y el Worker solo debe orquestar su ejecución [156].
- **Conditions:** language: kotlin, framework: WorkManager
- **Action:** Inyectar la lógica de negocio (Use Case o Repository) en el Worker a través de DI, manteniendo la clase `Worker` simple [139].
- **Bad example:**
```
class SyncWorker : Worker() { override fun doWork(): Result { database.sync(); return Result.success() } }
```
- **Good example:**
```
class SyncWorker @Inject constructor(private val syncUseCase: SyncDataUseCase) : Worker()
```
- **References:**
  - https://medium.com/tecoble/workmanager%EB%A1%9C-%EB%B0%B0%EC%9A%B0%EB%8A%94-%EC%95%88%EC%A0%95%EC%A0%81%EC%9D%B8-%EB%B0%B1%EA%B7%B8%EB%9D%BC%EC%9A%B4%EB%93%9C-%EC%9E%91%EC%97%85-%EC%84%A4%EA%B3%84-06e01fba67d3
  - https://medium.com/codetodeploy/workmanager-in-android-a-complete-guide-with-real-world-implementation-and-interview-prep-7fdcddf03c59

### WORKER_003
- **Severity:** MEDIUM
- **Description:** Se debe probar el código del Worker en aislamiento utilizando las herramientas de prueba de `WorkManager` (ej. `WorkManagerTestInitHelper`) [160].
- **Conditions:** language: kotlin, framework: Testing, WorkManager
- **Action:** Usar `WorkManagerTestInitHelper` y `TestDriver` para controlar y verificar la ejecución del `Worker` de manera determinista [160].
- **Bad example:**
```
No probar Workers
```
- **Good example:**
```
@Test fun testSyncWorker() { val context = ApplicationProvider.getApplicationContext<Context>(); val worker = TestListenableWorkerBuilder<SyncWorker>(context).build() }
```
- **References:**
  - https://medium.com/tecoble/workmanager%EB%A1%9C-%EB%B0%B0%EC%9A%B0%EB%8A%94-%EC%95%88%EC%A0%95%EC%A0%81%EC%9D%B8-%EB%B0%B1%EA%B7%B8%EB%9D%BC%EC%9A%B4%EB%93%9C-%EC%9E%91%EC%97%85-%EC%84%A4%EA%B3%84-06e01fba67d3
  - https://medium.com/codetodeploy/workmanager-in-android-a-complete-guide-with-real-world-implementation-and-interview-prep-7fdcddf03c59

---

## Arquitectura

### MVI_001
- **Severity:** MEDIUM
- **Description:** En arquitecturas `MVI` (Model-View-Intent), se debe definir la intención del usuario a través de una `sealed class` de `UiAction` [161, 162].
- **Conditions:** language: kotlin, framework: MVI
- **Action:** Implementar acciones discretas y tipadas que representen todas las interacciones del usuario [161].
- **Bad example:**
```
fun onButtonClick() { viewModel.loadData() }
```
- **Good example:**
```
sealed class Intent { object LoadData : Intent() }; viewModel.processIntent(Intent.LoadData)
```
- **References:**
  - https://medium.com/mobile-app-development-publication/mvi-architecture-in-android-0be27c3b400a
  - https://medium.com/@and_rey/a-minimal-clean-example-of-ui-viewmodel-communication-in-mvi-architecture-android-kotlin-5e03a2a22a39

### MVI_002
- **Severity:** MEDIUM
- **Description:** En `MVI`, los eventos de un solo uso (que no deben sobrevivir a la configuración) pueden exponerse como `SharedFlow<UiSingleEvent>` [162, 163].
- **Conditions:** language: kotlin, framework: MVI, Flows
- **Action:** Usar `SharedFlow` para eventos de notificación o `Toast` [162].
- **Bad example:**
```
val navigationEvent: StateFlow<String?>
```
- **Good example:**
```
sealed class Event { data class Navigate(val route: String) : Event() }; val events: Flow<Event>
```
- **References:**
  - https://medium.com/mobile-app-development-publication/mvi-architecture-in-android-0be27c3b400a
  - https://medium.com/@and_rey/a-minimal-clean-example-of-ui-viewmodel-communication-in-mvi-architecture-android-kotlin-5e03a2a22a39

---

## Red

### NETWORK_002
- **Severity:** MEDIUM
- **Description:** Las clases de modelos utilizadas para la serialización (`ApiModel`) deben usar las anotaciones de la librería de serialización (`@JsonClass` para Moshi o `@Serializable` para Kotlinx Serialization) [127, 165].
- **Conditions:** language: kotlin, framework: Serialization
- **Action:** Asegurar que los modelos tengan el generador de adaptadores activado para la serialización en tiempo de compilación [127, 165].
- **Bad example:**
```
suspend fun getUsers(): Response<List<User>>
```
- **Good example:**
```
suspend fun getUsers(): Result<List<User>> = try { Result.Success(api.getUsers()) } catch(e: Exception) { Result.Error(e) }
```
- **References:**
  - https://medium.com/@za7922997/mastering-networking-web-services-in-android-development-retrofit-rest-apis-json-services-c8201f8771bb
  - https://devharshmittal.medium.com/why-retrofit-3-0-0-matters-even-if-2-9-0-still-works-77d7bd817061

### NETWORK_003
- **Severity:** MEDIUM
- **Description:** Al usar `Kotlinx Serialization`, se debe usar `@SerialName` o `@Json(name)` para mapear las propiedades de Kotlin a los nombres de campo de JSON para mayor claridad y resiliencia [166, 167].
- **Conditions:** language: kotlin, framework: Serialization
- **Action:** Usar las anotaciones de nombre si los nombres de campo de JSON difieren de los nombres de propiedad de Kotlin [166, 167].
- **Bad example:**
```
val okHttpClient = OkHttpClient.Builder().build()
```
- **Good example:**
```
val okHttpClient = OkHttpClient.Builder()\n    .connectTimeout(30, TimeUnit.SECONDS)\n    .readTimeout(30, TimeUnit.SECONDS)\n    .build()
```
- **References:**
  - https://medium.com/@za7922997/mastering-networking-web-services-in-android-development-retrofit-rest-apis-json-services-c8201f8771bb
  - https://devharshmittal.medium.com/why-retrofit-3-0-0-matters-even-if-2-9-0-still-works-77d7bd817061

### NETWORK_004
- **Severity:** MEDIUM
- **Description:** Se debe usar `OkHttp` junto con `Retrofit` para manejar la capa de transporte HTTP, permitiendo la configuración de *timeouts* e *interceptors* [133, 169].
- **Conditions:** language: kotlin, framework: OkHttp
- **Action:** Configurar `OkHttpClient.Builder()` para establecer timeouts de lectura/conexión [133, 170].
- **Bad example:**
```
val retrofit = Retrofit.Builder().baseUrl(BASE_URL).build()
```
- **Good example:**
```
val okHttpClient = OkHttpClient.Builder().readTimeout(30, TimeUnit.SECONDS).build(); val retrofit = Retrofit.Builder().baseUrl(BASE_URL).client(okHttpClient).build()
```
- **References:**
  - https://medium.com/@za7922997/mastering-networking-web-services-in-android-development-retrofit-rest-apis-json-services-c8201f8771bb
  - https://devharshmittal.medium.com/why-retrofit-3-0-0-matters-even-if-2-9-0-still-works-77d7bd817061

---

## Accesibilidad

### A11Y_002
- **Severity:** MEDIUM
- **Description:** Las pruebas de IU deben verificar la **semántica** de los componentes para asegurar que los servicios de accesibilidad (como TalkBack) interpreten correctamente la UI [96].
- **Conditions:** language: kotlin, framework: Compose Test
- **Action:** Utilizar la API de prueba de Compose para verificar la semántica, ya que es crucial para la accesibilidad y el funcionamiento del framework de pruebas [96].
- **Bad example:**
```
onNodeWithText("Submit").assertExists()
```
- **Good example:**
```
onNodeWithContentDescription("Submit button").assertIsDisplayed().assertHasClickAction()
```
- **References:**
  - https://medium.com/simform-engineering/android-accessibility-and-talkback-6a79fde05b54
  - https://medium.com/@iamkiruba43/unlocking-android-accessibility-service-the-hidden-superpower-in-your-phone-8763831248f5

---

## CI/CD

### CI_001
- **Severity:** MEDIUM
- **Description:** Se recomienda el uso de **Version Catalogs** (ej. `libs.versions.toml` en Gradle) para centralizar la gestión de versiones de dependencias y asegurar la uniformidad en todos los módulos [47, 174].
- **Conditions:** language: kotlin, framework: Gradle
- **Action:** Migrar todas las dependencias a un catálogo centralizado para simplificar la gestión y evitar conflictos de versión [174].
- **Bad example:**
```
implementation "com.squareup.retrofit2:retrofit:2.9.0"
```
- **Good example:**
```
libs.versions.toml: retrofit = "2.9.0"; build.gradle.kts: implementation(libs.retrofit)
```
- **References:**
  - https://medium.com/@nurberinkarakus/b%C3%B6l%C3%BCm-4-ci-cd-gradle-y%C3%BCksek-performansl%C4%B1-android-build-pipelinelar%C4%B1-kurmak-remote-cache-25aceeccfe49
  - https://medium.com/@xenoterracide/skipping-pre-releases-when-youre-using-dynamic-dependencies-part-4-31fab3c38ce3

### CI_003
- **Severity:** MEDIUM
- **Description:** Utilizar `Android App Bundle (AAB)` como formato de publicación, delegando la generación de APK a Google Play para optimizar el tamaño de la aplicación [176, 177].
- **Conditions:** language: kotlin, framework: Publishing
- **Action:** Asegurar que el proceso de CI/CD (ej. GitHub Actions) ensamble el AAB de *release* para el despliegue [178, 179].
- **Bad example:**
```
./gradlew assembleRelease
```
- **Good example:**
```
./gradlew bundleRelease
```
- **References:**
  - https://medium.com/@nurberinkarakus/b%C3%B6l%C3%BCm-4-ci-cd-gradle-y%C3%BCksek-performansl%C4%B1-android-build-pipelinelar%C4%B1-kurmak-remote-cache-25aceeccfe49
  - https://medium.com/@xenoterracide/skipping-pre-releases-when-youre-using-dynamic-dependencies-part-4-31fab3c38ce3

### CI_005
- **Severity:** MEDIUM
- **Description:** Se debe utilizar `R8` (obfuscation/shrinking) en las compilaciones de *release* para optimizar el tamaño y ocultar el código [181, 182].
- **Conditions:** language: kotlin, framework: R8
- **Action:** Incluir las reglas de ProGuard (`proguard-rules.pro`) para evitar que las clases de serialización (ej. `CatEntity`) sean ofuscadas [181, 182].
- **Bad example:**
```
release { minifyEnabled false }
```
- **Good example:**
```
buildTypes { release { minifyEnabled true; shrinkResources true } }
```
- **References:**
  - https://medium.com/@nurberinkarakus/b%C3%B6l%C3%BCm-4-ci-cd-gradle-y%C3%BCksek-performansl%C4%B1-android-build-pipelinelar%C4%B1-kurmak-remote-cache-25aceeccfe49
  - https://medium.com/@xenoterracide/skipping-pre-releases-when-youre-using-dynamic-dependencies-part-4-31fab3c38ce3

---

## Gobernanza Arquitectónica

### ADR_101
- **Severity:** MEDIUM
- **Description:** Las decisiones arquitectónicas relevantes deben estar respaldadas por ADRs vigentes y la implementación debe mantenerse alineada con dichas decisiones.
- **Conditions:** language: all, principle: Architecture Decision Records
- **Action:** Mantener ADR con estado (proposed/accepted/superseded), alcance e impacto; en cada cambio crítico, validar y actualizar la trazabilidad ADR ↔ código.
- **Bad example:**
```
Se migra de MVVM a MVI en código sin actualizar documentación ni decisión previa.
```
- **Good example:**
```
ADR-012 documenta migración MVVM→MVI, estado accepted y referencias a módulos/PRs afectados.
```
- **References:**
  - https://martinfowler.com/articles/architecture-decision-records.html
  - https://github.com/joelparkerhenderson/architecture-decision-record

---

## Gobernanza Técnica

### GOV_101
- **Severity:** MEDIUM
- **Description:** La deuda técnica crítica debe registrarse con owner, riesgo, fecha objetivo y plan de mitigación verificable.
- **Conditions:** language: all, principle: Technical Debt Management
- **Action:** Mantener backlog de deuda priorizado por impacto y probabilidad, con seguimiento periódico y criterios de cierre medibles.
- **Bad example:**
```
TODOs críticos sin responsable ni horizonte de resolución.
```
- **Good example:**
```
Registro TECHDEBT-034 con owner, riesgo alto, fecha compromiso y tareas de pago en roadmap.
```
- **References:**
  - https://martinfowler.com/bliki/TechnicalDebt.html
  - https://martinfowler.com/bliki/TechnicalDebtQuadrant.html

---

## Observabilidad

### OBS_101
- **Severity:** MEDIUM
- **Description:** La aplicación debe emitir observabilidad accionable con logs estructurados, correlación de eventos y alertas para flujos críticos.
- **Conditions:** language: all, framework: Logging/Monitoring
- **Action:** Estandarizar campos de logging (trace_id, user_scope, feature, outcome), definir SLO/SLI y conectar alertas con runbooks operativos.
- **Bad example:**
```
Logs de texto libre sin contexto ni identificador de correlación.
```
- **Good example:**
```
Evento estructurado con trace_id y outcome, dashboard con alertas por tasa de error y latencia p95.
```
- **References:**
  - https://opentelemetry.io/docs/concepts/observability-primer/
  - https://sre.google/sre-book/monitoring-distributed-systems/
