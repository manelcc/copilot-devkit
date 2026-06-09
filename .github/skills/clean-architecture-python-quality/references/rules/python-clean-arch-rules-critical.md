# Copilot Guidelines: Clean Architecture Python — CRITICAL

---

Total rules: **38**

## ARCH_CORE

### ARCH_CORE_001
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_001`
- **Description:** Las dependencias de código fuente solo deben apuntar hacia adentro, hacia las políticas de nivel superior (La Regla de Dependencia). Nada en un círculo interior puede saber nada sobre algo en un círculo exterior.
- **Bad example:**
```python
# En domain/entities/task.py
from infrastructure.database import db_session  # Error: El dominio depende de la infraestructura
```
- **Good example:**
```python
# En domain/entities/task.py
class Task:
    pass  # No conoce detalles externos
```
- **References:**
  - https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 203
  - Clean Architecture with Python — Sam Keen — Cap. 1 "Implementing Clean Architecture in Python", p. 15

---

### ARCH_CORE_002
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_002`
- **Description:** El núcleo del negocio (Entities) debe estar completamente libre de dependencias de frameworks, bases de datos o servicios externos.
- **Bad example:**
```python
@dataclass
class Order(db.Model):  # Acoplamiento directo a SQLAlchemy en la Entidad
    id = db.Column(db.Integer, primary_key=True)
```
- **Good example:**
```python
@dataclass
class Order:  # Pura lógica de negocio (POPO)
    id: UUID
```
- **References:**
  - https://testdriven.io/blog/clean-code-python/
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 20 "Business Rules", p. 190
  - Clean Architecture with Python — Sam Keen — Cap. 4 "Ensuring domain independence", p. 100

---

### ARCH_CORE_003
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_003`
- **Description:** Se prohíben las dependencias circulares entre componentes o capas. La estructura de dependencia debe ser un Grafo Acíclico Dirigido (DAG).
- **Bad example:**
```python
# ComponenteA importa de ComponenteB y ComponenteB importa de ComponenteA.
```
- **Good example:**
```python
# Utilizar el Principio de Inversión de Dependencia (DIP) mediante interfaces (ABCs) para romper el ciclo.
```
- **References:**
  - https://en.wikipedia.org/wiki/Acyclic_dependencies_principle
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 14 "Component Coupling", p. 114

---

### ARCH_CORE_004
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_004`
- **Description:** Los Use Cases no deben contener lógica de interfaz de usuario ni detalles de persistencia; deben orquestar el flujo de datos hacia y desde las Entidades.
- **Bad example:**
```python
class CreateUserUseCase:
    def execute(self, request):
        if not request.form['email']:
            return render_template('error.html')  # Error: Lógica de UI en Use Case
```
- **Good example:**
```python
class CreateUserUseCase:
    def execute(self, user_data: UserRequest) -> Result:
        user = User(user_data.email)
        return Result.success(user)
```
- **References:**
  - https://martinfowler.com/bliki/UseCase.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 20 "Business Rules", p. 192
  - Clean Architecture with Python — Sam Keen — Cap. 5 "The Application Layer: Orchestrating Use Cases", p. 110

---

### ARCH_CORE_005
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_005`
- **Description:** Inversión de Dependencias (DIP) obligatoria en el acceso a datos. El caso de uso define la interfaz, la infraestructura la implementa.
- **Bad example:**
```python
# Dentro de un interactor
db.save(user)  # Dependencia directa de la infraestructura
```
- **Good example:**
```python
class CreateUserUseCase:
    def __init__(self, repo: UserRepository): ...
    def execute(self, data): self.repo.save(user)
```
- **References:**
  - https://en.wikipedia.org/wiki/Dependency_inversion_principle
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 11 "DIP: The Dependency Inversion Principle", p. 87

---

### ARCH_CORE_006
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_006`
- **Description:** Prohibido el uso de Pydantic u otras librerías de terceros dentro de las Entidades del Dominio. Las entidades deben usar solo tipos nativos de Python.
- **Bad example:**
```python
class Order(BaseModel):  # Pydantic en la entidad de dominio
    id: str
```
- **Good example:**
```python
class Order:  # Tipos nativos, sin dependencia de terceros
    def __init__(self, id: str): self.id = id
```
- **References:**
  - https://docs.python.org/3/library/typing.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 32, p. 289

