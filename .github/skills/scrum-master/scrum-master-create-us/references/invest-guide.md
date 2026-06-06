# Guía INVEST y Ejemplos Few-Shot

## El estándar INVEST

INVEST es el acrónimo que define una Historia de Usuario de calidad. Cada criterio actúa como
filtro de calidad antes de que la historia entre al sprint.

| Letra | Criterio | Definición práctica |
|---|---|---|
| **I** | Independiente | Puede desarrollarse sin depender de otra historia del mismo sprint. Si existe dependencia, se modela como historia separada o como precondición explícita. |
| **N** | Negociable | El alcance puede ajustarse con el Product Owner sin perder el valor central. No es un contrato rígido. |
| **V** | Valiosa | Aporta valor observable al usuario o al negocio por sí sola. No es un task técnico sin valor visible. |
| **E** | Estimable | El equipo puede dar una estimación razonable con la información disponible. Si no puede, falta contexto o la historia es demasiado grande. |
| **S** | Small (Pequeña) | Cabe en un sprint. Como regla orientativa: no supera la mitad de la capacidad del equipo. |
| **T** | Testeable | Los Criterios de Aceptación son verificables sin interpretación subjetiva. Se pueden escribir tests antes de implementar. |

---

## Señales de alerta por criterio

### I — Independiente ⚠️

**Señal:** La historia menciona "después de implementar X" o "requiere que Y esté terminado".

**Acción:** Modela la dependencia como una historia separada y añade una nota de orden de implementación.
No bloquees el sprint fusionando historias dependientes en una sola.

### N — Negociable ⚠️

**Señal:** La historia especifica soluciones técnicas concretas en el cuerpo (frameworks, tablas de BD, endpoints).

**Acción:** Mueve los detalles técnicos a la sección "Notas técnicas". El cuerpo describe **qué** y **para qué**, no **cómo**.

### V — Valiosa ⚠️

**Señal:** La historia describe trabajo técnico interno sin beneficio visible para ningún usuario.

**Acción:** O bien la enmarcas como refactoring técnico con deuda reconocida, o la vinculas a un impacto
de usuario explícito. Si no tiene usuario, quizá es una tarea técnica, no una historia.

### E — Estimable ⚠️

**Señal:** El equipo dice "no sé cuánto tiempo llevaría esto".

**Acción:** Añade contexto técnico, ejemplos de interfaces o restricciones. Si sigue sin ser estimable,
es candidata a un spike de investigación.

### S — Small ⚠️

**Señal:** La historia tiene más de 8-10 criterios de aceptación o cubre múltiples flujos.

**Acción:** Divide por flujo de usuario (happy path, edge cases, administración) o por tipo de entidad.

### T — Testeable ⚠️

**Señal:** Los CA usan palabras como "rápido", "fácil", "correctamente", "bien".

**Acción:** Reemplaza por valores concretos: "en menos de 500ms", "sin errores de validación", "con código HTTP 201".

---

## Ejemplos few-shot — Bien vs. Mal

---

### Caso 1: Autenticación

#### ❌ Historia mal redactada

```markdown
## Login de usuarios

Hay que implementar el sistema de autenticación completo con JWT, refresh tokens,
recuperación de contraseña, 2FA y bloqueo por intentos fallidos.
El frontend y backend deben estar coordinados.

Criterios:
- Que el login funcione
- Que sea seguro
- Que el usuario pueda entrar
```

**Problemas INVEST:**

| Criterio | Estado | Problema |
|---|---|---|
| Independiente | ❌ | Mezcla frontend, backend, 2FA, recuperación — múltiples dominios |
| Negociable | ❌ | Prescribe JWT, refresh tokens, 2FA — implementación fijada |
| Valiosa | ⚠️ | Implícita pero no articulada |
| Estimable | ❌ | Demasiado amplia para estimar con fiabilidad |
| Small | ❌ | Cubre semanas de trabajo en una sola historia |
| Testeable | ❌ | CA vagos — "que funcione", "que sea seguro" no son verificables |

---

#### ✅ Historia bien redactada (atomización del mismo requisito)

