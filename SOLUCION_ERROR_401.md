# 🚀 Guía Completa: Solución Error 401 en /api/v1/MisMascotas

## 📋 Resumen del Problema

Tu backend espera un **token JWT de AdoPets**, no el token de Firebase directamente.

```
❌ INCORRECTO: usar token de Firebase
Authorization: Bearer <firebase-token>

✅ CORRECTO: usar token de AdoPets
Authorization: Bearer <adopets-token>
```

## ✅ Tu Código Ya Está Bien

Tu implementación **ES CORRECTA**:
1. Login con Firebase ✅
2. Obtener token de Firebase ✅
3. Intercambiar en `/auth/firebase` ✅
4. Guardar token de AdoPets ✅
5. Usar token de AdoPets en peticiones ✅

## 🔍 Diagnóstico

He agregado **logs detallados** para encontrar dónde falla:

### Paso 1: Ejecutar la app

```bash
flutter run
```

### Paso 2: Hacer login con Google

Observa los logs en la consola. Deberías ver:

```
🔄 Intercambiando token de Firebase por token de AdoPets...
   Firebase Token: eyJhbGciOiJSUzI1NiI...
   Endpoint: http://192.168.100.11:5151/api/v1/auth/firebase
📥 Respuesta HTTP:
   Status: 200
   Body length: 1245 chars
   JSON parseado correctamente ✅
   Estructura: success, message, data, errors
   data.keys: accessToken, refreshToken, tokenType, expiresIn, usuario
   ✅ accessToken presente en data
   ✅ refreshToken presente en data
   ✅ Procesando respuesta exitosa
📦 Respuesta del backend:
   success: true
   message: Login exitoso
   data: PRESENTE
✅ Token intercambiado exitosamente
   Usuario: tu-email@gmail.com
   AccessToken length: 245 chars
   RefreshToken length: 36 chars
   TokenType: Bearer
💾 Guardando tokens en storage...
   AccessToken: eyJhbGciOiJIUzI1NiI...
   RefreshToken: 7d5f8a9e-3b2c-4f1a...
✅ Sesión guardada correctamente
🔍 Verificación - Token guardado: SÍ
```

### Paso 3: Ir a "Mis Mascotas"

Observa los logs:

```
🐾 Obteniendo mis mascotas...
🔑 Token recuperado: eyJhbGciOiJIUzI1NiI...
📤 Headers con Authorization: Bearer eyJhbGciOiJIUzI1NiI...
📥 Respuesta HTTP:
   Status: 200
   ...
✅ Respuesta de mis mascotas: SUCCESS
```

### Paso 4: Usar la pantalla de Debug

1. Abre el drawer (menú lateral)
2. Toca "🔍 Debug Auth"
3. Verifica que TODO esté en ✅:
   - ✅ Tiene sesión activa: SÍ
   - ✅ Access Token: Presente
   - ✅ Refresh Token: Presente
   - ✅ Usuario: Cargado
4. Toca "Verificar token con /auth/me"
   - Si ves ✅ verde: el token funciona
   - Si ves ❌ rojo: hay un problema

## 🎯 Escenarios Posibles

### Escenario 1: Todo funciona ✅

**Logs:**
```
✅ Token intercambiado exitosamente
✅ Sesión guardada correctamente
🔍 Verificación - Token guardado: SÍ
🔑 Token recuperado: eyJhbGciOiJIUzI1NiI...
✅ Respuesta de mis mascotas: SUCCESS
```

**Acción:** ¡No hay problema! Tu app funciona correctamente.

---

### Escenario 2: Backend no devuelve el token ❌

**Logs:**
```
📥 Respuesta HTTP:
   Status: 200
   Estructura: accessToken, refreshToken  ← ⚠️ NO tiene "data"
❌ Error al parsear JSON: type 'String' is not a subtype...
```

**Causa:** El backend NO usa el formato `{ success, data, message }`

**Solución:** Ver documento `VERIFICACION_ESTRUCTURA_TOKEN.md` sección "Errores Comunes"

---

### Escenario 3: Token no se guarda ❌

**Logs:**
```
💾 Guardando tokens en storage...
🔍 Verificación - Token guardado: NO
```

**Causa:** Problema con FlutterSecureStorage

