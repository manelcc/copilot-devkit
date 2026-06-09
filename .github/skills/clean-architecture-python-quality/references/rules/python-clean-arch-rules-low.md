# Copilot Guidelines: Clean Architecture Python — LOW

---

Total rules: **31**

> **Notas de deduplicación:**
> - La regla 121 del catálogo original (Screaming Architecture: carpetas reflejan Casos de Uso) fue omitida por ser equivalente a `LOW ORG_STRUC_001`.
> - La regla 122 (`CODE_STYLE_001`) es complementaria a `MEDIUM PY_TYPE_001`: PY_TYPE_001 cubre contratos en fronteras de capa y evitar `Any`; CODE_STYLE_001 cubre la obligatoriedad de type hints en **todas** las funciones como práctica idiomática general.

---

## ORG_STRUC

### ORG_STRUC_001
- **Severity:** LOW
- **Source:** `custom` / `custom:ORG_STRUC_001`
- **Description:** La estructura de carpetas debe reflejar la arquitectura (Screaming Architecture), no el framework utilizado.
- **Bad example:**
```
controllers/
models/
views/
```
- **Good example:**
```
domain/
application/
infrastructure/
interfaces/
```
- **References:**
  - https://blog.cleancoder.com/uncle-bob/2011/09/30/Screaming-Architecture.html
- **Book References:**
  - Clean Architecture — Robert C. Martin — Cap. 21 "Screaming Architecture", p. 195
  - Clean Architecture with Python — Sam Keen — Cap. 10 "Verifying architectural integrity", p. 260

---

### ORG_STRUC_002
- **Severity:** LOW
- **Source:** `custom` / `custom:ORG_STRUC_002`
- **Description:** Mantener el `README.md` actualizado con instrucciones de arquitectura, estructura de carpetas y guía de arranque del proyecto.
- **References:**
  - Clean Architecture — Robert C. Martin — Cap. 1 "What Is Design and Architecture?", p. 4

---

### ORG_STRUC_003
- **Severity:** LOW
- **Source:** `custom` / `custom:ORG_STRUC_003`
- **Description:** Las dependencias de desarrollo deben estar separadas de las de producción (ej: `requirements.txt` vs `requirements-dev.txt`, o grupos en `pyproject.toml`).
- **Bad example:**
```
requirements.txt  # Contiene pytest, black, mypy mezclados con Flask y SQLAlchemy
```
- **Good example:**
```
requirements.txt       # Solo dependencias de producción
requirements-dev.txt   # pytest, black, mypy, flake8
```
- **References:**
  - https://12factor.net/dependencies

---

### ORG_STRUC_004
- **Severity:** LOW
- **Source:** `custom` / `custom:ORG_STRUC_004`
- **Description:** El sistema debe poder arrancarse con un solo comando documentado (ej: `make run`, `docker compose up`). La fricción de arranque debe ser mínima.
- **References:**
  - Clean Architecture — Robert C. Martin — Cap. 16 "Independence", p. 148

---

### ORG_STRUC_005
- **Severity:** LOW
- **Source:** `custom` / `custom:ORG_STRUC_005`
- **Description:** Los archivos de configuración no deben contener lógica, solo datos estáticos o carga de variables de entorno.
- **Bad example:**
```python
# settings.py
DATABASE_POOL_SIZE = int(os.getenv("WORKERS", 2)) * 4  # Lógica de cálculo en configuración
```
- **Good example:**
```python
# settings.py
DATABASE_POOL_SIZE = int(os.getenv("DATABASE_POOL_SIZE", 8))
```
- **References:**
  - Clean Architecture — Robert C. Martin — Cap. 17 "Boundaries: Drawing Lines", p. 155

---

## CODE_NAME

### CODE_NAME_001
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_NAME_001`
- **Description:** Utilizar el "Lenguaje Ubicuo" (Ubiquitous Language) del dominio para nombrar variables, clases y métodos, evitando términos técnicos en el núcleo.
- **Bad example:**
```python
class TaskDataModel: ...
```
- **Good example:**
```python
class Task: ...
```
- **References:**
  - https://martinfowler.com/bliki/UbiquitousLanguage.html
- **Book References:**
  - Clean Architecture with Python — Sam Keen — Cap. 4 "Identifying and modeling the Domain layer using DDD", p. 83

---

### CODE_NAME_002
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_NAME_002`
- **Description:** Los nombres de las clases deben ser sustantivos. Los nombres de los métodos deben ser verbos o frases verbales.
- **Bad example:**
```python
class Process: ...       # Verbo como nombre de clase
def data(self): ...      # Sustantivo como nombre de método
```
- **Good example:**
```python
class OrderProcessor: ...
def process_order(self): ...
```
- **References:**
  - Clean Code — Robert C. Martin — Cap. 2 "Meaningful Names"

