/// Constantes de la aplicación
class AppConstants {
  // Información de la app
  static const String appName = 'AdoPets';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyRememberMe = 'remember_me';

  // Validación
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;

  // Mensajes
  static const String msgNetworkError = 'No se pudo conectar con el servidor. Verifica tu conexión.';
  static const String msgUnknownError = 'Ocurrió un error inesperado. Por favor, intenta de nuevo.';
  static const String msgSessionExpired = 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
  static const String msgUnauthorized = 'No tienes permisos para realizar esta acción.';

  // Regex patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
  );

  static final RegExp phoneRegex = RegExp(
    r'^[0-9]{10,15}$',
  );
}
