# Overview

```mermaid
flowchart TD
    A[POST /auth/login|guest] --> B[Validación credenciales]
    B --> C[Generar Access JWT + Refresh token]
    C --> D[Persistir refresh token]
    D --> E[Respuesta autenticación]
    F[POST /auth/refresh] --> G[Rotación refresh token]
    G --> E
```
