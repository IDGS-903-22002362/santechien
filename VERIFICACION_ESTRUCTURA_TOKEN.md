# 🔍 Verificación de Estructura de Token

## 📌 El Problema

El backend de AdoPets debe devolver una respuesta en este formato:

```json
{
  "success": true,
  "message": "Login exitoso",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "7d5f8a9e-3b2c-4f1a-9e8d-2c1b5a8e9f3d",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "usuario": {
      "id": 123,
      "nombre": "Juan",
      "apellidoPaterno": "Pérez",
      "apellidoMaterno": "García",
      "email": "juan@gmail.com",
      "telefono": "1234567890",
      "roles": ["Adoptante"]
    }
  },
  "errors": []
}
```

## ✅ Flujo Correcto (Equivalente JavaScript → Dart)

### JavaScript (tu ejemplo):
```javascript
// 1. Login con Firebase
const loginResponse = await fetch('http://192.168.100.11:5151/api/v1/auth/firebase', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    idToken: firebaseIdToken  // Token de Firebase
  })
});

const loginData = await loginResponse.json();

// 2. Extraer el token del backend
const token = loginData.data.accessToken;  // ← Este es el token JWT del backend
console.log('Token obtenido:', token);

// 3. Guardar el token
localStorage.setItem('adopets_token', token);

// 4. Usar el token en peticiones subsecuentes
const misMascotasResponse = await fetch('http://192.168.100.11:5151/api/v1/MisMascotas', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ nombre: "Max", especie: "Perro", sexo: 1 })
});
```

### Dart (tu código actual):
```dart
// 1. Login con Firebase
final response = await _apiService.post<AuthResponse>(
  ApiConfig.authFirebase, // '/auth/firebase'
  body: {'idToken': idToken},
  fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
  requiresAuth: false,
);

// 2. Extraer el token del backend
// ApiResponse<AuthResponse> ya parsea automáticamente:
// - response.data.accessToken ← Este es el token JWT del backend
// - response.data.refreshToken
// - response.data.usuario

if (response.success && response.data != null) {
  final token = response.data!.accessToken;
  print('Token obtenido: $token');
  
  // 3. Guardar el token
  await _storageService.saveAccessToken(token);
  await _storageService.saveRefreshToken(response.data!.refreshToken);
  await _storageService.saveUsuario(response.data!.usuario);
  
  // 4. Usar el token en peticiones subsecuentes
  // Esto ya se hace automáticamente en _getHeaders()
}
```

## 🔎 Logs Agregados para Verificación

He agregado logs MUY DETALLADOS que mostrarán:

### 1. Al hacer login (en `auth_service.dart`):
```
🔄 Intercambiando token de Firebase por token de AdoPets...
   Firebase Token: eyJhbGciOiJSUzI1NiIsImtpZCI...
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
   Usuario: juan@gmail.com
   AccessToken length: 245 chars
   RefreshToken length: 36 chars
   TokenType: Bearer
💾 Guardando tokens en storage...
   AccessToken: eyJhbGciOiJIUzI1NiI...
   RefreshToken: 7d5f8a9e-3b2c-4f1a...
✅ Sesión guardada correctamente
🔍 Verificación - Token guardado: SÍ
```

### 2. Al obtener mascotas (en `mascota_service.dart` y `api_service.dart`):
```
🐾 Obteniendo mis mascotas...
🔑 Token recuperado: eyJhbGciOiJIUzI1NiI...
📤 Headers con Authorization: Bearer eyJhbGciOiJIUzI1NiI...
📥 Respuesta HTTP:
   Status: 200
   Body length: 523 chars
   JSON parseado correctamente ✅
   Estructura: success, message, data, errors
   ✅ Procesando respuesta exitosa
✅ Respuesta de mis mascotas: SUCCESS
```

## ❌ Posibles Errores y Sus Logs

### Error 1: Backend devuelve formato incorrecto

**Logs que verás:**
```
📥 Respuesta HTTP:
   Status: 200
   Body length: 1245 chars
   JSON parseado correctamente ✅
   Estructura: accessToken, refreshToken, tokenType  ← ⚠️ NO tiene "data"
   ❌ Error al parsear JSON: type 'String' is not a subtype of type 'Map<String, dynamic>'
```

**Solución:** El backend debe envolver la respuesta en `{ "success": true, "data": {...} }`

