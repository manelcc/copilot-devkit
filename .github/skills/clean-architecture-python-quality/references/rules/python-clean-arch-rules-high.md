# Copilot Guidelines: Clean Architecture Python — HIGH

---

Total rules: **41**

## SOLID

### SOLID_SRP_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:SOLID_SRP_001`
- **Description:** Una clase o módulo debe tener una, y solo una, razón para cambiar. Los métodos que responden a diferentes "actores" deben estar en clases separadas.
- **Bad example:**
```python
class Employee:  # Clase que sirve al CFO (pago) y al COO (reporte de horas)
    def calculate_pay(self): ...
    def report_hours(self): ...
```
- **Good example:**
```python
class PayCalculator:
    def calculate_pay(self): ...

class HourReporter:
    def report_hours(self): ...
```
- **References:**
  - https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 7 "SRP: The Single Responsibility Principle", p. 62
  - Clean Architecture with Python — Sam Keen — Cap. 2 "Understanding single responsibility", p. 26

---

### SOLID_DIP_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:SOLID_DIP_001`
- **Description:** Los módulos de alto nivel no deben depender de módulos de bajo nivel. Ambos deben depender de abstracciones (interfaces/ABCs).
- **Bad example:**
```python
class UserEntity:
    def __init__(self):
        self.database = MySQLDatabase()  # Dependencia directa de bajo nivel
```
- **Good example:**
```python
class UserEntity:
    def __init__(self, db: DatabaseInterface):  # Dependencia de abstracción
        self.database = db
```
- **References:**
  - https://en.wikipedia.org/wiki/Dependency_inversion_principle
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 11 "DIP: The Dependency Inversion Principle", p. 87
  - Clean Architecture with Python — Sam Keen — Cap. 2 "Dependency Inversion Principle (DIP)", p. 47

---

## ARCH_DATA

### ARCH_DATA_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:ARCH_DATA_001`
- **Description:** Solo estructuras de datos simples (DTOs, diccionarios, dataclasses) deben cruzar las fronteras entre capas. Nunca pasar filas de bases de datos o entidades a la capa de UI.
- **Bad example:**
```python
# El controlador devuelve directamente la fila de SQLAlchemy a la vista
return render_template('user.html', user=user_db_model)
```
- **Good example:**
```python
# El controlador convierte la entidad en un ResponseModel
response = UserResponse.from_entity(user)
return render_template('user.html', user=response)
```
- **References:**
  - https://martinfowler.com/eaaCatalog/dataTransferObject.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 207
  - Clean Architecture with Python — Sam Keen — Cap. 5 "Defining request and response models", p. 123

---

### SOLID_ISP_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:SOLID_ISP_001`
- **Description:** Los clientes no deben ser obligados a depender de métodos que no utilizan. Es mejor tener muchas interfaces pequeñas que una grande.
- **Bad example:**
```python
class MultiFunctionDevice(ABC):
    @abstractmethod
    def print(self): ...
    @abstractmethod
    def scan(self): ...
```
- **Good example:**
```python
class Printer(ABC):
    @abstractmethod
    def print(self): ...

class Scanner(ABC):
    @abstractmethod
    def scan(self): ...
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 10 "ISP: The Interface Segregation Principle", p. 84
  - Clean Architecture with Python — Sam Keen — Cap. 2 "Tailoring interfaces to clients", p. 35

---

### SOLID_OCP_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** El sistema debe ser extensible sin modificar código existente. Añadir nuevos comportamientos mediante nuevas clases o plugins, nunca mediante condicionales `if/elif` sobre tipos.
- **Bad example:**
```python
def render(shape):
    if shape.type == 'circle':
        draw_circle(shape)
    elif shape.type == 'square':
        draw_square(shape)
```
- **Good example:**
```python
class Shape(ABC):
    @abstractmethod
    def draw(self): ...

class Circle(Shape):
    def draw(self): ...

class Square(Shape):
    def draw(self): ...
```
- **References:**
  - https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 8 "OCP: The Open-Closed Principle", p. 69

---

### SOLID_LSP_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Las subclases deben ser sustituibles por sus clases base sin romper el sistema. Si una subclase requiere restricciones adicionales que su base no impone, viola LSP.
- **Bad example:**
```python
class Rectangle:
    def set_width(self, w): self.width = w
    def set_height(self, h): self.height = h

class Square(Rectangle):  # Rompe la invariante de área al fijar ambos lados
    def set_width(self, w):
        self.width = w
        self.height = w
