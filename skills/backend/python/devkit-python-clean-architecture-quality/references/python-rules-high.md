# Copilot Guidelines: Python — HIGH

---

Total rules: **47**

## SOLID

### PY_SOLID_001
- **Severity:** HIGH
- **Description:** Aplicar el Principio de Inversión de Dependencia (DIP): los módulos de alto nivel no deben depender de los de bajo nivel; ambos deben depender de abstracciones [11, 12].
- **Conditions:** language: python, principle: Dependency Inversion Principle
- **Action:** Utilizar Clases Base Abstractas (ABCs) o Protocols para definir interfaces que las capas externas deben implementar [13-15].
- **Source references:** 12, 14
- **Bad example:**
```
class NotificationService:
    def __init__(self):
        self.sender = EmailSender() # Dependencia concreta
```
- **Good example:**
```
class NotificationService:
    def __init__(self, sender: Notifier): # Dependencia de abstracción
        self.sender = sender
```

---

## Mantenibilidad

### PY_TYPE_001
- **Severity:** HIGH
- **Description:** Utilizar Type Hinting para fortalecer los límites arquitectónicos y mejorar la legibilidad y detección temprana de errores [16-18].
- **Conditions:** language: python, principle: Type Awareness
- **Action:** Anotar parámetros de funciones, valores de retorno y variables con tipos específicos, evitando el uso de 'Any' salvo como último recurso [19, 20].
- **Source references:** 16, 19
- **Bad example:**
```
def process_task(task):
    return task.id
```
- **Good example:**
```
def process_task(task: Task) -> UUID:
    return task.id
```

---

## Dominio

### PY_DOMAIN_001
- **Severity:** HIGH
- **Description:** Las entidades deben ser objetos ricos que encapsulen tanto datos como las reglas críticas de negocio (invariantes), manteniendo su validez interna [21, 22].
- **Conditions:** language: python, principle: Domain-Driven Design
- **Action:** Usar dataclasses con validación en '__post_init__' para asegurar que la entidad nunca esté en un estado inválido [23-25].
- **Source references:** 22, 25
- **Bad example:**
```
user = User(email='not-an-email') # El objeto es creado inválido
```
- **Good example:**
```
@dataclass
class User:
    email: str
    def __post_init__(self):
        if '@' not in self.email:
            raise ValueError('Invalid email')
```

---

## Capa de Datos

### PY_DATA_001
- **Severity:** HIGH
- **Description:** Centralizar el acceso a los datos mediante el patrón Repository para desacoplar la lógica de negocio de los mecanismos de persistencia [29-31].
- **Conditions:** language: python, principle: Repository Pattern
- **Action:** Definir interfaces de repositorio en el dominio y sus implementaciones concretas en la infraestructura [32, 33].
- **Source references:** 30, 32
- **Bad example:**
```
class CreateTaskUseCase:
    def execute(self):
        db.session.add(task) # Acoplamiento directo a SQLAlchemy
```
- **Good example:**
```
class CreateTaskUseCase:
    def __init__(self, repository: TaskRepository):
        self.repository = repository
    def execute(self):
        self.repository.save(task)
```

---

## SRP

### PY_SOLID_001
- **Severity:** HIGH
- **Description:** Cada módulo o clase debe tener una sola razón para cambiar. Mezclar la gestión de datos con la lógica de negocio en una sola clase (ej. User) viola este principio [6-9].
- **Conditions:** language: python, principle: Single Responsibility
- **Action:** Dividir las clases con múltiples responsabilidades en componentes enfocados como 'PostManager' o 'ProfileManager' [10, 11].
- **Source references:** 6, 7, 8, 9, 10, 11
- **Bad example:**
```
class User: def save_to_db(self): ... def update_profile(self): ...
```
- **Good example:**
```
class User: ... # Solo datos. La persistencia va a un Repository.
```

---

## OCP

