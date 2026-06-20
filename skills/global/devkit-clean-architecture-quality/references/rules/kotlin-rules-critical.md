# Copilot Guidelines: Android (Kotlin) — CRITICAL

---

Total rules: **14**

## Dependencias

### ARCH_001
- **Severity:** CRITICAL
- **Description:** El código fuente debe seguir la Regla de Dependencia: las dependencias deben apuntar solo hacia adentro, hacia políticas de nivel superior (capas internas).
- **Conditions:** language: kotlin, principle: Dependency Rule
- **Action:** Reestructurar módulos para que las capas externas (UI, Data) dependan de las capas internas (Domain, Abstracciones).
- **Bad example:**
```
:domain depende de :data-repository
```
- **Good example:**
```
:data-repository depende de :domain (que contiene interfaces/abstracciones)
```
- **References:**
  - https://medium.com/@farimarwat/clean-architecture-in-kotlin-android-1b523ae5b6b0
  - https://medium.com/@naeem0313/android-clean-architecture-fcf69a0bf033

---

## Capas

### ARCH_002
- **Severity:** CRITICAL
- **Description:** La capa de IU (Componibles, Actividades, ViewModels) no debe interactuar directamente con fuentes de datos (Databases, DataStore, APIs de Firebase), sino a través de Repositorios.
- **Conditions:** language: kotlin, source_type: UI
- **Action:** Delegar el acceso a los datos a la capa de Repositorio para mantener la abstracción.
- **Bad example:**
```
class PostViewModel(private val database: AppDatabase) : ViewModel() {
    fun loadPosts() {
        viewModelScope.launch {
            val posts = database.postDao().getAllPosts()
            _uiState.value = UiState.Success(posts)
        }
    }
}
```
- **Good example:**
```
class PostViewModel(private val repository: PostRepository) : ViewModel() {
    fun loadPosts() {
        viewModelScope.launch {
            val posts = repository.getAllPosts()
            _uiState.value = UiState.Success(posts)
        }
    }
}
```
- **References:**
  - https://medium.com/androiddevelopers/repository-pattern-in-android-c31d0268118c
  - https://proandroiddev.com/clean-architecture-data-flow-dependency-rule-615ffdd79e29

### ARCH_005
- **Severity:** CRITICAL
- **Description:** Evitar crear componentes clasificados como 'Zona de Dolor Arquitectónica' (0 estabilidad, 0 abstracción), ya que son extremadamente difíciles de cambiar y mantener.
- **Conditions:** language: kotlin
- **Action:** Introducir abstracciones (interfaces) o aumentar la estabilidad del componente para mitigar el acoplamiento.
- **Bad example:**
```
Clase concreta volátil (sujeta a cambios) usada por muchas capas internas.
```
- **Good example:**
```
Introducir una interfaz/clase abstracta y aplicar el Principio de Inversión de Dependencia (DIP).
```
- **References:**
  - https://medium.com/@farimarwat/clean-architecture-in-kotlin-android-1b523ae5b6b0
  - https://medium.com/@astamato/start-making-your-android-app-more-secure-today-bf9bb22be353

---

## Excepciones

### ARCH_003
- **Severity:** CRITICAL
- **Description:** Evitar capturar excepciones genéricas (como TooGenericExceptionCaught) o 'tragarse' excepciones (SwallowedException), ya que ocultan errores críticos y llevan a estados inconsistentes.
- **Conditions:** language: kotlin, pattern: catch(e: Exception)
- **Action:** Capturar solo tipos de excepciones específicos y relevantes, o re-lanzar aquellas que no se puedan manejar adecuadamente.
- **Bad example:**
```
try { ... } catch (e: Exception) { e.printStackTrace() }
```
- **Good example:**
```
try { ... } catch (e: NetworkException) { throw UseCaseException.PostException(e) }
```
- **References:**
  - https://medium.com/@smith.emily2584/mastering-java-best-practices-a-guide-for-developers-and-businesses-127d3c40e330
  - https://medium.com/@MohamedManbar/exception-handling-in-java-best-practices-with-examples-3181ab4cadbe

---

## Release

