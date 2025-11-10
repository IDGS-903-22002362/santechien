# 🧪 Prueba de Debug - POST con Authorization

## ✅ Cambios Realizados

### 1. **api_service.dart**
- ✅ Cambiado `requiresAuth = false` a `requiresAuth = true` en método POST
- ✅ Agregado logging detallado para JWT (decodificación con jwt_decoder)
- ✅ Logging de todos los headers antes de enviar petición
- ✅ Verificación de token expirado
- ✅ Muestra todos los claims del JWT

### 2. **mascota_service.dart**
- ✅ Agregado logging en método `registrarMascota`

### 3. **debug_auth_screen.dart**
- ✅ Agregado botón de prueba "🧪 Probar POST /MisMascotas (DEBUG)"

## 📋 Instrucciones para Probar

### Paso 1: Hot Restart de la App
```powershell
# En VS Code: Ctrl + Shift + F5
# O en terminal:
flutter run
```

**⚠️ IMPORTANTE:** Debe ser **Hot Restart**, NO hot reload. El cambio en `requiresAuth` necesita restart completo.

### Paso 2: Navegar a Debug Auth Screen
1. Abre el drawer/menú lateral
2. Selecciona "🔍 Debug Autenticación"

### Paso 3: Ejecutar Prueba
1. En la pantalla de Debug, ve a la sección "⚙️ Acciones"
2. Presiona el botón morado: **"🧪 Probar POST /MisMascotas (DEBUG)"**
3. **INMEDIATAMENTE** ve a tu consola/terminal de Flutter

### Paso 4: Revisar Logs de Flutter

Deberías ver algo como esto:

```
🧪 === INICIANDO PRUEBA DE POST ===
🐾 Registrando nueva mascota...
   Endpoint: /MisMascotas
   requiresAuth: true (por defecto)
🔷 POST Request:
   Endpoint: /MisMascotas
   requiresAuth: true
🔑 Token recuperado: eyJhbGciOiJIUzI1NiIs...
⏰ Token expirado: false
✅ Token válido. Tiempo restante: 59 minutos
📋 Claims del token:
   http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier: 123e4567-e89b-12d3-a456-426614174000
   http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress: usuario@example.com
   sub: 123e4567-e89b-12d3-a456-426614174000
   email: usuario@example.com
   jti: abc123...
   exp: 1699564321
   iss: AdoPets
   aud: AdoPets
📤 Headers con Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
🌐 Enviando petición POST a: http://192.168.100.11:5151/api/v1/MisMascotas
   Headers finales que se enviarán:
   Content-Type: application/json
   Accept: application/json
   Authorization: Bearer eyJhbGciOiJIUzI1...
📨 Petición POST enviada. Status code: 201 o 400
🧪 === FIN PRUEBA DE POST ===
```

### Paso 5: Revisar Logs del Backend (C#)

En la consola del backend deberías ver:

```
info: Microsoft.AspNetCore.Hosting.Diagnostics[1]
      Request starting HTTP/1.1 POST http://192.168.100.11:5151/api/v1/MisMascotas
fail: Program[0]
      ?? OnMessageReceived - Token recibido: eyJhbGc...
info: Microsoft.AspNetCore.Authorization.DefaultAuthorizationService[1]
      Authorization was successful.
```

## ✅ Confirmaciones Esperadas

### Si TODO está BIEN:

#### En Flutter:
- ✅ `requiresAuth: true`
- ✅ Token recuperado (NO NULL)
- ✅ Token NO expirado
- ✅ Claims presentes (incluyendo `nameidentifier`)
- ✅ `Authorization header present: Bearer ...`
- ✅ Headers incluyen: Content-Type, Accept, **Authorization**

#### En Backend:
- ✅ `OnMessageReceived - Token recibido`
- ✅ `Authorization was successful`
- ✅ Método del controller se ejecuta

### Si ALGO está MAL:

#### Si el token no llega al backend:
```
❌ Authorization failed - DenyAnonymousAuthorizationRequirement
❌ OnChallenge - Autenticación desafiada
```

**Causa:** Header `Authorization` no se está enviando

#### Si el token está expirado:
```
⚠️ WARNING: El token JWT está EXPIRADO
   Fecha de expiración: 2024-11-08 10:00:00
   Fecha actual: 2024-11-08 11:00:00
```

**Solución:** Vuelve a hacer login (signOut → signInWithGoogle)

#### Si no hay token:
```
❌ ERROR: No hay token de acceso en storage
```

**Solución:** No estás autenticado. Haz login primero.

## 🔍 Qué Buscar en los Logs

### Prioridad ALTA:
1. **¿Dice `requiresAuth: true`?** → Debe ser SÍ
2. **¿Token recuperado es NULL?** → Debe ser NO (debe mostrar token)
3. **¿Token expirado?** → Debe ser false
4. **¿Authorization header present?** → Debe ser SÍ
5. **¿Headers finales incluyen Authorization?** → Debe ser SÍ

### Prioridad MEDIA:
6. **¿Claims incluyen `nameidentifier`?** → Debe estar presente
7. **¿Backend dice "OnMessageReceived"?** → Debe aparecer
8. **¿Status code es 401?** → NO debe ser 401 (debe ser 201 o 400)

## 📸 Evidencia Requerida

Por favor copia y pega:

1. **TODOS los logs de Flutter** desde `🧪 === INICIANDO PRUEBA DE POST ===` hasta `🧪 === FIN PRUEBA DE POST ===`

2. **Logs del backend** de la misma petición

3. **Screenshot** de la consola de Flutter mostrando los logs

## 🎯 Objetivo

Confirmar que:
- ✅ El cambio de `requiresAuth = false` → `requiresAuth = true` se aplicó
- ✅ El token se está recuperando de storage
- ✅ El token NO está expirado
- ✅ El header `Authorization` se está agregando
- ✅ El header `Authorization` se está ENVIANDO al backend
- ✅ El backend RECIBE el token

Si después de esto el backend aún da 401, entonces el problema está en la validación JWT del backend, NO en el frontend.
