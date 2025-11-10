# 🔧 Cambios Realizados - Diagnóstico de Autenticación

## ✅ Archivos Modificados

### 1. **lib/services/api_service.dart**
- ✅ Agregados logs de debugging en `_getHeaders()` para rastrear tokens

```dart
print('🔑 Token recuperado: ${token != null ? '${token.substring(0, 20)}...' : 'NULL'}');
print('📤 Headers con Authorization: ${headers['Authorization']?.substring(0, 30)}...');
```

### 2. **lib/services/auth_service.dart**
- ✅ Agregados logs en `_exchangeFirebaseToken()` para ver el intercambio
- ✅ Agregados logs en `_saveSession()` para confirmar guardado del token

```dart
print('🔄 Intercambiando token de Firebase por token de AdoPets...');
print('💾 Guardando tokens en storage...');
print('🔍 Verificación - Token guardado: ${savedToken != null ? 'SÍ' : 'NO'}');
```

### 3. **lib/services/mascota_service.dart**
- ✅ Agregados logs en `obtenerMisMascotas()` para rastrear peticiones

```dart
print('🐾 Obteniendo mis mascotas...');
print('✅ Respuesta de mis mascotas: ${response.success ? 'SUCCESS' : 'FAIL'}');
```

### 4. **lib/screens/debug/debug_auth_screen.dart** ⭐ NUEVO
- ✅ Pantalla completa de diagnóstico de autenticación
- Muestra estado de sesión
- Muestra tokens (access y refresh)
- Muestra datos del usuario
- Permite verificar token con `/auth/me`
- Permite copiar tokens al portapapeles
- Permite limpiar storage

### 5. **lib/main.dart**
- ✅ Agregada ruta `/debug-auth` para la pantalla de debug

### 6. **lib/screens/home_screen.dart**
- ✅ Agregado item en el drawer para acceder a Debug Auth

### 7. **DIAGNOSTICO_AUTENTICACION.md** ⭐ NUEVO
- Documentación completa del problema
- Explicación del flujo correcto vs incorrecto
- Pasos de diagnóstico
- Soluciones rápidas

---

## 🎯 Cómo Usar las Herramientas de Diagnóstico

### Opción 1: Ver logs en tiempo real

1. Ejecuta la app:
   ```bash
   flutter run
   ```

2. Haz login con Google

3. Observa la consola. Deberías ver:
   ```
   🔄 Intercambiando token de Firebase por token de AdoPets...
      Firebase Token: eyJhbGciOiJSUzI1NiIsImtpZCI...
   ✅ Token intercambiado exitosamente
      Usuario: tu-email@gmail.com
   💾 Guardando tokens en storage...
      AccessToken: eyJhbGciOiJIUzI1NiIsInR5c...
      RefreshToken: 7d5f8a9e-3b2c-4f1a-9e8d...
   ✅ Sesión guardada correctamente
   🔍 Verificación - Token guardado: SÍ
   ```

4. Navega a "Mis Mascotas" y verás:
   ```
   🐾 Obteniendo mis mascotas...
   🔑 Token recuperado: eyJhbGciOiJIUzI1NiIsInR5c...
   📤 Headers con Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5c...
   ✅ Respuesta de mis mascotas: SUCCESS
   ```

### Opción 2: Pantalla de Debug

1. Abre el drawer (menú lateral)
2. Toca "🔍 Debug Auth"
3. Verás una pantalla con:
   - ✅/❌ Estado de sesión
   - ✅/❌ Access Token presente
   - ✅/❌ Refresh Token presente
   - ✅/❌ Usuario cargado
   - Primeros 50 caracteres de cada token
   - Datos del usuario (ID, nombre, email, roles)
   - Botón para verificar token con el backend
   - Botón para copiar token completo
   - Botón para limpiar storage

4. Toca "Verificar token con /auth/me" para confirmar que el token es válido

---

## 🔍 Interpretación de Resultados

### ✅ TODO BIEN - Deberías ver:

```
✅ Sesión guardada correctamente
🔍 Verificación - Token guardado: SÍ
🔑 Token recuperado: eyJhbGciOiJIUzI1NiI...
📤 Headers con Authorization: Bearer eyJhbGciOiJIUzI1NiI...
✅ Respuesta de mis mascotas: SUCCESS
```

**Esto significa:** El flujo de autenticación funciona correctamente.

