# Copilot Guidelines: Android (Kotlin) — HIGH

---

Total rules: **80**

## Flujo de Datos

### UI_001
- **Severity:** HIGH
- **Description:** Seguir el Patrón de Flujo Unidireccional de Datos (UDF): el estado fluye hacia abajo (ViewModel a UI) y los eventos fluyen hacia arriba (UI a ViewModel).
- **Conditions:** language: kotlin, pattern: UDF
- **Action:** Asegurar que el ViewModel exponga el estado (como StateFlow) y reciba acciones a través de llamadas a métodos.
- **Bad example:**
```
@Composable
fun ProfileScreen(viewModel: ProfileViewModel) {
    Button(onClick = {
        viewModel.uiState.value = UiState.Loading
        viewModel.userName = "New Name"
    }) { Text("Update") }
}
```
- **Good example:**
```
@Composable
fun ProfileScreen(viewModel: ProfileViewModel) {
    Button(onClick = {
        viewModel.onUpdateUserName("New Name")
    }) { Text("Update") }
}
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

---

## ViewModel

### VM_001
- **Severity:** HIGH
- **Description:** Los ViewModels deben ser independientes del ciclo de vida de Android: no deben contener referencias a tipos relacionados con el ciclo de vida, como Activity, Fragment, Context o Resources.
- **Conditions:** language: kotlin, source_type: ViewModel
- **Action:** Mover dependencias de Context a la capa de UI o Data, o usar `@ApplicationContext` en el constructor si es estrictamente necesario en un módulo de Data.
- **Bad example:**
```
class MyViewModel(private val context: Context)
```
- **Good example:**
```
class MyViewModel(private val useCase: MyUseCase)
```
- **References:**
  - https://medium.com/@vontonnie/context-in-viewmodel-debate-239485108cfb
  - https://medium.com/@vivekbansal19/android-viewmodels-best-practices-part-1-35ebec871655

### VM_002
- **Severity:** HIGH
- **Description:** Usar ViewModels a nivel de la pantalla (Screen-level) o destinos de navegación. Evitar usarlos en piezas de UI reutilizables.
- **Conditions:** language: kotlin, framework: Compose/Views
- **Action:** Para componentes de UI reutilizables, usar clases contenedoras de estados sin formato (`Plain State Holder Classes`) cuyo estado pueda ser elevado y controlado externamente.
- **Bad example:**
```
Un componente Card reutilizable inyecta su propio ViewModel.
```
- **Good example:**
```
Card recibe su estado y callbacks como parámetros de la pantalla contenedora.
```
- **References:**
  - https://medium.com/@scripturesintech/%EF%B8%8F-state-hoisting-in-android-jetpack-compose-how-it-follows-solid-principles-2a76dc13db3c
  - https://medium.com/@hiren6997/the-best-patterns-for-state-hoisting-in-compose-ui-why-your-code-keeps-breaking-and-how-to-fix-89eecf7d1fb0

### VM_003
- **Severity:** HIGH
- **Description:** Exponer el estado de la UI (UiState) a través de un objeto de estado único y observable, preferiblemente `StateFlow`, y usar el operador `stateIn` con `WhileSubscribed(5000)` para transmisiones de datos.
- **Conditions:** language: kotlin, framework: Coroutines/Flow
- **Action:** Asegurar que el ViewModel exponga una única propiedad `uiState` (o múltiples si los datos no están relacionados).
- **Bad example:**
```
Exponer LiveData, o múltiples variables mutables separadas en el ViewModel.
```
- **Good example:**
```
val uiState: StateFlow<ScreenUiState> = dataFlow.stateIn(..., WhileSubscribed(5000))
```
- **References:**
  - https://medium.com/@vivekbansal19/android-viewmodels-best-practices-part-2-4798d3291199
  - https://medium.com/@hiren6997/kotlin-flow-in-2025-my-7-favorite-patterns-for-clean-reactive-code-2dff57d09a3a

### UI_013
- **Severity:** HIGH
- **Description:** Los `ViewModels` deben usarse a nivel de pantalla o destino de navegación. Su alcance debe definirse en el gráfico de navegación o Activity/Fragment [38, 99].
- **Conditions:** language: kotlin, framework: MVVM
- **Action:** No usar `ViewModels` en piezas de IU reutilizables ni compartir la misma instancia de VM entre destinos que no lo requieran [39, 99].
- **Bad example:**
```
@Composable fun ListItem(item: Item, viewModel: ItemViewModel = viewModel())
```
- **Good example:**
```
@Composable fun Screen(viewModel: ScreenViewModel = hiltViewModel())
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_016
- **Severity:** HIGH
- **Description:** Se prohíbe pasar instancias de `ViewModel` a otras funciones `Composable` que no sean de nivel de pantalla, ya que esto oscurece la Fuente Única de Verdad (SSOT) [1, 37].
- **Conditions:** language: kotlin, framework: Compose, UDF
- **Action:** Seguir las prácticas recomendadas de UDF: pasar solo el estado necesario y los eventos de propagación (hoist events) [37].
- **Bad example:**
```
fun Component(viewModel: MyViewModel)
```
- **Good example:**
```
fun Component(data: String, onAction: () -> Unit)
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_017
- **Severity:** HIGH
- **Description:** El `ViewModel` debe exponer su estado de la IU utilizando una `data class` inmutable (`${Screen}UiState`) para garantizar la seguridad de subprocesos y la coherencia del estado [55, 103].
- **Conditions:** language: kotlin, framework: MVVM, Immutability
- **Action:** Asegurar que todas las propiedades dentro de `UiState` sean `val` [55, 103].
- **Bad example:**
```
val isLoading: StateFlow<Boolean>; val error: StateFlow<String?>
```
- **Good example:**
```
data class PetsUiState(val isLoading: Boolean = false, val error: String? = null); val uiState: StateFlow<PetsUiState>
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

---

## Capas

### DATA_001
- **Severity:** HIGH
- **Description:** Definir una capa de datos clara y crear clases de repositorio para exponer los datos de la aplicación al resto de la app.
- **Conditions:** language: kotlin, principle: Layered Architecture
- **Action:** Asegurarse de que el repositorio actúe como punto de entrada a la capa de datos.
- **Bad example:**
```
La lógica de negocio reside en Activity/Fragment/ViewModel.
```
- **Good example:**
```
La lógica de negocio reside en la capa de datos o de dominio.
```
- **References:**
  - https://medium.com/@naeem0313/android-clean-architecture-fcf69a0bf033
  - https://medium.com/@vivekbansal19/android-viewmodels-best-practices-part-1-35ebec871655

---

## Asincronía

### COROUTINES_001
- **Severity:** HIGH
- **Description:** Usar Coroutines y Flows de Kotlin para la comunicación entre capas y el manejo de datos asíncronos.
- **Conditions:** language: kotlin
- **Action:** Utilizar funciones `suspend` para operaciones únicas y `Flow` para recibir notificaciones de cambios de datos a lo largo del tiempo.
- **Bad example:**
```
Usar callbacks de Java o RxJava sin necesidad.
```
- **Good example:**
```
fun getUsers(): Flow<List<User>>
```
- **References:**
  - https://medium.com/@hiren6997/kotlin-flow-in-2025-my-7-favorite-patterns-for-clean-reactive-code-2dff57d09a3a
  - https://medium.com/@vivekbansal19/android-viewmodels-best-practices-part-2-4798d3291199

---

## Compose