```markdown
## US-011 — Iniciar sesión con credenciales de correo y contraseña

**Como** usuario registrado,
**quiero** iniciar sesión con mi correo y contraseña,
**para** acceder a las funcionalidades protegidas de mi cuenta sin necesitar soporte.

### Criterios de Aceptación

1. Dado un correo y contraseña válidos, cuando inicio sesión, recibo un token de acceso y soy
   redirigido al dashboard en menos de 2 segundos.
2. Si el correo no existe o la contraseña es incorrecta, el sistema muestra el mensaje:
   "Credenciales incorrectas. Inténtalo de nuevo." (sin revelar cuál campo es erróneo).
3. Tras 5 intentos fallidos consecutivos, la cuenta se bloquea durante 15 minutos y se notifica
   al usuario por correo.
4. La sesión expira tras 30 minutos de inactividad.
5. El endpoint POST /auth/login devuelve HTTP 200 con body `{ token, expiresAt }` en caso de éxito
   y HTTP 401 en caso de credenciales inválidas.
6. Pruebas unitarias cubren: credenciales válidas, contraseña incorrecta, correo inexistente,
   cuenta bloqueada. Cobertura ≥ 80% según DoD.
7. El código pasa `detekt` sin warnings de nivel error.

### Notas técnicas

- El mecanismo de token (JWT vs. sesión de servidor) lo decide el equipo en refinación técnica.

### Validación INVEST

| Criterio | Estado | Observación |
|---|---|---|
| Independiente | ✅ | No depende de 2FA ni recuperación de contraseña |
| Negociable | ✅ | El tipo de token no está prescrito |
| Valiosa | ✅ | El usuario puede acceder a su cuenta |
| Estimable | ✅ | Alcance claro y acotado |
| Small | ✅ | Un flujo principal + validaciones |
| Testeable | ✅ | Todos los CA tienen condiciones verificables |
```

---

### Caso 2: Notificaciones push

#### ❌ Historia mal redactada

```markdown
## Notificaciones

Implementar todas las notificaciones push de la app: pedidos, promociones, recordatorios,
alertas de seguridad y mensajes del sistema.
```

**Problemas:** No tiene persona, mezcla 5 tipos distintos de notificación, sin CA, sin valor articulado.

---

#### ✅ Historia bien redactada

```markdown
## US-034 — Recibir notificación push al cambiar el estado de un pedido

**Como** cliente con pedido activo,
**quiero** recibir una notificación push cada vez que mi pedido cambia de estado,
**para** estar informado sin necesidad de abrir la app manualmente.

### Criterios de Aceptación

1. Cuando el estado del pedido cambia (confirmado → preparando → enviado → entregado),
   el sistema envía una notificación push al dispositivo del cliente en menos de 30 segundos.
2. La notificación incluye: título del estado, número de pedido y un deep link al detalle del pedido.
3. Si el usuario tiene las notificaciones desactivadas, el estado actualizado se refleja
   igualmente en la app en la próxima apertura.
4. No se envían notificaciones duplicadas si el estado no ha cambiado realmente.
5. Pruebas unitarias: cambio de estado válido, estado sin cambio (sin notificación), usuario
   sin token de push (silencio sin error). Cobertura ≥ 80%.
6. El servicio de envío de push está abstraído detrás de una interfaz; el proveedor
   (FCM, APNs) se configura por entorno.

### Notas técnicas

- El proveedor de push no está prescrito; se decide en refinación técnica.

### Validación INVEST

| Criterio | Estado | Observación |
|---|---|---|
| Independiente | ✅ | No depende de notificaciones de promociones u otras categorías |
| Negociable | ✅ | Proveedor de push no prescrito |
| Valiosa | ✅ | El cliente tiene visibilidad de su pedido sin abrir la app |
| Estimable | ✅ | Flujo bien acotado |
| Small | ✅ | Un tipo de notificación, un trigger |
| Testeable | ✅ | CA con condiciones y tiempos concretos |
```

---

## Plantilla vacía reutilizable

```markdown
## US-XXX — [Título orientado a la acción]

**Como** [persona],
**quiero** [acción concreta],
**para** [beneficio de negocio medible].

### Criterios de Aceptación

1. Dado [contexto], cuando [acción], entonces [resultado esperado].
2. Si [entrada inválida o excepción], el sistema [respuesta concreta].
3. [Criterio técnico de la DoD: pruebas, cobertura, análisis estático, etc.]

### Notas técnicas *(opcional)*

- [Restricción arquitectónica, deuda técnica, decisión de diseño]

### Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | | |
| Negociable | | |
| Valiosa | | |
| Estimable | | |
| Small | | |
| Testeable | | |
```