---

### ❌ PROBLEMA 1: Token no se guarda

```
💾 Guardando tokens en storage...
🔍 Verificación - Token guardado: NO
```

**Causa:** Problema con FlutterSecureStorage  
**Solución:** 
- Verifica permisos en `AndroidManifest.xml`
- Desinstala y reinstala la app
- Verifica que `StorageService().init()` se llame en `main.dart`

---

### ❌ PROBLEMA 2: Token NULL al hacer peticiones

```
🐾 Obteniendo mis mascotas...
🔑 Token recuperado: NULL
❌ ERROR: No hay token de acceso en storage
```

**Causa:** El token se perdió después del login  
**Solución:**
- Revisa que no haya llamadas accidentales a `signOut()`
- Verifica que esperas el resultado del login antes de navegar
- Usa la pantalla de Debug para ver si el token existe

---

### ❌ PROBLEMA 3: Backend rechaza el token

```
🔑 Token recuperado: eyJhbGciOiJIUzI1NiI...
📤 Headers con Authorization: Bearer eyJhbGciOiJIUzI1NiI...
❌ Error al obtener mascotas: 401 Unauthorized
```

**Causa:** El backend no reconoce el token  
**Solución:**
- Verifica que el token sea del backend, no de Firebase
- Usa la pantalla de Debug → "Verificar token con /auth/me"
- Si `/auth/me` también da 401, el problema está en el backend
- Revisa configuración JWT del backend
- Verifica que el usuario existe en la BD del backend

---

## 🧪 Pruebas Manuales

### Test 1: Verificar que el token se intercambia

1. Abre la app
2. Haz login con Google
3. Busca en los logs:
   ```
   🔄 Intercambiando token de Firebase por token de AdoPets...
   ✅ Token intercambiado exitosamente
   ```

### Test 2: Verificar que el token se guarda

1. Después del login, ve a Debug Auth
2. Verifica que aparezca:
   - ✅ Tiene sesión activa: SÍ
   - ✅ Access Token: Presente
   - ✅ Refresh Token: Presente
   - ✅ Usuario: Cargado

### Test 3: Verificar que el token funciona

1. En Debug Auth, toca "Verificar token con /auth/me"
2. Deberías ver un mensaje verde: ✅ Token válido - Usuario obtenido
3. Si ves un error rojo, copia el token y verifica con Postman

### Test 4: Verificar peticiones protegidas

1. Ve a "Mis Mascotas"
2. Busca en los logs:
   ```
   🔑 Token recuperado: eyJhbGciOiJIUzI1NiI...
   📤 Headers con Authorization: Bearer eyJhbGciOiJIUzI1NiI...
   ✅ Respuesta de mis mascotas: SUCCESS
   ```

---

## 🔥 Solución Rápida si Nada Funciona

1. **Limpiar storage:**
   - Ve a Debug Auth → "Limpiar storage"
   - O desinstala y reinstala la app

2. **Hacer login de nuevo:**
   - Usa Google Sign In
   - Verifica los logs paso a paso

3. **Copiar el token y probar en Postman:**
   ```bash
   GET http://192.168.100.11:5151/api/v1/auth/me
   Headers:
     Authorization: Bearer <tu-token-aquí>
   ```

4. **Si Postman funciona pero la app no:**
   - El problema está en cómo la app envía las peticiones
   - Verifica los logs de `_getHeaders()`

5. **Si Postman también da 401:**
   - El problema está en el backend
   - Verifica configuración JWT
   - Verifica que el usuario existe en la BD

---

## 📞 Próximos Pasos

1. Ejecuta la app con los logs
2. Haz login con Google
3. Ve a "Mis Mascotas"
4. **Copia y pega TODOS los logs de la consola aquí**
5. También ve a Debug Auth y toma screenshot
6. Con esa información podré identificar exactamente el problema

---

## ⚠️ IMPORTANTE: Eliminar en Producción

Antes de publicar la app, **DEBES ELIMINAR**:

1. Todos los `print()` de debug
2. La pantalla `DebugAuthScreen`
3. La ruta `/debug-auth` en `main.dart`
4. El item del drawer "Debug Auth"

O usa constantes de entorno:

```dart
const bool kDebugMode = true; // Cambiar a false en producción

if (kDebugMode) {
  print('🔍 Debug info...');
}
```