### PY_SOLID_002
- **Severity:** HIGH
- **Description:** El sistema debe estar abierto a la extensión pero cerrado a la modificación. No se deben usar bloques 'if isinstance' para manejar múltiples tipos de lógica [12-15].
- **Conditions:** language: python, principle: Open-Closed
- **Action:** Utilizar polimorfismo y clases base abstractas (ABCs) para permitir nuevos comportamientos sin alterar el código existente [16, 17].
- **Source references:** 12, 13, 14, 15, 16, 17
- **Bad example:**
```
def calculate(shape): if isinstance(shape, Circle): ... elif isinstance(shape, Square): ...
```
- **Good example:**
```
class Shape(ABC): @abstractmethod def area(self): ... # Se extiende creando subclases.
```

---

## LSP

### PY_SOLID_004
- **Severity:** HIGH
- **Description:** Las subclases deben ser sustituibles por sus clases base sin alterar la corrección del programa ni violar el contrato establecido [12, 24-26].
- **Conditions:** language: python, principle: Liskov Substitution
- **Action:** Asegurar que las jerarquías de herencia respeten el comportamiento esperado y no lancen excepciones inesperadas en subtipos [27-29].
- **Source references:** 12, 24, 25, 26, 27, 28, 29
- **Bad example:**
```
class ElectricCar(Vehicle): # consume_fuel lanza error porque no usa gasolina.
```
- **Good example:**
```
class Vehicle: def drive(self): self.power_source.consume()
```

---

## Tipado

### PY_TYPE_001
- **Severity:** HIGH
- **Description:** El uso de Type Hints es obligatorio para fortalecer las fronteras arquitectónicas y facilitar el análisis estático [39-43].
- **Conditions:** language: python, feature: Type Hinting
- **Action:** Anotar parámetros, valores de retorno y variables críticas en todas las funciones y clases [44-46].
- **Source references:** 39, 40, 41, 42, 43
- **Bad example:**
```
def process_data(data): ...
```
- **Good example:**
```
def process_data(data: TaskRequest) -> TaskResponse: ...
```

---

## Entidades

### PY_DOMAIN_001
- **Severity:** HIGH
- **Description:** Las entidades se definen por su identidad única (ID) que persiste a través de cambios de estado, y deben encapsular las reglas críticas de negocio [57-60].
- **Conditions:** layer: Domain, element: Entity
- **Action:** Implementar entidades usando dataclasses con igualdad y hash basados estrictamente en el ID único [61, 62].
- **Source references:** 57, 58, 59, 60, 61, 62
- **Bad example:**
```
class Task: # Sin ID, comparada por atributos.
```
- **Good example:**
```
@dataclass class Task(Entity): id: UUID; # Comparada por identidad.
```

---

## Value Objects

### PY_DOMAIN_002
- **Severity:** HIGH
- **Description:** Los Objetos de Valor deben ser inmutables y definirse únicamente por sus atributos, sin identidad propia [58, 63-65].
- **Conditions:** layer: Domain, element: Value Object
- **Action:** Utilizar '@dataclass(frozen=True)' para garantizar la inmutabilidad y prevenir efectos secundarios [66, 67].
- **Source references:** 58, 63, 64, 65, 66, 67
- **Bad example:**
```
task.status = 'DONE' # String mutable.
```
- **Good example:**
```
@dataclass(frozen=True) class Money: amount: float; currency: str
```

---

## Invariantes

### PY_DOMAIN_003
- **Severity:** HIGH
- **Description:** Las entidades deben garantizar su propia validez interna mediante validaciones de negocio en el momento de creación o cambio de estado [63, 68-70].
- **Conditions:** layer: Domain
- **Action:** Usar el método '__post_init__' de las dataclasses para lanzar excepciones de dominio si los datos son inválidos [66, 71, 72].
- **Source references:** 63, 66, 68, 69, 70, 71, 72
- **Bad example:**
```
task = Task(due_date=past_date) # Objeto creado en estado inválido.
```
- **Good example:**
```
def __post_init__(self): if self.date < now: raise ValueError
```

---

## Aggregates

