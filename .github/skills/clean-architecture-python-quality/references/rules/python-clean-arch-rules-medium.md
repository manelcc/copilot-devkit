# Copilot Guidelines: Clean Architecture Python — MEDIUM

---

Total rules: **22**

> **Nota de deduplicación:** La regla 095 del catálogo original (no retornar modelos de BD directamente a la vista) fue omitida por ser equivalente a `HIGH ARCH_DATA_001`.

## CODE

### CODE_FUNC_001
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:CODE_FUNC_001`
- **Description:** Las funciones deben ser pequeñas y hacer una sola cosa. Un buen indicador es el nivel de abstracción; todos los enunciados de una función deben estar en el mismo nivel.
- **Bad example:**
```python
def process_data(data):
    clean_data = [d.strip() for d in data]
    save_to_s3(clean_data)
    update_local_cache(clean_data)
```
- **Good example:**
```python
def process_data(data):
    cleaned = clean(data)
    persist(cleaned)
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 5 "Structured Programming", p. 34
  - Clean Architecture with Python — Sam Keen — Cap. 2 "SOLID Foundations", p. 26

---

## PY_TYPE

### PY_TYPE_001
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:PY_TYPE_001`
- **Description:** Utilizar `Type Hints` de Python para definir contratos claros en las fronteras de las capas. Evitar el uso de `Any` siempre que sea posible.
- **Bad example:**
```python
def process_order(order: Any) -> Any:
```
- **Good example:**
```python
def process_order(order: OrderRequest) -> Result[OrderResponse]:
```
- **References:**
  - https://docs.python.org/3/library/typing.html
- **Book References:**
  - Clean Architecture with Python — Sam Keen — Cap. 3 "Type-Enhanced Python", p. 68

---

## ARCH_OBS

### ARCH_OBS_001
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_OBS_001`
- **Description:** El registro de logs (logging) no debe estar acoplado al framework. La lógica de negocio debe usar loggers estándar de Python sin conocer si se ejecutan en Web, CLI o Cloud.
- **Bad example:**
```python
from flask import current_app
current_app.logger.info("Task created")  # Dependencia de framework
```
- **Good example:**
```python
import logging
logger = logging.getLogger(__name__)
logger.info("Task created")
```
- **Book References:**
  - Clean Architecture with Python — Sam Keen — Cap. 10 "Avoiding framework coupling in logging", p. 248

---

### ARCH_OBS_002
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_OBS_002`
- **Description:** Los `Trace IDs` para observabilidad deben generarse en la capa de entrada (controlador/gateway) y propagarse a través de DTOs o contexto de request. Nunca generarlos en la capa de dominio.
- **Bad example:**
```python
class CreateOrderUseCase:
    def execute(self, request):
        trace_id = str(uuid4())  # Error: el dominio genera infraestructura
        logger.info(f"[{trace_id}] Creating order")
