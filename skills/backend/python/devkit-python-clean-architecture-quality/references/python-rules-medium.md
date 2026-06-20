# Copilot Guidelines: Python — MEDIUM

---

Total rules: **32**

## Aplicación

### PY_APP_001
- **Severity:** MEDIUM
- **Description:** Utilizar el patrón 'Result Object' para el manejo de errores en la capa de aplicación, proporcionando una gestión explícita de éxito y fracaso sin depender únicamente de excepciones [26, 27].
- **Conditions:** language: python, principle: Error Handling
- **Action:** Retornar una instancia de una clase Result que encapsule el valor de éxito o los detalles del error [27, 28].
- **Source references:** 26, 28
- **Bad example:**
```
def execute(self):
    if not found:
        raise Exception('Not found')
    return data
```
- **Good example:**
```
def execute(self) -> Result:
    if not found:
        return Result.failure(Error.not_found('User', id))
    return Result.success(data)
```

---

## Adaptadores

### PY_INTER_001
- **Severity:** MEDIUM
- **Description:** Aplicar el patrón Humble Object en la capa de presentación para separar la lógica de formateo (testable) de la visualización (difícil de testear) [34, 35].
- **Conditions:** language: python, principle: Humble Object Pattern
- **Action:** Crear presentadores que transformen objetos de respuesta en ViewModels compuestos únicamente por tipos primitivos listos para la interfaz [36, 37].
- **Source references:** 34, 35, 37
- **Bad example:**
```
# En la plantilla HTML
<p>{{ task.due_date.strftime('%Y-%m-%d') }}</p>
```
- **Good example:**
```
# En el presentador
class WebPresenter:
    def present(self, task):
        return TaskViewModel(due_date_display=task.due_date.isoformat())
```

---

## ISP

### PY_SOLID_003
- **Severity:** MEDIUM
- **Description:** Los clientes no deben ser forzados a depender de métodos que no utilizan. Las interfaces monolíticas deben segregarse en contratos más pequeños [12, 18-20].
- **Conditions:** language: python, principle: Interface Segregation
- **Action:** Descomponer interfaces grandes en ABCs o Protocols enfocados a tareas específicas [21-23].
- **Source references:** 12, 18, 19, 20, 21, 22, 23
- **Bad example:**
```
class Multimedia(ABC): play_audio(); play_video(); # Fuerza a MusicPlayer a implementar video.
```
- **Good example:**
```
class AudioPlayable(ABC): play_audio(); class VideoPlayable(ABC): play_video();
```

---

## Tipado

### PY_TYPE_002
- **Severity:** MEDIUM
- **Description:** Evitar el uso de 'Any' en el código interno. Su presencia suele indicar una interfaz mal definida o la necesidad de una refactorización [47-49].
- **Conditions:** language: python
- **Action:** Reemplazar 'Any' por tipos específicos, uniones (Union) o Protocols [50].
- **Source references:** 47, 48, 49, 50
- **Bad example:**
```
def save(item: Any): ...
```
- **Good example:**
```
def save(item: TaskEntity): ...
```

### PY_TYPE_003
- **Severity:** MEDIUM
- **Description:** Utilizar 'Sequence' en lugar de 'List' en las firmas de funciones para permitir mayor flexibilidad y adherencia a ISP y LSP [47, 51, 52].
- **Conditions:** language: python, principle: LSP/ISP
- **Action:** Preferir tipos de colección genéricos de 'typing' que solo requieran la interfaz mínima de iteración [53].
- **Source references:** 47, 51, 52, 53
- **Bad example:**
```
def process(items: list[int]): ... # Obliga a pasar una lista.
```
- **Good example:**
```
def process(items: Sequence[int]): ... # Acepta listas, tuplas o generadores.
```

### PY_TYPE_004
- **Severity:** MEDIUM
- **Description:** Usar 'NewType' para identificadores y valores críticos de dominio para prevenir mezclas accidentales de tipos primitivos iguales [47, 54, 55].
- **Conditions:** language: python
- **Action:** Crear tipos semánticos distintos para UserId, ProductId, etc., incluso si ambos son 'int' [56].
- **Source references:** 47, 54, 55, 56
- **Bad example:**
```
user_id: int; order_id: int
```
- **Good example:**
```
UserId = NewType('UserId', int); OrderId = NewType('OrderId', int)
```

---

## Domain Services