### PY_DOMAIN_005
- **Severity:** HIGH
- **Description:** Los Agregados deben actuar como límites transaccionales, con una Entidad Raíz que controle el acceso y la consistencia de los objetos internos [63, 78-80].
- **Conditions:** layer: Domain, element: Aggregate
- **Action:** Agrupar entidades relacionadas (ej. Project y sus Tasks) bajo una raíz que gestione su ciclo de vida y mantenga las invariantes globales [81-83].
- **Source references:** 63, 78, 79, 80, 81, 82, 83
- **Bad example:**
```
task.update_project_count() # Lógica dispersa.
```
- **Good example:**
```
project.add_task(task) # El agregado centraliza el cambio.
```

---

## Aplicación

### PY_APP_001
- **Severity:** HIGH
- **Description:** La Capa de Aplicación (Use Cases) debe orquestar los objetos de dominio para cumplir las reglas específicas de la aplicación, ocultando la complejidad del dominio al exterior [84-87].
- **Conditions:** layer: Application
- **Action:** Implementar 'Interactores' de Caso de Uso que reciban DTOs de solicitud y devuelvan DTOs de respuesta [88-90].
- **Source references:** 84, 85, 86, 87, 88, 89, 90
- **Bad example:**
```
Controller llama directamente a entity.do_something()
```
- **Good example:**
```
Controller llama a ProcessOrderUseCase.execute(request)
```

### PY_APP_003
- **Severity:** HIGH
- **Description:** Los Interactores de Caso de Uso deben ser clases sin estado (stateless) para garantizar su reusabilidad y facilitar el testeo [84, 96-98].
- **Conditions:** layer: Application, element: UseCase
- **Action:** Inyectar todas las dependencias (repositorios, servicios) por constructor y no mantener datos de sesión internamente [99-101].
- **Source references:** 84, 96, 97, 98, 99, 100, 101
- **Bad example:**
```
class CreateTask: self.temp_list = []
```
- **Good example:**
```
@dataclass(frozen=True) class CreateTask: repo: TaskRepository
```

### PY_TRANS_001
- **Severity:** HIGH
- **Description:** El Caso de Uso es el responsable de definir los límites transaccionales de una operación de negocio [89, 102, 257, 258].
- **Conditions:** layer: Application
- **Action:** Garantizar que todas las operaciones dentro del 'execute' del caso de uso (ej. guardar tarea y notificar) se manejen como una unidad lógica [254, 259].
- **Source references:** 89, 102, 254, 257, 258, 259
- **Bad example:**
```
El Controller maneja el commit de la base de datos.
```
- **Good example:**
```
El Use Case coordina la persistencia de múltiples entidades.
```

---

## Error Handling

### PY_APP_002
- **Severity:** HIGH
- **Description:** Utilizar el patrón 'Result Object' para el manejo de errores en los casos de uso, evitando el uso excesivo de excepciones para el control de flujo [84, 91, 92].
- **Conditions:** layer: Application, feature: Result Object
- **Action:** Retornar una instancia de una clase 'Result' que encapsule explícitamente el éxito o un objeto de error estandarizado [93-95].
- **Source references:** 84, 91, 92, 93, 94, 95
- **Bad example:**
```
raise Exception('User not found')
```
- **Good example:**
```
return Result.failure(Error.not_found('User', id))
```

---

## DTO

### PY_APP_004
- **Severity:** HIGH
- **Description:** Definir Modelos de Solicitud (Request Models) para validar y transformar datos de entrada antes de que lleguen a la lógica del caso de uso [88, 102-104].
- **Conditions:** layer: Application, element: RequestModel
- **Action:** Validar formatos primitivos y transformar IDs de string a UUID en el método de transformación del modelo [105-107].
- **Source references:** 88, 102, 103, 104, 105, 106, 107
- **Bad example:**
```
use_case.execute(request.json) # Diccionario crudo.
```
- **Good example:**
```
request = CreateTaskRequest(**data); use_case.execute(request)
```

### PY_APP_005
- **Severity:** HIGH
- **Description:** Utilizar Modelos de Respuesta (Response Models) para proteger a las entidades de la exposición directa al mundo exterior [102, 108-110].
- **Conditions:** layer: Application, element: ResponseModel
- **Action:** Implementar métodos de clase como 'from_entity()' para controlar qué campos del dominio se serializan [111-113].
- **Source references:** 102, 108, 109, 110, 111, 112, 113
- **Bad example:**
```
return task_entity # Expone toda la entidad incluyendo lógica interna.
```
- **Good example:**
```
return TaskResponse.from_entity(task)
```