```
- **Good example:**
```python
class Shape(ABC):
    @abstractmethod
    def area(self) -> float: ...

class Rectangle(Shape): ...
class Square(Shape): ...
```
- **References:**
  - https://en.wikipedia.org/wiki/Liskov_substitution_principle
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 9 "LSP: The Liskov Substitution Principle", p. 78

---

### SOLID_LSP_002
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** No usar `super()` de forma que altere las pre-condiciones o invariantes del padre. Extender con `super()` está permitido solo si no se debilitan las garantías del contrato base.
- **Bad example:**
```python
class Base:
    def process(self, value: int):
        assert value > 0

class Child(Base):
    def process(self, value: int):
        super().process(-value)  # Invierte la pre-condición
```
- **Good example:**
```python
class Child(Base):
    def process(self, value: int):
        super().process(value)  # Respeta la pre-condición del padre
        self._extra_step(value)
```
- **References:**
  - https://en.wikipedia.org/wiki/Liskov_substitution_principle
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 9, p. 78

---

### SOLID_ISP_002
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Los métodos de interfaz deben ser atómicos: una sola acción por método. Combinar acciones en un único método de interfaz viola ISP y dificulta la sustitución de adaptadores.
- **Bad example:**
```python
class NotificationPort(ABC):
    @abstractmethod
    def save_and_notify(self, user): ...
```
- **Good example:**
```python
class NotificationPort(ABC):
    @abstractmethod
    def save(self, user): ...
    @abstractmethod
    def notify(self, user): ...
```
- **References:**
  - https://en.wikipedia.org/wiki/Interface_segregation_principle
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 10, p. 84

---

### SOLID_ISP_003
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Usar `typing.Protocol` para definir interfaces de solo lectura y de escritura por separado, siguiendo ISP. Evita que los consumidores dependan de operaciones que no necesitan.
- **Bad example:**
```python
class UserRepository(Protocol):
    def get(self, id: int) -> User: ...
    def save(self, user: User) -> None: ...
    def delete(self, id: int) -> None: ...
```
- **Good example:**
```python
class UserReader(Protocol):
    def get(self, id: int) -> User: ...

class UserWriter(Protocol):
    def save(self, user: User) -> None: ...
    def delete(self, id: int) -> None: ...
```
- **References:**
  - https://peps.python.org/pep-0544/
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 10, p. 84

---

### SOLID_ISP_004
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Los parámetros de los métodos de interfaz deben ser los mínimos necesarios. Pasar objetos grandes cuando solo se necesitan uno o dos campos crea acoplamiento innecesario.
- **Bad example:**
```python
class EmailPort(Protocol):
    def send(self, user: User) -> None: ...  # Solo necesita email y nombre
```
- **Good example:**
```python
class EmailPort(Protocol):
    def send(self, to: str, subject: str, body: str) -> None: ...
```
- **References:**
  - https://en.wikipedia.org/wiki/Interface_segregation_principle
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 10, p. 84

---

### SOLID_DIP_002
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Las interfaces (Ports) deben pertenecer a la capa que las consume, no a la capa que las implementa. El caso de uso define el contrato; la infraestructura lo cumple.
- **Bad example:**
```python
# infra/repositories.py define la interfaz que el caso de uso importa
class UserRepositoryInterface(ABC): ...  # definida en infra ← MAL
```
- **Good example:**
```python
# domain/ports.py define la interfaz
class UserRepositoryPort(ABC): ...  # definida en domain ← BIEN

# infra/repositories.py implementa el port
class UserRepositorySQLAlchemy(UserRepositoryPort): ...
```
- **References:**
  - https://martinfowler.com/articles/dipInTheWild.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 11, p. 91

---

### SOLID_SRP_002
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Las clases de dominio deben ser pequeñas. Si una clase supera las 200 líneas, probablemente está asumiendo más de una responsabilidad y viola el SRP.
- **Bad example:**
```python
class OrderService:  # 450 líneas: crea, valida, notifica, persiste, reporta
    ...
```
- **Good example:**
```python
class OrderCreator: ...       # < 80 líneas
class OrderValidator: ...     # < 60 líneas
class OrderNotifier: ...      # < 50 líneas
```
- **References:**
  - https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 7, p. 62

---

## ARCH_TYPE

### ARCH_TYPE_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** No usar `Any` en los type hints de los contratos de interfaz (Ports). `Any` elimina la verificación estática y oculta dependencias incorrectas entre capas.
- **Bad example:**
```python
from typing import Any

