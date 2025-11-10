# AdoPets - App Móvil Flutter

Aplicación móvil para el sistema de gestión de adopción de mascotas y citas veterinarias.

## 🔐 Autenticación

La app usa **Firebase Authentication** con Google Sign-In, intercambiando el token de Firebase por un token JWT del backend AdoPets.

### Flujo de Autenticación

```
1. Usuario → Login con Google → Firebase Auth
2. Firebase → Token ID (JWT de Firebase)
3. App → POST /api/v1/auth/firebase { idToken }
4. Backend → Token JWT de AdoPets
5. App → Guarda token en FlutterSecureStorage
6. App → Usa token en todas las peticiones subsiguientes
```

## 🐛 Debugging de Autenticación

Si tienes problemas con error **401 Unauthorized**:

### Opción 1: Logs en Consola
```bash
flutter run
```
Busca emojis en la consola: 🔄, ✅, 🔑, 📤, 🐾

### Opción 2: Pantalla de Debug
1. Abre el drawer (menú lateral)
2. Toca "🔍 Debug Auth"
3. Verifica estado de tokens y sesión

## 📚 Documentación de Autenticación

- **[SOLUCION_ERROR_401.md](SOLUCION_ERROR_401.md)** - Guía completa de solución
- **[DIAGNOSTICO_AUTENTICACION.md](DIAGNOSTICO_AUTENTICACION.md)** - Explicación del problema
- **[VERIFICACION_ESTRUCTURA_TOKEN.md](VERIFICACION_ESTRUCTURA_TOKEN.md)** - Formato de respuesta esperado
- **[INSTRUCCIONES_DEBUG.md](INSTRUCCIONES_DEBUG.md)** - Cómo usar herramientas de debug

## 🧪 Testing con Postman

Importa la colección: `Documentation/AdoPets_Test_Token_Flow.postman_collection.json`

Incluye pruebas para:
- Login con Firebase Token
- Verificar token con /auth/me
- Registrar mascota
- Obtener mis mascotas

## 🚀 Instalación

1. **Clonar el repositorio**
```bash
git clone <repo-url>
cd app_movil
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Firebase**
- Copiar `google-services.json` en `android/app/`
- Verificar `firebase_options.dart`

4. **Configurar API**
Editar `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'http://TU-IP:5151/api/v1';
```

5. **Ejecutar**
```bash
flutter run
```

## 📁 Estructura del Proyecto

```
lib/
├── config/           # Configuración (API, tema, constantes)
├── models/          # Modelos de datos
├── providers/       # Estado global (Provider)
├── screens/         # Pantallas de la app
│   ├── auth/       # Login, registro
│   ├── citas/      # Gestión de citas
│   ├── mascotas/   # Gestión de mascotas
│   ├── solicitudes/# Solicitudes de citas
│   └── debug/      # 🔍 Herramientas de debug (solo desarrollo)
├── services/        # Servicios (API, Auth, Storage)
└── widgets/         # Componentes reutilizables
```

## 🔧 Configuración de Desarrollo

### AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### Inicialización en main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await StorageService().init(); // ← Importante para tokens
  runApp(const AdoPetsApp());
}
```

## 🐛 Debug vs Release Mode

### ⚠️ IMPORTANTE: Siempre usa Debug Mode durante desarrollo

```powershell
# ✅ CORRECTO para desarrollo
flutter run --debug
flutter build apk --debug

# ❌ NO USAR durante desarrollo (elimina logs)
flutter build apk --release
```

**¿Por qué?** Release mode elimina TODOS los `print()` y `debugPrint()`. No verás los logs de diagnóstico.

Ver: **[DEBUG_VS_RELEASE.md](DEBUG_VS_RELEASE.md)** para más detalles.

### Ver logs en celular físico

```powershell
# Conectar celular por USB
flutter logs

# O con adb
adb logcat | Select-String "🔄|✅|🔑|📤|🐾|❌"
```

## ⚠️ Antes de Producción

Eliminar herramientas de debug:
- `lib/screens/debug/debug_auth_screen.dart`
- Todos los `print()` statements
- Ruta `/debug-auth` en `main.dart`
- Item "Debug Auth" del drawer

O usar:
```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  print('🔍 Solo en desarrollo');
}
```

## 📦 Dependencias Principales

- `firebase_auth` - Autenticación
- `google_sign_in` - Login con Google
- `flutter_secure_storage` - Almacenamiento seguro de tokens
- `provider` - Gestión de estado
- `http` - Peticiones HTTP

## 🐛 Solución de Problemas

### Error 401 en peticiones
→ Ver [SOLUCION_ERROR_401.md](SOLUCION_ERROR_401.md)

### Token no se guarda
1. Desinstalar app
2. Limpiar cache: `flutter clean`
3. Reinstalar: `flutter run`

### Error de conexión
1. Verificar que el backend esté corriendo
2. Verificar IP en `api_config.dart`
3. Verificar permisos de red en AndroidManifest

## 📞 Soporte

Para reportar problemas:
1. Ejecutar app con `flutter run`
2. Reproducir el error
3. Copiar logs completos de la consola
4. Usar pantalla Debug Auth y tomar screenshot
5. Adjuntar ambos al reporte