---

## Interface Adapters

### PY_ADAP_001
- **Severity:** HIGH
- **Description:** Los controladores deben ser agnósticos a los frameworks. No deben contener lógica de rutas, HTTP o frameworks de CLI [114-117].
- **Conditions:** layer: Interfaces, element: Controller
- **Action:** Aislar el código del framework (FastAPI, Click) en la capa de Infraestructura y delegar al controlador limpio de la capa de Interfaces [118-120].
- **Source references:** 114, 115, 116, 117, 118, 119, 120
- **Bad example:**
```
@app.get('/tasks') def get_tasks(): ... # Lógica en el framework.
```
- **Good example:**
```
class TaskController: def handle_get(self): ... # Independiente.
```

---

## Presenters

### PY_ADAP_002
- **Severity:** HIGH
- **Description:** Aplicar el patrón Humble Object: mantener las vistas (HTML, CLI) lo más simples posible, moviendo la lógica de formateo al Presentador [121-124].
- **Conditions:** layer: Interfaces, element: Presenter
- **Action:** El Presentador debe transformar modelos de respuesta en ViewModels compuestos solo por tipos primitivos listos para mostrar [125-127].
- **Source references:** 121, 122, 123, 124, 125, 126, 127
- **Bad example:**
```
HTML: {{ task.due_date.strftime('%Y-%m-%d') }}
```
- **Good example:**
```
Presenter: task_vm.due_date_display = date.isoformat()
```

---

## Persistencia

### PY_INFRA_001
- **Severity:** HIGH
- **Description:** Los repositorios deben implementar interfaces (ports) definidas en las capas internas. La infraestructura depende del dominio [131-134].
- **Conditions:** layer: Infrastructure, element: Repository
- **Action:** Encapsular todos los detalles de SQL, ORMs o acceso a archivos dentro de implementaciones concretas en la capa de infraestructura [135-137].
- **Source references:** 131, 132, 133, 134, 135, 136, 137
- **Bad example:**
```
Use Case importando 'SQLAlchemySession'.
```
- **Good example:**
```
class SqliteTaskRepository(TaskRepository): ... # Implementación.
```

---

## Composición

### PY_INFRA_002
- **Severity:** HIGH
- **Description:** El 'Composition Root' (típicamente main.py) es el único lugar donde se deben instanciar manualmente las dependencias concretas [138-141].
- **Conditions:** element: Main
- **Action:** Centralizar la creación de la aplicación y la inyección de dependencias en un solo punto de entrada [19, 142-144].
- **Source references:** 19, 138, 139, 140, 141, 142, 143, 144
- **Bad example:**
```
Un repositorio instanciando su propia conexión a DB global.
```
- **Good example:**
```
main.py instancia repo -> use_case -> controller -> app.
```

---

## Testing

### PY_TEST_001
- **Severity:** HIGH
- **Description:** Seguir el patrón Arrange-Act-Assert (AAA) para mantener tests claros y alineados con las fronteras de Clean Architecture [145-148].
- **Conditions:** element: Test
- **Action:** Organizar cada caso de prueba en tres fases: preparación de datos, ejecución de la acción y verificación de resultados [149-151].
- **Source references:** 145, 146, 147, 148, 149, 150, 151
- **Bad example:**
```
Test mezclando aserciones con lógica de configuración.
```
- **Good example:**
```
# Arrange: task=Task(); # Act: task.complete(); # Assert: assert task.done
```

### PY_TEST_002
- **Severity:** HIGH
- **Description:** Las pruebas de dominio deben realizarse en aislamiento total, sin dependencias de bases de datos, red o frameworks [145, 152-155].
- **Conditions:** layer: Domain
- **Action:** Verificar las reglas de negocio puras usando objetos de Python estándar y simulando repositorios si es necesario [156-158].
- **Source references:** 145, 152, 153, 154, 155, 156, 157, 158
- **Bad example:**
```
Test de entidad que requiere levantar un servidor Flask.
```
- **Good example:**
```
Test instanciando una dataclass en memoria y verificando un valor.
```

