/// Configuración de la API
class ApiConfig {
  // URL base de la API
  static const String baseUrl =
      'https://adopetsbkd20251124143834-b0abacgfbsd5fbdz.canadacentral-01.azurewebsites.net/api/v1'; // Dispositivo físico Android
  // static const String baseUrl = 'http://10.0.2.2:5151/api/v1'; // Android Emulator
  // static const String baseUrl = 'http://localhost:5151/api/v1'; // iOS Simulator
  // static const String baseUrl = 'https://tu-api.com/api/v1'; // Producción

  // Timeout
  static const Duration timeout = Duration(seconds: 30);

  // Endpoints de autenticación
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authFirebase = '/auth/firebase';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';
  static const String authRefresh = '/auth/refresh';
  static const String authChangePassword = '/auth/change-password';

  // Endpoints de usuarios
  static const String usuarios = '/usuarios';
  static String usuarioById(String id) => '/usuarios/$id';
  static String usuarioActivate(String id) => '/usuarios/$id/activate';
  static String usuarioDeactivate(String id) => '/usuarios/$id/deactivate';
  static String usuarioRoles(String id) => '/usuarios/$id/roles';

  // Endpoints de mascotas personales
  static const String misMascotas = '/MisMascotas';
  static String miMascotaById(String id) => '/MisMascotas/$id';

  // Endpoints de donaciones
  static const String donaciones = '/Donaciones';
  static const String donacionesPayPalCrear = '/Donaciones/paypal/create-order';
  static const String donacionesPayPalCapturar = '/Donaciones/paypal/capture';
  static String donacionById(String id) => '/Donaciones/$id';
  static String donacionByPayPalOrderId(String orderId) =>
      '/Donaciones/paypal/$orderId';
  static String donacionesByUsuario(String usuarioId) =>
      '/Donaciones/usuario/$usuarioId';
  static String donacionCancelar(String id) => '/Donaciones/$id/cancelar';
  static const String donacionesPublicas = '/Donaciones/publicas';
  static const String donacionesWebhookPayPal = '/Donaciones/webhook/paypal';

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}
