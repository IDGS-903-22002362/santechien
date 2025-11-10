# ?? Quick Start Guide - App Móvil AdoPets

## ? Inicio Rápido (5 minutos)

### Prerequisitos

```bash
# Flutter
flutter --version  # >= 3.0.0

# Firebase CLI
npm install -g firebase-tools
firebase --version  # >= 11.0.0

# Configuración de entorno
cp .env.example .env
```

### Variables de Entorno (.env)

```env
# Backend AdoPets
API_BASE_URL=https://api.adopets.com/api
API_TIMEOUT=30000

# Firebase
FIREBASE_PROJECT_ID=adopets-app
FIREBASE_API_KEY=AIzaSy...
FIREBASE_APP_ID=1:123456789:android:abc123

# PayPal (Sandbox)
PAYPAL_RETURN_URL=adopets://payment/success
PAYPAL_CANCEL_URL=adopets://payment/cancel

# Deep Linking
DEEP_LINK_SCHEME=adopets
```

---

## ?? Instalación

### 1. Clonar Proyecto

```bash
git clone https://github.com/adopets/mobile-app.git
cd mobile-app
```

### 2. Instalar Dependencias

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Autenticación
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  google_sign_in: ^6.1.5
  
  # Networking
  dio: ^5.4.0
  pretty_dio_logger: ^1.3.1
  
  # Estado
  provider: ^6.1.1
  
  # Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  
  # UI
  cached_network_image: ^3.3.0
  image_picker: ^1.0.5
  webview_flutter: ^4.4.2
  
  # Deep Linking
  uni_links: ^0.5.1
  
  # Utils
  intl: ^0.18.1
  url_launcher: ^6.2.1
```

```bash
flutter pub get
```

### 3. Configurar Firebase

**Android** (`android/app/google-services.json`):
```bash
# Descargar desde Firebase Console
# Project Settings > General > Your apps > Download google-services.json
```

**iOS** (`ios/Runner/GoogleService-Info.plist`):
```bash
# Descargar desde Firebase Console
# Project Settings > General > Your apps > Download GoogleService-Info.plist
```

### 4. Ejecutar App

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

---

## ?? Implementación Rápida

### Paso 1: Configurar API Client (10 min)

```dart
// lib/services/api_client.dart
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  late Dio _dio;
  static const baseUrl = 'https://api.adopets.com/api';
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    // Agregar logger en desarrollo
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));
  }
  
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }
  
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }
  
  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }
  
  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
