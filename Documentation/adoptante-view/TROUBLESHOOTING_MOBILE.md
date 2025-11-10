# ?? Troubleshooting y Casos de Uso - App Móvil AdoPets

## ?? Índice
1. [Casos de Uso Comunes](#casos-de-uso-comunes)
2. [Problemas Frecuentes](#problemas-frecuentes)
3. [Logs y Debugging](#logs-y-debugging)
4. [Performance y Optimización](#performance-y-optimización)
5. [Testing](#testing)

---

## Casos de Uso Comunes

### Caso 1: Usuario Nuevo - Primera Cita

**Escenario:** Usuario se registra por primera vez y quiere agendar una cita para su mascota.

**Flujo:**
1. Usuario abre app
2. Click en "Iniciar sesión con Google"
3. Selecciona cuenta de Google
4. App obtiene Firebase token
5. App intercambia token por JWT del backend
6. **Usuario es creado automáticamente con rol "Adoptante"**
7. App muestra pantalla de bienvenida
8. Usuario navega a "Mis Mascotas"
9. Click en "Agregar Mascota"
10. Completa formulario y sube fotos
11. Mascota registrada
12. Usuario navega a "Solicitar Cita"
13. Selecciona mascota y servicio
14. Completa formulario de cita
15. Revisa resumen: Total $1,218, Anticipo $609
16. Click en "Pagar"
17. Redirigido a PayPal
18. Completa pago
19. Recibe confirmación de pago
20. Espera confirmación del personal

**Código de ejemplo:**

```dart
class PrimeraCitaFlow {
  final AdoPetsApiClient api;
  
  Future<void> ejecutarFlujoCompleto() async {
    try {
      // 1. Login
      final loginExitoso = await api.loginWithGoogle();
      if (!loginExitoso) throw Exception('Error en login');
      
      // 2. Registrar mascota
      final mascota = await api.registrarMascota(
        nombre: 'Max',
        especie: 'Perro',
        raza: 'Labrador',
        fechaNacimiento: DateTime(2020, 5, 15),
        sexo: 1,
        personalidad: 'Juguetón',
        estadoSalud: 'Saludable',
      );
      
      // 3. Crear solicitud
      final solicitud = await api.crearSolicitudCita(
        usuarioId: await _getUserId(),
        mascotaId: mascota['id'],
        nombreMascota: mascota['nombre'],
        especieMascota: mascota['especie'],
        razaMascota: mascota['raza'],
        servicioId: await _getServicioId(),
        descripcionServicio: 'Esterilización',
        fechaHoraSolicitada: DateTime(2024, 2, 15, 10, 0),
        duracionEstimadaMin: 120,
        costoEstimado: 1218.00,
      );
      
      // 4. Pagar
      final orden = await api.crearOrdenPayPal(
        solicitudCitaId: solicitud['id'],
        usuarioId: await _getUserId(),
        monto: solicitud['montoAnticipo'],
        concepto: 'Anticipo 50%',
        montoTotal: solicitud['costoEstimado'],
      );
      
      // 5. Abrir PayPal (implementar WebView)
      final orderId = await _abrirPayPal(orden['approvalUrl']);
      
      // 6. Capturar pago
      await api.capturarPagoPayPal(orderId);
      
      print('? Flujo completado exitosamente');
      
    } catch (e) {
      print('? Error en flujo: $e');
      rethrow;
    }
  }
}
```

### Caso 2: Usuario Existente - Nueva Cita

**Escenario:** Usuario ya tiene cuenta y mascotas registradas, quiere agendar otra cita.

**Flujo Simplificado:**
1. Login con Google (token guardado, auto-login)
2. Navegar a "Solicitar Cita"
3. Seleccionar mascota existente de lista
4. Completar formulario
5. Pagar
6. Confirmar

**Optimización:**

```dart
class CitaRapidaFlow {
  Future<void> agendarCitaRapida(String mascotaId) async {
    // Token ya guardado, no necesita login
    
    // 1. Obtener datos de mascota
    final mascota = await api.obtenerMascota(mascotaId);
    
    // 2. Pre-llenar formulario con datos de mascota
    final solicitud = await api.crearSolicitudCita(
      mascotaId: mascotaId,
      nombreMascota: mascota['nombre'],
      especieMascota: mascota['especie'],
      // ... otros campos pre-llenados
    );
    
    // 3. Flujo de pago normal
    await _procesarPago(solicitud);
  }
}
```

### Caso 3: Múltiples Mascotas

**Escenario:** Usuario tiene 3 mascotas y quiere agendar citas para todas.

```dart
class MultipleCitasFlow {
  Future<void> agendarCitasMultiples(List<String> mascotaIds) async {
    final solicitudes = <Map<String, dynamic>>[];
    
    for (final mascotaId in mascotaIds) {
      try {
        final solicitud = await api.crearSolicitudCita(
          mascotaId: mascotaId,
          // ... otros campos
        );
        
        solicitudes.add(solicitud);
      } catch (e) {
        print('Error con mascota $mascotaId: $e');
      }
    }
    
    // Pagar todas juntas
    await _pagarMultiplesSolicitudes(solicitudes);
  }
  
  Future<void> _pagarMultiplesSolicitudes(List<Map> solicitudes) async {
    final montoTotal = solicitudes.fold<double>(
      0,
      (sum, s) => sum + s['montoAnticipo'],
    );
    
    // Crear orden única para todas
    final orden = await api.crearOrdenPayPal(
      monto: montoTotal,
      concepto: 'Anticipo para ${solicitudes.length} citas',
      // ...
    );
    
    // Procesar pago
  }
}
```

### Caso 4: Reprogramar Cita

**Escenario:** Usuario necesita cambiar la fecha de una cita ya solicitada.

```dart
class ReprogramarCitaFlow {
  Future<void> reprogramarCita(String solicitudId) async {
    // 1. Obtener solicitud actual
    final solicitud = await api.obtenerSolicitud(solicitudId);
    
    // 2. Verificar si puede reprogramarse
    if (solicitud['estado'] == 5) {
      throw Exception('No se puede reprogramar una cita confirmada');
    }
    
    // 3. Si hay pago, debe contactar al personal
    if (solicitud['pagoAnticipoId'] != null) {
      await _contactarSoporte(solicitud);
      return;
    }
    
    // 4. Cancelar solicitud actual
    await api.cancelarSolicitud(solicitudId);
    
    // 5. Crear nueva solicitud
    await api.crearSolicitudCita(/* nueva fecha */);
  }
}
```

---

## Problemas Frecuentes

### ?? Problema 1: "Token de Firebase inválido"

**Error:**
```json
{
  "success": false,
  "message": "Token de Firebase inválido o expirado"
}
```

**Causas:**
1. Token de Firebase expirado (válido por 1 hora)
2. Configuración incorrecta de Firebase en backend
3. Discrepancia entre projectId de Firebase

**Solución:**

```dart
class TokenManager {
  Future<String> obtenerTokenValido() async {
    try {
      // Intentar obtener token actual
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Forzar re-login
        return await _reLogin();
      }
      
      // Refrescar token
      final newToken = await user.getIdToken(true); // force refresh
      return newToken!;
      
    } catch (e) {
      // Si falla, hacer login completo
      return await _reLogin();
    }
  }
  
  Future<String> _reLogin() async {
    final loginExitoso = await api.loginWithGoogle();
    if (!loginExitoso) throw Exception('No se pudo renovar sesión');
    return await FirebaseAuth.instance.currentUser!.getIdToken();
  }
}
```

### ?? Problema 2: "Debe tener al menos una mascota registrada"

**Error:**
```json
{
  "success": false,
  "message": "Debe tener al menos una mascota registrada"
}
```

**Causa:** Usuario intenta crear solicitud sin tener mascotas.

**Solución:**

```dart
class ValidacionMascotasMiddleware {
  Future<void> validarAntesDeCrearSolicitud() async {
    final mascotas = await api.obtenerMisMascotas();
    
    if (mascotas.isEmpty) {
      // Mostrar diálogo
      final registrar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Sin mascotas'),
          content: Text(
            'Necesitas registrar al menos una mascota antes de solicitar una cita.\n\n'
            '¿Deseas registrar una mascota ahora?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Registrar'),
            ),
          ],
        ),
      );
      
      if (registrar ?? false) {
        Navigator.pushNamed(context, '/registrar-mascota');
      }
      
      throw Exception('Operación cancelada');
    }
  }
}
```

### ?? Problema 3: PayPal no redirige correctamente

**Problema:** Después de pagar en PayPal, no regresa a la app.

**Causa:** Deep links mal configurados.

**Solución Android (AndroidManifest.xml):**

```xml
<activity android:name=".MainActivity">
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    
    <!-- Deep link scheme -->
    <data
      android:scheme="adopets"
      android:host="payment" />
  </intent-filter>
</activity>
```

**Solución iOS (Info.plist):**

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>adopets</string>
    </array>
  </dict>
</array>
```

**Manejo en Flutter:**

```dart
import 'package:uni_links/uni_links.dart';

class DeepLinkHandler {
  StreamSubscription? _sub;
  
  void iniciarEscucha() {
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        _manejarDeepLink(link);
      }
    });
  }
  
  void _manejarDeepLink(String link) {
    final uri = Uri.parse(link);
    
    if (uri.path == '/payment/success') {
      final orderId = uri.queryParameters['token'];
      if (orderId != null) {
        _capturarPago(orderId);
      }
    } else if (uri.path == '/payment/cancel') {
      _mostrarCancelacion();
    }
  }
  
  Future<void> _capturarPago(String orderId) async {
    try {
      await api.capturarPagoPayPal(orderId);
      // Mostrar éxito
    } catch (e) {
      // Mostrar error
    }
  }
  
  void dispose() {
    _sub?.cancel();
  }
}
```

### ?? Problema 4: "El pago no fue completado"

**Error:**
```json
{
  "success": false,
  "message": "El pago no fue completado. Estado: CREATED"
}
```

**Causa:** Usuario no completó el proceso en PayPal.

**Solución:**

```dart
class PayPalErrorHandler {
  Future<void> manejarPagoIncompleto(String orderId) async {
    // Mostrar diálogo
    final reintentar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pago Incompleto'),
        content: Text(
          'El pago no se completó.\n\n'
          '¿Deseas intentar nuevamente?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
    
    if (reintentar ?? false) {
      // Crear nueva orden
      await _crearNuevaOrden();
    }
  }
}
```

### ?? Problema 5: Token JWT expirado

**Error:** HTTP 401 en peticiones subsecuentes.

**Solución con Interceptor:**

```dart
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token expirado, renovar
      try {
        final nuevoToken = await _renovarToken();
        
        // Reintentar petición original
        final opts = Options(
          method: err.requestOptions.method,
          headers: {
            ...err.requestOptions.headers,
            'Authorization': 'Bearer $nuevoToken',
          },
        );
        
        final response = await dio.request(
          err.requestOptions.path,
          options: opts,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
        );
        
        return handler.resolve(response);
      } catch (e) {
        // Si falla renovación, cerrar sesión
        await _cerrarSesion();
        return handler.reject(err);
      }
    }
    
    return handler.next(err);
  }
  
  Future<String> _renovarToken() async {
    final user = FirebaseAuth.instance.currentUser;
    final newToken = await user?.getIdToken(true);
    
    if (newToken == null) throw Exception('No se pudo renovar token');
    
    // Intercambiar por nuevo JWT
    final response = await api.loginWithFirebaseToken(newToken);
    return response.accessToken;
  }
}
```

---

## Logs y Debugging

### Habilitar Logs Detallados

```dart
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('?? REQUEST[${options.method}] => PATH: ${options.path}');
    print('Headers: ${options.headers}');
    print('Body: ${options.data}');
    super.onRequest(options, handler);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('?? RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('Data: ${response.data}');
    super.onResponse(response, handler);
  }
  
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print('?? ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('Message: ${err.message}');
    print('Data: ${err.response?.data}');
    super.onError(err, handler);
  }
}
```

### Logs Recomendados por Flujo

**Login:**
```
?? Iniciando Google Sign-In
?? Token de Google obtenido
?? Autenticando con Firebase
?? Token de Firebase obtenido
?? Intercambiando por JWT del backend
? Login exitoso - Token guardado
```

**Crear Solicitud:**
```
?? Validando mascota seleccionada
?? Creando solicitud de cita
?? Solicitud creada: SOL-20240115-0001
?? Estado: PendientePago
?? Monto anticipo: $609.00
```

**Pago:**
```
?? Creando orden de PayPal
?? Orden creada: 8VF91827TN047864P
?? Abriendo WebView de PayPal
?? Usuario redirigido a PayPal
? Esperando aprobación...
?? PayPal redirigió a returnUrl
?? Capturando pago...
? Pago capturado exitosamente
```

---

## Performance y Optimización

### 1. Caché de Datos

```dart
class CacheManager {
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheValidity = Duration(minutes: 5);
  