### UI_002
- **Severity:** HIGH
- **Description:** Utilizar la recopilación de estado de la UI optimizada para ciclos de vida, como `collectAsStateWithLifecycle` en Jetpack Compose o `repeatOnLifecycle` en el sistema de Vistas.
- **Conditions:** language: kotlin, framework: Compose/Views
- **Action:** Asegurar que la recopilación de Flows/LiveData se detenga cuando la UI no esté activa para evitar fugas de contexto y consumo innecesario de recursos.
- **Bad example:**
```
flow.collect { ... } sin manejo de ciclo de vida.
```
- **Good example:**
```
val uiState by viewModel.uiState.collectAsStateWithLifecycle()
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_001
- **Severity:** HIGH
- **Description:** Se prohíben las 'Escrituras Hacia Atrás' (`Backwards Writes`), donde un `Composable` modifica un estado basado en la lectura de otro estado en el mismo cuerpo, violando el UDF [33].
- **Conditions:** language: kotlin, framework: Compose, UDF
- **Action:** Mover la lógica de mutación de estado a los `event handlers` (lambdas) o al `ViewModel` [33].
- **Bad example:**
```
if (stateA > 5) stateB = true dentro del cuerpo de un Composable.
```
- **Good example:**
```
Button(onClick = { if (stateA > 5) onStateBChange(true) })
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_002
- **Severity:** HIGH
- **Description:** El parámetro `key` en `LazyColumn`/`LazyRow` (`items()`) es obligatorio y debe ser un identificador único y estable (ej., `item.id`), no el índice [33, 34].
- **Conditions:** language: kotlin, framework: Compose, Performance
- **Action:** Añadir `key = { item.id }` en la función `items` de la lista perezosa para preservar el estado correctamente y optimizar la recomposición [33, 34].
- **Bad example:**
```
LazyColumn { items(list) { ... } }
```
- **Good example:**
```
LazyColumn { items(list, key = { it.id }) { ... } }
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_004
- **Severity:** HIGH
- **Description:** Para cualquier estado de IU que sea una transformación o derivación de uno o más estados subyacentes, es obligatorio usar `derivedStateOf` [33].
- **Conditions:** language: kotlin, framework: Compose, Performance
- **Action:** Envolver la lógica de derivación de estado en `derivedStateOf` para asegurar que la recomposición solo ocurra si el *resultado* de la expresión cambia [33].
- **Bad example:**
```
val isEnabled = count.value > 0
```
- **Good example:**
```
val isEnabled by remember { derivedStateOf { count.value > 0 } }
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_011
- **Severity:** HIGH
- **Description:** Pasar las acciones del usuario (`event handlers`) como lambdas inmutables (`onClick: () -> Unit`) en lugar de mutar el estado directamente en el Composable [95, 96].
- **Conditions:** language: kotlin, framework: Compose, UDF
- **Action:** Usar valores inmutables para lambdas del controlador de estados y eventos para mejorar la reutilización y evitar problemas de simultaneidad [95].
- **Bad example:**
```
Button(onClick = { count++ })
```
- **Good example:**
```
Button(onClick = onIncrementClicked)
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_021
- **Severity:** HIGH
- **Description:** Para asegurar la coherencia, la lógica de la IU de comportamiento (ej. mostrar un `Toast`, navegación) debe residir en la Capa de IU (Composable/Activity/Fragment), no en el `ViewModel` [1, 130].
- **Conditions:** language: kotlin, framework: UDF, MVVM
- **Action:** El `ViewModel` debe producir el *qué* (el estado) y la IU debe manejar el *cómo* (la navegación o el comportamiento) [130].
- **Bad example:**
```
ViewModel.navigateToDetails()
```
- **Good example:**
```
UI reacciona al estado `uiState.navigationTarget`
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_022
- **Severity:** HIGH
- **Description:** Se debe aplicar rigurosamente el *State Hoisting* (elevación de estado). Los Composables deben ser 'tontos' (`Stateless`), aceptando estado como parámetros y exponiendo eventos como lambdas [96].
- **Conditions:** language: kotlin, framework: Compose, State
- **Action:** El estado mutable debe ser elevado al Composable con el ciclo de vida más alto posible o al `ViewModel` [96].
- **Bad example:**
```
Composable con `val isExpanded by remember { mutableStateOf(false) }`
```
- **Good example:**
```
Composable que acepta `isExpanded: Boolean` y `onExpandedChange: (Boolean) -> Unit`.
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

---

## Dependencias

### DI_001
- **Severity:** HIGH
- **Description:** Implementar la Inserción de Dependencias (DI), priorizando la inyección por constructor siempre que sea posible.
- **Conditions:** language: kotlin
- **Action:** Usar frameworks como Hilt para gestionar las dependencias y el ámbito de los componentes.
- **Bad example:**
```
object RetrofitClient { val instance = Retrofit.Builder().baseUrl(BASE_URL).build() }
```
- **Good example:**
```
@Module\n@InstallIn(SingletonComponent::class)\nobject NetworkModule {\n    @Provides\n    @Singleton\n    fun provideRetrofit(): Retrofit =\n        Retrofit.Builder()\n            .baseUrl(BASE_URL)\n            .build()\n}
```
- **References:**
  - https://medium.com/@mohamed.youssef.abdallah/dependency-injection-in-kotlin-by-example-c11f71420b72
  - https://medium.com/androiddevelopers/hilt-and-jetpack-compose-with-best-practices-d12903740e53

### DI_002
- **Severity:** HIGH
- **Description:** Definir el ámbito de un contenedor de dependencias si el tipo contiene datos mutables que deben compartirse o si la inicialización es costosa y se usa ampliamente.
- **Conditions:** language: kotlin, framework: Hilt
- **Action:** Utilizar anotaciones de ámbito (scope) como `@Singleton` o definir ámbitos personalizados siguiendo el ciclo de vida de la aplicación/flujo.
- **Bad example:**
```
class UseCase { private val ioDispatcher = Dispatchers.IO }
```
- **Good example:**
```
@Module @InstallIn(SingletonComponent::class) object DispatchersModule { @Provides @IoDispatcher fun provideIoDispatcher() = Dispatchers.IO }
```
- **References:**
  - https://medium.com/@kiran.developer/jetpack-compose-and-hilt-a-comprehensive-guide-f8b8e0b674b8
  - https://medium.com/@mohamed.youssef.abdallah/dependency-injection-in-kotlin-by-example-c11f71420b72

---

## Testabilidad

### TEST_001
- **Severity:** HIGH
- **Description:** Para garantizar el determinismo en las pruebas asíncronas, todos los Dispatchers de prueba utilizados en una prueba deben compartir el mismo planificador (`Scheduler`) [3].
- **Conditions:** language: kotlin, framework: Coroutines Test
- **Action:** Asegurar que `runTest` se configure para usar un planificador compartido para todas las corrutinas que se prueban [3].
- **Bad example:**
```
val dispatcher1 = StandardTestDispatcher() val dispatcher2 = StandardTestDispatcher()
```
- **Good example:**
```
val dispatcher = StandardTestDispatcher(); val scope = TestScope(dispatcher)
```
- **References:**
  - https://medium.com/@supsabhi/testing-kotlin-flows-in-android-a-comprehensive-guide-f8876e938f38
  - https://medium.com/@naeem0313/unit-testing-in-android-kotlin-with-mockk-and-coroutines-test-68853610e7b9

### TEST_002
- **Severity:** HIGH
- **Description:** Al probar `ViewModels` que usan `viewModelScope`, es obligatorio llamar a `Dispatchers.setMain` e inyectar un `TestDispatcher` para controlar la ejecución [3].
- **Conditions:** language: kotlin, framework: Coroutines Test
- **Action:** Configurar el `TestDispatcher` en el `setUp` y restaurar el `Main` en el `tearDown` [3].
- **Bad example:**
```
viewModel.someSuspendFunction() (Depende del Main real)
```
- **Good example:**
```
Dispatchers.setMain(testDispatcher)
```
- **References:**
  - https://medium.com/@supsabhi/testing-kotlin-flows-in-android-a-comprehensive-guide-f8876e938f38
  - https://medium.com/@naeem0313/unit-testing-in-android-kotlin-with-mockk-and-coroutines-test-68853610e7b9

### TEST_003
- **Severity:** HIGH
- **Description:** Las pruebas unitarias que involucran `StateFlows` deben aseverar la propiedad `value` siempre que sea posible para verificar el estado de la IU [4].
- **Conditions:** language: kotlin, framework: Coroutines Test, StateFlow
- **Action:** Siempre acceder al estado final usando `.value` o usando librerías de prueba de flujos para coleccionar y aseverar [4].
- **Bad example:**
```
viewModel.uiState.collect { ... } (Lógica compleja para una simple aseveración de valor)
```
- **Good example:**
```
assert(viewModel.uiState.value.data == expected)
```
- **References:**
  - https://medium.com/@supsabhi/testing-kotlin-flows-in-android-a-comprehensive-guide-f8876e938f38
  - https://medium.com/@naeem0313/unit-testing-in-android-kotlin-with-mockk-and-coroutines-test-68853610e7b9

### TEST_005
- **Severity:** HIGH
- **Description:** Las pruebas de navegación de la IU deben implementarse como pruebas de instrumentación para verificar los flujos de usuario clave [7].
- **Conditions:** language: kotlin, framework: Compose, Navigation
- **Action:** Implementar pruebas de instrumentación para verificar los flujos de navegación clave [7].
- **Bad example:**
```
Verificar navegación en pruebas unitarias sin contexto de UI
```
- **Good example:**
```
val navController = TestNavHostController(ApplicationProvider.getApplicationContext()); navController.setGraph(R.navigation.trivia); onView(withId(R.id.play_btn)).perform(click()); assertThat(navController.currentDestination?.id).isEqualTo(R.id.in_game)
```
- **References:**
  - https://medium.com/@tojosphine/android-espresso-testing-best-practices-and-patterns-796b165bfef8
  - https://medium.com/@tojosphine/native-android-automation-with-espresso-for-fast-and-stable-tests-bad9ff7108e1

### TEST_006
- **Severity:** HIGH
- **Description:** Las pruebas de integración de bases de datos deben usar bases de datos en memoria (`in-memory database`) cuando se prueba `Room` para garantizar determinismo [8].
- **Conditions:** language: kotlin, framework: Room, Testing
- **Action:** Configurar la base de datos de Room en el entorno de prueba para que se ejecute en memoria [8].
- **Bad example:**
```
Usar la base de datos persistente en las pruebas unitarias
```
- **Good example:**
```
db = Room.inMemoryDatabaseBuilder(ApplicationProvider.getApplicationContext(), TestDatabase::class.java).build()
```
- **References:**
  - https://medium.com/@tojosphine/android-espresso-testing-best-practices-and-patterns-796b165bfef8
  - https://medium.com/@tojosphine/native-android-automation-with-espresso-for-fast-and-stable-tests-bad9ff7108e1

### TEST_008
- **Severity:** HIGH
- **Description:** Utilizar `MockWebServer` o herramientas similares para realizar llamadas HTTP y HTTPS falsas en pruebas de red, asegurando el determinismo de los tests [8, 64].
- **Conditions:** language: kotlin, framework: Retrofit, Testing
- **Action:** Crear un `MockRequestDispatcher` que mapee las rutas de la API a respuestas JSON controladas, evitando dependencia de la red real [64].
- **Bad example:**
```
Hacer llamadas HTTP reales en pruebas
```
- **Good example:**
```
val mockWebServer = MockWebServer(); mockWebServer.enqueue(MockResponse().setBody(jsonResponse)); mockWebServer.start()
```
- **References:**
  - https://medium.com/@tojosphine/android-espresso-testing-best-practices-and-patterns-796b165bfef8
  - https://medium.com/@tojosphine/native-android-automation-with-espresso-for-fast-and-stable-tests-bad9ff7108e1

### TEST_009
- **Severity:** HIGH
- **Description:** Las pruebas de integración de la Capa de Datos deben ejecutarse en un entorno controlado (ej. bases de datos en memoria para Room) para ser confiables [8, 26].
- **Conditions:** language: kotlin, framework: Room, Testing
- **Action:** Usar la base de datos de Room en memoria para pruebas de DAO y Repositorios [8].
- **Bad example:**
```
Pruebas de integración usando base de datos de producción
```
- **Good example:**
```
db = Room.inMemoryDatabaseBuilder(context, AppDatabase::class.java).allowMainThreadQueries().build()
```
- **References:**
  - https://medium.com/@tojosphine/android-espresso-testing-best-practices-and-patterns-796b165bfef8
  - https://medium.com/@tojosphine/native-android-automation-with-espresso-for-fast-and-stable-tests-bad9ff7108e1

### TEST_012
- **Severity:** HIGH
- **Description:** Se requiere que las pruebas de Casos Negativos (escenarios de error, datos no válidos, fallos de red) sean explícitas y cubran los casos límite [60].
- **Conditions:** language: kotlin, framework: Testing
- **Action:** Para cada `Use Case` o `Repository`, debe haber una prueba explícita que verifique el manejo y la propagación de errores [60].
- **Bad example:**
```
Solo probar casos exitosos
```
- **Good example:**
```
mockWebServer.enqueue(MockResponse().setResponseCode(500)); assertThrows<PostException> { repository.createPost() }
```
- **References:**
  - https://medium.com/@tojosphine/android-espresso-testing-best-practices-and-patterns-796b165bfef8
  - https://medium.com/@tojosphine/native-android-automation-with-espresso-for-fast-and-stable-tests-bad9ff7108e1

### TEST_013
- **Severity:** HIGH
- **Description:** Las pruebas unitarias deben validar que las funciones de manejo de errores en `Use Cases` y `Repositorios` emiten las entidades de error correctas [50, 67].
- **Conditions:** language: kotlin, framework: Testing, Domain
- **Action:** Asegurarse de que `Result.Error` contenga la subclase correcta de `UseCaseException` según el fallo subyacente [46, 50].
- **Bad example:**
```
assert(result is Result.Error) sin verificar tipo específico
```
- **Good example:**
```
assert(result is Result.Error && result.exception is PostException)
```
- **References:**
  - https://medium.com/@tojosphine/android-espresso-testing-best-practices-and-patterns-796b165bfef8
  - https://medium.com/@tojosphine/native-android-automation-with-espresso-for-fast-and-stable-tests-bad9ff7108e1

### COROUTINE_010
- **Severity:** HIGH
- **Description:** El `viewModelScope` está codificado en `Dispatchers.Main`; al probar, se debe usar `Dispatchers.setMain` con un `TestDispatcher` [3].
- **Conditions:** language: kotlin, framework: Coroutines Test
- **Action:** Utilizar `TestDispatcher` (ej. `StandardTestDispatcher`) para reemplazar `Dispatchers.Main` y hacer que los tests de ViewModel sean deterministas [3].
- **Bad example:**
```
No configurar dispatcher de test para ViewModel
```
- **Good example:**
```
@Before fun setUp() { Dispatchers.setMain(StandardTestDispatcher()) }
```
- **References:**
  - https://medium.com/@kumarsamy19792/optimizing-android-app-performance-with-kotlin-coroutines-449249f5c676
  - https://medium.com/@zabiirana27/the-coroutine-secret-even-10-year-android-developers-dont-know-02d21c3285c7

### TEST_014
- **Severity:** HIGH
- **Description:** Se requiere que el módulo `:domain` (lógica empresarial pura) mantenga un umbral mínimo de cobertura de código (ej., 80%) [129].
- **Conditions:** language: kotlin, framework: Testing, Domain
- **Action:** Verificar automáticamente la cobertura de código en el pipeline de CI/CD para garantizar que la lógica de negocio esté completamente probada [129].
- **Bad example:**
```
Cobertura del módulo :domain al 60%
```
- **Good example:**
```
jacoco { toolVersion = "0.8.10" }; jacocoTestCoverageVerification { violationRules { rule { limit { minimum = 0.80 } } } }
```
- **References:**
  - https://medium.com/@tojosphine/android-espresso-testing-best-practices-and-patterns-796b165bfef8
  - https://medium.com/@tojosphine/native-android-automation-with-espresso-for-fast-and-stable-tests-bad9ff7108e1

### TEST_015
- **Severity:** HIGH
- **Description:** Al probar `StateFlows` creados con `stateIn` y la política `WhileSubscribed`, se debe crear un `collectJob` explícito para asegurar que el flujo esté activo [4].
- **Conditions:** language: kotlin, framework: StateFlow Test
- **Action:** Lanzar una corrutina para iniciar la recolección del `StateFlow` antes de realizar aserciones, y cancelarla después [4].
- **Bad example:**
```
runTest { viewModel.uiState.test { ... } }
```
- **Good example:**
```
runTest { val job = launch { viewModel.uiState.collect() }; advanceUntilIdle(); job.cancel() }
```
- **References:**
  - https://medium.com/@tojosphine/android-espresso-testing-best-practices-and-patterns-796b165bfef8
  - https://medium.com/@tojosphine/native-android-automation-with-espresso-for-fast-and-stable-tests-bad9ff7108e1

---

## Capa de Datos

### DATA_002
- **Severity:** HIGH
- **Description:** Separar las clases de modelos (`DTOs` de red/base de datos) y hacer que los Repositorios expongan solo los datos requeridos por las capas superiores (`Article` en lugar de `ArticleApiModel`) [11, 12].
- **Conditions:** language: kotlin, framework: Data Layer, DTO
- **Action:** Definir clases de modelos separadas para cada capa y utilizar funciones de mapeo dentro del Repositorio [11].
- **Bad example:**
```
Pasar un `UserNetworkDto` al `ViewModel`
```
- **Good example:**
```
Mapear `UserNetworkDto` a `User` (Entidad/Modelo de Dominio)
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### DATA_004
- **Severity:** HIGH
- **Description:** El Repositorio debe definir explícitamente una **Fuente Única de Verdad** (SSOT) para el tipo de dato que maneja [15, 16].
- **Conditions:** language: kotlin, framework: Repository Pattern
- **Action:** Verificar que el Repositorio orqueste las llamadas para asegurarse de que los datos siempre provengan del SSOT. Si se requiere soporte *offline-first*, el SSOT debe ser una fuente de datos local [17, 18].
- **Bad example:**
```
Exponer Flows directamente desde la red sin sincronizar con la base de datos local
```
- **Good example:**
```
fun getArticles(): Flow<List<Article>> = articleDao.getAll()
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### DATA_005
- **Severity:** HIGH
- **Description:** Las operaciones únicas de Creación, Lectura, Actualización y Eliminación (CRUD) deben exponerse como funciones `suspend` en Kotlin [19].
- **Conditions:** language: kotlin, framework: Coroutines, Data Layer
- **Action:** Reemplazar devoluciones de llamada o tipos RxJava (`Single`, `Maybe`, `Completable`) con `suspend fun` [19].
- **Bad example:**
```
fun getArticle(id: Int, callback: (Article) -> Unit)
```
- **Good example:**
```
suspend fun getArticle(id: Int): Article
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### DATA_008
- **Severity:** HIGH
- **Description:** Está prohibido el uso de `SharedPreferences`. Toda persistencia de datos clave-valor debe migrarse a `Jetpack DataStore` debido a la falta de APIs asíncronas y transaccionales [23, 24].
- **Conditions:** language: kotlin, framework: DataStore
- **Action:** Usar `DataStore` o `Proto DataStore` en su lugar [23, 24].
- **Bad example:**
```
context.getSharedPreferences('prefs', MODE_PRIVATE)
```
- **Good example:**
```
val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = 'user_preferences')
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### DATA_009
- **Severity:** HIGH
- **Description:** Los datos que la capa de datos expone al resto de la app deben ser **inmutables** para evitar la manipulación externa y garantizar la seguridad de subprocesos [16, 68].
- **Conditions:** language: kotlin, framework: Immutability
- **Action:** Asegurarse de que los modelos de datos expuestos sean `data class` con propiedades `val` [68].
- **Bad example:**
```
class User(var name: String)
```
- **Good example:**
```
data class User(val name: String)
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### DATA_010
- **Severity:** HIGH
- **Description:** El mapeo entre los modelos de datos de infraestructura (DTOs) y los modelos de Dominio/IU debe realizarse **exclusivamente** dentro de los `Data Sources` o el `Repository` [69, 70].
- **Conditions:** language: kotlin, framework: Mapping
- **Action:** El Dominio nunca debe importar directamente una clase DTO de infraestructura (ej., `UserApiModel` con anotaciones Moshi) [69].
- **Bad example:**
```
Domain: import com.data.UserApiModel
```
- **Good example:**
```
Repository: userApiModel.toDomain()
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

---

## Persistencia

### ROOM_002
- **Severity:** HIGH
- **Description:** Se debe verificar que todas las consultas SQL (`@Query`) se definan en los `DAOs`. `Room` verifica estas consultas en tiempo de compilación [25].
- **Conditions:** language: kotlin, framework: Room
- **Action:** Asegurar la verificación de tiempo de compilación de Room para prevenir errores de SQL en tiempo de ejecución [25, 26].
- **Bad example:**
```
Definir SQL como una cadena fuera del DAO.
```
- **Good example:**
```
@Query("SELECT * FROM users") fun getUsers(): List<User>
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### ROOM_003
- **Severity:** HIGH
- **Description:** Las operaciones de `DAOs` deben exponer flujos de datos continuos usando `Flow` y operaciones de escritura/lectura única usando `suspend` [25, 27].
- **Conditions:** language: kotlin, framework: Room, Flows
- **Action:** Cambiar los métodos de consulta de `LiveData` o síncronos a `Flow` o `suspend fun` [25].
- **Bad example:**
```
@Query("...") fun getUsers(): List<User>
```
- **Good example:**
```
@Query("...") fun getUsers(): Flow<List<UserEntity>>
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### DATA_012
- **Severity:** HIGH
- **Description:** Se recomienda usar `Room` para grandes conjuntos de datos que requieran consultas complejas, integridad referencial o actualizaciones parciales [20, 21].
- **Conditions:** language: kotlin, framework: Room
- **Action:** Si se necesita persistencia de datos estructurados, usar `Room` como el SSOT local [20, 21].
- **Bad example:**
```
Usar `DataStore` para almacenar artículos de noticias.
```
- **Good example:**
```
Usar `Room` para almacenar artículos de noticias y sus autores [20].
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### DATA_013
- **Severity:** HIGH
- **Description:** Utilizar `DataStore` para la persistencia de pequeños conjuntos de datos (pares clave-valor) o configuraciones de usuario [20, 21].
- **Conditions:** language: kotlin, framework: DataStore
- **Action:** Limitar el uso de `DataStore` a configuraciones que solo necesitan recuperarse y configurarse, no consultarse [20, 21].
- **Bad example:**
```
Usar SharedPreferences para persistencia de preferencias
```
- **Good example:**
```
val Context.dataStore by preferencesDataStore('settings'); dataStore.edit { preferences -> preferences[TOKEN_KEY] = token }
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### DATA_015
- **Severity:** HIGH
- **Description:** Las `data classes` utilizadas en `DataStore` deben ser **inmutables** para mantener la consistencia y evitar errores difíciles de detectar [74].
- **Conditions:** language: kotlin, framework: DataStore, Immutability
- **Action:** Definir el tipo genérico `T` de `DataStore<T>` como una clase inmutable, preferiblemente con Protocol Buffers o JSON serializado [74].
- **Bad example:**
```
class Settings(var count: Int)
```
- **Good example:**
```
data class Settings(val count: Int)
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### ROOM_006
- **Severity:** HIGH
- **Description:** Se debe generar el esquema JSON de Room (`room.schemaLocation`) para garantizar que las migraciones sean válidas y trazables [151, 152].
- **Conditions:** language: kotlin, framework: Room
- **Action:** Configurar el procesador de anotaciones de Gradle para generar el archivo de esquema en la carpeta `schemas` del proyecto [151].
- **Bad example:**
```
No exportar schema JSON de Room
```
- **Good example:**
```
android { javaCompileOptions { annotationProcessorOptions { arguments += ["room.schemaLocation": "$projectDir/schemas"] } } }
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

---

## Concurrencia

### COROUTINE_003
- **Severity:** HIGH
- **Description:** Se prohíbe el uso de `GlobalScope` en la lógica de la aplicación, ya que dificulta las pruebas, la cancelación y el control del ciclo de vida [28].
- **Conditions:** language: kotlin, framework: Coroutines
- **Action:** Inyectar un `CoroutineScope` externo o usar `viewModelScope` o `lifecycleScope` [28].
- **Bad example:**
```
GlobalScope.launch { //... }
```
- **Good example:**
```
externalScope.launch { ... }
```
- **References:**
  - https://medium.com/@kumarsamy19792/optimizing-android-app-performance-with-kotlin-coroutines-449249f5c676
  - https://medium.com/@zabiirana27/the-coroutine-secret-even-10-year-android-developers-dont-know-02d21c3285c7

### COROUTINE_004
- **Severity:** HIGH
- **Description:** Cualquier corrutina o función `suspend` que realice bucles largos o cálculos intensivos debe incluir llamadas periódicas a `ensureActive()` o `yield()` para permitir la cancelación cooperativa [28].
- **Conditions:** language: kotlin, framework: Coroutines
- **Action:** Añadir `ensureActive()` dentro de bucles de cálculo intensivo para verificar si se canceló la corrutina [28].
- **Bad example:**
```
while (true) { longCalculation() }
```
- **Good example:**
```
while (true) { ensureActive(); longCalculation() }
```
- **References:**
  - https://medium.com/@kumarsamy19792/optimizing-android-app-performance-with-kotlin-coroutines-449249f5c676
  - https://medium.com/@zabiirana27/the-coroutine-secret-even-10-year-android-developers-dont-know-02d21c3285c7

### COROUTINE_006
- **Severity:** HIGH
- **Description:** Las `Views` (Activities, Fragments o Componibles) **no** deben activar directamente corrutinas para realizar lógica empresarial [48].
- **Conditions:** language: kotlin, framework: MVVM, Coroutines
- **Action:** Delegar la activación de corrutinas para lógica empresarial al `ViewModel` usando `viewModelScope` [48].
- **Bad example:**
```
lifecycleScope.launch { repository.saveData(item) } en un Fragment.
```
- **Good example:**
```
ViewModel.onSaveDataClicked()
```
- **References:**
  - https://medium.com/@kumarsamy19792/optimizing-android-app-performance-with-kotlin-coroutines-449249f5c676
  - https://medium.com/@zabiirana27/the-coroutine-secret-even-10-year-android-developers-dont-know-02d21c3285c7

### COROUTINE_007
- **Severity:** HIGH
- **Description:** La Capa de Presentación no debe preocuparse por cambiar el contexto a `Dispatchers.IO`, ya que las funciones del Repositorio deben ser **main-safe** [17, 18].
- **Conditions:** language: kotlin, framework: Coroutines, MVVM
- **Action:** Eliminar el uso de `withContext(Dispatchers.IO)` en el `ViewModel` si la función del repositorio ya es *main-safe* [17, 18].
- **Bad example:**
```
viewModelScope.launch { withContext(Dispatchers.IO) { repository.fetchData() } }
```
- **Good example:**
```
viewModelScope.launch { repository.fetchData() }
```
- **References:**
  - https://medium.com/@kumarsamy19792/optimizing-android-app-performance-with-kotlin-coroutines-449249f5c676
  - https://medium.com/@zabiirana27/the-coroutine-secret-even-10-year-android-developers-dont-know-02d21c3285c7

### DATA_014
- **Severity:** HIGH
- **Description:** Todas las clases en la Capa de Datos (`Repositories` y `Data Sources`) deben ser **main-safe** [17, 18].
- **Conditions:** language: kotlin, framework: Threading
- **Action:** Asegurar que las operaciones de bloqueo de larga duración se ejecuten en un subproceso apropiado (ej. `Dispatchers.IO`) [17, 18].
- **Bad example:**
```
fun readFromFile(): String = File(path).readText()
```
- **Good example:**
```
suspend fun readFromFile(): String = withContext(Dispatchers.IO) { File(path).readText() }
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### COROUTINE_008
- **Severity:** HIGH
- **Description:** Para las operaciones orientadas a la aplicación que deben sobrevivir al ciclo de vida del llamador (ej. caché de datos o marcado de favoritos), se debe inyectar y usar un `CoroutineScope` externo [92, 93].
- **Conditions:** language: kotlin, framework: Coroutines
- **Action:** Inyectar un `externalScope` (ej. `CoroutineScope(SupervisorJob() + Dispatchers.Default)`) en Repositorios o Casos de Uso que ejecuten lógica de larga duración [92, 93].
- **Bad example:**
```
viewModelScope.launch { bookmarkArticle() }
```
- **Good example:**
```
class ArticlesRepository @Inject constructor(private val externalScope: CoroutineScope) { fun bookmarkArticle(id: String) { externalScope.launch { dataSource.bookmark(id) } } }
```
- **References:**
  - https://medium.com/@kumarsamy19792/optimizing-android-app-performance-with-kotlin-coroutines-449249f5c676
  - https://medium.com/@zabiirana27/the-coroutine-secret-even-10-year-android-developers-dont-know-02d21c3285c7

### COROUTINE_009
- **Severity:** HIGH
- **Description:** Las funciones `suspend` en capas inferiores deben garantizar ser *main-safe* cambiando el contexto a `Dispatchers.IO` para I/O y a `Dispatchers.Default` para cálculos intensivos [31, 94].
- **Conditions:** language: kotlin, framework: Dispatchers
- **Action:** Usar `withContext` para el cambio de despachador dentro de las funciones que realizan el trabajo bloqueante [31].
- **Bad example:**
```
suspend fun processList() { massiveComputation() }
```
- **Good example:**
```
suspend fun processList() = withContext(Dispatchers.Default) { massiveComputation() }
```
- **References:**
  - https://medium.com/@kumarsamy19792/optimizing-android-app-performance-with-kotlin-coroutines-449249f5c676
  - https://medium.com/@zabiirana27/the-coroutine-secret-even-10-year-android-developers-dont-know-02d21c3285c7

### COROUTINE_011
- **Severity:** HIGH
- **Description:** Asegurar que las corrutinas que realizan operaciones de bloqueo sean **cancelables** mediante el uso de `ensureActive()` [28].
- **Conditions:** language: kotlin, framework: Coroutines
- **Action:** Si se realizan bucles de lectura de disco o cálculos intensivos, incluir `ensureActive()` para verificar la cancelación cooperativa [28].
- **Bad example:**
```
repeat(1000) { processLargeFile(it) }
```
- **Good example:**
```
repeat(1000) { ensureActive(); processLargeFile(it) }
```
- **References:**
  - https://medium.com/@kumarsamy19792/optimizing-android-app-performance-with-kotlin-coroutines-449249f5c676
  - https://medium.com/@zabiirana27/the-coroutine-secret-even-10-year-android-developers-dont-know-02d21c3285c7

---

## Navegación

### UI_009
- **Severity:** HIGH
- **Description:** La transferencia de datos y la navegación entre destinos deben pasar argumentos serializados a través de la URL, evitando Parcelable cuando sea posible [41, 42].
- **Conditions:** language: kotlin, framework: Navigation Compose
- **Action:** Utilizar `navArgument` con `NavType` explícito y funciones `routeForName/fromEntry` para construir y deconstruir los argumentos del destino [41].
- **Bad example:**
```
Pasar un objeto `Parcelable` grande.
```
- **Good example:**
```
Pasar `Json.encodeToString(object)` como argumento de tipo `StringType` [43].
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

### UI_015
- **Severity:** HIGH
- **Description:** Cuando el `ViewModel` establece un estado de navegación, la lógica de navegación debe residir en la IU, y se debe usar un estado adicional para gestionar la re-navegación si el destino se conserva en la pila [101, 102].
- **Conditions:** language: kotlin, framework: Navigation
- **Action:** Implementar una variable de estado booleana (`validationInProgress`) en la IU para controlar si se debe navegar automáticamente después de una validación [102].
- **Bad example:**
```
navController.navigate() dentro de ViewModel
```
- **Good example:**
```
LaunchedEffect(navigationEvent) { event?.let { navController.navigate(it) } }
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

---

## Dominio

### DOMAIN_001
- **Severity:** HIGH
- **Description:** Cada `Use Case` (o Interactor) debe tener una responsabilidad única, siguiendo el Principio de Responsabilidad Única (SRP) [80, 81].
- **Conditions:** language: kotlin, framework: Use Cases
- **Action:** Asegurar que los Use Cases sean atómicos (ej., `GetUserDetailsUseCase`, no `HandleUserOperationsUseCase`) [80].
- **Bad example:**
```
class UserDataProcessorUseCase
```
- **Good example:**
```
class LogOutUserUseCase [82]
```
- **References:**
  - https://medium.com/@ys.yogendra22/mvvm-with-clean-architecture-851262ccd919
  - https://medium.com/@sivavishnu0705/mvvm-coordinator-in-android-building-a-clean-and-scalable-architecture-201cb0a321bf

### DOMAIN_002
- **Severity:** HIGH
- **Description:** Los `Use Cases` deben ser implementados como clases **sin estado** (`stateless`), aceptando solo dependencias inyectadas y promoviendo la reutilización [80, 82].
- **Conditions:** language: kotlin, framework: Use Cases
- **Action:** Evitar el estado mutable interno (`var`) dentro de la clase `Use Case` [80].
- **Bad example:**
```
class GetUserUseCase { private var cachedId: String }
```
- **Good example:**
```
class GetUserUseCase @Inject constructor(...) { ... }
```
- **References:**
  - https://medium.com/@ys.yogendra22/mvvm-with-clean-architecture-851262ccd919
  - https://medium.com/@sivavishnu0705/mvvm-coordinator-in-android-building-a-clean-and-scalable-architecture-201cb0a321bf

### DOMAIN_003
- **Severity:** HIGH
- **Description:** La validación de la lógica de negocio (ej. verificación de formato de datos, cumplimiento de requisitos) debe ocurrir dentro del `Use Case`, no en la UI [80, 83].
- **Conditions:** language: kotlin, framework: Use Cases
- **Action:** Mover la lógica de validación de entradas que define las reglas de negocio al Dominio, antes de interactuar con el Repositorio [80].
- **Bad example:**
```
ViewModel: if (email.contains('@')) useCase.execute(email)
```
- **Good example:**
```
UseCase: fun execute(email) { require(email.isValid()) { throw InvalidEmail } }
```
- **References:**
  - https://medium.com/@ys.yogendra22/mvvm-with-clean-architecture-851262ccd919
  - https://medium.com/@sivavishnu0705/mvvm-coordinator-in-android-building-a-clean-and-scalable-architecture-201cb0a321bf

### DOMAIN_006
- **Severity:** HIGH
- **Description:** Las Entidades deben encapsular las **Reglas Críticas de Negocio** y los **Datos Críticos de Negocio** de forma independiente [87, 88].
- **Conditions:** language: kotlin, framework: Entities
- **Action:** Asegurar que la Entidad no dependa de frameworks, bases de datos o IU, y que contenga lógica empresarial fundamental (ej. `getFullName()`) [89].
- **Bad example:**
```
data class User(val id: String, val firstName: String, val lastName: String)
```
- **Good example:**
```
data class User(\n    val id: String,\n    val firstName: String,\n    val lastName: String\n) {\n    fun getFullName() = "$firstName $lastName"\n    fun isValid() = id.isNotEmpty()\n}
```
- **References:**
  - https://medium.com/@ys.yogendra22/mvvm-with-clean-architecture-851262ccd919
  - https://medium.com/@sivavishnu0705/mvvm-coordinator-in-android-building-a-clean-and-scalable-architecture-201cb0a321bf

### DOMAIN_007
- **Severity:** HIGH
- **Description:** Los modelos de datos que cruzan los límites de la arquitectura (Entidades, Request/Response Models) deben ser estructuras de datos simples sin dependencias que violen la Regla de Dependencia [90, 91].
- **Conditions:** language: kotlin, framework: Boundaries
- **Action:** Evitar pasar objetos `Entity` o filas de bases de datos directamente a través de las fronteras; usar objetos de transferencia de datos simples [91].
- **Bad example:**
```
UseCase recibe un `HttpRequest`.
```
- **Good example:**
```
UseCase recibe un `Request` (data class simple) [90].
```
- **References:**
  - https://medium.com/@ys.yogendra22/mvvm-with-clean-architecture-851262ccd919
  - https://medium.com/@sivavishnu0705/mvvm-coordinator-in-android-building-a-clean-and-scalable-architecture-201cb0a321bf

---

## Arquitectura

### ARCH_005
- **Severity:** HIGH
- **Description:** Los ViewModels no deben contener referencias a tipos relacionados con el ciclo de vida de Android (`Activity`, `Context`, `Fragment`) para mantener la independencia [53, 54].
- **Conditions:** language: kotlin, framework: MVVM
- **Action:** Mover la lógica que requiere `Context` a la Capa de Datos (si es I/O) o a la Capa de Presentación (si es UI-relacionada) [53, 54].
- **Bad example:**
```
class ViewModel(context: Context)
```
- **Good example:**
```
Usar el `Application Context` si es absolutamente necesario, inyectado por DI.
```
- **References:**
  - https://medium.com/@sivavishnu0705/mvvm-coordinator-in-android-building-a-clean-and-scalable-architecture-201cb0a321bf
  - https://medium.com/@sandeepkella23/what-top-1-android-engineers-know-about-android-architecture-that-others-dont-34164c7fad0a

### ARCH_101
- **Severity:** HIGH
- **Description:** Se debe evitar el acoplamiento temporal entre módulos causado por orden implícito de inicialización o side-effects de arranque.
- **Conditions:** language: kotlin, principle: Low Coupling
- **Action:** Explicitar dependencias de arranque con contratos de inicialización, idempotencia y validaciones de estado para evitar fallos por orden de ejecución.
- **Bad example:**
```
FeatureB asume que FeatureA inicializó un singleton global antes de su primer uso.
```
- **Good example:**
```
FeatureB recibe dependencias por DI y valida precondiciones de inicialización en un ApplicationInitializer explícito.
```
- **References:**
  - https://martinfowler.com/bliki/TemporalCoupling.html
  - https://developer.android.com/topic/libraries/app-startup

---

## DI

### ARCH_006
- **Severity:** HIGH
- **Description:** Se debe usar un framework de Inyección de Dependencias (DI) como `Hilt` o `Koin` para gestionar y proporcionar dependencias de manera segura y escalable [109, 110].
- **Conditions:** language: kotlin, framework: DI
- **Action:** Garantizar que los Repositorios, `Use Cases` y `ViewModels` se inyecten a través del constructor con DI [111, 112].
- **Bad example:**
```
Manual instantiation of dependencies.
```
- **Good example:**
```
@Inject constructor(repository: MyRepository)
```
- **References:**
  - https://medium.com/@sivavishnu0705/mvvm-coordinator-in-android-building-a-clean-and-scalable-architecture-201cb0a321bf
  - https://medium.com/@sandeepkella23/what-top-1-android-engineers-know-about-android-architecture-that-others-dont-34164c7fad0a

### DI_001
- **Severity:** HIGH
- **Description:** La configuración de `Retrofit` (Base URL, `OkHttpClient`, `ConverterFactory`) debe ser definida en módulos de DI (`NetworkModule`) y proporcionada como dependencias `Singleton` [133-135].
- **Conditions:** language: kotlin, framework: Hilt, Retrofit
- **Action:** Centralizar la configuración de red y la provisión de servicios (`ConcreteDataService`) en módulos inyectables [135, 136].
- **Bad example:**
```
object RetrofitClient { val instance = Retrofit.Builder().baseUrl(BASE_URL).build() }
```
- **Good example:**
```
@Module @InstallIn(SingletonComponent::class) object NetworkModule { @Provides @Singleton fun provideRetrofit(): Retrofit = Retrofit.Builder().baseUrl(BASE_URL).build() }
```
- **References:**
  - https://medium.com/@sauravsushant58_66393/complete-guide-dependency-injection-in-android-4f5017c2ed93
  - https://renan-costaalencar.medium.com/from-zero-to-hero-with-hilt-c0eadfb89f85

### DI_002
- **Severity:** HIGH
- **Description:** La provisión de `CoroutineDispatcher` (ej. `Dispatchers.IO`) a los `Use Cases` debe hacerse a través de una `Configuration` inyectable para facilitar las pruebas [32, 137].
- **Conditions:** language: kotlin, framework: Hilt, Coroutines
- **Action:** Definir y proporcionar un `UseCase.Configuration` que contenga el `CoroutineDispatcher` deseado [32, 137].
- **Bad example:**
```
class UseCase { private val ioDispatcher = Dispatchers.IO }
```
- **Good example:**
```
@Module @InstallIn(SingletonComponent::class) object DispatchersModule { @Provides @IoDispatcher fun provideIoDispatcher() = Dispatchers.IO }
```
- **References:**
  - https://medium.com/@sauravsushant58_66393/complete-guide-dependency-injection-in-android-4f5017c2ed93
  - https://renan-costaalencar.medium.com/from-zero-to-hero-with-hilt-c0eadfb89f85

### DI_004
- **Severity:** HIGH
- **Description:** La Inyección de Dependencias debe ser utilizada para obtener las dependencias de `WorkManager` (Worker instances) a través de la anotación `@HiltWorker` y `AssistedInject` [139, 140].
- **Conditions:** language: kotlin, framework: WorkManager, Hilt
- **Action:** Asegurar que las dependencias de los `Worker` se inyecten correctamente para mantener la testabilidad y el control [139].
- **Bad example:**
```
class MyViewModel : ViewModel() { private val repository = MyRepository() }
```
- **Good example:**
```
@HiltViewModel class MyViewModel @Inject constructor(private val repository: MyRepository) : ViewModel()
```
- **References:**
  - https://medium.com/@sauravsushant58_66393/complete-guide-dependency-injection-in-android-4f5017c2ed93
  - https://renan-costaalencar.medium.com/from-zero-to-hero-with-hilt-c0eadfb89f85

---

## Seguridad/Persistencia

### SEC_001
- **Severity:** HIGH
- **Description:** Los datos privados o sensibles (incluidas las credenciales) deben almacenarse en el **almacenamiento interno** (`internal storage`) de la aplicación [113, 114].
- **Conditions:** language: kotlin
- **Action:** Evitar guardar datos privados en almacenamiento externo, que es globalmente legible [113, 115].
- **Bad example:**
```
context.openFileOutput("sensitive.txt", MODE_WORLD_READABLE)
```
- **Good example:**
```
val masterKey = MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build(); EncryptedSharedPreferences.create(context, "secret_prefs", masterKey, ...)
```
- **References:**
  - https://proandroiddev.com/ci-cd-secrets-leaks-how-to-secure-your-android-build-pipeline-4f430796eb60
  - https://medium.com/@weevanssord/tips-to-ensure-app-security-on-android-platform-32951994337f

### SEC_007
- **Severity:** HIGH
- **Description:** Se debe usar `DataStore` para almacenar información sensible como tokens de autenticación debido a su diseño asíncrono y la posibilidad de integración con Tink para cifrado [73, 126].
- **Conditions:** language: kotlin, framework: DataStore
- **Action:** Migrar credenciales o tokens de `SharedPreferences` a `DataStore` [73].
- **Bad example:**
```
Almacenar tokens sin cifrar
```
- **Good example:**
```
val masterKey = MasterKey.Builder(context).setKeyScheme(AES256_GCM).build(); val encryptedPrefs = EncryptedSharedPreferences.create(context, "secret", masterKey, ...)
```
- **References:**
  - https://proandroiddev.com/ci-cd-secrets-leaks-how-to-secure-your-android-build-pipeline-4f430796eb60
  - https://medium.com/@weevanssord/tips-to-ensure-app-security-on-android-platform-32951994337f

---

## Sistema/Background

### SEC_003
- **Severity:** HIGH
- **Description:** Las tareas que deben persistir a través del cierre de la aplicación o reinicio del dispositivo (operaciones orientadas a la empresa) deben usar `WorkManager` [13, 14, 118].
- **Conditions:** language: kotlin, framework: WorkManager
- **Action:** Usar `PeriodicWorkRequest` o `OneTimeWorkRequest` para la programación de tareas asíncronas garantizadas [119].
- **Bad example:**
```
Usar un `Service` o `AlarmManager` antiguo para el backup de datos.
```
- **Good example:**
```
Usar `UploadMessagesWorker` programado por `WorkManager` [120].
```
- **References:**
  - https://proandroiddev.com/ci-cd-secrets-leaks-how-to-secure-your-android-build-pipeline-4f430796eb60
  - https://medium.com/@weevanssord/tips-to-ensure-app-security-on-android-platform-32951994337f

---

## Seguridad/Memory

### SEC_005
- **Severity:** HIGH
- **Description:** Se prohíbe pasar un `Activity Context` a clases de larga duración (Singletons, Repositorios) para prevenir fugas de memoria (`memory leaks`) [118, 124].
- **Conditions:** language: kotlin
- **Action:** Si se necesita `Context`, usar el `Application Context` inyectado, que tiene un ciclo de vida más largo y seguro [118].
- **Bad example:**
```
Singleton(activityContext: Activity)
```
- **Good example:**
```
Singleton(appContext: ApplicationContext)
```
- **References:**
  - https://proandroiddev.com/ci-cd-secrets-leaks-how-to-secure-your-android-build-pipeline-4f430796eb60
  - https://medium.com/@weevanssord/tips-to-ensure-app-security-on-android-platform-32951994337f

---

## Flows

### KOTLIN_015
- **Severity:** HIGH
- **Description:** Se debe usar el operador `map` en `Flow` para realizar transformaciones de datos, manteniendo la naturaleza reactiva del flujo [32, 128].
- **Conditions:** language: kotlin, framework: Flows
- **Action:** Garantizar que el mapeo entre modelos de capa se realice dentro del flujo con operadores funcionales [128].
- **Bad example:**
```
flow.collect { emit(transform(it)) }
```
- **Good example:**
```
flow.map { transform(it) }
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

---

## Lógica Negocio

### LOGIC_001
- **Severity:** HIGH
- **Description:** La lógica empresarial compleja no debe residir en `MainActivity`, `Activity` o `Fragment`, sino delegarse a capas inferiores (ViewModel, Use Case, Repository) [142].
- **Conditions:** language: kotlin
- **Action:** Mover la lógica que puede ser probada unitariamente fuera de los componentes del framework de Android [142].
- **Bad example:**
```
Mover la concatenación de datos de la UI a `MainActivity` [142].
```
- **Good example:**
```
Mover la concatenación a un `ViewModel` o un `Converter` [143].
```
- **References:**
  - https://medium.com/@sivavishnu0705/the-single-constructor-rule-why-your-android-fragment-needs-a-default-327a8f468410
  - https://blog.stackademic.com/android-memory-leaks-common-causes-and-how-to-fix-them-69e36696e2ae

---

## Performance

### PERF_002
- **Severity:** HIGH
- **Description:** Al trabajar con I/O o red (`suspend fun`), se debe usar `withContext(Dispatchers.IO)` para asegurar que estas operaciones no bloqueen el hilo principal [31, 146].
- **Conditions:** language: kotlin, framework: Coroutines
- **Action:** Verificar que las operaciones de guardar o leer archivos grandes, red o base de datos se ejecuten en el despachador `IO` [31, 146].
- **Bad example:**
```
suspend fun loadData() { val data = database.query() }
```
- **Good example:**
```
suspend fun loadData() = withContext(Dispatchers.IO) { database.query() }
```
- **References:**
  - https://medium.com/@ahmadrazaofficial159/optimising-android-performance-129897406a76
  - https://medium.com/@sivavishnu0705/the-blueprint-for-speed-a-deep-dive-into-android-baseline-profiles-d968f085ba16

### PERF_004
- **Severity:** HIGH
- **Description:** La manipulación de `MutableList` debe evitarse en `Composable`. Se debe exponer `List<T>` (inmutable) desde el estado para evitar romper el mecanismo de seguimiento de Compose [33].
- **Conditions:** language: kotlin, framework: Compose
- **Action:** El `ViewModel` debe exponer listas como `List<T>` y no como `MutableList<T>` [33].
- **Bad example:**
```
var items: MutableList<T>
```
- **Good example:**
```
val items: List<T>
```
- **References:**
  - https://medium.com/@ahmadrazaofficial159/optimising-android-performance-129897406a76
  - https://medium.com/@sivavishnu0705/the-blueprint-for-speed-a-deep-dive-into-android-baseline-profiles-d968f085ba16

---

## I/O

### DATA_022
- **Severity:** HIGH
- **Description:** La capa de datos debe ser diseñada para el soporte *offline-first*, consultando la fuente de datos local (Room/DataStore) antes de la red [18, 128].
- **Conditions:** language: kotlin, framework: Repository Pattern
- **Action:** El Repositorio debe orquestar el flujo: intentar obtener datos locales primero, y si no están disponibles, obtenerlos de la red e insertarlos localmente [128].
- **Bad example:**
```
Repository que solo funciona con conexión
```
- **Good example:**
```
fun getArticles(): Flow<List<Article>> = flow {\n    emit(database.getAll())\n    try {\n        val remote = api.fetch()\n        database.insertAll(remote)\n    } catch(e: IOException) { }\n}
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

---

## WorkManager

### WORKER_002
- **Severity:** HIGH
- **Description:** Se debe definir restricciones (`Constraints`) apropiadas para los `WorkRequest` (ej. tipo de red, batería) para la ejecución eficiente y garantizada [157, 158].
- **Conditions:** language: kotlin, framework: WorkManager
- **Action:** Asegurar que las tareas asíncronas solo se ejecuten cuando las condiciones necesarias se cumplan (ej. `NetworkType.CONNECTED` para red) [157, 158].
- **Bad example:**
```
val request = OneTimeWorkRequestBuilder<UploadWorker>().build()
```
- **Good example:**
```
val constraints = Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build(); val request = OneTimeWorkRequestBuilder<UploadWorker>().setConstraints(constraints).build()
```
- **References:**
  - https://medium.com/tecoble/workmanager%EB%A1%9C-%EB%B0%B0%EC%9A%B0%EB%8A%94-%EC%95%88%EC%A0%95%EC%A0%81%EC%9D%B8-%EB%B0%B1%EA%B7%B8%EB%9D%BC%EC%9A%B4%EB%93%9C-%EC%9E%91%EC%97%85-%EC%84%A4%EA%B3%84-06e01fba67d3
  - https://medium.com/codetodeploy/workmanager-in-android-a-complete-guide-with-real-world-implementation-and-interview-prep-7fdcddf03c59

---

## Red

### NETWORK_001
- **Severity:** HIGH
- **Description:** Los servicios de Retrofit deben usar la palabra clave `suspend` para sus funciones de API, facilitando la integración con `Coroutines` y `Flow` [127, 164].
- **Conditions:** language: kotlin, framework: Retrofit, Coroutines
- **Action:** Asegurar que los métodos de la interfaz `Service` sean funciones de suspensión [127, 164].
- **Bad example:**
```
interface ApiService { @GET("users") fun getUsers(): Call<List<User>> }
```
- **Good example:**
```
interface ApiService { @GET("users") suspend fun getUsers(): List<User> }
```
- **References:**
  - https://medium.com/@za7922997/mastering-networking-web-services-in-android-development-retrofit-rest-apis-json-services-c8201f8771bb
  - https://devharshmittal.medium.com/why-retrofit-3-0-0-matters-even-if-2-9-0-still-works-77d7bd817061

---

## CI/CD

### CI_002
- **Severity:** HIGH
- **Description:** Un Pull Request no puede ser marcado como listo para revisión si las pruebas unitarias y de integración fallan en el entorno de CI [129].
- **Conditions:** language: kotlin, framework: CI/CD
- **Action:** Integrar el paso de prueba (`./gradlew test connectedCheck`) en el flujo de trabajo de CI (ej. GitHub Actions) antes de permitir la revisión de código [175].
- **Bad example:**
```
Permitir merge sin que pasen las pruebas
```
- **Good example:**
```
GitHub Actions + Branch Protection: Require status checks before merging
```
- **References:**
  - https://medium.com/@nurberinkarakus/b%C3%B6l%C3%BCm-4-ci-cd-gradle-y%C3%BCksek-performansl%C4%B1-android-build-pipelinelar%C4%B1-kurmak-remote-cache-25aceeccfe49
  - https://medium.com/@xenoterracide/skipping-pre-releases-when-youre-using-dynamic-dependencies-part-4-31fab3c38ce3

### CI_004
- **Severity:** HIGH
- **Description:** Se debe asegurar que la firma de la aplicación (`keystore`) y otros secretos (ej. `GOOGLE_SERVICES_JSON`) se gestionen de forma segura en las variables de entorno o secretos de la plataforma CI/CD [123, 180].
- **Conditions:** language: kotlin, framework: Security
- **Action:** Nunca almacenar archivos de firma (`.jks`) en el repositorio. Usar `base64` para codificar la clave y almacenarla como secreto de CI [180].
- **Bad example:**
```
git add release.jks; git commit
```
- **Good example:**
```
Cifrar: openssl base64 < keystore.jks > keystore.txt; GitHub Secrets + CI: echo $KEYSTORE_BASE64 | base64 -d > keystore.jks
```
- **References:**
  - https://medium.com/@nurberinkarakus/b%C3%B6l%C3%BCm-4-ci-cd-gradle-y%C3%BCksek-performansl%C4%B1-android-build-pipelinelar%C4%B1-kurmak-remote-cache-25aceeccfe49
  - https://medium.com/@xenoterracide/skipping-pre-releases-when-youre-using-dynamic-dependencies-part-4-31fab3c38ce3

### CI_006
- **Severity:** HIGH
- **Description:** Se prohíbe el registro (`Logcat`) o la depuración en las compilaciones de lanzamiento (`release builds`), ya que expone información sensible y disminuye el rendimiento [1].
- **Conditions:** language: kotlin
- **Action:** Utilizar `no-op` de librerías de depuración (ej. `Chucker`) en las compilaciones de lanzamiento y wrappers para `Log.d()` [173].
- **Bad example:**
```
Log.d(TAG, "User data: $userData") en producción
```
- **Good example:**
```
if (BuildConfig.DEBUG) { Log.d(TAG, info) }; releaseImplementation(libs.chucker.no.op)
```
- **References:**
  - https://medium.com/@nurberinkarakus/b%C3%B6l%C3%BCm-4-ci-cd-gradle-y%C3%BCksek-performansl%C4%B1-android-build-pipelinelar%C4%B1-kurmak-remote-cache-25aceeccfe49
  - https://medium.com/@xenoterracide/skipping-pre-releases-when-youre-using-dynamic-dependencies-part-4-31fab3c38ce3

---

## Privacidad

### PRIV_101
- **Severity:** HIGH
- **Description:** Los eventos de analytics deben anonimizarse y filtrar PII/secretos antes de enviarse a terceros o sistemas internos de telemetría.
- **Conditions:** language: kotlin, framework: Analytics/Privacy
- **Action:** Definir un contrato de eventos con allowlist de campos y aplicar sanitización previa al envío; bloquear email, teléfono, tokens y payloads libres sin control.
- **Bad example:**
```
analytics.logEvent("purchase", bundleOf("email" to user.email, "token" to sessionToken))
```
- **Good example:**
```
analytics.logEvent("purchase", bundleOf("user_id_hash" to hash(user.id), "plan" to planType))
```
- **References:**
  - https://developer.android.com/privacy-and-security/privacy-best-practices
  - https://firebase.google.com/docs/analytics/configure-data-collection

---

## Contratos entre Módulos

### CONTRACT_101
- **Severity:** HIGH
- **Description:** Las interfaces entre módulos deben estar versionadas y verificadas para evitar rupturas por contratos implícitos o cambios incompatibles.
- **Conditions:** language: kotlin, framework: Module Contracts
- **Action:** Definir contratos tipados, versionado semántico y tests de compatibilidad (contract/integration tests) en los límites entre módulos.
- **Bad example:**
```
Módulo A cambia un campo requerido en una respuesta sin actualizar consumidores ni tests.
```
- **Good example:**
```
Módulo A publica contrato v2, mantiene compatibilidad temporal y valida consumidores con tests de contrato.
```
- **References:**
  - https://martinfowler.com/articles/microservice-testing/#contract-testing
  - https://docs.pact.io/

---

## Resiliencia

### RES_101
- **Severity:** HIGH
- **Description:** Los flujos críticos deben definir modo degradado (graceful degradation) ante caída de dependencias externas o internas.
- **Conditions:** language: kotlin, framework: Resilience/Fallback
- **Action:** Implementar estrategias de fallback (cache, reintento acotado, circuito abierto, mensaje de contingencia) y probar escenarios de fallo.
- **Bad example:**
```
Si falla el backend de catálogo, la pantalla queda en error bloqueante sin alternativa.
```
- **Good example:**
```
Ante fallo de backend, la app muestra último estado válido en cache y desactiva acciones no críticas.
```
- **References:**
  - https://learn.microsoft.com/azure/architecture/patterns/circuit-breaker
  - https://developer.android.com/topic/architecture/data-layer/offline-first
