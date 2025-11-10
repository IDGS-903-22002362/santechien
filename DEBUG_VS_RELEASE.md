# 🐛 Debug vs Release: Cómo Probar tu App en el Celular

## ❌ El Problema que Tenías

Estabas usando:
```powershell
flutter build apk --release
```

En **Release Mode**:
- ❌ Se eliminan TODOS los `print()` y `debugPrint()`
- ❌ No hay logs de debugging
- ❌ Código optimizado (más difícil de depurar)
- ❌ Hot reload no funciona
- ✅ Pero la app es más pequeña y rápida

Por eso **NO VEÍAS LOS LOGS** que agregamos (🔄, ✅, 🔑, etc.)

---

## ✅ Soluciones

### Solución 1: Usar Debug Build (RECOMENDADO para desarrollo)

#### Método A: Instalar directamente con USB

1. **Conecta tu celular por USB**
2. **Activa USB Debugging en el celular:**
   - Settings → About phone → Tap "Build number" 7 veces
   - Settings → Developer options → Enable "USB debugging"

3. **Verifica que se detecte:**
   ```powershell
   flutter devices
   ```

4. **Instala en modo debug:**
   ```powershell
   flutter install
   ```

5. **AHORA SÍ verás los logs:**
   ```powershell
   flutter logs
   ```

#### Método B: Generar APK de Debug

```powershell
# Generar APK de debug
flutter build apk --debug

# La APK estará en:
# build\app\outputs\flutter-apk\app-debug.apk

# Transfiere la APK a tu celular e instala
```

**Ventajas del Debug Build:**
- ✅ Ves TODOS los logs
- ✅ Puedes usar Flutter DevTools
- ✅ Símbolos de debug incluidos
- ✅ Más fácil identificar errores

**Desventajas:**
- ❌ APK más grande (~40-60 MB vs ~20-30 MB)
- ❌ Algo más lento
- ❌ No optimizado

---

### Solución 2: Ver Logs de Release Build

Si necesitas usar release por alguna razón, puedes ver logs del sistema:

```powershell
# Conectar celular por USB

# Ver todos los logs
adb logcat

# Filtrar solo logs de Flutter
adb logcat | Select-String "flutter"

# Filtrar por tu app
adb logcat | Select-String "AdoPets"

# Ver solo errores
adb logcat *:E
```

**Pero:** Los `print()` normales NO aparecerán. Solo errores del sistema.

---

### Solución 3: Usar Logger Profesional (MEJOR OPCIÓN)

He creado `lib/utils/app_logger.dart` que funciona en AMBOS modos:

```dart
import 'package:app_movil/utils/app_logger.dart';

// En lugar de print(), usar:
AppLogger.info('🔄 Intercambiando token...');
AppLogger.success('✅ Token guardado');
AppLogger.error('❌ Error al obtener mascotas', error: e);
AppLogger.debug('🔍 Solo en debug mode');
```

**Ventajas:**
- ✅ Funciona en debug Y release
- ✅ Niveles de log (info, success, warning, error)
- ✅ Timestamp automático
- ✅ Visible en `adb logcat`
- ✅ Se puede desactivar en producción

---

## 📋 Comparación de Modos

| Característica | Debug | Profile | Release |
|----------------|-------|---------|---------|
| Tamaño APK | Grande | Medio | Pequeño |
| Velocidad | Lenta | Media | Rápida |
| Logs `print()` | ✅ Sí | ❌ No | ❌ No |
| Hot Reload | ✅ Sí | ✅ Sí | ❌ No |
| DevTools | ✅ Sí | ✅ Sí | ❌ No |
| Optimizado | ❌ No | ✅ Sí | ✅ Sí |
| **Usar para** | Desarrollo | Pruebas rendimiento | Producción |

---

## 🎯 Recomendación para TU Caso

### Durante Desarrollo (AHORA):

```powershell
# 1. Conecta el celular por USB
flutter devices

# 2. Ejecuta en modo debug
flutter run --debug

# O instala APK debug
flutter build apk --debug
# Luego instala: build\app\outputs\flutter-apk\app-debug.apk
```

### Para Probar Rendimiento:

```powershell
flutter run --profile
```

### Para Producción (DESPUÉS):

```powershell
# Solo cuando TODO funcione bien
flutter build apk --release
```

---

## 🔧 Comandos Útiles

### Ver logs en tiempo real

```powershell
# Con celular conectado por USB
flutter logs

# O con adb
adb logcat | Select-String "AdoPets"
```

### Limpiar y reconstruir

```powershell
flutter clean
flutter pub get
flutter build apk --debug
```

### Verificar dispositivos conectados

```powershell
flutter devices
adb devices
```

### Desinstalar versión anterior

```powershell
adb uninstall com.example.app_movil
```

---

## 🚀 Pasos para AHORA

1. **Desinstala la APK de release de tu celular**

2. **Genera APK de debug:**
   ```powershell
   flutter build apk --debug
   ```

3. **Instala la nueva APK:**
   - Copia `build\app\outputs\flutter-apk\app-debug.apk` a tu celular
   - Instala

4. **Conecta por USB y ve los logs:**
   ```powershell
   adb logcat | Select-String "🔄|✅|🔑|📤|🐾|❌"
   ```

5. **Haz login con Google**

6. **AHORA SÍ verás todos los logs con emojis**

7. **Ve a "Mis Mascotas"**

8. **Copia y pega aquí TODOS los logs**

---

## ⚠️ IMPORTANTE

**Para desarrollo, SIEMPRE usa:**
- `flutter run --debug` (recomendado)
- `flutter build apk --debug`

**NUNCA uses release hasta que esté todo funcionando.**

---

## 💡 Extra: Profile Mode

Si quieres probar rendimiento pero con logs:

```powershell
flutter run --profile
```

Profile mode:
- ✅ Optimizado
- ✅ Algunos logs visibles
- ✅ DevTools funciona
- ❌ Un poco más grande que release

---

## 🎯 Resumen

**Tu error era:** Probar con `--release` donde los logs no aparecen.

**Solución:** Usar `--debug` para ver los logs y diagnosticar el problema 401.

**Próximo paso:** 
1. Instalar APK debug
2. Conectar por USB
3. Copiar logs completos
4. Identificar exactamente dónde falla

¡Ahora SÍ podrás ver todos los logs que agregamos! 🎉