```
- **Good example:**
```python
# En el controlador / entry point
trace_id = request.headers.get("X-Request-ID", str(uuid4()))
use_case.execute(OrderRequest(trace_id=trace_id, ...))
```
- **References:**
  - https://opentelemetry.io/docs/concepts/observability-primer/
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 32 "Frameworks are Details", p. 287

---

### ARCH_OBS_003
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_OBS_003`
- **Description:** El logging en adaptadores debe incluir metadatos de contexto relevantes (`user_id`, `request_id`, nombre del adaptador) para facilitar el trazado en producción.
- **Bad example:**
```python
class UserRepository:
    def save(self, user):
        db.session.add(user)
        logger.info("User saved")  # Sin contexto
```
- **Good example:**
```python
class UserRepository:
    def save(self, user, request_id: str):
        db.session.add(user)
        logger.info("User saved", extra={"user_id": user.id, "request_id": request_id})
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 32 "Frameworks are Details", p. 287

---

### ARCH_OBS_004
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_OBS_004`
- **Description:** No usar `print()` para logging en producción. Utilizar siempre un logger configurado del módulo estándar `logging` o una librería compatible (loguru, structlog).
- **Bad example:**
```python
def process_payment(payment):
    print(f"Processing payment {payment.id}")  # No configurable, no niveles
    ...
```
- **Good example:**
```python
import logging
logger = logging.getLogger(__name__)

def process_payment(payment):
    logger.info("Processing payment", extra={"payment_id": payment.id})
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 32 "Frameworks are Details", p. 287

---

## ADAPT_CTRL

### ADAPT_CTRL_001
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ADAPT_CTRL_001`
- **Description:** Patrón Humble Object: Los controladores deben ser tan simples que no necesiten tests unitarios complejos. Solo extraen datos de la request y delegan al interactor/use case.
- **Bad example:**
```python
@app.post("/orders")
def create_order():
    data = request.json
    if data["total"] > 1000:  # Lógica de negocio en el controlador
        apply_discount(data)
    user = db.query(User).get(data["user_id"])
    order = Order(user=user, total=data["total"])
    db.session.add(order)
    return jsonify(order.to_dict())
```
- **Good example:**
```python
@app.post("/orders")
def create_order():
    req = CreateOrderRequest(**request.json)
    result = create_order_use_case.execute(req)
    return jsonify(result.to_dict()), 201
```
- **References:**
  - https://martinfowler.com/bliki/HumbleObject.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 23 "Presenters and Humble Objects", p. 217

---

### ADAPT_CTRL_002
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ADAPT_CTRL_002`
- **Description:** Los controladores deben capturar las excepciones de dominio y convertirlas en la respuesta HTTP adecuada (JSON de error, código de estado). El dominio no debe saber nada de HTTP.
- **Bad example:**
```python
@app.post("/users")
def create_user():
    # Si el use case lanza ValueError, Flask devuelve 500 sin manejar
    result = create_user_use_case.execute(request.json)
    return jsonify(result)
```
- **Good example:**
```python
@app.post("/users")
def create_user():
    try:
        result = create_user_use_case.execute(CreateUserRequest(**request.json))
        return jsonify(result.to_dict()), 201
    except DomainValidationError as e:
        return jsonify({"error": str(e)}), 422
    except UserAlreadyExistsError as e:
        return jsonify({"error": str(e)}), 409
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 207

---

### ADAPT_CTRL_003
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ADAPT_CTRL_003`
- **Description:** La validación de tipos básicos (int, string, formato de email) debe ocurrir en la frontera del sistema (controlador / request model), no en el interior del dominio.
- **Bad example:**
```python
class CreateUserUseCase:
    def execute(self, data: dict):
        if not isinstance(data.get("age"), int):  # Validación de tipos en dominio
            raise TypeError("age must be int")
```
- **Good example:**
```python
@dataclass
class CreateUserRequest:
    name: str
    age: int  # Pydantic / dataclass valida en la frontera
    email: EmailStr

class CreateUserUseCase:
    def execute(self, req: CreateUserRequest):
        # El dominio recibe datos ya validados
        user = User(name=req.name, age=req.age)
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 207

---

### ADAPT_CTRL_004
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ADAPT_CTRL_004`
- **Description:** El adaptador de red debe ser capaz de reintentar operaciones fallidas (con backoff) sin que el dominio tenga conocimiento de esa lógica de reintento.
- **Bad example:**
```python
class NotificationUseCase:
    def execute(self, user_id):
        for attempt in range(3):  # Lógica de reintento en el dominio
            try:
                self.email_service.send(user_id)
                break
            except ConnectionError:
                time.sleep(2 ** attempt)
```
- **Good example:**
```python
class SmtpEmailAdapter(EmailGateway):
    def send(self, user_id: str):
        # Reintento encapsulado en el adaptador
        @retry(stop=stop_after_attempt(3), wait=wait_exponential())
        def _send():
            self._smtp.sendmail(...)
        _send()
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 207