---

### ARCH_CORE_007
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_007`
- **Description:** El flujo de control debe ser opuesto a la dependencia de código fuente mediante polimorfismo. Los interactors deben depender de `Protocol` o ABCs, nunca de implementaciones concretas.
- **Bad example:**
```python
from infrastructure.repositories import SQLAlchemyUserRepository
class GetUserUseCase:
    def __init__(self): self.repo = SQLAlchemyUserRepository()
```
- **Good example:**
```python
from typing import Protocol
class UserRepository(Protocol):
    def find_by_id(self, id: str): ...
class GetUserUseCase:
    def __init__(self, repo: UserRepository): ...
```
- **References:**
  - https://peps.python.org/pep-0544/
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 5, p. 44

---

### ARCH_CORE_008
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_008`
- **Description:** El "Composition Root" (main.py o punto de entrada) es el único lugar donde se permite el acoplamiento con implementaciones concretas de infraestructura.
- **Bad example:**
```python
# En una vista de Flask
def create_user():
    repo = SQLAlchemyUserRepository()  # Instancia concreta en la vista
    use_case = CreateUserUseCase(repo)
```
- **Good example:**
```python
# En main.py / app factory
container = Container()
container.wire(modules=[views])
```
- **References:**
  - https://python-dependency-injector.ets-labs.org/
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 26, p. 227

---

### ARCH_CORE_009
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_009`
- **Description:** El dominio debe ser agnóstico al tiempo y al sistema de archivos. `datetime.now()` o `open()` nunca deben aparecer dentro de una entidad.
- **Bad example:**
```python
class Order:
    def confirm(self):
        self.confirmed_at = datetime.now()  # El dominio toma el tiempo del sistema
```
- **Good example:**
```python
class Order:
    def confirm(self, clock: Clock):
        self.confirmed_at = clock.now()
```
- **References:**
  - https://martinfowler.com/articles/injection.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 17, p. 155

---

### ARCH_CORE_010
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_010`
- **Description:** Las excepciones de infraestructura deben ser capturadas en los adaptadores y convertidas en excepciones de dominio antes de propagarse hacia capas interiores.
- **Bad example:**
```python
# El controlador captura directamente una excepción de SQLAlchemy
except sqlalchemy.exc.NoResultFound:
    return 404
```
- **Good example:**
```python
# El repositorio convierte la excepción
except sqlalchemy.exc.NoResultFound:
    raise UserNotFoundError(user_id)
```
- **References:**
  - https://docs.python.org/3/tutorial/errors.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22, p. 207

---

### ARCH_CORE_011
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_011`
- **Description:** Prohibido pasar objetos de request HTTP (`HttpRequest`, `Request`) a los interactors o casos de uso. Solo se deben pasar DTOs o tipos primitivos.
- **Bad example:**
```python
class CreateUserUseCase:
    def execute(self, request: Request): ...
```
- **Good example:**
```python
class CreateUserUseCase:
    def execute(self, data: CreateUserDTO): ...
```
- **References:**
  - https://fastapi.tiangolo.com/tutorial/sql-databases/
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22, p. 208

---

### ARCH_CORE_012
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_012`
- **Description:** Las firmas de los métodos del dominio deben usar solo tipos primitivos o entidades de dominio. Nunca tipos de librerías externas como `pd.DataFrame` o `np.ndarray`.
- **Bad example:**
```python
def process(self, data: pd.DataFrame): ...
```
- **Good example:**
```python
def process(self, data: List[Record]): ...
```
- **References:**
  - https://docs.python.org/3/library/typing.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22, p. 209

---