### PY_TEST_003
- **Severity:** HIGH
- **Description:** Utilizar Dobles de Prueba (Mocks/Fakes) con 'spec' para asegurar que el simulacro respeta la interfaz real definida en el dominio [145, 159-161].
- **Conditions:** element: Mock
- **Action:** Usar 'unittest.mock.Mock(spec=Interface)' para capturar errores de contrato durante el testeo de casos de uso [162-164].
- **Source references:** 145, 159, 160, 161, 162, 163, 164
- **Bad example:**
```
mock_repo = Mock(); mock_repo.metodo_inexistente() # No falla.
```
- **Good example:**
```
mock_repo = Mock(spec=UserRepository) # Falla si el método no existe.
```

### PY_TEST_007
- **Severity:** HIGH
- **Description:** Las pruebas unitarias de los ViewModels y Presenters no deben requerir un navegador ni el framework web levantado [145, 180-182].
- **Conditions:** layer: Interfaces
- **Action:** Verificar la lógica de formateo de datos pasando respuestas de dominio simuladas directamente al presentador [183-186].
- **Source references:** 145, 180, 181, 182, 183, 184, 185, 186
- **Bad example:**
```
Test de UI usando Selenium para ver si una fecha está bien formateada.
```
- **Good example:**
```
assert 'Overdue' in presenter.present(task).date_display
```

### PY_TEST_001
- **Severity:** HIGH
- **Description:** Escribir unit tests para todas las funciones de lógica de negocio.
- **Conditions:** language: python, location: src|core
- **Action:** Crear archivo test_*.py para cada módulo con pytest.
- **Source references:** -
- **Bad example:**
```
# calculate_total.py
def calculate_total(items):
    return sum(item.price for item in items)
# Sin tests
```
- **Good example:**
```
# test_calculate_total.py
import pytest
from entities.item import Item
from core.calculator import calculate_total

def test_calculate_total_empty():
    assert calculate_total([]) == 0

def test_calculate_total_with_items():
    items = [Item(price=10), Item(price=20)]
    assert calculate_total(items) == 30
```

---

## Observabilidad

### PY_OBS_002
- **Severity:** HIGH
- **Description:** Asignar un Trace ID único a cada solicitud para rastrear operaciones a través de múltiples capas arquitectónicas [44, 187, 194, 195].
- **Conditions:** layer: Infrastructure
- **Action:** Utilizar ContextVar o middleware para propagar el trace_id automáticamente en todos los logs de la solicitud [196-199].
- **Source references:** 44, 187, 194, 195, 196, 197, 198, 199
- **Bad example:**
```
Logs sin identificador común entre el Controller y el Repository.
```
- **Good example:**
```
Log: [trace_id: abc-123] Procesando tarea...
```

---

## Fitness Functions

### PY_FIT_001
- **Severity:** HIGH
- **Description:** Implementar pruebas automáticas que verifiquen la integridad de la estructura de capas y el cumplimiento de la Regla de Dependencia [187, 200-202].
- **Conditions:** tool: pytest, principle: Arch Verification
- **Action:** Crear tests que analicen el AST de Python para detectar importaciones prohibidas de capas internas a externas [203-207].
- **Source references:** 187, 200, 201, 202, 203, 204, 205, 206, 207
- **Bad example:**
```
Revisión manual de arquitectura en Pull Requests.
```
- **Good example:**
```
Test que falla si 'domain' importa algo de 'infrastructure'.
```

---

## Legado

### PY_LEG_001
- **Severity:** HIGH
- **Description:** Al transformar código legado, utilizar el patrón 'Strangler Fig' para migrar piezas incrementalmente en lugar de reescrituras completas [208-212].
- **Conditions:** state: Legacy
- **Action:** Envolver la lógica nueva en Clean Architecture y usar Feature Flags para alternar entre implementaciones [213-215].
- **Source references:** 208, 209, 210, 211, 212, 213, 214, 215
- **Bad example:**
```
Borrar el módulo viejo y empezar de cero en una rama aparte.
```
- **Good example:**
```
If USE_CLEAN_ARCH: call_new_controller() else: call_legacy_code()
```