---

## ARCH_PRESENT

### ARCH_PRESENT_001
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_PRESENT_001`
- **Description:** Los Presenters son responsables de formatear los datos para la UI. El interactor/use case retorna objetos de dominio o DTOs sin formato; el Presenter los transforma para la vista.
- **Bad example:**
```python
class CreateInvoiceUseCase:
    def execute(self, req) -> dict:
        invoice = Invoice(date=date.today())
        return {"date": invoice.date.strftime("%d/%m/%Y")}  # Formato en el dominio
```
- **Good example:**
```python
class CreateInvoiceUseCase:
    def execute(self, req) -> InvoiceResponse:
        invoice = Invoice(date=date.today())
        return InvoiceResponse(date=invoice.date)  # Retorna objeto date sin formato

class InvoicePresenter:
    def present(self, response: InvoiceResponse) -> dict:
        return {"date": response.date.strftime("%d/%m/%Y")}  # Formato en el Presenter
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 23 "Presenters and Humble Objects", p. 217

---

### ARCH_PRESENT_002
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_PRESENT_002`
- **Description:** Los Presenters no deben contener lógica de decisión de negocio. Solo transforman datos de salida para la vista.
- **Bad example:**
```python
class OrderPresenter:
    def present(self, order: OrderResponse) -> dict:
        if order.total > 1000:  # Lógica de negocio en el Presenter
            discount = order.total * 0.1
        return {"total": order.total, "discount": discount}
```
- **Good example:**
```python
class OrderPresenter:
    def present(self, order: OrderResponse) -> dict:
        return {
            "total": f"${order.total:.2f}",
            "discount": f"${order.discount:.2f}" if order.discount else None,
        }
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 23 "Presenters and Humble Objects", p. 217

---

## ARCH_GATEWAY

### ARCH_GATEWAY_001
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_GATEWAY_001`
- **Description:** Los Gateways de bases de datos deben ocultar el lenguaje de consulta (SQL, NoSQL, ORM). El dominio solo llama a métodos semánticos del repositorio.
- **Bad example:**
```python
class UserRepository:
    def find(self, query: str):
        return db.execute(query)  # El dominio conoce SQL

# Uso en dominio:
repo.find("SELECT * FROM users WHERE active = 1")
```
- **Good example:**
```python
class UserRepository(ABC):
    @abstractmethod
    def get_active_users(self) -> list[User]: ...

class SqlUserRepository(UserRepository):
    def get_active_users(self) -> list[User]:
        rows = db.execute("SELECT * FROM users WHERE active = 1")
        return [User.from_row(r) for r in rows]
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 23 "Presenters and Humble Objects", p. 217

---

### ARCH_GATEWAY_002
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_GATEWAY_002`
- **Description:** Las consultas de lectura pesadas (read-heavy queries) pueden saltarse la capa de dominio por razones de rendimiento (CQRS query side), pero deben estar documentadas y justificadas explícitamente.
- **Bad example:**
```python
# Sin documentación: consulta directa sin justificación
def get_dashboard_stats():
    return db.execute("SELECT COUNT(*), SUM(total) FROM orders GROUP BY status")
```
- **Good example:**
```python
# PERF-BYPASS: Query directa justificada por rendimiento (evita N+1 con ORM).
# Revisado: 2024-01-15. Ver ADR-007.
def get_dashboard_stats() -> DashboardStats:
    rows = db.execute("SELECT COUNT(*), SUM(total) FROM orders GROUP BY status")
    return DashboardStats.from_rows(rows)
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 30 "The Database is a Detail", p. 277

---

## ARCH_PERSIST

