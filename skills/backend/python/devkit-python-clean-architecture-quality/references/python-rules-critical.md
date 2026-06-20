# Copilot Guidelines: Python — CRITICAL

---

Total rules: **12**

## Arquitectura

### PY_ARCH_001
- **Severity:** CRITICAL
- **Description:** Implementar Clean Architecture separando el sistema en círculos concéntricos: Entidades (reglas de negocio universales), Casos de Uso (reglas de aplicación), Adaptadores de Interfaz (controladores/presentadores) y Frameworks/Drivers [1-4].
- **Conditions:** language: python, principle: Clean Architecture
- **Action:** Organizar el proyecto en capas donde la lógica de negocio esté aislada de detalles como bases de datos o frameworks web [5, 6].
- **Source references:** 1, 6, 7
- **Bad example:**
```
# Lógica de negocio mezclada con detalles de infraestructura
def create_user(data):
    db = sqlite3.connect('users.db')
    db.execute(f"INSERT INTO users VALUES ('{data['name']}')")
```
- **Good example:**
```
# use_cases/create_user.py
class CreateUserUseCase:
    def __init__(self, repository: UserRepository):
        self.repository = repository
    def execute(self, user_data: UserRequest):
        user = User(name=user_data.name)
        self.repository.save(user)
```

### PY_ARCH_002
- **Severity:** CRITICAL
- **Description:** Respetar la Regla de Dependencia: las dependencias del código fuente solo pueden apuntar hacia adentro, hacia las políticas de nivel superior. Los círculos internos no deben saber nada de los externos [8, 9].
- **Conditions:** language: python, principle: Dependency Rule
- **Action:** Asegurar que módulos como 'domain' o 'application' no importen nada de 'infrastructure' o 'web' [6, 10].
- **Source references:** 6, 8, 9
- **Bad example:**
```
# domain/entities.py
from infrastructure.database import db_session # VIOLACIÓN
```
- **Good example:**
```
# domain/entities.py
# Solo importa otros elementos del dominio o tipos estándar de Python
```

### PY_ARCH_001
- **Severity:** CRITICAL
- **Description:** Las dependencias de código fuente deben apuntar únicamente hacia adentro, hacia las políticas de nivel superior (Capa de Dominio y Aplicación). Los círculos internos no deben saber nada de los externos [1-4].
- **Conditions:** language: python, principle: Dependency Rule
- **Action:** Asegurar que los módulos de 'domain' o 'use_cases' nunca importen componentes de 'infrastructure' o 'interfaces' [2, 5].
- **Source references:** 1, 2, 3, 4, 5
- **Bad example:**
```
from infrastructure.persistence import database # Violación de la Regla de Dependencia
```
- **Good example:**
```
from domain.entities.task import Task # Dependencia hacia el núcleo estable
```

### PY_BOUND_001
- **Severity:** CRITICAL
- **Description:** Los formatos de datos declarados por frameworks externos (ej. modelos de Django, respuestas de Requests) no deben cruzar los límites hacia los círculos internos [1, 2, 264, 265].
- **Conditions:** language: python
- **Action:** Convertir objetos de librerías externas a tipos de dominio o DTOs planos inmediatamente en la frontera de la capa de Infraestructura [116, 266].
- **Source references:** 1, 2, 116, 264, 265, 266
- **Bad example:**
```
Use Case aceptando un objeto 'flask.Request'.
```
- **Good example:**
```
Use Case aceptando un 'CreateTaskRequest' plano.
```

### PY_ARCH_001
- **Severity:** CRITICAL
- **Description:** Implementar Clean Architecture: separar en capas (Controllers, Use Cases, Entities, Repositories, Frameworks).
- **Conditions:** language: python, principle: Clean Architecture
- **Action:** Reorganizar el código en capas claramente separadas con responsabilidades bien definidas.
- **Source references:** -
- **Bad example:**
```
from sqlalchemy import create_engine
from fastapi import FastAPI

app = FastAPI()
engine = create_engine('postgresql://...')

@app.get('/users/{user_id}')
def get_user(user_id: int):
    result = engine.execute(f'SELECT * FROM users WHERE id={user_id}')
    return result
```
- **Good example:**
```
# controllers/user_controller.py
from fastapi import FastAPI
from use_cases.get_user_use_case import GetUserUseCase

app = FastAPI()
get_user_use_case = GetUserUseCase()

@app.get('/users/{user_id}')
async def get_user(user_id: int):
    return await get_user_use_case.execute(user_id)
```

---

## DIP

### PY_SOLID_005
- **Severity:** CRITICAL
- **Description:** Los módulos de alto nivel no deben depender de módulos de bajo nivel; ambos deben depender de abstracciones. El código interno define el contrato [30-34].
- **Conditions:** language: python, principle: Dependency Inversion
- **Action:** Inyectar dependencias a través de constructores utilizando interfaces (ABCs) o Protocols definidos en la capa interna [35-38].
- **Source references:** 30, 31, 32, 33, 34, 35, 36, 37, 38
- **Bad example:**
```
def __init__(self): self.db = MySQLDatabase() # Acoplamiento directo.
```
- **Good example:**
```
def __init__(self, db: DatabaseInterface): self.db = db
```