class UserRepositoryPort(ABC):
    @abstractmethod
    def save(self, obj: Any) -> Any: ...
```
- **Good example:**
```python
class UserRepositoryPort(ABC):
    @abstractmethod
    def save(self, entity: User) -> None: ...
```
- **References:**
  - https://peps.python.org/pep-0484/
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 1, p. 5

---

## ARCH_DATA

### ARCH_DATA_002
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Los DTOs (Data Transfer Objects) deben ser inmutables para evitar efectos secundarios entre capas. Usar `NamedTuple` o `dataclass(frozen=True)`.
- **Bad example:**
```python
class UserDTO:
    def __init__(self):
        self.data: dict = {}  # mutable, modificable en cualquier capa
```
- **Good example:**
```python
from typing import NamedTuple

class UserDTO(NamedTuple):
    id: int
    name: str
    email: str
```
- **References:**
  - https://docs.python.org/3/library/typing.html#typing.NamedTuple
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22, p. 207

---

### ARCH_DATA_003
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** No exponer la estructura interna de las entidades de dominio en los DTOs de salida (Output Models). Los Response Models son proyecciones explícitas, no serializaciones directas.
- **Bad example:**
```python
# El controlador serializa directamente la entidad de dominio
return jsonify(user_entity.__dict__)
```
- **Good example:**
```python
response = UserResponse(id=user.id, name=user.name)
return jsonify(response._asdict())
```
- **References:**
  - https://martinfowler.com/eaaCatalog/dataTransferObject.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 8, p. 69

---

## ARCH_UC

### ARCH_UC_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** El interactor (Caso de Uso) debe validar que los datos de entrada (Input DTO) cumplen los requisitos mínimos antes de ejecutar lógica de negocio.
- **Bad example:**
```python
class TransferMoneyUseCase:
    def execute(self, dto: TransferDTO):
        self.account_repo.debit(dto.account_id, dto.amount)  # Sin validar monto
```
- **Good example:**
```python
class TransferMoneyUseCase:
    def execute(self, dto: TransferDTO):
        if dto.amount <= 0:
            raise InvalidAmountError("El monto debe ser positivo")
        self.account_repo.debit(dto.account_id, dto.amount)
```
- **References:**
  - https://en.wikipedia.org/wiki/Defensive_programming
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 20, p. 193

---

### ARCH_UC_002
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** El número de argumentos en el constructor de un interactor no debe exceder 5. Si se necesitan más dependencias, agruparlas en un objeto de configuración o dividir el caso de uso.
- **Bad example:**
```python
class CreateOrderUseCase:
    def __init__(self, repo, notifier, logger, validator, cache, metrics, audit):
        ...
```
- **Good example:**
```python
@dataclass(frozen=True)
class CreateOrderDeps:
    repo: OrderRepositoryPort
    notifier: NotificationPort
    logger: LoggerPort

class CreateOrderUseCase:
    def __init__(self, deps: CreateOrderDeps): ...
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 7, p. 62

---

### ARCH_UC_003
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Los Casos de Uso deben ser stateless entre ejecuciones. No almacenar estado de sesión o de petición como atributos de instancia del interactor.
- **Bad example:**
```python
class GetUserUseCase:
    def execute(self, user_id: int):
        self.last_user_id = user_id  # Estado entre llamadas ← MAL
        return self.repo.get(user_id)
```
- **Good example:**
```python
class GetUserUseCase:
    def execute(self, user_id: int) -> User:
        return self.repo.get(user_id)  # Stateless
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 20, p. 193

---

### ARCH_UC_004
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Los servicios de aplicación (interactors) no deben llamar a otros servicios de aplicación. Esto crea acoplamiento circular y dificulta las pruebas. Extraer lógica común al dominio.
- **Bad example:**
```python
class CreateOrderUseCase:
    def execute(self, dto):
        self.notify_use_case.execute(dto.user_id)  # Llama a otro use case ← MAL
```
- **Good example:**
```python
class CreateOrderUseCase:
    def execute(self, dto):
        self.notification_port.send(dto.user_id)  # Usa el port directamente
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 14, p. 137

---