### ARCH_PERSIST_001
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_PERSIST_001`
- **Description:** Cada adaptador de persistencia debe tener su propio modelo de datos ORM (separado de la Entidad de Dominio) y un mapper para convertir entre ambos.
- **Bad example:**
```python
# La misma clase sirve como entidad de dominio Y modelo ORM
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String)
    # Mezcla lógica de negocio con anotaciones de SQLAlchemy
    def is_premium(self): ...
```
- **Good example:**
```python
# Entidad de dominio pura
@dataclass
class User:
    id: UUID
    name: str
    def is_premium(self): ...

# Modelo ORM separado
class UserORM(Base):
    __tablename__ = "users"
    id = Column(UUID, primary_key=True)
    name = Column(String)

# Mapper
def to_domain(orm: UserORM) -> User:
    return User(id=orm.id, name=orm.name)
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 30 "The Database is a Detail", p. 277

---

### ARCH_PERSIST_002
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_PERSIST_002`
- **Description:** Las migraciones de base de datos deben ejecutarse como parte del despliegue (CI/CD pipeline), no durante el arranque de la aplicación.
- **Bad example:**
```python
# app.py — arranque de la app
def create_app():
    app = Flask(__name__)
    with app.app_context():
        db.create_all()          # Crea tablas en cada arranque
        run_migrations()         # Migraciones en arranque
    return app
```
- **Good example:**
```python
# deploy.sh — parte del pipeline de despliegue
# alembic upgrade head

# app.py — arranque limpio
def create_app():
    app = Flask(__name__)
    return app  # Sin migraciones en arranque
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 30 "The Database is a Detail", p. 277

---

## ARCH_TEST

### ARCH_TEST_001
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_TEST_001`
- **Description:** Los adaptadores de terceros (ej: Stripe, SendGrid, AWS S3) deben tener sus propios tests de integración, separados de los tests unitarios del dominio.
- **Bad example:**
```python
# test_create_order.py — test unitario que llama a Stripe real
def test_create_order():
    use_case = CreateOrderUseCase(stripe_adapter=StripeAdapter())  # Llama a API real
    result = use_case.execute(...)
    assert result.is_success
```
- **Good example:**
```python
# test_create_order.py — test unitario con mock
def test_create_order():
    mock_payment = Mock(spec=PaymentGateway)
    mock_payment.charge.return_value = PaymentResult(success=True)
    use_case = CreateOrderUseCase(payment_gateway=mock_payment)
    result = use_case.execute(...)
    assert result.is_success

# test_stripe_adapter_integration.py — test de integración separado
@pytest.mark.integration
def test_stripe_adapter_charges_card():
    adapter = StripeAdapter(api_key=os.getenv("STRIPE_TEST_KEY"))
    result = adapter.charge(amount=100, token="tok_visa")
    assert result.success
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 28 "The Test Boundary", p. 257

---

## ARCH_DI

### ARCH_DI_001
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_DI_001`
- **Description:** Utilizar inyección de dependencias para el sistema de archivos. No usar `open()` directo en adaptadores o casos de uso; inyectar una abstracción de `FileStorage`.
- **Bad example:**
```python
class ReportUseCase:
    def execute(self, report_id: str):
        with open(f"/reports/{report_id}.pdf", "rb") as f:  # Acoplamiento al filesystem
            return f.read()
```
- **Good example:**
```python
class FileStorage(ABC):
    @abstractmethod
    def read(self, path: str) -> bytes: ...

class LocalFileStorage(FileStorage):
    def read(self, path: str) -> bytes:
        with open(path, "rb") as f:
            return f.read()

class ReportUseCase:
    def __init__(self, storage: FileStorage):
        self._storage = storage

    def execute(self, report_id: str) -> bytes:
        return self._storage.read(f"/reports/{report_id}.pdf")
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 17 "Boundaries: Drawing Lines", p. 153

---

## ARCH_CONFIG