### PY_DOMAIN_004
- **Severity:** MEDIUM
- **Description:** Los Servicios de Dominio deben implementarse para operaciones sin estado que involucran múltiples entidades o lógica que no pertenece a una sola entidad [63, 73-75].
- **Conditions:** layer: Domain, element: Service
- **Action:** Encapsular lógica de orquestación de negocio pura en clases de servicio estáticas o inyectables dentro del dominio [76, 77].
- **Source references:** 63, 73, 74, 75, 76, 77
- **Bad example:**
```
order.check_inventory(inventory_service) # Acoplamiento de entidad a servicio externo.
```
- **Good example:**
```
class OrderPriorityCalculator: @staticmethod def calculate(order): ...
```

---

## ViewModel

### PY_ADAP_003
- **Severity:** MEDIUM
- **Description:** Los ViewModels deben ser inmutables y contener solo datos pre-formateados (strings, números, booleanos) para la interfaz específica [7, 121, 128, 129].
- **Conditions:** layer: Interfaces, element: ViewModel
- **Action:** Utilizar 'frozen=True' en dataclasses de ViewModel para asegurar que la vista no pueda alterar el estado [127, 130].
- **Source references:** 7, 121, 127, 128, 129, 130
- **Bad example:**
```
ViewModel con objetos 'datetime' vivos.
```
- **Good example:**
```
ViewModel con campos 'status_display' pre-formateados.
```

---

## Testing

### PY_TEST_004
- **Severity:** MEDIUM
- **Description:** Las pruebas de integración deben ser estratégicas y centrarse exclusivamente en el cruce de fronteras críticas como la persistencia [25, 165-167].
- **Conditions:** type: Integration Test
- **Action:** Utilizar bases de datos en memoria o directorios temporales (ej. tmp_path) para validar implementaciones reales de repositorios [168-170].
- **Source references:** 25, 165, 166, 167, 168, 169, 170
- **Bad example:**
```
Probar todo el flujo de negocio en el test de base de datos.
```
- **Good example:**
```
Test de repositorio verificando que un objeto se guarda y recupera del disco.
```

### PY_TEST_005
- **Severity:** MEDIUM
- **Description:** Utilizar 'freezegun' para probar lógicas dependientes del tiempo (deadlines, expiraciones) de forma determinista [165, 171-173].
- **Conditions:** element: Time-sensitive logic
- **Action:** Congelar el tiempo en una fecha específica dentro del bloque de test para evitar fallos aleatorios por milisegundos [174, 175].
- **Source references:** 165, 171, 172, 173, 174, 175
- **Bad example:**
```
assert task.created_at == datetime.now() # Fallará por mseg.
```
- **Good example:**
```
with freeze_time('2024-01-01'): ...
```

### PY_TEST_006
- **Severity:** MEDIUM
- **Description:** Ejecutar tests en orden aleatorio para detectar dependencias de estado ocultas o fugas entre pruebas [28, 165, 176, 177].
- **Conditions:** tool: pytest
- **Action:** Configurar 'pytest-random-order' para forzar la independencia absoluta de cada caso de prueba [178, 179].
- **Source references:** 28, 165, 176, 177, 178, 179
- **Bad example:**
```
Test A que depende de que el Test B cree un archivo previo.
```
- **Good example:**
```
Cada test crea y limpia sus propios recursos.
```

### PY_TEST_002
- **Severity:** MEDIUM
- **Description:** Usar mocks para dependencias externas (BD, APIs, servicios) en tests.
- **Conditions:** language: python, location: test_
- **Action:** Usar unittest.mock o pytest-mock para aislar componentes.
- **Source references:** -
- **Bad example:**
```
def test_get_user():
    user = get_user(1)  # Query real a BD
    assert user.name == 'John'
```
- **Good example:**
```
from unittest.mock import patch

@patch('repositories.user_repository.UserRepository.find_by_id')
def test_get_user(mock_find):
    mock_find.return_value = User(id=1, name='John')
    user = get_user(1)
    assert user.name == 'John'
    mock_find.assert_called_once_with(1)
```

---

## Observabilidad