### ARCH_CORE_013
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_013`
- **Description:** Las entidades deben agrupar datos y reglas de negocio críticas, no ser meras bolsas de datos (Anemic Domain Model). La lógica de negocio debe vivir en la entidad.
- **Bad example:**
```python
class Invoice:  # Solo atributos, sin lógica
    total: float
    items: list
# Lógica de cálculo en InvoiceService de infraestructura
```
- **Good example:**
```python
class Invoice:
    def calculate_total(self) -> float:
        return sum(item.price for item in self.items)
```
- **References:**
  - https://martinfowler.com/bliki/AnemicDomainModel.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 20, p. 192

---

### ARCH_CORE_014
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_014`
- **Description:** Independencia de Dispositivo: el dominio no debe saber si la salida es una consola, un JSON o un archivo. Debe retornar DTOs y dejar que el presentador decida el formato.
- **Bad example:**
```python
def get_report(self):
    print(f"Total: {self.total}")  # El dominio decide el formato de salida
```
- **Good example:**
```python
def get_report(self) -> ReportDTO:
    return ReportDTO(total=self.total)  # El presentador formatea
```
- **References:**
  - https://en.wikipedia.org/wiki/Device_independence
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 15, p. 138

---

### ARCH_CORE_015
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_015`
- **Description:** El esquema de la base de datos debe ser un detalle derivado del dominio, no al revés. El modelo de dominio se define primero y se mapea a la DB mediante un Data Mapper.
- **Bad example:**
```python
# Crear tablas en DB y generar clases Python desde el esquema
# python manage.py inspectdb > models.py
```
- **Good example:**
```python
# Definir el modelo de dominio primero
@dataclass
class Product:
    id: UUID
# Luego mapear a la DB en la capa de infraestructura
```
- **References:**
  - https://martinfowler.com/eaaCatalog/dataMapper.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 30, p. 265

---

### ARCH_CORE_016
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_016`
- **Description:** Uso obligatorio de `Abstract Base Classes` (ABCs) para definir contratos de infraestructura en componentes críticos.
- **Bad example:**
```python
# Duck typing sin validación de interfaz en componentes críticos
class EmailService:
    def send(self, to, body): ...
```
- **Good example:**
```python
from abc import ABC, abstractmethod
class NotificationGateway(ABC):
    @abstractmethod
    def send(self, to: str, body: str) -> None: ...
```
- **References:**
  - https://docs.python.org/3/library/abc.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 11, p. 91

---

### ARCH_CORE_017
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_017`
- **Description:** Prohibido el uso de variables globales para almacenar conexiones a bases de datos o sesiones. La sesión debe inyectarse por dependencias.
- **Bad example:**
```python
db = SQLAlchemy()  # Variable global de conexión
@app.route('/users')
def get_users():
    return db.session.query(User).all()
```
- **Good example:**
```python
class UserRepository:
    def __init__(self, session: Session): self.session = session
```
- **References:**
  - https://en.wikipedia.org/wiki/Global_variable
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 26, p. 228

---

### ARCH_CORE_018
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_018`
- **Description:** La lógica de autorización y autenticación debe residir en adaptadores o decoradores, nunca dentro del dominio de negocio.
- **Bad example:**
```python
class InvoiceCalculator:
    def calculate(self, user, invoice):
        if user.role != 'admin':  # Lógica de auth en cálculo de negocio
            raise PermissionError()
```
- **Good example:**
```python
@require_role('admin')
@app.route('/invoice/calculate')
def calculate():
    return invoice_use_case.execute(data)
```
- **References:**
  - https://flask.palletsprojects.com/en/2.0.x/patterns/viewdecorators/
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22, p. 209

---

### ARCH_CORE_019
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_019`
- **Description:** La capa de aplicación (interactors) no debe depender directamente de librerías de logging externas. Se debe inyectar un `LoggerPort` que abstraiga la implementación.
- **Bad example:**
```python
import logging
class CreateOrderUseCase:
    def execute(self, data):
        logging.error("Order failed")  # Dependencia directa de logging