---

## Eventos

### PY_EVENT_001
- **Severity:** HIGH
- **Description:** En arquitecturas dirigidas por eventos, los eventos de dominio deben ser ciudadanos de primera clase dentro de la capa de Dominio [216-219].
- **Conditions:** architecture: Event-driven
- **Action:** Definir eventos como Objetos de Valor inmutables que representen hechos significativos del negocio [220-222].
- **Source references:** 216, 217, 218, 219, 220, 221, 222
- **Bad example:**
```
Entidad publicando directamente en una cola de Kafka.
```
- **Good example:**
```
Entidad genera un evento -> Use Case lo publica vía Port.
```

---

## Inyección de Dependencias

### PY_DI_001
- **Severity:** HIGH
- **Description:** Las dependencias deben inyectarse, no instanciarse. Esto permite intercambiar implementaciones para pruebas o cambios de tecnología [99, 101, 114, 163, 230].
- **Conditions:** language: python
- **Action:** Pasar las dependencias (ej. repositorios) a través del constructor de los casos de uso [34, 231, 232].
- **Source references:** 34, 99, 101, 114, 163, 230, 231, 232
- **Bad example:**
```
class UseCase: repo = SQLRepo()
```
- **Good example:**
```
class UseCase: def __init__(self, repo: IRepo): self.repo = repo
```

---

## Ports

### PY_PORT_001
- **Severity:** HIGH
- **Description:** Los puertos (interfaces) deben definir exactamente qué capacidades necesita la aplicación, sin revelar detalles de implementación [5, 102, 239, 240].
- **Conditions:** layer: Application
- **Action:** Crear interfaces que utilicen nombres de métodos de negocio (ej. 'notify_task_completed') en lugar de tecnológicos (ej. 'send_email') [241-243].
- **Source references:** 5, 102, 239, 240, 241, 242, 243
- **Bad example:**
```
interface.send_email_via_smtp()
```
- **Good example:**
```
interface.notify_user_of_update()
```

---

## Adapters

### PY_ADAP_004
- **Severity:** HIGH
- **Description:** El mapeo entre modelos de infraestructura (DTOs) y modelos de Dominio debe ocurrir exclusivamente en la capa de Interfaces o Infraestructura [121, 244-246].
- **Conditions:** layer: Interfaces/Infrastructure
- **Action:** Implementar funciones de mapeo que conviertan tipos de frameworks a entidades del dominio antes de llamar al caso de uso [247, 248].
- **Source references:** 121, 244, 245, 246, 247, 248
- **Bad example:**
```
Domain: import infrastructure.models.UserTable
```
- **Good example:**
```
Adapter: user_entity = map_db_to_domain(db_row)
```

---

## Abstracción

### PY_ABC_001
- **Severity:** HIGH
- **Description:** Utilizar Clases Base Abstractas (ABCs) para definir interfaces formales cuando se requiere una validación estricta de la implementación [47, 91, 232, 249].
- **Conditions:** language: python, feature: ABC
- **Action:** Anotar los métodos de la interfaz con '@abstractmethod' para obligar a su implementación en las capas externas [136, 249, 250].
- **Source references:** 47, 91, 136, 232, 249, 250
- **Bad example:**
```
class Repo: pass # Sin métodos abstractos.
```
- **Good example:**
```
class IRepo(ABC): @abstractmethod def save(self, ...): ...
```

---

## Seguridad

### PY_SEC_006
- **Severity:** HIGH
- **Description:** Implementar autenticación y autorización en todos los endpoints. No dejar endpoints públicos accidentalmente.
- **Conditions:** language: python, framework: fastapi, pattern: @app.get|@app.post
- **Action:** Usar FastAPI dependencies con JWT, OAuth2, o verificación de permisos.
- **Source references:** -
- **Bad example:**
```
@app.get('/admin/users')
async def get_all_users():
    return all_users
```
- **Good example:**
```
from fastapi import Depends
from fastapi.security import HTTPBearer

security = HTTPBearer()

@app.get('/admin/users')
async def get_all_users(credentials: str = Depends(security)):
    verify_token(credentials)
    return all_users
```