### PY_OBS_001
- **Severity:** MEDIUM
- **Description:** Implementar logging estructurado en JSON para facilitar el análisis automático sin acoplarse a frameworks externos [187-190].
- **Conditions:** layer: Infrastructure
- **Action:** Definir un JsonFormatter personalizado en la capa de infraestructura que capture el contexto del log [191-193].
- **Source references:** 187, 188, 189, 190, 191, 192, 193
- **Bad example:**
```
logging.info('Created task: ' + task.id)
```
- **Good example:**
```
logger.info('Created task', extra={'context': {'id': task.id}})
```

---

## Pragmatismo

### PY_PRAG_001
- **Severity:** MEDIUM
- **Description:** En sistemas API-first con FastAPI, se puede permitir Pydantic en la capa de dominio si se trata como una extensión estable del sistema de tipos [223-226].
- **Conditions:** framework: FastAPI, tool: Pydantic
- **Action:** Documentar esta decisión mediante un Architectural Decision Record (ADR) para mantener la transparencia [227-229].
- **Source references:** 223, 224, 225, 226, 227, 228, 229
- **Bad example:**
```
Duplicar masivamente modelos de Pydantic con dataclasses puras sin justificación.
```
- **Good example:**
```
Aceptar Pydantic en entidades para validación automática pero documentado como excepción.
```

---

## Dominio

### PY_ENUM_001
- **Severity:** MEDIUM
- **Description:** Usar Enums para estados y prioridades discretas en lugar de strings o enteros para evitar la 'Obsesión por Primitivos' [66, 233-235].
- **Conditions:** layer: Domain
- **Action:** Definir clases que hereden de Enum para representar conceptos con valores restringidos [235, 236].
- **Source references:** 66, 233, 234, 235, 236
- **Bad example:**
```
status: str = 'DONE'
```
- **Good example:**
```
status: TaskStatus = TaskStatus.DONE
```

---

## Validación

### PY_POST_001
- **Severity:** MEDIUM
- **Description:** Utilizar validaciones de post-inicialización para asegurar que las entidades nunca existan en un estado incompleto o ilegal [66, 72, 237, 238].
- **Conditions:** language: python, element: Entity
- **Action:** Lanzar 'ValueError' en el método '__post_init__' si faltan campos obligatorios o hay lógica inconsistente [69, 72].
- **Source references:** 66, 69, 72, 237, 238
- **Bad example:**
```
Validar datos solo en el Controller.
```
- **Good example:**
```
def __post_init__(self): if not self.title: raise ValueError
```

---

## Abstracción

### PY_PROT_001
- **Severity:** MEDIUM
- **Description:** Utilizar 'Protocols' para Duck Typing con tipado estático cuando se desea evitar jerarquías de herencia rígidas [57, 251, 252].
- **Conditions:** language: python, feature: Protocols
- **Action:** Definir contratos de comportamiento que las clases externas implementen de forma implícita [103, 253, 254].
- **Source references:** 57, 103, 251, 252, 253, 254
- **Bad example:**
```
Fuerza de herencia para mocks simples.
```
- **Good example:**
```
class Notifier(Protocol): def send(self, msg: str): ...
```

---

## Repositorios

### PY_REPO_001
- **Severity:** MEDIUM
- **Description:** Utilizar repositorios en memoria (InMemory) durante el desarrollo y las pruebas para acelerar el ciclo de feedback [131, 135, 136, 255].
- **Conditions:** element: Repository
- **Action:** Implementar la misma interfaz de repositorio usando diccionarios simples para permitir el testeo sin base de datos [137, 256].
- **Source references:** 131, 135, 136, 137, 255, 256
- **Bad example:**
```
Mockear cada llamada individual a SQL en los tests.
```
- **Good example:**
```
Inyectar 'InMemoryTaskRepository' en el test del caso de uso.
```

---

## Infraestructura

### PY_CONFIG_001
- **Severity:** MEDIUM
- **Description:** La configuración del sistema debe estar aislada de la lógica de negocio y ser inyectada mediante variables de entorno [138-140, 260].
- **Conditions:** layer: Infrastructure
- **Action:** Usar una clase 'Config' dedicada para leer secretos y rutas, proporcionándolas al 'Composition Root' [261-263].
- **Source references:** 138, 139, 140, 260, 261, 262, 263
- **Bad example:**
```
os.getenv() dentro de una Entidad de Dominio.
```
- **Good example:**
```
main.py lee la API_KEY y la pasa al servicio inyectado.
```

---

## FastAPI