### ARCH_UC_005
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Los interactores deben gestionar la integridad transaccional mediante un port de `Unit of Work`, no llamando directamente a métodos de commit del repositorio.
- **Bad example:**
```python
class TransferUseCase:
    def execute(self, dto):
        self.account_repo.debit(dto.from_id, dto.amount)
        self.account_repo.credit(dto.to_id, dto.amount)
        self.db_session.commit()  # Detalle de infra en el caso de uso ← MAL
```
- **Good example:**
```python
class TransferUseCase:
    def execute(self, dto):
        with self.unit_of_work:
            self.unit_of_work.accounts.debit(dto.from_id, dto.amount)
            self.unit_of_work.accounts.credit(dto.to_id, dto.amount)
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22, p. 207

---

### ARCH_UC_006
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** El interactor no debe conocer detalles de la sesión del usuario ni tokens JWT. Esa información debe ser resuelta en la capa de entrada (controlador/presenter) y pasada como un ID tipado.
- **Bad example:**
```python
class GetProfileUseCase:
    def execute(self, token: str):
        user_id = jwt.decode(token)['sub']  # Decode JWT en el use case ← MAL
```
- **Good example:**
```python
class GetProfileUseCase:
    def execute(self, user_id: UserId) -> UserProfile:
        return self.repo.get(user_id)
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22, p. 207

---

## ARCH_ENTITY

### ARCH_ENTITY_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Las Entidades de dominio no deben tener dependencias inyectadas en el constructor. Los servicios externos se pasan como parámetros de método, no como atributos de instancia.
- **Bad example:**
```python
class Order:
    def __init__(self, repo: OrderRepository):  # Dependencia inyectada ← MAL
        self.repo = repo
```
- **Good example:**
```python
class Order:
    def __init__(self, id: OrderId, items: list[OrderItem]): ...

    def calculate_total(self, pricing_service: PricingPort) -> Money:
        return pricing_service.calculate(self.items)
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 20, p. 185

---

### ARCH_ENTITY_002
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Utilizar `@dataclass(frozen=True)` para representar Value Objects. Garantiza inmutabilidad y facilita la comparación por valor.
- **Bad example:**
```python
class Money:
    def __init__(self, amount, currency):
        self.amount = amount    # mutable
        self.currency = currency
```
- **Good example:**
```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Money:
    amount: Decimal
    currency: str
```
- **References:**
  - https://martinfowler.com/bliki/ValueObject.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 20, p. 185

---

### ARCH_ENTITY_003
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Los constructores de Entidades deben garantizar que el objeto siempre esté en un estado válido. Nunca permitir construir una entidad con datos inválidos.
- **Bad example:**
```python
class User:
    def __init__(self, email: str):
        self.email = email  # email puede ser vacío o inválido
```
- **Good example:**
```python
class User:
    def __init__(self, email: str):
        if not email or '@' not in email:
            raise ValueError(f"Email inválido: {email!r}")
        self.email = email
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 20, p. 185

---

## ARCH_DOMAIN

### ARCH_DOMAIN_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Las clases de lógica de negocio críticas deben ser no heredables (usar `Final` o convención de equipo) para proteger la integridad de sus invariantes.
- **Bad example:**
```python
class PaymentCalculator:
    def calculate(self, order): ...

class HackedCalculator(PaymentCalculator):
    def calculate(self, order): return 0  # Rompe la invariante ← MAL
```
- **Good example:**
```python
from typing import final

@final
class PaymentCalculator:
    def calculate(self, order: Order) -> Money: ...
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 9, p. 78

---

### ARCH_DOMAIN_002
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** No usar `@staticmethod` para lógica que debería ser una función pura de módulo o un método de instancia. `@staticmethod` dentro de clases de dominio oculta dependencias y dificulta el testing.
- **Bad example:**
```python
class OrderService:
    @staticmethod
    def calculate_discount(order):  # No accede a self, debería ser función de módulo
        ...
```
- **Good example:**
```python
# domain/order_discount.py
def calculate_discount(order: Order) -> Money: ...
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 3, p. 27

---

### ARCH_DOMAIN_003
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Usar `Enum` para representar estados finitos de negocio. Evitar strings mágicos que no son verificados por el compilador.
- **Bad example:**
```python
order.status = "shipped"   # String mágico, propenso a typos
if order.status == "shiped": ...  # Bug silencioso
```
- **Good example:**
```python
from enum import Enum

class OrderStatus(Enum):
    PENDING = "pending"
    SHIPPED = "shipped"
    DELIVERED = "delivered"

order.status = OrderStatus.SHIPPED
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 3, p. 27

---

### ARCH_DOMAIN_004
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Prohibido el uso de `global` en Python para cualquier dato relacionado con la lógica de negocio. El estado global oculta dependencias y hace el código no testeable.
- **Bad example:**
```python
current_user = None  # Estado global