---

## Dependencias

### PY_ARCH_002
- **Severity:** CRITICAL
- **Description:** La capa de Controladores (FastAPI) no debe importar directamente de Repositorios o Bases de Datos. Usar Use Cases como intermediarios.
- **Conditions:** language: python, pattern: from.*repository|from.*database|sqlalchemy
- **Action:** Inyectar dependencias a través de Use Cases, no acceder directamente a la base de datos.
- **Source references:** -
- **Bad example:**
```
# controller.py
from repositories.user_repository import UserRepository
from fastapi import FastAPI

repo = UserRepository()

@app.get('/users/{user_id}')
async def get_user(user_id: int):
    return repo.find_by_id(user_id)
```
- **Good example:**
```
# controller.py
from use_cases.get_user import GetUserUseCase
from fastapi import FastAPI

get_user_uc = GetUserUseCase()

@app.get('/users/{user_id}')
async def get_user(user_id: int):
    return await get_user_uc.execute(user_id)
```

---

## Secretos

### PY_SEC_001
- **Severity:** CRITICAL
- **Description:** NUNCA hardcodear secretos, credenciales, tokens, o claves API directamente en el código.
- **Conditions:** language: python, pattern: password.*=|api_key.*=|token.*=|secret.*=
- **Action:** Usar variables de entorno a través de python-dotenv o variables de sistema.
- **Source references:** -
- **Bad example:**
```
DATABASE_URL = 'postgresql://user:password123@localhost:5432/db'
API_KEY = 'sk-abc123def456'
GEMINI_KEY = 'AIzaSyKa...'
```
- **Good example:**
```
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv('DATABASE_URL')
API_KEY = os.getenv('API_KEY')
GEMINI_KEY = os.getenv('GEMINI_KEY')
```

### PY_SEC_002
- **Severity:** CRITICAL
- **Description:** No loguear secretos, tokens, contraseñas o información sensible en logs o excepciones.
- **Conditions:** language: python, pattern: logger.*password|print.*password|raise.*password
- **Action:** Enmascarar o omitir información sensible en logs.
- **Source references:** -
- **Bad example:**
```
try:
    connect(user='admin', password=password)
except Exception as e:
    logger.error(f'Connection failed: {e}')
    # Esto puede mostrar la contraseña
```
- **Good example:**
```
try:
    connect(user='admin', password=password)
except Exception as e:
    logger.error('Connection failed: Database connection error')
    # Info sensible no se loguea
```

### PY_SEC_003
- **Severity:** CRITICAL
- **Description:** No commitear archivos .env, credentials.json, o archivos de configuración con secretos. Usar .gitignore.
- **Conditions:** language: python, file_pattern: \.env|\.git/config|credentials\.json|config\.yaml
- **Action:** Añadir a .gitignore: .env, *.pem, credentials.json, config.yaml
- **Source references:** -
- **Bad example:**
```
# .gitignore está vacío o no incluye .env
# Archivo .env commiteado con DB_PASSWORD=secret123
```
- **Good example:**
```
# .gitignore
.env
.env.local
*.pem
credentials.json
config.yaml
__pycache__/
```

---

## Seguridad

### PY_SEC_004
- **Severity:** CRITICAL
- **Description:** Usar SQL Parameterized Queries para evitar SQL Injection. Nunca concatenar SQL directamente.
- **Conditions:** language: python, pattern: f'SELECT|f'INSERT|f'UPDATE|f'DELETE|.execute\(f'|format\(.*FROM
- **Action:** Usar ORM (SQLAlchemy) o prepared statements con placeholders (?, %s).
- **Source references:** -
- **Bad example:**
```
user_id = request.query_params.get('id')
query = f"SELECT * FROM users WHERE id={user_id}"
result = db.execute(query)
```
- **Good example:**
```
from sqlalchemy import select
from sqlalchemy.orm import Session

user = session.execute(
    select(User).where(User.id == user_id)
).scalar_one_or_none()
```

### PY_SEC_005
- **Severity:** CRITICAL
- **Description:** Validar TODAS las entradas del usuario usando Pydantic models en FastAPI.
- **Conditions:** language: python, framework: fastapi, pattern: request.body|request.form|request.query_params
- **Action:** Crear Pydantic models para validar tipos, longitudes, formatos (email, URL, etc).
- **Source references:** -
- **Bad example:**
```
@app.post('/users')
async def create_user(user_id: str, name: str):
    # Sin validación, podría ser 'DROP TABLE users'
```
- **Good example:**
```
from pydantic import BaseModel, Field

class UserCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    email: str = Field(..., regex=r'^[\w\.-]+@[\w\.-]+\.\w+$')

@app.post('/users')
async def create_user(user: UserCreate):
    # Validado automáticamente
```