---

### CODE_NAME_003
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_NAME_003`
- **Description:** El nombre del interactor/use case debe ser un verbo de acción en PascalCase que describa el caso de uso de negocio.
- **Bad example:**
```python
class UserHandler: ...
class UserManager: ...
```
- **Good example:**
```python
class RegisterUser: ...
class CancelOrder: ...
```
- **References:**
  - Clean Architecture — Robert C. Martin — Cap. 21 "Screaming Architecture", p. 197

---

### CODE_NAME_004
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_NAME_004`
- **Description:** Evitar abreviaturas crípticas en nombres de variables, parámetros y atributos. Los nombres deben ser auto-explicativos.
- **Bad example:**
```python
u_repo = UserRepository()
ord_svc = OrderService()
```
- **Good example:**
```python
user_repository = UserRepository()
order_service = OrderService()
```
- **References:**
  - Clean Code — Robert C. Martin — Cap. 2 "Meaningful Names"

---

## CODE_STYLE

### CODE_STYLE_001
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_STYLE_001`
- **Description:** Uso mandatorio de Type Hints en todos los argumentos y retornos de función como mecanismo de autoprotección y documentación implícita. Ver también `MEDIUM PY_TYPE_001` para contratos en fronteras de capa.
- **Bad example:**
```python
def calculate_total(items, discount):
    ...
```
- **Good example:**
```python
def calculate_total(items: list[Item], discount: Decimal) -> Decimal:
    ...
```
- **References:**
  - Clean Architecture — Robert C. Martin — Cap. 1 "What Is Design and Architecture?", p. 4
  - https://docs.python.org/3/library/typing.html

---

### CODE_STYLE_002
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_STYLE_002`
- **Description:** Usar nombres de módulos en minúsculas con guiones bajos (snake_case). Nunca usar PascalCase o guiones en nombres de archivos `.py`.
- **Bad example:**
```
UserRepository.py
order-service.py
```
- **Good example:**
```
user_repository.py
order_service.py
```
- **References:**
  - https://peps.python.org/pep-0008/#package-and-module-names

---

### CODE_STYLE_003
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_STYLE_003`
- **Description:** Las constantes de configuración deben declararse en UPPER_CASE para distinguirlas visualmente de variables mutables.
- **Bad example:**
```python
max_retries = 3
defaultTimeout = 30
```
- **Good example:**
```python
MAX_RETRIES = 3
DEFAULT_TIMEOUT = 30
```
- **References:**
  - https://peps.python.org/pep-0008/#constants

---

### CODE_STYLE_004
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_STYLE_004`
- **Description:** Usar `pathlib.Path` en lugar de concatenación de strings para manipulación de rutas de archivos.
- **Bad example:**
```python
config_path = base_dir + "/config/" + env + ".yml"
```
- **Good example:**
```python
from pathlib import Path
config_path = Path(base_dir) / "config" / f"{env}.yml"
```
- **References:**
  - https://docs.python.org/3/library/pathlib.html

---

### CODE_STYLE_005
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_STYLE_005`
- **Description:** El uso de `Optional[X]` en Type Hints debe ser explícito. No usar `X | None` implícito sin declaración.
- **Bad example:**
```python
def find_user(user_id: int) -> User:  # Puede retornar None sin declararlo
    ...
```
- **Good example:**
```python
from typing import Optional
def find_user(user_id: int) -> Optional[User]:
    ...
```
- **References:**
  - https://peps.python.org/pep-0484/#using-none

---

### CODE_STYLE_006
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_STYLE_006`
- **Description:** Organizar las importaciones en tres bloques separados por línea en blanco: (1) librería estándar, (2) dependencias de terceros, (3) módulos locales del proyecto.
- **Bad example:**
```python
from my_app.domain import User
import os
from flask import Flask
import json
```
- **Good example:**
```python
import json
import os

from flask import Flask

from my_app.domain import User
```
- **References:**
  - https://peps.python.org/pep-0008/#imports