def process_order():
    global current_user
    if current_user.is_admin: ...
```
- **Good example:**
```python
def process_order(current_user: User) -> None:
    if current_user.is_admin: ...
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 3, p. 27

---

### ARCH_DOMAIN_005
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Las excepciones de negocio deben contener datos de contexto estructurados, no solo mensajes de texto. Facilita el logging, el debugging y la respuesta al cliente.
- **Bad example:**
```python
raise ValueError("Saldo insuficiente")
```
- **Good example:**
```python
@dataclass(frozen=True)
class InsufficientFundsError(DomainError):
    account_id: str
    required: Decimal
    available: Decimal
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 20, p. 193

---

### ARCH_DOMAIN_006
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** La lógica de ordenamiento y filtrado de negocio debe residir en el dominio, no delegarse al SQL de la base de datos. El SQL filtra por rendimiento; el dominio define las reglas.
- **Bad example:**
```python
# La regla de negocio "activos con saldo > 0" vive en SQL
repo.query("SELECT * FROM accounts WHERE active=1 AND balance > 0 ORDER BY name")
```
- **Good example:**
```python
# domain/account.py
def is_eligible_for_report(account: Account) -> bool:
    return account.is_active and account.balance > Money.zero()
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 30, p. 295

---

### ARCH_DOMAIN_007
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Los errores de validación deben agruparse y retornarse todos juntos (Notification Pattern), en lugar de lanzar una excepción al primer error encontrado.
- **Bad example:**
```python
def validate(dto):
    if not dto.email: raise ValidationError("Email requerido")
    if not dto.name: raise ValidationError("Nombre requerido")  # Nunca llega aquí
```
- **Good example:**
```python
def validate(dto) -> list[str]:
    errors = []
    if not dto.email: errors.append("Email requerido")
    if not dto.name:  errors.append("Nombre requerido")
    if errors: raise ValidationErrors(errors)
```
- **References:**
  - https://martinfowler.com/eaaDev/Notification.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 20, p. 193

---

### ARCH_DOMAIN_008
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Prohibido incluir lógica de negocio dentro de archivos `__init__.py`. Estos archivos son exclusivamente para exportaciones y configuración de paquetes.
- **Bad example:**
```python
# domain/__init__.py
def calculate_tax(amount):  # Lógica de negocio en __init__ ← MAL
    return amount * 0.21
```
- **Good example:**
```python
# domain/__init__.py  ← solo exportaciones
from .entities import User, Order
from .value_objects import Money

# domain/tax_calculator.py  ← lógica en su propio módulo
def calculate_tax(amount: Money) -> Money: ...
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 34, p. 341

---

## ARCH_LAYER

### ARCH_LAYER_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Un cambio en la base de datos (schema, ORM, motor) no debe forzar ningún cambio en las entidades de dominio. El dominio es independiente de los detalles de persistencia.
- **Bad example:**
```python
# domain/user.py
from sqlalchemy import Column, Integer, String, Base

class User(Base):  # La entidad hereda del ORM ← MAL
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
```
- **Good example:**
```python
# domain/user.py  — sin imports de infraestructura
@dataclass
class User:
    id: UserId
    name: str
    email: str
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 30, p. 295

---

### ARCH_LAYER_002
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Los adaptadores (implementaciones de Ports) deben ser intercambiables sin modificar el núcleo. Sustituir un adaptador por otro solo requiere implementar el Port.
- **Bad example:**
```python
# El caso de uso instancia directamente el adaptador
class CreateUserUseCase:
    def __init__(self):
        self.repo = PostgreSQLUserRepository()  # Acoplado a infra ← MAL
```
- **Good example:**
```python
class CreateUserUseCase:
    def __init__(self, repo: UserRepositoryPort): ...
    # Inyectar PostgreSQL, SQLite o Mock sin tocar el caso de uso
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 17, p. 163

---

### ARCH_LAYER_003
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** El Dominio no debe usar tipos `Union` que incluyan tipos de infraestructura o de framework. Los tipos en las firmas del dominio deben ser exclusivamente del dominio o de la stdlib.
- **Bad example:**
```python
# domain/ports.py
from sqlalchemy.orm import Session

class UserRepositoryPort(ABC):
    def get(self, session: Session, id: int) -> User: ...  # Tipo de infra ← MAL