### ARCH_004
- **Severity:** CRITICAL
- **Description:** La activación de registros (Logcat) o la depuración en las compilaciones de lanzamiento (Release) expone información sensible y disminuye el rendimiento.
- **Conditions:** language: all
- **Action:** Asegurar que el logging y las herramientas de depuración estén deshabilitados para compilaciones de lanzamiento (Release).
- **Bad example:**
```
if (BuildConfig.DEBUG) Log.d('TAG', 'User data: $user')
```
- **Good example:**
```
Usar herramientas como Crashlytics para errores específicos, no logs generales.
```
- **References:**
  - https://proandroiddev.com/efficient-logging-in-kotlin-with-proguard-optimization-452bdac5c016
  - https://medium.com/@supsabhi/effortless-android-logging-with-timber-and-kotlin-f0aaa0a701b7

---

## Persistencia

### ROOM_001
- **Severity:** CRITICAL
- **Description:** Está prohibido interactuar directamente con `SQLiteOpenHelper` o las APIs nativas de SQLite. `Room` es la capa de abstracción obligatoria para la gestión de datos estructurados [25].
- **Conditions:** language: kotlin, framework: Room
- **Action:** Reestructurar el acceso a la base de datos para usar `Room` [25].
- **Bad example:**
```
val db = SQLiteDatabase.openOrCreateDatabase(...)
```
- **Good example:**
```
Usar un DAO de Room.
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

### DATA_018
- **Severity:** CRITICAL
- **Description:** Nunca crear más de una instancia de `DataStore` para un archivo dado en el mismo proceso, ya que puede romper la funcionalidad [74].
- **Conditions:** language: kotlin, framework: DataStore
- **Action:** Usar el delegado de propiedad `preferencesDataStore` o `dataStore` a nivel superior en el archivo Kotlin para asegurar una instancia Singleton [76, 77].
- **Bad example:**
```
DataStore<Preferences>(file1); DataStore<Preferences>(file1)
```
- **Good example:**
```
val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = 'settings')
```
- **References:**
  - https://blog.venturemagazine.net/mastering-local-data-a-comprehensive-guide-to-room-persistence-library-in-android-767b6f394c05
  - https://medium.com/@tejbhansahu0.ts/database-standards-for-android-room-sqlite-d355be3da068

---

## Concurrencia

### COROUTINE_001
- **Severity:** CRITICAL
- **Description:** Los bloques `try-catch` que envuelven corrutinas **no deben consumir** la `CancellationException` sin relanzarla, para mantener la cancelación cooperativa [28].
- **Conditions:** language: kotlin, framework: Coroutines
- **Action:** Relanzar `CancellationException` o capturar solo tipos específicos de excepciones [28].
- **Bad example:**
```
catch (e: Exception) { Log.e("TAG", "Cancelled") }
```
- **Good example:**
```
catch (e: CancellationException) { throw e } catch (e: Exception) { ... }
```
- **References:**
  - https://medium.com/@kumarsamy19792/optimizing-android-app-performance-with-kotlin-coroutines-449249f5c676
  - https://medium.com/@zabiirana27/the-coroutine-secret-even-10-year-android-developers-dont-know-02d21c3285c7

---

## Compose

### UI_003
- **Severity:** CRITICAL
- **Description:** Se prohíbe pasar una lista mutable (`MutableList`) a un `LazyColumn` o `LazyRow`. Se debe pasar una lista inmutable (`List<T>`) [33].
- **Conditions:** language: kotlin, framework: Compose, Performance
- **Action:** Usar la lista inmutable expuesta por el `ViewModel` (`List<T>`) para evitar romper el mecanismo de seguimiento de Compose [33].
- **Bad example:**
```
LazyColumn { items(mutableListOf(item1)) { ... } }
```
- **Good example:**
```
LazyColumn { items(list.toList()) { ... } }
```
- **References:**
  - https://medium.com/@sixtinbydizora/compose-ui-performance-myths-what-makes-your-app-slow-287f091c17af
  - https://medium.com/@dharmakshetri/recomposition-deep-dive-with-counterscreen-example-7ac8f775ec84

---

## Estilo/Herramientas

### KOTLIN_006
- **Severity:** CRITICAL
- **Description:** Se prohíbe capturar excepciones genéricas (`TooGenericExceptionCaught`) o 'tragarse' excepciones (`SwallowedException`), ya que ocultan errores críticos [1].
- **Conditions:** language: kotlin
- **Action:** Reemplazar `catch (e: Exception)` con tipos de excepciones específicos y re-lanzar aquellas que no se pueden manejar [1].
- **Bad example:**
```
try { ... } catch (e: Exception) { // Silent fail }
```
- **Good example:**
```
try { ... } catch (e: NetworkException) { ... }
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

---

## UDF

### UDF_001
- **Severity:** CRITICAL
- **Description:** Los `ViewModels` **no deben enviar eventos transitorios** (ej. navegación, `Snackbar`) a la IU a través de canales (`Channels`) o `streams` únicos [1, 51].
- **Conditions:** language: kotlin, framework: UDF, State Flow
- **Action:** El evento debe modelarse como una **actualización del estado de la IU** (`uiState`) para garantizar la entrega y la reproducibilidad [1, 51].
- **Bad example:**
```
_singleEvent.send(NavigationEvent.ToLogin)
```
- **Good example:**
```
uiState.update { it.copy(navigationTarget = NavigationTarget.Login) }
```
- **References:**
  - https://jamshidbekboynazarov.medium.com/from-mvp-to-mvi-why-modern-android-apps-are-moving-to-unidirectional-data-flow-17acd3d17733
  - https://medium.com/@shishirshiv007/mvi-part-1-why-mvi-works-better-than-mvvm-in-jetpack-compose-apps-420331279fb5

---

## Estilo/Idomático

### KOTLIN_010
- **Severity:** CRITICAL
- **Description:** El uso excesivo y no justificado de `!!` (operador de aserción no nula) está prohibido, ya que anula el sistema de seguridad de nulos de Kotlin y aumenta el riesgo de `NullPointerException` [44].
- **Conditions:** language: kotlin
- **Action:** Reemplazar `!!` con `?.` y `?:` o con bloques `require/check` [44].
- **Bad example:**
```
val name = user.name!!
```
- **Good example:**
```
val name = user?.name ?: throw IllegalStateException(...)
```
- **References:**
  - https://kabi20.medium.com/access-to-external-media-files-with-permission-handling-in-kotlin-87deca2d3fbe
  - https://medium.com/@esracangungor/dynamic-shortcuts-in-android-with-kotlin-1d4ed2c64f9b

---

## Seguridad

### SEC_004
- **Severity:** CRITICAL
- **Description:** Las claves de API (`API Keys`), credenciales o secretos no deben ser codificados o confirmados al repositorio de código fuente [121, 122].
- **Conditions:** language: kotlin
- **Action:** Usar mecanismos de secretos de Gradle (ej. `secrets-gradle-plugin`) o de CI/CD (ej. `GitHub Secrets`) para la gestión de claves [121, 123].
- **Bad example:**
```
const val API_KEY = "abcd123"
```
- **Good example:**
```
Referenciar la clave desde `BuildConfig` o `Secrets`.
```
- **References:**
  - https://proandroiddev.com/ci-cd-secrets-leaks-how-to-secure-your-android-build-pipeline-4f430796eb60
  - https://medium.com/@weevanssord/tips-to-ensure-app-security-on-android-platform-32951994337f

### SEC_101
- **Severity:** CRITICAL
- **Description:** Está prohibido almacenar secretos, tokens, credenciales o datos sensibles en texto claro en almacenamiento local (SharedPreferences, archivos planos, DB sin cifrar).
- **Conditions:** language: kotlin, framework: Security/Storage
- **Action:** Usar Android Keystore, cifrado en reposo y políticas de rotación/revocación de credenciales; eliminar valores sensibles de logs y backups.
- **Bad example:**
```
sharedPrefs.edit().putString("access_token", token).apply()
```
- **Good example:**
```
val encryptedPrefs = EncryptedSharedPreferences.create(...); encryptedPrefs.edit().putString("access_token", token).apply()
```
- **References:**
  - https://developer.android.com/privacy-and-security/risks/unsafe-storage-of-sensitive-data
  - https://developer.android.com/topic/security/best-practices