---

### CODE_STYLE_007
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_STYLE_007`
- **Description:** Las funciones auxiliares internas de un módulo deben ser privadas usando el prefijo `_` para señalizar que no forman parte de la API pública.
- **Bad example:**
```python
def validate_email(email: str) -> bool: ...  # Helper expuesto públicamente
```
- **Good example:**
```python
def _validate_email(email: str) -> bool: ...  # Helper privado del módulo
```
- **References:**
  - https://peps.python.org/pep-0008/#naming-conventions

---

### CODE_STYLE_008
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_STYLE_008`
- **Description:** Usar f-strings para el formateo de cadenas por legibilidad y rendimiento. Evitar `%` formatting y `.format()` en código nuevo.
- **Bad example:**
```python
message = "User %s created with id %d" % (name, user_id)
message = "User {} created with id {}".format(name, user_id)
```
- **Good example:**
```python
message = f"User {name} created with id {user_id}"
```
- **References:**
  - https://docs.python.org/3/reference/lexical_analysis.html#formatted-string-literals

---

## CODE_QUAL

### CODE_QUAL_001
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_QUAL_001`
- **Description:** Un archivo de Python no debe superar las 400 líneas de código. Si lo supera, es señal de violación del SRP y debe dividirse.
- **References:**
  - Clean Code — Robert C. Martin — Cap. 7 "Error Handling", p. 103

---

### CODE_QUAL_002
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_QUAL_002`
- **Description:** Evitar comentarios innecesarios si el nombre de la función o variable describe suficientemente su intención. El buen código se documenta a sí mismo.
- **Bad example:**
```python
# Incrementa el contador en 1
counter += 1
```
- **Good example:**
```python
approved_requests_count += 1
```
- **References:**
  - Clean Code — Robert C. Martin — Cap. 4 "Comments"

---

### CODE_QUAL_003
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_QUAL_003`
- **Description:** No dejar código comentado (código muerto). Eliminar el código obsoleto y confiar en el historial de Git para recuperarlo si fuera necesario.
- **Bad example:**
```python
# def old_calculate_tax(amount):
#     return amount * 0.21
def calculate_tax(amount: Decimal) -> Decimal:
    return amount * TAX_RATE
```
- **Good example:**
```python
def calculate_tax(amount: Decimal) -> Decimal:
    return amount * TAX_RATE
```
- **References:**
  - Clean Code — Robert C. Martin — Cap. 4 "Comments"

---

### CODE_QUAL_004
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_QUAL_004`
- **Description:** Las funciones no deben tener más de 3 niveles de indentación. El exceso de anidamiento dificulta la lectura y es señal de lógica compleja no extraída.
- **Bad example:**
```python
def process(orders):
    for order in orders:
        if order.is_valid():
            for item in order.items:
                if item.in_stock():  # Nivel 4
                    ship(item)
```
- **Good example:**
```python
def process(orders):
    valid_orders = [o for o in orders if o.is_valid()]
    for order in valid_orders:
        _ship_available_items(order.items)
```
- **References:**
  - Clean Code — Robert C. Martin — Cap. 3 "Functions"

---

### CODE_QUAL_005
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_QUAL_005`
- **Description:** No usar bloques `try-except` vacíos ni capturar la excepción base genérica `Exception` sin justificación. Siempre capturar excepciones específicas.
- **Bad example:**
```python
try:
    process_order(order)
except:
    pass

try:
    connect_to_db()
except Exception:
    pass
```
- **Good example:**
```python
try:
    process_order(order)
except OrderValidationError as e:
    logger.warning(f"Invalid order: {e}")
    raise
```
- **References:**
  - https://docs.python.org/3/tutorial/errors.html#handling-exceptions

---

### CODE_QUAL_006
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_QUAL_006`
- **Description:** Usar linters automáticos (`flake8`, `black`, `isort`, `mypy`) configurados en el repositorio para garantizar consistencia visual y detectar errores estáticos.
- **References:**
  - https://peps.python.org/pep-0008/

---

### CODE_QUAL_007
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_QUAL_007`
- **Description:** Documentar las fronteras de los componentes mediante docstrings en módulos, clases y métodos públicos que forman parte de la API interna.
- **Bad example:**
```python
class UserRepository:
    def find_by_email(self, email: str) -> Optional[User]:
        ...
