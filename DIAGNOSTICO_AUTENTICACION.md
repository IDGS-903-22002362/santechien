# 🔐 Diagnóstico: Error 401 en /api/v1/MisMascotas

## ❌ El Problema

Tu backend está rechazando las peticiones a `/api/v1/MisMascotas` con error **401 Unauthorized**:

```
Authorization failed. These requirements were not met:
DenyAnonymousAuthorizationRequirement: Requires an authenticated user.
```

## 🔍 Causa Raíz

El backend de AdoPets **NO acepta tokens de Firebase directamente**. Necesita su propio token JWT.

### Flujo INCORRECTO ❌

```dart
// Esto NO funciona:
final firebaseToken = await user.getIdToken();
fetch('/api/v1/MisMascotas', {
  headers: { 'Authorization': 'Bearer $firebaseToken' }  // ❌ Token de Firebase
});
```

### Flujo CORRECTO ✅

```dart
// 1. Obtener token de Firebase
final firebaseToken = await user.getIdToken();

// 2. Intercambiar por token de AdoPets
final response = await fetch('/api/v1/auth/firebase', {
  method: 'POST',
  body: { 'idToken': firebaseToken }
});

final backendToken = response.data.accessToken;  // ✅ Token del backend

// 3. Usar token de AdoPets para peticiones
fetch('/api/v1/MisMascotas', {
  headers: { 'Authorization': 'Bearer $backendToken' }  // ✅ Correcto
});
```

## ✅ Tu Código YA Implementa el Flujo Correcto

Tu `AuthService` ya tiene el flujo correcto:

```dart
// lib/services/auth_service.dart
Future<ApiResponse<AuthResponse>> signInWithGoogle() async {
  // 1. Login con Firebase
  final userCredential = await _firebaseAuth.signInWithCredential(credential);
  
  // 2. Obtener token de Firebase
  final idToken = await userCredential.user?.getIdToken();
  
  // 3. Intercambiar por token de AdoPets ✅
  return await _exchangeFirebaseToken(idToken);
}

Future<ApiResponse<AuthResponse>> _exchangeFirebaseToken(String idToken) async {
  // Llamada a /api/v1/auth/firebase
  final response = await _apiService.post<AuthResponse>(
    ApiConfig.authFirebase,  // ← POST /api/v1/auth/firebase
    body: {'idToken': idToken},
    requiresAuth: false,
  );

  if (response.success && response.data != null) {
    // Guardar token de AdoPets en storage seguro ✅
    await _saveSession(response.data!);
  }

  return response;
}
```

## 🔧 Posibles Problemas y Soluciones

### 1. **Token no se está guardando correctamente**

**Verificar:**
- ¿El login retorna `success: true`?
- ¿Se ejecuta `_saveSession()`?
- ¿El token se guarda en `FlutterSecureStorage`?

**He agregado logs** para verificar esto. Ejecuta la app y revisa la consola:

```
💾 Guardando tokens en storage...
   AccessToken: eyJhbGciOiJIUzI1NiI...
✅ Sesión guardada correctamente
🔍 Verificación - Token guardado: SÍ
```

### 2. **Token se pierde entre pantallas**

**Verificar:**
- ¿Cambias de pantalla antes de que termine `_saveSession()`?
- ¿Hay algún `signOut()` accidental?

**Solución:** Asegúrate de esperar el resultado antes de navegar:

```dart
// ✅ CORRECTO
Future<void> _handleGoogleSignIn() async {
  setState(() => _isLoading = true);

  final authProvider = context.read<AuthProvider>();
  final success = await authProvider.signInWithGoogle(); // ← await

  if (mounted) {
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}
```

### 3. **Storage no está inicializado**

**Verificar:** ¿Llamas a `StorageService.init()` en `main.dart`?

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Inicializar storage ✅
  await StorageService().init();
  
  runApp(const MyApp());
}
```

### 4. **El endpoint `/auth/firebase` no está funcionando**

**Verificar logs del backend:**
```
POST /api/v1/auth/firebase
Status: 200 OK
Response: { "accessToken": "...", "refreshToken": "..." }
```

Si ves **401 o 500**, el problema está en el backend.

### 5. **Peticiones subsiguientes no envían el token**

**Código actual (CORRECTO):**

```dart
// lib/services/api_service.dart
Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
  if (!requiresAuth) {
    return ApiConfig.headers;
  }

  final token = await _storageService.getAccessToken(); // ✅ Lee del storage
  if (token == null) {
    throw Exception('No hay token de acceso');
  }

  return ApiConfig.authHeaders(token); // ✅ Agrega Authorization header
}
```

**He agregado logs** para verificar:

```
🔑 Token recuperado: eyJhbGciOiJIUzI1NiI...
📤 Headers con Authorization: Bearer eyJhbGciOiJIUzI1NiI...
```

## 📋 Pasos para Diagnosticar

### Paso 1: Ejecutar la app y hacer login

```bash
flutter run
```

### Paso 2: Revisar logs de autenticación

Busca en la consola:

```
🔄 Intercambiando token de Firebase por token de AdoPets...
✅ Token intercambiado exitosamente
💾 Guardando tokens en storage...
✅ Sesión guardada correctamente
🔍 Verificación - Token guardado: SÍ
```

Si ves **NO** en la verificación, hay un problema con `FlutterSecureStorage`.

### Paso 3: Intentar obtener mascotas

Navega a "Mis Mascotas" y revisa:

```
🐾 Obteniendo mis mascotas...
🔑 Token recuperado: eyJhbGciOiJIUzI1NiI...
📤 Headers con Authorization: Bearer eyJhbGciOiJIUzI1NiI...
```

Si no ves el token, significa que se perdió entre pantallas.

### Paso 4: Verificar respuesta del backend

```
✅ Respuesta de mis mascotas: SUCCESS
```

o

```
❌ Error al obtener mascotas: Exception: No hay token de acceso
```

## 🎯 Soluciones Rápidas

### Si el token NO se guarda:

```dart
// Verificar permisos en AndroidManifest.xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### Si el token se pierde:

```dart
// Asegúrate de no llamar signOut() por error
// Busca en tu código: grep -r "signOut" lib/
```

### Si el backend rechaza el token:

1. Verifica que el token sea del backend, no de Firebase
2. Revisa la configuración JWT del backend
3. Verifica que el usuario exista en la base de datos del backend

## 🧪 Prueba Manual

Ejecuta esto después del login:

```dart
// En cualquier pantalla después del login
ElevatedButton(
  onPressed: () async {
    final storage = StorageService();
    final token = await storage.getAccessToken();
    print('🔍 Token en storage: ${token?.substring(0, 30)}...');
    
    final usuario = await storage.getUsuario();
    print('👤 Usuario: ${usuario?.email}');
  },
  child: Text('Verificar Token'),
)
```

## 📞 Próximos Pasos

1. **Ejecuta la app con los logs activados**
2. **Copia y pega aquí los logs completos** desde el login hasta el error 401
3. Veremos exactamente dónde está fallando

---

**Nota:** Los logs se eliminarán en producción. Solo son para debugging.