### PY_SEC_007
- **Severity:** HIGH
- **Description:** Configurar CORS correctamente. No usar CORSMiddleware con origins=['*'].
- **Conditions:** language: python, framework: fastapi, pattern: CORSMiddleware|allow_origins=\[.*\*.*\]
- **Action:** Especificar dominios permitidos explícitamente.
- **Source references:** -
- **Bad example:**
```
from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(CORSMiddleware, allow_origins=['*'])
```
- **Good example:**
```
app.add_middleware(
    CORSMiddleware,
    allow_origins=['https://cardiochef.com', 'https://app.cardiochef.com'],
    allow_credentials=True,
    allow_methods=['GET', 'POST'],
    allow_headers=['Content-Type', 'Authorization']
)
```

### PY_SEC_008
- **Severity:** HIGH
- **Description:** No hardcodear URLs de bases de datos, hosts o endpoints de servicios externos.
- **Conditions:** language: python, pattern: localhost|127\.0\.0\.1|http://|https://
- **Action:** Usar variables de entorno para todas las URLs de servicios.
- **Source references:** -
- **Bad example:**
```
OLLAMA_URL = 'http://localhost:11434'
GEMINI_API = 'https://generativelanguage.googleapis.com'
DB = 'postgresql://localhost:5432/mydb'
```
- **Good example:**
```
OLLAMA_URL = os.getenv('OLLAMA_URL')
GEMINI_API = os.getenv('GEMINI_API')
DATABASE_URL = os.getenv('DATABASE_URL')
```

---

## FastAPI

### PY_FAST_001
- **Severity:** HIGH
- **Description:** Usar async/await para todas las operaciones I/O (database, API calls, file I/O).
- **Conditions:** language: python, framework: fastapi, pattern: def |async def
- **Action:** Convertir endpoints a async def y usar await para operaciones I/O.
- **Source references:** -
- **Bad example:**
```
@app.get('/users/{user_id}')
def get_user(user_id: int):
    user = db.query(User).filter(User.id == user_id).first()
    return user
```
- **Good example:**
```
@app.get('/users/{user_id}')
async def get_user(user_id: int):
    user = await db.query(User).filter(User.id == user_id).first()
    return user
```

### PY_FAST_002
- **Severity:** HIGH
- **Description:** Usar HTTPException con status codes apropiados. No retornar 200 OK para errores.
- **Conditions:** language: python, framework: fastapi, pattern: return.*error|raise.*Exception
- **Action:** Usar raise HTTPException(status_code=xxx) o response con status_code correcto.
- **Source references:** -
- **Bad example:**
```
@app.get('/users/{user_id}')
async def get_user(user_id: int):
    user = find_user(user_id)
    if not user:
        return {'error': 'Not found'}
    return user
```
- **Good example:**
```
from fastapi import HTTPException

@app.get('/users/{user_id}')
async def get_user(user_id: int):
    user = await find_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail='User not found')
    return user
```

---

## Type Hints

### PY_TYPE_001
- **Severity:** HIGH
- **Description:** Usar type hints en todas las funciones (parámetros y return type).
- **Conditions:** language: python, pattern: def 
- **Action:** Añadir anotaciones de tipo en todas las funciones.
- **Source references:** -
- **Bad example:**
```
def calculate_total(items):
    return sum(item.price for item in items)
```
- **Good example:**
```
from typing import List
from entities.item import Item

def calculate_total(items: List[Item]) -> float:
    return sum(item.price for item in items)
```

---

## Manejo de Excepciones