  Future<T?> getCachedOrFetch<T>(
    String key,
    Future<T> Function() fetcher,
  ) async {
    // Verificar si hay caché válido
    if (_cache.containsKey(key)) {
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null && 
          DateTime.now().difference(timestamp) < _cacheValidity) {
        return _cache[key] as T;
      }
    }
    
    // Fetch y guardar en caché
    final data = await fetcher();
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    
    return data;
  }
  
  void invalidate(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }
}

// Uso
final servicios = await cache.getCachedOrFetch(
  'servicios',
  () => api.obtenerServicios(),
);
```

### 2. Compresión de Imágenes

```dart
import 'package:image/image.dart' as img;

class ImageOptimizer {
  Future<String> optimizarImagen(File imageFile) async {
    // Leer imagen
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Imagen inválida');
    
    // Redimensionar si es muy grande
    img.Image resized = image;
    if (image.width > 1600) {
      resized = img.copyResize(image, width: 1600);
    }
    
    // Comprimir como JPEG
    final compressed = img.encodeJpg(resized, quality: 75);
    
    // Convertir a base64
    return base64Encode(compressed);
  }
}
```

### 3. Paginación

```dart
class PaginatedList<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  
  PaginatedList({
    required this.items,
    required this.currentPage,
    required this.totalPages,
  }) : hasMore = currentPage < totalPages;
  
  Future<PaginatedList<T>> loadMore(
    Future<List<T>> Function(int page) fetcher,
  ) async {
    if (!hasMore) return this;
    
    final nextPage = currentPage + 1;
    final newItems = await fetcher(nextPage);
    
    return PaginatedList(
      items: [...items, ...newItems],
      currentPage: nextPage,
      totalPages: totalPages,
    );
  }
}