```
- **Good example:**
```python
class CreateOrderUseCase:
    def __init__(self, logger: LoggerPort): ...
    def execute(self, data):
        self.logger.error("Order failed")
```
- **References:**
  - https://docs.python.org/3/library/logging.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 32, p. 291

---

### ARCH_CORE_020
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_020`
- **Description:** Despliegue Independiente: los componentes de negocio deben poder ejecutarse y testearse sin necesidad de una DB o UI real. Los tests de dominio deben usar Mocks/Fakes.
- **Bad example:**
```python
# El código no ejecuta tests sin una URL de DB válida
def test_create_order():
    db = create_engine(os.getenv('DATABASE_URL'))  # Test depende de DB real
```
- **Good example:**
```python
def test_create_order():
    repo = InMemoryOrderRepository()  # Fake en memoria
    use_case = CreateOrderUseCase(repo)
```
- **References:**
  - https://en.wikipedia.org/wiki/Mock_object
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 16, p. 147

---

### ARCH_CORE_021
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_021`
- **Description:** Prohibido el acoplamiento temporal mediante variables de estado en Singletons de negocio. El estado debe pasarse como argumento al método del interactor.
- **Bad example:**
```python
Config.set_current_user(user)  # Estado global mutable
use_case.execute()
```
- **Good example:**
```python
use_case.execute(user=current_user, data=dto)
```
- **References:**
  - https://en.wikipedia.org/wiki/Singleton_pattern
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 26, p. 229

---

### ARCH_CORE_022
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_022`
- **Description:** El Dominio debe ser testeable en milisegundos. Cualquier test de dominio que abra un socket, archivo o conexión de red es un indicador crítico de violación arquitectónica.
- **Bad example:**
```python
def test_business_rule():
    redis = Redis(host='localhost')  # Test de dominio levanta Redis
    rule = BusinessRule(redis)
```
- **Good example:**
```python
def test_business_rule():
    cache = InMemoryCache()  # Fake en memoria, sin I/O
    rule = BusinessRule(cache)
```
- **References:**
  - https://martinfowler.com/articles/practical-test-pyramid.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 28, p. 245

---

### ARCH_CORE_023
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_023`
- **Description:** Uso de `Protocols` para dependencias de "Plugins". Las librerías de terceros son plugins del sistema, no el núcleo; el dominio nunca debe depender de sus tipos directamente.
- **Bad example:**
```python
class NotificationService:
    def notify(self, response: requests.Response): ...
```
- **Good example:**
```python
from typing import Protocol
class HttpClientProtocol(Protocol):
    def get(self, url: str) -> HttpResponse: ...
```
- **References:**
  - https://peps.python.org/pep-0544/
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 17, p. 157

---

### ARCH_CORE_024
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_024`
- **Description:** La validación de formato (email válido, longitud) puede estar en DTOs, pero la validación de negocio (email duplicado, saldo suficiente) solo debe residir en el Dominio.
- **Bad example:**
```python
@app.route('/transfer')
def transfer():
    if account.balance < amount:  # Validación de negocio en el controlador
        return error(400)
```
- **Good example:**
```python
class Account:
    def transfer(self, amount: Decimal):
        if self.balance < amount:
            raise InsufficientFundsError()
```
- **References:**
  - https://martinfowler.com/eaaCatalog/serviceLayer.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 20, p. 195

---

### ARCH_CORE_025
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_025`
- **Description:** Evitar el uso de `getattr`, `setattr` o `locals()` para manipular entidades de dominio; rompe el tipado estático y la intención explícita del modelo.
- **Bad example:**
```python
for field, value in updates.items():
    setattr(user, field, value)  # Mutación dinámica de entidad
```
- **Good example:**
```python
user.update_email(new_email)
user.update_name(new_name)
```
- **References:**
  - https://docs.python.org/3/library/functions.html#getattr
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 1, p. 5

---

### ARCH_CORE_026
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_026`
- **Description:** Los objetos de configuración de infraestructura no deben penetrar en el interactor. Solo se deben pasar los valores primitivos estrictamente necesarios.
- **Bad example:**
```python
use_case.run(settings=flask_app.config)  # Config completa de infra al interactor
```
- **Good example:**
```python
use_case.run(api_key=settings.PAYMENT_API_KEY)
```
- **References:**
  - https://12factor.net/config
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22, p. 209