### ARCH_CONFIG_001
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_CONFIG_001`
- **Description:** Separar la configuración de desarrollo de la de producción en archivos o clases distintas. No usar condicionales `if env == "production"` dispersos en el código.
- **Bad example:**
```python
# config.py
DATABASE_URL = "sqlite:///dev.db" if os.getenv("ENV") == "dev" else "postgresql://prod-host/db"
DEBUG = True if os.getenv("ENV") == "dev" else False
```
- **Good example:**
```python
# config/base.py
class BaseConfig:
    DEBUG = False

# config/development.py
class DevelopmentConfig(BaseConfig):
    DEBUG = True
    DATABASE_URL = "sqlite:///dev.db"

# config/production.py
class ProductionConfig(BaseConfig):
    DATABASE_URL = os.getenv("DATABASE_URL")
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 26 "The Main Component", p. 237

---

## ARCH_RESULT

### ARCH_RESULT_001
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_RESULT_001`
- **Description:** Usar un objeto `Result` (o similar) para manejar fallos esperados en lugar de lanzar excepciones para flujos de control normales.
- **Bad example:**
```python
class AuthUseCase:
    def login(self, email: str, password: str) -> User:
        user = self.repo.find_by_email(email)
        if not user:
            raise UserNotFoundError("User not found")  # Excepción para flujo esperado
        if not user.check_password(password):
            raise InvalidPasswordError("Invalid password")
        return user
```
- **Good example:**
```python
@dataclass
class Result(Generic[T]):
    value: T | None
    error: str | None

    @classmethod
    def success(cls, value: T) -> "Result[T]": ...

    @classmethod
    def failure(cls, error: str) -> "Result[T]": ...

class AuthUseCase:
    def login(self, email: str, password: str) -> Result[User]:
        user = self.repo.find_by_email(email)
        if not user:
            return Result.failure("USER_NOT_FOUND")
        if not user.check_password(password):
            return Result.failure("INVALID_PASSWORD")
        return Result.success(user)
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 20 "Business Rules", p. 190

---

## ARCH_CACHE

### ARCH_CACHE_001
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_CACHE_001`
- **Description:** El adaptador de cache (Redis, Memcached) debe ser un detalle reemplazable. En tests o entornos locales debe poder sustituirse por un diccionario en memoria sin cambiar el dominio.
- **Bad example:**
```python
class ProductUseCase:
    def get_product(self, product_id: str):
        redis_client = redis.Redis(host="localhost")  # Dependencia directa de Redis
        cached = redis_client.get(product_id)
        ...
```
- **Good example:**
```python
class CacheGateway(ABC):
    @abstractmethod
    def get(self, key: str) -> str | None: ...
    @abstractmethod
    def set(self, key: str, value: str, ttl: int = 300) -> None: ...

class RedisCacheAdapter(CacheGateway):
    def __init__(self, client: redis.Redis): ...

class InMemoryCacheAdapter(CacheGateway):
    def __init__(self): self._store: dict = {}
    def get(self, key): return self._store.get(key)
    def set(self, key, value, ttl=300): self._store[key] = value

class ProductUseCase:
    def __init__(self, cache: CacheGateway): ...
```
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 17 "Boundaries: Drawing Lines", p. 153

---

## ARCH_API

### ARCH_API_001
- **Severity:** MEDIUM
- **Source:** `custom` / `custom:ARCH_API_001`
- **Description:** No exponer IDs internos secuenciales (auto-increment) en la API pública cuando sea posible. Preferir UUIDs u otros identificadores opacos para evitar enumeración de recursos.
- **Bad example:**
```python
# GET /users/1, /users/2, /users/3 — enumerable, predecible
class UserResponse:
    id: int  # Auto-increment expuesto
    name: str
```
- **Good example:**
```python
# GET /users/550e8400-e29b-41d4-a716-446655440000
class UserResponse:
    id: UUID  # Opaco, no enumerable
    name: str
```
- **References:**
  - https://cheatsheetseries.owasp.org/cheatsheets/IDOR_Prevention_Cheat_Sheet.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 207