```
- **Good example:**
```python
class UserRepository:
    """Abstracción de acceso a datos para la entidad User. Implementa el puerto de salida UserRepositoryPort."""

    def find_by_email(self, email: str) -> Optional[User]:
        """Busca un usuario por su dirección de email. Retorna None si no existe."""
        ...
```
- **References:**
  - https://peps.python.org/pep-0257/

---

### CODE_QUAL_008
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_QUAL_008`
- **Description:** No usar "Magic Numbers". Reemplazar literales numéricos o de cadena con constantes nombradas descriptivas.
- **Bad example:**
```python
if user.age > 18:
    discount = price * 0.15
```
- **Good example:**
```python
LEGAL_AGE = 18
SENIOR_DISCOUNT_RATE = Decimal("0.15")

if user.age > LEGAL_AGE:
    discount = price * SENIOR_DISCOUNT_RATE
```
- **References:**
  - Clean Code — Robert C. Martin — Cap. 17 "Smells and Heuristics"

---

### CODE_QUAL_009
- **Severity:** LOW
- **Source:** `custom` / `custom:CODE_QUAL_009`
- **Description:** Evitar el uso de `eval()` y `exec()` por razones de seguridad (inyección de código) y legibilidad. Buscar siempre alternativas explícitas.
- **Bad example:**
```python
result = eval(user_input)
exec(f"config.{key} = {value}")
```
- **Good example:**
```python
allowed_ops = {"add": operator.add, "sub": operator.sub}
result = allowed_ops[operation](a, b)
```
- **References:**
  - https://docs.python.org/3/library/functions.html#eval

---

## TEST

### TEST_001
- **Severity:** LOW
- **Source:** `custom` / `custom:TEST_001`
- **Description:** Los nombres de los tests deben describir el comportamiento esperado de forma legible, siguiendo el patrón `test_should_<acción>_when_<condición>`.
- **Bad example:**
```python
def test_user():
def test_order_2():
```
- **Good example:**
```python
def test_should_reject_negative_amount_when_creating_order():
def test_should_return_none_when_user_not_found():
```
- **References:**
  - Clean Architecture — Robert C. Martin — Cap. 28 "The Test Boundary", p. 264

---

### TEST_002
- **Severity:** LOW
- **Source:** `custom` / `custom:TEST_002`
- **Description:** Separar los tests unitarios de los tests de integración en carpetas distintas para poder ejecutarlos de forma independiente.
- **Good example:**
```
tests/
  unit/
    test_order_entity.py
  integration/
    test_order_repository.py
```
- **References:**
  - Clean Architecture — Robert C. Martin — Cap. 28 "The Test Boundary", p. 264

---

### TEST_003
- **Severity:** LOW
- **Source:** `custom` / `custom:TEST_003`
- **Description:** Los tests no deben depender del orden de ejecución. Cada test debe ser completamente independiente y configurar su propio estado mediante fixtures.
- **References:**
  - Clean Architecture — Robert C. Martin — Cap. 28 "The Test Boundary", p. 264

---

### TEST_004
- **Severity:** LOW
- **Source:** `custom` / `custom:TEST_004`
- **Description:** Usar `pytest` como framework de pruebas estándar por su potencia de fixtures, parametrización y plugins del ecosistema.
- **References:**
  - Clean Architecture — Robert C. Martin — Cap. 28 "The Test Boundary", p. 264
  - https://docs.pytest.org

---

## ARCH_ADAPT

### ARCH_ADAPT_001
- **Severity:** LOW
- **Source:** `custom` / `custom:ARCH_ADAPT_001`
- **Description:** La lógica de la interfaz de línea de comandos (CLI) debe residir en un adaptador independiente, no en el núcleo de negocio ni en los use cases.
- **Bad example:**
```python
# En domain/use_cases/register_user.py
import click

@click.command()
def register_user():
    ...
```
- **Good example:**
```python
# En interfaces/cli/commands.py
import click
from application.use_cases import RegisterUser

@click.command()
def register_user_cmd():
    RegisterUser().execute(...)
```
- **References:**
  - Clean Architecture — Robert C. Martin — Cap. 22 "The Clean Architecture", p. 205