---

### ARCH_CORE_027
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_027`
- **Description:** El interactor debe retornar objetos simples (DTOs, listas de entidades), nunca cursores de base de datos vivos, generadores de ORM o streams de infraestructura.
- **Bad example:**
```python
class GetUsersUseCase:
    def execute(self):
        return self.session.query(User)  # Retorna cursor vivo de SQLAlchemy
```
- **Good example:**
```python
class GetUsersUseCase:
    def execute(self) -> List[UserDTO]:
        return [UserDTO.from_entity(u) for u in self.repo.find_all()]
```
- **References:**
  - https://en.wikipedia.org/wiki/Data_transfer_object
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22, p. 208

---

### ARCH_CORE_028
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_028`
- **Description:** Las dependencias de librerías matemáticas o científicas (numpy, pandas) deben estar encapsuladas en adaptadores si no son el núcleo del negocio; el dominio recibe objetos de dominio, no DataFrames.
- **Bad example:**
```python
class RiskCalculator:
    def calculate(self, data: pd.DataFrame): ...
```
- **Good example:**
```python
class AnalysisGateway(ABC):
    @abstractmethod
    def analyze(self, records: List[Record]) -> RiskResult: ...
# La implementación usa pandas internamente
```
- **References:**
  - https://pandas.pydata.org/
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 32, p. 293

---

### ARCH_CORE_029
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_029`
- **Description:** Principio de Estabilidad de Abstracciones: cuanto más abstracto sea un componente, más estable debe ser. Las interfaces de repositorio solo deben cambiar cuando cambia el requerimiento de negocio, nunca por cambios de esquema de DB.
- **Bad example:**
```python
# La interfaz cambia cada vez que se añade una columna a la tabla
class UserRepository(ABC):
    def find_by_id_with_address_and_phone(self, id): ...
```
- **Good example:**
```python
class UserRepository(ABC):
    def find_by_id(self, id: UserId) -> User: ...
```
- **References:**
  - https://en.wikipedia.org/wiki/Stable-abstractions_principle
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 14, p. 129

---

### ARCH_CORE_030
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_030`
- **Description:** Prohibido el uso de hilos (`threading`) o asincronía (`asyncio`) dentro de las entidades de dominio puro. El interactor gestiona la concurrencia; el modelo es síncrono y puro.
- **Bad example:**
```python
class RiskModel:
    async def calculate_risk(self): ...
```
- **Good example:**
```python
class RiskModel:
    def calculate_risk(self) -> RiskScore: ...
# El interactor decide si ejecuta async
```
- **References:**
  - https://docs.python.org/3/library/asyncio.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 18, p. 165

---

### ARCH_CORE_031
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_031`
- **Description:** El acceso a variables de entorno (`os.getenv`) debe estar restringido a la capa de configuración o infraestructura. El dominio recibe valores concretos, nunca llama a `os.getenv`.
- **Bad example:**
```python
class PaymentService:
    def charge(self):
        if os.getenv('ENV') == 'prod':  # os.getenv en el dominio
            ...
```
- **Good example:**
```python
class PaymentService:
    def __init__(self, is_production: bool): ...
```
- **References:**
  - https://docs.python.org/3/library/os.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 17, p. 159

---

### ARCH_CORE_032
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_032`
- **Description:** Separación de intereses: la lógica de "cómo se guarda" no debe mezclarse con "qué se guarda". Los métodos de persistencia no deben pertenecer a las entidades.
- **Bad example:**
```python
class User:
    def save_to_s3(self): ...
```
- **Good example:**
```python
class StoragePort(ABC):
    @abstractmethod
    def save(self, user: User) -> None: ...
```
- **References:**
  - https://en.wikipedia.org/wiki/Separation_of_concerns
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 15, p. 140