**Solución:**
1. Desinstalar y reinstalar la app
2. Verificar permisos en `AndroidManifest.xml`
3. Limpiar storage desde Debug Auth

---

### Escenario 4: Token se pierde ❌

**Logs:**
```
✅ Sesión guardada correctamente
🔍 Verificación - Token guardado: SÍ
...
(al obtener mascotas)
🔑 Token recuperado: NULL
❌ ERROR: No hay token de acceso en storage
```

**Causa:** El token se eliminó entre pantallas

**Solución:**
1. Verificar que no hay llamadas a `signOut()`
2. Usar Debug Auth para ver si el token existe
3. Revisar que `StorageService().init()` se llama en `main.dart`

---

### Escenario 5: Backend rechaza el token ❌

**Logs:**
```
🔑 Token recuperado: eyJhbGciOiJIUzI1NiI...
📤 Headers con Authorization: Bearer eyJhbGciOiJIUzI1NiI...
📥 Respuesta HTTP:
   Status: 401
❌ Error al obtener mascotas: 401 Unauthorized
```

**Causa:** El backend no reconoce el token

**Solución:**
1. Copiar el token desde Debug Auth
2. Probar con Postman (ver colección incluida)
3. Si Postman funciona pero la app no: problema en headers
4. Si Postman también da 401: problema en el backend

---

## 🧪 Prueba con Postman

1. Importa: `Documentation/AdoPets_Test_Token_Flow.postman_collection.json`

2. Configura variables:
   - `baseUrl`: `http://192.168.100.11:5151/api/v1`
   - `firebaseIdToken`: Cópialo desde los logs de la app

3. Ejecuta en orden:
   1. Login con Firebase Token
   2. Verificar Token con /auth/me
   3. POST - Registrar Mascota
   4. GET - Mis Mascotas

Si todo funciona en Postman pero no en la app, el problema es la implementación móvil.
Si nada funciona en Postman, el problema es el backend.

---

## 📁 Archivos Creados

1. **`DIAGNOSTICO_AUTENTICACION.md`**
   - Explicación completa del problema
   - Flujo correcto vs incorrecto
   - Causas y soluciones

2. **`INSTRUCCIONES_DEBUG.md`**
   - Cómo usar las herramientas de debug
   - Interpretación de logs
   - Checklist de verificación

3. **`VERIFICACION_ESTRUCTURA_TOKEN.md`**
   - Formato esperado de la respuesta
   - Comparación JavaScript vs Dart
   - Soluciones si el backend usa formato diferente

4. **`lib/screens/debug/debug_auth_screen.dart`**
   - Pantalla visual para ver estado de autenticación
   - Botones para verificar y copiar tokens
   - Solo para desarrollo

5. **`Documentation/AdoPets_Test_Token_Flow.postman_collection.json`**
   - Colección de Postman para probar el backend
   - Tests automáticos incluidos

---

## 📞 Próximos Pasos

1. **Ejecuta la app**: `flutter run`
2. **Haz login con Google**
3. **Copia TODOS los logs** y pégalos aquí
4. **Toma screenshot** de Debug Auth
5. **Prueba con Postman** y comparte resultados

Con esa información podré identificar exactamente el problema y darte la solución específica.

---

## ⚠️ Antes de Producción

Eliminar:
- Todos los `print()` de debug
- `lib/screens/debug/debug_auth_screen.dart`
- Ruta `/debug-auth` en `main.dart`
- Item "Debug Auth" del drawer

O usar:
```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  print('🔍 Solo en desarrollo');
}
```

---

## 💡 Equivalencia JavaScript ↔ Dart

Tu ejemplo en JavaScript es **EXACTAMENTE** lo que hace tu código Dart:

| JavaScript | Dart |
|------------|------|
| `fetch('/auth/firebase', { body: { idToken } })` | `_apiService.post(ApiConfig.authFirebase, body: {'idToken': idToken})` |
| `const token = loginData.data.accessToken` | `final token = response.data!.accessToken` |
| `localStorage.setItem('adopets_token', token)` | `await _storageService.saveAccessToken(token)` |
| `fetch('/MisMascotas', { headers: { 'Authorization': 'Bearer ' + token } })` | `_getHeaders()` agrega automáticamente `Authorization: Bearer <token>` |

Tu implementación **ES CORRECTA**. Los logs te dirán si hay algún problema de formato o comunicación. 🎯
