/// Configuración de la API
class ApiConfig {
  // URL base de la API
  static const String baseUrl =
      'http://192.168.129.51:5151/api/v1'; // Dispositivo físico Android
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