### PY_FAST_003
- **Severity:** MEDIUM
- **Description:** Definir response models con Pydantic para documentación y validación de respuestas.
- **Conditions:** language: python, framework: fastapi, pattern: @app\.(get|post|put|delete)
- **Action:** Añadir response_model en cada endpoint.
- **Source references:** -
- **Bad example:**
```
@app.get('/users/{user_id}')
async def get_user(user_id: int):
    return await db.fetch_user(user_id)
```
- **Good example:**
```
from pydantic import BaseModel

class UserResponse(BaseModel):
    id: int
    name: str
    email: str

@app.get('/users/{user_id}', response_model=UserResponse)
async def get_user(user_id: int):
    return await db.fetch_user(user_id)
```

---

## Type Hints

### PY_TYPE_002
- **Severity:** MEDIUM
- **Description:** Usar typing.Optional para parámetros que pueden ser None, en lugar de dejar sin anotación.
- **Conditions:** language: python, pattern: =None|None
- **Action:** Usar Optional[Type] = None.
- **Source references:** -
- **Bad example:**
```
def find_user(user_id, role=None):
    pass
```
- **Good example:**
```
from typing import Optional

def find_user(user_id: int, role: Optional[str] = None) -> Optional[User]:
    pass
```

---

## Performance

### PY_PERF_001
- **Severity:** MEDIUM
- **Description:** No hacer queries a base de datos dentro de loops. Usar bulk operations.
- **Conditions:** language: python, pattern: for.*in.*:|while.*:|[^\n]*query|[^\n]*execute
- **Action:** Usar bulk_insert_mappings(), bulk_update(), o JOIN queries.
- **Source references:** -
- **Bad example:**
```
for user_id in user_ids:
    user = session.query(User).filter(User.id == user_id).first()
    user.last_login = datetime.now()
    session.commit()
```
- **Good example:**
```
stmt = update(User).where(User.id.in_(user_ids)).values(last_login=datetime.now())
session.execute(stmt)
session.commit()
```

### PY_PERF_002
- **Severity:** MEDIUM
- **Description:** Usar conexión pooling para bases de datos. No crear nuevas conexiones en cada request.
- **Conditions:** language: python, pattern: create_engine|sqlalchemy
- **Action:** Configurar pool_size y max_overflow en create_engine.
- **Source references:** -
- **Bad example:**
```
from sqlalchemy import create_engine
engine = create_engine(DATABASE_URL)
```
- **Good example:**
```
from sqlalchemy import create_engine
engine = create_engine(
    DATABASE_URL,
    pool_size=20,
    max_overflow=40,
    pool_pre_ping=True,
    echo=False
)
```

---

## Logging

