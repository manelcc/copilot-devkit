---
name: "android-xml-java-patterns"
description: >
  Skill de patrones Android legacy con XML + Java. Cubre ViewBinding, Retrofit,
  Room, MVVM legacy con LiveData y recomendaciones de migración gradual a Kotlin
  y Jetpack Compose para proyectos existentes.
triggers:
  - "patron android legacy"
  - "android xml java"
  - "viewbinding patron"
  - "retrofit android"
  - "room android"
  - "mvvm legacy android"
  - "livedata patron"
  - "antipatron android xml"
  - "migrar android a compose"
  - "android java a kotlin"
  - "asynctask alternativa"
  - "fragment android legacy"
non_triggers:
  - "jetpack compose exclusivamente (usar android-patterns)"
  - "kotlin multiplatform o kmp"
  - "backend o servidor"
  - "infraestructura ci/cd"
---

# Android XML + Java Patterns

## Purpose

Proporcionar una guía práctica de patrones para desarrollar y mantener apps Android
legacy escritas en Java con layouts XML. Cubre los bloques fundamentales: ViewBinding,
Retrofit para red, Room para persistencia, MVVM con LiveData y una hoja de ruta de
migración incremental hacia Kotlin y Jetpack Compose.

La skill está pensada para equipos que mantienen código legacy y necesitan mejorar
su calidad sin reescribir desde cero.

## When to use

- Estás manteniendo o añadiendo features a una app Android en Java + XML.
- Quieres auditar código legacy para detectar antipatrones.
- Necesitas implementar MVVM con LiveData en un proyecto ya existente.
- Quieres planificar la migración incremental a Kotlin o Compose.
- Necesitas elegir entre patrones de red o persistencia en un contexto legacy.

**Trigger phrases:**
- "¿Qué patrón uso para esta Activity Java?"
- "Revisa este código Android legacy, ¿hay antipatrones?"
- "¿Cómo migro este Fragment a Kotlin sin romper nada?"
- "¿Cómo implemento Room en un proyecto Java?"

## When NOT to use

- El proyecto es 100% Kotlin + Compose → usar `android-patterns`
- Tareas de CI/CD o infraestructura cloud
- Código iOS, Swift o backend
- Preguntas sobre Coroutines o Flow exclusivamente → usar skill específica de Kotlin

## Inputs

**Contexto requerido:**
- `activity_or_fragment_code`: Fragmento de Activity/Fragment o clase Java a analizar
- `objetivo`: Qué quieres conseguir (nueva feature, refactor, migración parcial)

**Contexto opcional:**
- `min_sdk`: Versión mínima Android del proyecto (ej. API 21, API 26)
- `arquitectura_actual`: MVC, MVP, MVVM u otra
- `usa_data_binding`: Si el proyecto usa DataBinding o ViewBinding

## Steps

1. **Clasificar el problema:**
   - Identificar si es un problema de arquitectura (MVP vs MVVM), UI (Activity/Fragment/ViewBinding), red (Retrofit), persistencia (Room/SQLite) o migración.

2. **Seleccionar patrón candidato:**
   - Evaluar 2-3 opciones con trade-offs (ver catálogos en `references/`).
   - Descartar según constraints: versión min SDK, código Java existente, tiempo disponible.

3. **Detectar antipatrones existentes:**
   - God Activity (lógica de negocio en `onCreate`)
   - AsyncTask (deprecated API 30) sin alternativa
   - Acceso directo a SQLite sin Room ni Repository
   - `findViewById` sin ViewBinding
   - Llamadas de red en el hilo principal
   - Acoplamiento directo Activity → red → BD

4. **Proponer implementación:**
   - Código Java idiomático con el patrón recomendado
   - Separación clara: Activity (UI) · ViewModel (lógica) · Repository (datos)
   - Ciclo de vida: `onCreate`, `onResume`, `onDestroy`

5. **Migración incremental (si aplica):**
   - Java → Kotlin: fichero a fichero, sin romper interoperabilidad
   - XML → Compose: usar `ComposeView` en layouts existentes
   - AsyncTask → `ExecutorService` o Coroutines (si ya hay Kotlin en el proyecto)
   - DataBinding → ViewBinding como paso intermedio

6. **Validar con checklist:**
   - Sin lógica de negocio en Activity/Fragment
   - Operaciones I/O fuera del hilo principal
   - Room con DAO + Repository bien definidos
   - ViewModel sin referencias a Context (usar `AndroidViewModel` si necesario)
   - Tests unitarios posibles sobre ViewModel y Repository

## Expected outputs

- Patrón recomendado con justificación y trade-offs descartados
- Fragmento de código Java (o Kotlin si aplica) con el patrón aplicado
- Lista de antipatrones detectados con severidad (CRITICAL / HIGH / MEDIUM / LOW)
- Plan de migración incremental si se solicita (pasos ordenados, app funcional en cada paso)
- Hoja de ruta Java → Kotlin → Compose si el contexto lo requiere

## Validation