```

### Paso 2: Configurar Autenticación (15 min)

```dart
// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // Stream de estado de autenticación
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  
  // Usuario actual
  User? get currentUser => _firebaseAuth.currentUser;
  
  // Login con Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // 1. Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Login cancelado por el usuario');
      }
      
      // 2. Obtener autenticación de Google
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      // 3. Crear credencial de Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // 4. Sign in con Firebase
      final userCredential = 
          await _firebaseAuth.signInWithCredential(credential);
      
      // 5. Obtener Firebase ID Token
      final String? firebaseIdToken = 
          await userCredential.user?.getIdToken();
      
      if (firebaseIdToken == null) {
        throw Exception('No se pudo obtener token de Firebase');
      }
      
      // 6. Intercambiar por JWT del backend
      final response = await _apiClient.post('/v1/auth/firebase', data: {
        'idToken': firebaseIdToken,
        'deviceInfo': 'Flutter ${Platform.operatingSystem}',
      });
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final accessToken = data['accessToken'] as String;
        
        // 7. Guardar token
        await _storage.write(key: 'access_token', value: accessToken);
        _apiClient.setAuthToken(accessToken);
        
        return data;
      }
      
      throw Exception('Error al autenticar con el backend');
      
    } catch (e) {
      print('Error en signInWithGoogle: $e');
      rethrow;
    }
  }
  
  // Cargar token guardado
  Future<bool> loadSavedToken() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        _apiClient.setAuthToken(token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Cerrar sesión
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    await _storage.delete(key: 'access_token');
  }
  
  // Renovar token
  Future<String?> refreshToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      
      final newToken = await user.getIdToken(true);
      
      if (newToken != null) {
        final response = await _apiClient.post('/v1/auth/firebase', data: {
          'idToken': newToken,
        });
        
        if (response.statusCode == 200) {
          final accessToken = response.data['data']['accessToken'] as String;
          await _storage.write(key: 'access_token', value: accessToken);
          _apiClient.setAuthToken(accessToken);
          return accessToken;
        }
      }
      
      return null;
    } catch (e) {
      print('Error al renovar token: $e');
      return null;
    }
  }
}
```

### Paso 3: Crear Pantalla de Login (10 min)

```dart
// lib/screens/login_screen.dart
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    
    try {
      final userData = await _authService.signInWithGoogle();
      
      // Login exitoso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido ${userData['usuario']['nombreCompleto']}!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navegar a home
      Navigator.pushReplacementNamed(context, '/home');
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[400]!, Colors.blue[800]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Icon(
                  Icons.pets,
                  size: 120,
                  color: Colors.white,
                ),
                SizedBox(height: 24),
                
                // Título
                Text(
                  'AdoPets',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                
                // Subtítulo
                Text(
                  'Tu veterinaria de confianza',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 80),
                
                // Botón de Google Sign-In
                _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton.icon(
                        onPressed: _handleGoogleSignIn,
                        icon: Image.asset(
                          'assets/google_logo.png',
                          height: 24,
                        ),
                        label: Text(
                          'Continuar con Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.grey[800],
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### Paso 4: Servicios de Dominio (15 min)

```dart
// lib/services/mascota_service.dart
class MascotaService {
  final ApiClient _api;
  
  MascotaService(this._api);
  
  Future<List<Mascota>> obtenerMisMascotas() async {
    final response = await _api.get('/mismascotas');
    return (response.data['data'] as List)
        .map((json) => Mascota.fromJson(json))
        .toList();
  }
  
  Future<Mascota> registrarMascota(CreateMascotaDto dto) async {
    final response = await _api.post('/mismascotas', data: dto.toJson());
    return Mascota.fromJson(response.data['data']);
  }
}

// lib/services/solicitud_service.dart
class SolicitudService {
  final ApiClient _api;
  
  SolicitudService(this._api);
  
  Future<Solicitud> crearSolicitud(CreateSolicitudDto dto) async {
    final response = await _api.post(
      '/solicitudescitasdigitales',
      data: dto.toJson(),
    );
    return Solicitud.fromJson(response.data['data']);
  }
  
  Future<List<Solicitud>> obtenerMisSolicitudes(String usuarioId) async {
    final response = await _api.get(
      '/solicitudescitasdigitales/usuario/$usuarioId',
    );
    return (response.data['data'] as List)
        .map((json) => Solicitud.fromJson(json))
        .toList();
  }
}

// lib/services/pago_service.dart
class PagoService {
  final ApiClient _api;
  
  PagoService(this._api);
  
  Future<OrdenPayPal> crearOrdenPayPal(CreatePagoDto dto) async {
    final response = await _api.post(
      '/pagos/paypal/create-order',
      data: dto.toJson(),
    );
    return OrdenPayPal.fromJson(response.data['data']);
  }
  
  Future<Pago> capturarPago(String orderId) async {
    final response = await _api.post(
      '/pagos/paypal/capture',
      data: {'orderId': orderId},
    );
    return Pago.fromJson(response.data['data']);
  }
}
```

### Paso 5: Flujo Completo de Cita (20 min)

```dart
// lib/screens/solicitud_cita_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SolicitudCitaScreen extends StatefulWidget {
  @override
  _SolicitudCitaScreenState createState() => _SolicitudCitaScreenState();
}

class _SolicitudCitaScreenState extends State<SolicitudCitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final MascotaService _mascotaService = MascotaService(ApiClient());
  final SolicitudService _solicitudService = SolicitudService(ApiClient());
  final PagoService _pagoService = PagoService(ApiClient());
  
  List<Mascota> _mascotas = [];
  Mascota? _mascotaSeleccionada;
  DateTime _fechaSeleccionada = DateTime.now().add(Duration(days: 7));
  TimeOfDay _horaSeleccionada = TimeOfDay(hour: 10, minute: 0);
  String _motivoConsulta = '';
  bool _isLoading = false;
  String? _paypalUrl;
  String? _currentOrderId;
  
  @override
  void initState() {
    super.initState();
    _cargarMascotas();
  }
  
  Future<void> _cargarMascotas() async {
    setState(() => _isLoading = true);
    try {
      final mascotas = await _mascotaService.obtenerMisMascotas();
      setState(() {
        _mascotas = mascotas;
        _mascotaSeleccionada = mascotas.isNotEmpty ? mascotas.first : null;
      });
    } catch (e) {
      _mostrarError('Error al cargar mascotas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _crearSolicitudYPagar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_mascotaSeleccionada == null) {
      _mostrarError('Selecciona una mascota');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // 1. Crear solicitud
      final fechaHora = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day,
        _horaSeleccionada.hour,
        _horaSeleccionada.minute,
      );
      
      final solicitud = await _solicitudService.crearSolicitud(
        CreateSolicitudDto(
          mascotaId: _mascotaSeleccionada!.id,
          nombreMascota: _mascotaSeleccionada!.nombre,
          especieMascota: _mascotaSeleccionada!.especie,
          razaMascota: _mascotaSeleccionada!.raza,
          servicioId: 'servicio-id', // Obtener de lista
          descripcionServicio: 'Consulta General',
          motivoConsulta: _motivoConsulta,
          fechaHoraSolicitada: fechaHora.toIso8601String(),
          duracionEstimadaMin: 60,
          costoEstimado: 1218.00,
        ),
      );
      
      // 2. Confirmar pago
      final confirmar = await _mostrarDialogoConfirmacion(
        '¿Deseas pagar el anticipo ahora?\n\n'
        'Total: \$${solicitud.costoEstimado.toStringAsFixed(2)}\n'
        'Anticipo (50%): \$${solicitud.montoAnticipo.toStringAsFixed(2)}',
      );
      
      if (!confirmar) {
        _mostrarExito('Solicitud creada. Paga después desde "Mis Citas"');
        Navigator.pop(context);
        return;
      }
      
      // 3. Crear orden de PayPal
      final orden = await _pagoService.crearOrdenPayPal(
        CreatePagoDto(
          solicitudCitaId: solicitud.id,
          monto: solicitud.montoAnticipo,
          conceptoPago: 'Anticipo 50% - ${solicitud.descripcionServicio}',
          montoTotal: solicitud.costoEstimado,
        ),
      );
      
      // 4. Mostrar WebView de PayPal
      setState(() {
        _paypalUrl = orden.approvalUrl;
        _currentOrderId = orden.orderId;
      });
      
    } catch (e) {
      _mostrarError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _handlePayPalNavigation(String url) async {
    if (url.contains('payment/success')) {
      // Extraer orderId de la URL
      final uri = Uri.parse(url);
      final token = uri.queryParameters['token'];
      
      if (token != null || _currentOrderId != null) {
        setState(() => _isLoading = true);
        
        try {
          // Capturar pago
          await _pagoService.capturarPago(_currentOrderId ?? token!);
          
          setState(() {
            _paypalUrl = null;
            _currentOrderId = null;
          });
          
          _mostrarExito('¡Pago confirmado! Tu solicitud está en revisión');
          Navigator.pop(context);
          
        } catch (e) {
          _mostrarError('Error al confirmar pago: $e');
        } finally {
          setState(() => _isLoading = false);
        }
      }
    } else if (url.contains('payment/cancel')) {
      setState(() {
        _paypalUrl = null;
        _currentOrderId = null;
      });
      _mostrarError('Pago cancelado');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Mostrar WebView de PayPal si hay URL
    if (_paypalUrl != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Pagar con PayPal'),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                _paypalUrl = null;
                _currentOrderId = null;
              });
            },
          ),
        ),
        body: WebView(
          initialUrl: _paypalUrl,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (NavigationRequest request) {
            _handlePayPalNavigation(request.url);
            return NavigationDecision.navigate;
          },
        ),
      );
    }
    
    // Formulario normal
    return Scaffold(
      appBar: AppBar(title: Text('Solicitar Cita')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  // Selector de mascota
                  DropdownButtonFormField<Mascota>(
                    value: _mascotaSeleccionada,
                    decoration: InputDecoration(
                      labelText: 'Mascota',
                      border: OutlineInputBorder(),
                    ),
                    items: _mascotas.map((mascota) {
                      return DropdownMenuItem(
                        value: mascota,
                        child: Text('${mascota.nombre} (${mascota.especie})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _mascotaSeleccionada = value);
                    },
                    validator: (value) =>
                        value == null ? 'Selecciona una mascota' : null,
                  ),
                  SizedBox(height: 16),
                  
                  // Selector de fecha
                  ListTile(
                    title: Text('Fecha'),
                    subtitle: Text(
                      '${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}',
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: _fechaSeleccionada,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 90)),
                      );
                      if (fecha != null) {
                        setState(() => _fechaSeleccionada = fecha);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Selector de hora
                  ListTile(
                    title: Text('Hora'),
                    subtitle: Text(_horaSeleccionada.format(context)),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      final hora = await showTimePicker(
                        context: context,
                        initialTime: _horaSeleccionada,
                      );
                      if (hora != null) {
                        setState(() => _horaSeleccionada = hora);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Motivo de consulta
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Motivo de Consulta',
                      border: OutlineInputBorder(),
                      hintText: 'Describe el motivo de la cita...',
                    ),
                    maxLines: 3,
                    onChanged: (value) => _motivoConsulta = value,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
                  ),
                  SizedBox(height: 24),
                  
                  // Botón de solicitar
                  ElevatedButton(
                    onPressed: _crearSolicitudYPagar,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Solicitar Cita y Pagar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Future<bool> _mostrarDialogoConfirmacion(String mensaje) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }
  
  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
    );
  }
}
```

---

## ? Checklist Final

Antes de deployment:

### Desarrollo
- [x] API Client configurado
- [x] Firebase inicializado
- [x] Google Sign-In configurado
- [x] Deep links configurados
- [x] Servicios de dominio creados
- [x] Pantallas principales creadas

### Testing
- [ ] Login con Google funciona
- [ ] Registro de mascota funciona
- [ ] Crear solicitud funciona
- [ ] Pago con PayPal funciona
- [ ] Deep link returnUrl funciona
- [ ] Manejo de errores implementado

### Producción
- [ ] Cambiar URLs a producción
- [ ] Configurar Firebase producción
- [ ] Configurar PayPal producción
- [ ] Agregar analytics
- [ ] Agregar crash reporting
- [ ] Configurar CI/CD

---

## ?? Recursos

- **[Documentación Completa](./ADOPTER_APPOINTMENT_FLOW.md)**
- **[Troubleshooting](./TROUBLESHOOTING_MOBILE.md)**
- **[API Swagger](https://api.adopets.com/swagger)**
- **[Firebase Console](https://console.firebase.google.com)**
- **[PayPal Developer](https://developer.paypal.com)**

---

*Tiempo estimado de implementación: 60-90 minutos*  
*Nivel de dificultad: Intermedio*

¡Listo para comenzar! ??