### PY_ERROR_001
- **Severity:** HIGH
- **Description:** No capturar excepciones genéricas Exception. Ser específico con el tipo de error.
- **Conditions:** language: python, pattern: except Exception|except:|except BaseException
- **Action:** Capturar excepciones específicas (ValueError, KeyError, DatabaseError, etc).
- **Source references:** -
- **Bad example:**
```
try:
    user = get_user(user_id)
except Exception:
    logger.error('Error')
```
- **Good example:**
```
try:
    user = await get_user(user_id)
except UserNotFoundError:
    raise HTTPException(status_code=404)
except DatabaseError as e:
    logger.error(f'DB error: {str(e)}')
    raise HTTPException(status_code=500)
```

### PY_ERROR_002
- **Severity:** HIGH
- **Description:** No ignorar excepciones con pass vacío. Siempre manejar o re-lanzar.
- **Conditions:** language: python, pattern: except.*:\s*pass
- **Action:** Loguear el error, hacer fallback, o re-lanzar la excepción.
- **Source references:** -
- **Bad example:**
```
try:
    validate_email(email)
except ValueError:
    pass  # Ignorar silenciosamente
```
- **Good example:**
```
try:
    validate_email(email)
except ValueError as e:
    logger.warning(f'Invalid email: {str(e)}')
    raise HTTPException(status_code=400, detail='Invalid email')
```

---

## MCP Protocol

### PY_MCP_001
- **Severity:** HIGH
- **Description:** Implementar contratos MCP (tipos de solicitud/respuesta) bien definidos usando Pydantic.
- **Conditions:** language: python, framework: mcp
- **Action:** Definir RequestModel y ResponseModel para cada operación MCP.
- **Source references:** -
- **Bad example:**
```
def handle_request(data):
    # Sin validación de estructura
    return process(data)
```
- **Good example:**
```
from pydantic import BaseModel

class ReviewRequest(BaseModel):
    code: str
    language: str
    framework: str

class ReviewResponse(BaseModel):
    issues: List[dict]
    severity: str

def handle_review(request: ReviewRequest) -> ReviewResponse:
    issues = analyze(request.code, request.language)
    return ReviewResponse(issues=issues, severity='high')
```

### PY_MCP_002
- **Severity:** HIGH
- **Description:** Documentar el contrato MCP con ejemplos de request/response en docstrings.
- **Conditions:** language: python, framework: mcp
- **Action:** Añadir ejemplos de request/response en docstrings.
- **Source references:** -
- **Bad example:**
```
def handle_review(request):
    '''Process code review.'''
    pass
```
- **Good example:**
```
def handle_review(request: ReviewRequest) -> ReviewResponse:
    '''
    Process code review.
    
    Request:
        {"code": "python code", "language": "python", "framework": "fastapi"}
    
    Response:
        {"issues": [...], "severity": "high"}
    '''
    pass
```

---

## Database

### PY_DB_001
- **Severity:** HIGH
- **Description:** Usar ORM (SQLAlchemy) en lugar de raw SQL para prevenir SQL injection.
- **Conditions:** language: python, pattern: execute\(.*[fF]'|execute\(.*[fF]\"|\.format\(|% =
- **Action:** Usar select(), insert(), update(), delete() de SQLAlchemy.
- **Source references:** -
- **Bad example:**
```
from sqlalchemy import text
query = text(f'SELECT * FROM users WHERE email={email}')
result = session.execute(query)
```
- **Good example:**
```
from sqlalchemy import select
stmt = select(User).where(User.email == email)
result = session.execute(stmt)
user = result.scalar_one_or_none()
```

### PY_DB_002
- **Severity:** HIGH
- **Description:** Usar contextos de sesión (with, async context manager) para asegurar cleanup de conexiones.
- **Conditions:** language: python, pattern: Session\(|session =
- **Action:** Usar 'with SessionLocal() as session:' o async context managers.
- **Source references:** -
- **Bad example:**
```
session = SessionLocal()
user = session.query(User).first()
return user  # Sesión no se cierra correctamente
```
- **Good example:**
```
from sqlalchemy.orm import Session

def get_first_user(session: Session) -> User:
    return session.query(User).first()

with SessionLocal() as session:
    user = get_first_user(session)
    # Sesión se cierra automáticamente
```