// Uso con solicitudes
class SolicitudesScreen extends StatefulWidget {
  @override
  _SolicitudesScreenState createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  PaginatedList<Solicitud>? _solicitudes;
  
  @override
  void initState() {
    super.initState();
    _loadSolicitudes();
  }
  
  Future<void> _loadSolicitudes() async {
    final data = await api.obtenerSolicitudes(page: 1, pageSize: 20);
    setState(() {
      _solicitudes = PaginatedList(
        items: data['items'],
        currentPage: data['currentPage'],
        totalPages: data['totalPages'],
      );
    });
  }
  
  Future<void> _loadMore() async {
    if (_solicitudes == null || !_solicitudes!.hasMore) return;
    
    final updated = await _solicitudes!.loadMore(
      (page) async {
        final data = await api.obtenerSolicitudes(page: page, pageSize: 20);
        return data['items'];
      },
    );
    
    setState(() => _solicitudes = updated);
  }
}
```

---

## Testing

### Unit Tests

```dart
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class MockApiClient extends Mock implements AdoPetsApiClient {}

void main() {
  group('SolicitudCitaService Tests', () {
    late MockApiClient mockApi;
    late SolicitudCitaService service;
    
    setUp(() {
      mockApi = MockApiClient();
      service = SolicitudCitaService(mockApi);
    });
    
    test('Crear solicitud calcula anticipo del 50%', () async {
      // Arrange
      const costoTotal = 1218.0;
      const anticipoEsperado = 609.0;
      
      when(mockApi.crearSolicitudCita(any))
          .thenAnswer((_) async => {
                'costoEstimado': costoTotal,
                'montoAnticipo': anticipoEsperado,
              });
      
      // Act
      final resultado = await service.crearSolicitud(/* ... */);
      
      // Assert
      expect(resultado['montoAnticipo'], equals(anticipoEsperado));
      expect(resultado['costoEstimado'], equals(costoTotal));
    });
    
    test('No permite crear solicitud sin mascota', () async {
      // Arrange
      when(mockApi.obtenerMisMascotas())
          .thenAnswer((_) async => []);
      
      // Act & Assert
      expect(
        () => service.crearSolicitudConValidacion(/* ... */),
        throwsA(isA<Exception>()),
      );
    });
  });
  
  group('PayPalService Tests', () {
    test('Capturar pago actualiza estado', () async {
      // Implementar tests de PayPal
    });
  });
}
```

### Integration Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Flujo completo de cita', () {
    testWidgets('Usuario puede crear solicitud y pagar', (tester) async {
      // 1. Launch app
      await tester.pumpWidget(MyApp());
      
      // 2. Login
      await tester.tap(find.text('Iniciar sesión con Google'));
      await tester.pumpAndSettle();
      
      // 3. Registrar mascota
      await tester.tap(find.byIcon(Icons.pets));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Agregar Mascota'));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byKey(Key('nombre')), 'Max');
      await tester.enterText(find.byKey(Key('especie')), 'Perro');
      
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      
      // 4. Crear solicitud
      await tester.tap(find.text('Solicitar Cita'));
      await tester.pumpAndSettle();
      
      // ... completar formulario ...
      
      await tester.tap(find.text('Solicitar y Pagar'));
      await tester.pumpAndSettle();
      
      // 5. Verificar que se muestra PayPal WebView
      expect(find.byType(WebView), findsOneWidget);
    });
  });
}
```

### Manual Testing Checklist

- [ ] Login con Google funciona
- [ ] Token se guarda correctamente
- [ ] Token se renueva al expirar
- [ ] Registro de mascota con fotos
- [ ] Lista de mascotas carga correctamente
- [ ] Formulario de solicitud valida campos
- [ ] Anticipo se calcula al 50%
- [ ] WebView de PayPal abre correctamente
- [ ] Deep link de returnUrl funciona
- [ ] Pago se captura exitosamente
- [ ] Estado de solicitud se actualiza
- [ ] Notificaciones push llegan
- [ ] App funciona sin internet (offline mode)
- [ ] Loading states se muestran
- [ ] Errores se manejan correctamente

---

## ?? Soporte

Para reportar bugs o solicitar ayuda:
1. Revisar esta guía de troubleshooting
2. Verificar logs de la app
3. Revisar logs del backend en Swagger
4. Contactar a backend@adopets.com con:
   - Logs de la app
   - Pasos para reproducir
   - Capturas de pantalla
   - Información del dispositivo

---

*Última actualización: Enero 2024*  
*Versión: 1.0*