---

### Error 2: Token no se incluye en data

**Logs que verás:**
```
📥 Respuesta HTTP:
   Status: 200
   JSON parseado correctamente ✅
   Estructura: success, message, data, errors
   data.keys: usuario  ← ⚠️ NO tiene accessToken
   ❌ Error al parsear JSON: Missing required field 'accessToken'
```

**Solución:** El backend debe incluir `accessToken` dentro de `data`

---

### Error 3: Backend devuelve 401

**Logs que verás:**
```
📥 Respuesta HTTP:
   Status: 401
   ❌ Error HTTP 401
📦 Respuesta del backend:
   success: false
   message: Token de Firebase inválido
   data: NULL
❌ Error al intercambiar token: Token de Firebase inválido
```

**Solución:** Verificar que el token de Firebase sea válido

---

## 🧪 Prueba Manual con cURL

Para verificar que el backend devuelve el formato correcto:

```bash
# 1. Obtener token de Firebase (desde la app después de login)
# Busca en los logs: Firebase Token: eyJhbGciOiJSUzI1NiI...

# 2. Probar el endpoint
curl -X POST http://192.168.100.11:5151/api/v1/auth/firebase \
  -H "Content-Type: application/json" \
  -d '{"idToken":"TU_TOKEN_DE_FIREBASE_AQUI"}'
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Login exitoso",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiI...",
    "refreshToken": "7d5f8a9e-3b2c...",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "usuario": { ... }
  }
}
```

**Si el backend devuelve esto (INCORRECTO):**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiI...",
  "refreshToken": "7d5f8a9e-3b2c...",
  "tokenType": "Bearer",
  "usuario": { ... }
}
```

Entonces necesitas modificar el backend para envolver en `{ success, data, message }`.

---

## 🎯 Pasos a Seguir

1. **Ejecuta la app:**
   ```bash
   flutter run
   ```

2. **Haz login con Google**

3. **Copia TODOS los logs desde:**
   - `🔄 Intercambiando token...`
   - Hasta `🔍 Verificación - Token guardado: SÍ`

4. **Intenta obtener mascotas**

5. **Copia los logs desde:**
   - `🐾 Obteniendo mis mascotas...`
   - Hasta `✅ Respuesta de mis mascotas: SUCCESS` (o el error)

6. **Pega los logs aquí para analizarlos**

---

## 📊 Checklist de Verificación

Marca cada item según los logs:

- [ ] ✅ Status: 200 (en el login)
- [ ] ✅ JSON parseado correctamente
- [ ] ✅ Estructura incluye: success, message, data, errors
- [ ] ✅ data.keys incluye: accessToken, refreshToken
- [ ] ✅ accessToken presente en data
- [ ] ✅ refreshToken presente en data
- [ ] ✅ Token intercambiado exitosamente
- [ ] ✅ AccessToken length: > 100 chars
- [ ] ✅ Token guardado: SÍ
- [ ] ✅ Token recuperado al hacer peticiones

Si TODOS están ✅, tu flujo es correcto.  
Si alguno es ❌, los logs te dirán exactamente qué falta.

---

## 🚨 Errores Comunes

### El backend NO usa el formato ApiResponse

Si tu backend devuelve directamente:
```json
{
  "accessToken": "...",
  "refreshToken": "..."
}
```

En lugar de:
```json
{
  "success": true,
  "data": {
    "accessToken": "...",
    "refreshToken": "..."
  }
}
```

Necesitas modificar `AuthResponse.fromJson()`:

```dart
factory AuthResponse.fromJson(Map<String, dynamic> json) {
  // Si el backend NO envuelve en "data", usar json directamente
  return AuthResponse(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    tokenType: json['tokenType'] as String? ?? 'Bearer',
    expiresIn: json['expiresIn'] as int,
    usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
  );
}
```

Y en `auth_service.dart`:

```dart
final response = await _apiService.post<AuthResponse>(
  ApiConfig.authFirebase,
  body: {'idToken': idToken},
  fromJson: (json) {
    // Si el backend NO usa ApiResponse wrapper, parsear directamente
    return AuthResponse.fromJson(json as Map<String, dynamic>);
  },
  requiresAuth: false,
);
```

**PERO** esto solo si el backend NO usa el formato estándar.

Los logs te dirán qué formato está usando tu backend. 🎯