```
- **Good example:**
```python
# domain/ports.py — sin imports de infra
class UserRepositoryPort(ABC):
    def get(self, id: UserId) -> User: ...
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22, p. 207

---

## ARCH_COUP

### ARCH_COUP_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Prohibido el acoplamiento transitivo entre capas. Si A depende de B y B depende de C, A no debe conocer ni importar directamente a C.
- **Bad example:**
```python
# application/use_cases.py
from infrastructure.orm.models import UserModel  # A conoce directamente C ← MAL
```
- **Good example:**
```python
# application/use_cases.py
from domain.entities import User  # A solo conoce el dominio
# La infra adapta UserModel → User internamente
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 8, p. 69

---

## ARCH_COMP

### ARCH_COMP_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Evitar jerarquías de herencia de más de 2 niveles. Favorecer la composición sobre la herencia para extender comportamiento.
- **Bad example:**
```python
class User: ...
class Admin(User): ...
class SuperAdmin(Admin): ...
class SpecialSuperAdmin(SuperAdmin): ...  # 4 niveles ← MAL
```
- **Good example:**
```python
@dataclass
class User:
    permissions: list[Permission]  # Composición mediante lista de permisos
```
- **References:**
  - https://en.wikipedia.org/wiki/Composition_over_inheritance
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 5, p. 42

---

## ARCH_PATTERN

### ARCH_PATTERN_001
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Usar el patrón `Facade` para ocultar la complejidad de un subsistema a la capa de aplicación. El Facade expone una interfaz simplificada sin revelar los detalles internos.
- **Bad example:**
```python
# El caso de uso orquesta directamente 5 servicios internos del subsistema
class CheckoutUseCase:
    def execute(self, dto):
        self.inventory.lock(dto.items)
        self.pricing.apply_discounts(dto.items)
        self.tax_engine.calculate(dto.total)
        self.payment_gateway.charge(dto.card)
        self.warehouse.reserve(dto.items)
```
- **Good example:**
```python
class CheckoutFacade:
    def process(self, cart: Cart) -> Receipt: ...  # Oculta los 5 servicios

class CheckoutUseCase:
    def execute(self, dto):
        return self.checkout_facade.process(dto.cart)
```
- **References:**
  - https://refactoring.guru/design-patterns/facade
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 24, p. 237

---

### ARCH_PATTERN_002
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Implementar el patrón `Strategy` para encapsular algoritmos que cambian frecuentemente o que tienen múltiples variantes. Evita condicionales `if/elif` en el dominio.
- **Bad example:**
```python
def calculate_shipping(order, strategy: str):
    if strategy == 'express': return order.weight * 5
    elif strategy == 'standard': return order.weight * 2
```
- **Good example:**
```python
class ShippingStrategy(Protocol):
    def calculate(self, order: Order) -> Money: ...

class ExpressShipping:
    def calculate(self, order: Order) -> Money:
        return order.weight * Money(5, 'EUR')
```
- **References:**
  - https://refactoring.guru/design-patterns/strategy
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 8, p. 69

---

### ARCH_PATTERN_003
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Separar el código de "lectura" del de "escritura" (CQRS) cuando el negocio tiene requerimientos de rendimiento distintos para consultas y comandos.
- **Bad example:**
```python
class OrderRepository:
    def save(self, order: Order): ...
    def get_dashboard_summary(self) -> dict: ...  # Query compleja mezclada con writes
```
- **Good example:**
```python
class OrderCommandRepository:
    def save(self, order: Order): ...

class OrderQueryRepository:
    def get_dashboard_summary(self) -> DashboardSummaryDTO: ...
```
- **References:**
  - https://martinfowler.com/bliki/CQRS.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 16, p. 155

---

### ARCH_PATTERN_004
- **Severity:** HIGH
- **Source:** `custom` / `custom:Clean Architecture`
- **Description:** Utilizar fábricas abstractas para instanciar entidades complejas. Evita acoplar el creador a la clase concreta y centraliza las reglas de construcción.
- **Bad example:**
```python
# El caso de uso construye directamente la entidad compleja
order = Order(id=uuid4(), items=items, user=user, discount=Discount(...))
```
- **Good example:**
```python
class OrderFactory:
    def create(self, user: User, items: list[CartItem]) -> Order:
        return Order(
            id=OrderId(uuid4()),
            items=[OrderItem.from_cart(i) for i in items],
            discount=self.discount_policy.for_user(user),
        )
```
- **References:**
  - https://refactoring.guru/design-patterns/abstract-factory
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 11, p. 91