### PY_LOGGING_001
- **Severity:** MEDIUM
- **Description:** Usar logging estándar (logging module), no print() para logs en producción.
- **Conditions:** language: python, pattern: print\(
- **Action:** Usar logger.info(), logger.error(), logger.debug(), etc.
- **Source references:** -
- **Bad example:**
```
print(f'User {user_id} created')
print('Error:', error_message)
```
- **Good example:**
```
import logging
logger = logging.getLogger(__name__)
logger.info(f'User {user_id} created')
logger.error(f'Error: {error_message}')
```

### PY_LOGGING_002
- **Severity:** MEDIUM
- **Description:** Usar diferentes niveles de logging: DEBUG, INFO, WARNING, ERROR, CRITICAL.
- **Conditions:** language: python, pattern: logger\.
- **Action:** Usar el nivel apropiado para cada situación.
- **Source references:** -
- **Bad example:**
```
logger.info('User login')
logger.info('Database error occurred')
```
- **Good example:**
```
logger.debug('User login with ID 123')
logger.error('Database error occurred: connection timeout')
```

---

## Clean Code

### PY_CLEAN_001
- **Severity:** MEDIUM
- **Description:** Funciones deben tener una única responsabilidad. Si es muy larga, dividir.
- **Conditions:** language: python, pattern: def |class 
- **Action:** Refactorizar en funciones más pequeñas con responsabilidad única.
- **Source references:** -
- **Bad example:**
```
def process_user_data(user_dict):
    # Validar
    if not user_dict.get('name'): raise ValueError
    # Transformar
    user = transform(user_dict)
    # Guardar
    db.save(user)
    # Notificar
    send_email(user.email)
    # Retornar
    return user
```
- **Good example:**
```
def validate_user(user_dict) -> User:
    if not user_dict.get('name'): raise ValueError
    return User(**user_dict)

def process_user_data(user_dict: dict) -> User:
    user = validate_user(user_dict)
    await save_user(user)
    await notify_user(user)
    return user
```

### PY_CLEAN_002
- **Severity:** MEDIUM
- **Description:** Usar nombres descriptivos para variables, funciones y clases.
- **Conditions:** language: python, pattern: [a-z]\d+|x|y|u|v|tmp
- **Action:** Renombrar con nombres que expliquen su propósito.
- **Source references:** -
- **Bad example:**
```
def f(x, y):
    z = x + y
    return z

tmp = get_users()
for u in tmp:
    p = u.get('p')
```
- **Good example:**
```
def calculate_sum(first_value: int, second_value: int) -> int:
    total = first_value + second_value
    return total

all_users = await fetch_users()
for user in all_users:
    password_hash = user.get('password_hash')
```

---

## Asynchronous

### PY_ASYNC_001
- **Severity:** MEDIUM
- **Description:** Para operaciones que no son I/O, no usar async/await. Mantener simple.
- **Conditions:** language: python, pattern: async def
- **Action:** Usar async solo para I/O (DB, HTTP, filesystem). Para CPU-bound, usar threads o procesos.
- **Source references:** -
- **Bad example:**
```
async def calculate_factorial(n):
    return math.factorial(n)  # CPU-bound, no I/O
```
- **Good example:**
```
def calculate_factorial(n: int) -> int:
    return math.factorial(n)  # Función síncrona

async def get_user_factorial(user_id: int) -> int:
    user = await db.get_user(user_id)  # I/O
    factorial = calculate_factorial(user.number)  # CPU-bound en main thread
```

---

## Configuración

### PY_CONFIG_001
- **Severity:** MEDIUM
- **Description:** Centralizar toda la configuración en un archivo config.py usando Pydantic Settings.
- **Conditions:** language: python, pattern: os\.getenv|environ
- **Action:** Crear config.py con BaseSettings de Pydantic.
- **Source references:** -
- **Bad example:**
```
# En múltiples archivos
DB_URL = os.getenv('DATABASE_URL')
API_KEY = os.getenv('API_KEY')
PORT = os.getenv('PORT', '8000')
```
- **Good example:**
```
# config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    api_key: str
    port: int = 8000
    
    class Config:
        env_file = '.env'

settings = Settings()
```

---

## API Design

### PY_API_001
- **Severity:** MEDIUM
- **Description:** Versionar las APIs usando /v1/, /v2/ en la URL.
- **Conditions:** language: python, framework: fastapi, pattern: @app\.(get|post)
- **Action:** Usar APIRouter con prefix='/api/v1' para versioning.
- **Source references:** -
- **Bad example:**
```
@app.get('/users')
async def get_users(): pass
```
- **Good example:**
```
from fastapi import APIRouter

router = APIRouter(prefix='/api/v1')

@router.get('/users')
async def get_users(): pass

app.include_router(router)
```

### PY_API_002
- **Severity:** MEDIUM
- **Description:** Usar códigos de status HTTP correctos (200, 201, 400, 401, 403, 404, 500).
- **Conditions:** language: python, framework: fastapi
- **Action:** Revisar y usar status codes apropiados.
- **Source references:** -
- **Bad example:**
```
@app.post('/users')
async def create_user(user: UserCreate):
    await db.save(user)
    return user  # 200, debería ser 201
```
- **Good example:**
```
from fastapi import status

@app.post('/users', status_code=status.HTTP_201_CREATED)
async def create_user(user: UserCreate):
    saved = await db.save(user)
    return saved
```

---

## Dependencias

### PY_DEPS_001
- **Severity:** MEDIUM
- **Description:** Usar requirements.txt o pyproject.toml para dependency management. No usar pip install en Dockerfile.
- **Conditions:** language: python, file_pattern: requirements\.txt|pyproject\.toml|Dockerfile
- **Action:** Mantener requirements.txt actualizado o usar pyproject.toml con poetry.
- **Source references:** -
- **Bad example:**
```
# Dockerfile
RUN pip install fastapi uvicorn sqlalchemy pydantic
```
- **Good example:**
```
# requirements.txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.0
pydantic==2.0.0
pydantic-settings==2.0.0

# Dockerfile
COPY requirements.txt .
RUN pip install -r requirements.txt
```