- [ ] El patrón recomendado tiene trade-offs documentados vs alternativas descartadas
- [ ] El código propuesto no realiza operaciones I/O en el hilo principal
- [ ] La separación Activity / ViewModel / Repository está clara
- [ ] Si hay migración, los pasos son incrementales y la app compila en cada uno
- [ ] Los antipatrones detectados tienen nivel de severidad asignado
- [ ] Room se usa con DAO + `@Database` correctamente definidos

## Examples

### Ejemplo 1 — Refactorizar God Activity con MVVM

**Prompt del usuario:**
> "Tengo una Activity Java de 600 líneas con la llamada a Retrofit, el guardado en SQLite
> y la lógica de presentación mezclados. ¿Cómo lo refactorizo?"

**Acción del agente:**
1. Identificar antipatrón: **God Activity** (CRITICAL) + **Acceso SQLite directo** (HIGH)
2. Recomendar patrón **MVVM con Repository**:
   ```java
   // Repository — abstrae red y BD
   public class UserRepository {
       private final UserDao userDao;
       private final UserApiService apiService;

       public UserRepository(UserDao userDao, UserApiService apiService) {
           this.userDao = userDao;
           this.apiService = apiService;
       }

       public LiveData<List<User>> getUsers() {
           refreshUsers(); // actualiza en background
           return userDao.getAllUsers(); // Room observa cambios
       }

       private void refreshUsers() {
           AppExecutors.getInstance().networkIO().execute(() -> {
               try {
                   List<User> users = apiService.getUsers().execute().body();
                   if (users != null) userDao.insertAll(users);
               } catch (IOException e) {
                   // log error
               }
           });
       }
   }

   // ViewModel
   public class UserViewModel extends AndroidViewModel {
       private final UserRepository repository;
       public final LiveData<List<User>> users;

       public UserViewModel(@NonNull Application application) {
           super(application);
           repository = new UserRepository(
               AppDatabase.getInstance(application).userDao(),
               RetrofitClient.getInstance().create(UserApiService.class)
           );
           users = repository.getUsers();
       }
   }

   // Activity — solo UI
   public class UserActivity extends AppCompatActivity {
       private ActivityUserBinding binding;
       private UserViewModel viewModel;

       @Override
       protected void onCreate(Bundle savedInstanceState) {
           super.onCreate(savedInstanceState);
           binding = ActivityUserBinding.inflate(getLayoutInflater());
           setContentView(binding.getRoot());

           viewModel = new ViewModelProvider(this).get(UserViewModel.class);
           viewModel.users.observe(this, users -> adapter.submitList(users));
       }
   }
   ```
3. Plan incremental: extraer Repository primero → extraer ViewModel → limpiar Activity

---

### Ejemplo 2 — Configurar Room correctamente

**Prompt del usuario:**
> "¿Cómo implemento Room para persistencia local en Java?"

**Acción del agente:**
1. Definir capas Room correctamente:
   ```java
   // Entity
   @Entity(tableName = "users")
   public class User {
       @PrimaryKey
       public int id;
       @ColumnInfo(name = "name")
       public String name;
   }

   // DAO
   @Dao
   public interface UserDao {
       @Query("SELECT * FROM users")
       LiveData<List<User>> getAllUsers();

       @Insert(onConflict = OnConflictStrategy.REPLACE)
       void insertAll(List<User> users);
   }

   // Database singleton
   @Database(entities = {User.class}, version = 1, exportSchema = false)
   public abstract class AppDatabase extends RoomDatabase {
       private static volatile AppDatabase INSTANCE;

       public abstract UserDao userDao();

       public static AppDatabase getInstance(Context context) {
           if (INSTANCE == null) {
               synchronized (AppDatabase.class) {
                   if (INSTANCE == null) {
                       INSTANCE = Room.databaseBuilder(
                           context.getApplicationContext(),
                           AppDatabase.class, "app_database"
                       ).build();
                   }
               }
           }
           return INSTANCE;
       }
   }
   ```
2. Señalar que las queries Room deben ejecutarse en un hilo background (no en UI thread)

---

### Ejemplo 3 — Migración incremental Java → Kotlin

**Prompt del usuario:**
> "¿Cómo empiezo a migrar mi proyecto Java a Kotlin sin romper nada?"

**Acción del agente:**
1. Hoja de ruta incremental:
   - **Paso 1**: Añadir plugin Kotlin al `build.gradle` y verificar que el proyecto compila
   - **Paso 2**: Migrar modelos/data classes (los más sencillos, sin UI)
   - **Paso 3**: Migrar DAOs y Repository (Room funciona igual en Kotlin)
   - **Paso 4**: Migrar ViewModels (sustituir `AndroidViewModel` Java por Kotlin idiomático)
   - **Paso 5**: Migrar Activities/Fragments de menor a mayor complejidad
2. La interoperabilidad Java ↔ Kotlin es completa: clases Java llaman a Kotlin y viceversa
3. Usar `@JvmStatic`, `@JvmField` en Kotlin cuando Java necesita acceder a companions