---

### ARCH_CORE_033
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_033`
- **Description:** El sistema debe ser capaz de funcionar con una "Mock UI" (test unitario o script de consola) para validar todas las reglas de negocio sin necesidad de levantar un servidor HTTP.
- **Bad example:**
```python
# Lógica de negocio que solo se puede ejecutar mediante un POST de HTTP
@app.route('/checkout', methods=['POST'])
def checkout():
    # 80 líneas de lógica de negocio
```
- **Good example:**
```python
class CheckoutUseCase:
    def execute(self, cart: CartDTO) -> OrderDTO: ...
# Testeable desde pytest sin levantar Flask
```
- **References:**
  - https://en.wikipedia.org/wiki/Unit_testing
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 21, p. 198

---

### ARCH_CORE_034
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_034`
- **Description:** La estructura del proyecto debe ser independiente de cómo se despliega (Docker, Serverless, Monolito). Las carpetas se organizan por dominio, con adaptadores específicos para cada mecanismo de despliegue.
- **Bad example:**
```
handlers/          # Carpetas nombradas según AWS Lambda
lambda_function.py
```
- **Good example:**
```
domain/
application/
infrastructure/
    adapters/
        lambda_handler.py  # Adaptador específico de despliegue
```
- **References:**
  - https://aws.amazon.com/lambda/
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 16, p. 148

---

### ARCH_CORE_035
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_035`
- **Description:** Evitar decoradores de frameworks (ej: `@app.route`) en métodos que contienen lógica de negocio. Los controladores deben ser delgados y delegar inmediatamente al caso de uso.
- **Bad example:**
```python
@app.route('/calculate')
def calc():
    # 50 líneas de lógica de negocio aquí
    result = a * b + ...
```
- **Good example:**
```python
@app.route('/calculate')
def calc():
    return jsonify(interactor.execute(dto_from(request)))
```
- **References:**
  - https://flask.palletsprojects.com/
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 32, p. 290

---

### ARCH_CORE_036
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_036`
- **Description:** Prohibido importar modelos del ORM o del dominio en los scripts de migración de base de datos (Alembic). Los scripts de migración deben usar SQL puro o tablas locales.
- **Bad example:**
```python
# En un script de Alembic
from app.domain.models import User
def upgrade():
    op.add_column('users', Column('email', String))
```
- **Good example:**
```python
# En un script de Alembic — sin imports del dominio
def upgrade():
    op.add_column('users', sa.Column('email', sa.String(255)))
```
- **References:**
  - https://alembic.sqlalchemy.org/
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 30, p. 268

---

### ARCH_CORE_037
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_037`
- **Description:** El Dominio no debe conocer los códigos de estado HTTP (200, 404, 500). Los controladores son los responsables de mapear resultados y excepciones de dominio a respuestas HTTP.
- **Bad example:**
```python
class UserService:
    def get_user(self, id):
        return {"status": 404, "error": "Not found"}  # Código HTTP en el dominio
```
- **Good example:**
```python
class UserService:
    def get_user(self, id) -> User:
        raise UserNotFoundError(id)  # El controlador mapea a 404
```
- **References:**
  - https://developer.mozilla.org/es/docs/Web/HTTP/Status
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22, p. 208

---

### ARCH_CORE_038
- **Severity:** CRITICAL
- **Source:** `custom` / `custom:ARCH_CORE_038`
- **Description:** Aislamiento total del mundo exterior: el Dominio debe ser una "isla de pureza" lógica. Cualquier fuente de no-determinismo (tiempo, red, archivos, aleatoriedad) debe inyectarse como dependencia.
- **Bad example:**
```python
class Simulation:
    def run(self):
        random.seed()  # No-determinismo basado en el estado del sistema
```
- **Good example:**
```python
class Simulation:
    def __init__(self, rng: RandomProvider): ...
    def run(self):
        value = self.rng.next()  # Dependencia inyectada, testeable
```
- **References:**
  - https://en.wikipedia.org/wiki/Pure_function
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 19, p. 182
