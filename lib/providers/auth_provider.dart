import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../models/api_response.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

/// Estado de autenticación
enum AuthStatus { initial, authenticated, unauthenticated, loading }

/// Provider de autenticación
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  Usuario? _usuario;
  String? _errorMessage;

  AuthStatus get status => _status;
  Usuario? get usuario => _usuario;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  /// Inicializar - Verificar si hay sesión activa
  Future<void> initialize() async {
    try {
      _setStatus(AuthStatus.loading);

      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _usuario = await _authService.getCurrentUser();
        _setStatus(AuthStatus.authenticated);
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  /// Iniciar sesión con Google
  Future<bool> signInWithGoogle() async {
    try {
      _setStatus(AuthStatus.loading);
      _errorMessage = null;

      final response = await _authService.signInWithGoogle();

      if (response.success && response.data != null) {
        _usuario = response.data!.usuario;
        _setStatus(AuthStatus.authenticated);

        // Registrar dispositivo para notificaciones (en segundo plano, sin esperar)
        _registrarDispositivoNotificaciones();

        return true;
      } else {
        _errorMessage = response.message;
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  /// Iniciar sesión con email y contraseña
  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _setStatus(AuthStatus.loading);
      _errorMessage = null;

      final response = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (response.success && response.data != null) {
        _usuario = response.data!.usuario;
        _setStatus(AuthStatus.authenticated);

        // Registrar dispositivo para notificaciones (en segundo plano, sin esperar)
        _registrarDispositivoNotificaciones();

        return true;
      } else {
        _errorMessage = response.message;
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  /// Registrar nuevo usuario
  Future<bool> register({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String email,
    required String telefono,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      _setStatus(AuthStatus.loading);
      _errorMessage = null;

      final response = await _authService.register(
        nombre: nombre,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        email: email,
        telefono: telefono,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (response.success && response.data != null) {
        _usuario = response.data!.usuario;
        _setStatus(AuthStatus.authenticated);

        // Registrar dispositivo para notificaciones (en segundo plano, sin esperar)
        _registrarDispositivoNotificaciones();

        return true;
      } else {
        _errorMessage = response.message;
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  /// Registrar dispositivo para notificaciones push
  /// Este método NO debe bloquear el login si falla
  Future<void> _registrarDispositivoNotificaciones() async {
    try {
      final fcmToken = NotificationService().fcmToken;

      if (fcmToken == null) {
        debugPrint('⚠️ No hay FCM token disponible para registrar');
        return;
      }

      // Determinar plataforma: 2 = Android, 3 = iOS
      final plataforma = Platform.isAndroid ? 2 : 3;

      final apiService = ApiService();

      // Timeout corto para no bloquear el login
      final response = await apiService
          .registrarDispositivo(
            fcmToken: fcmToken,
            plataforma: plataforma,
            appVersion: '1.0.0',
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint(
                '⏱️ Timeout al registrar dispositivo - continuando sin bloquear',
              );
              return ApiResponse(
                success: false,
                message: 'Timeout',
                errors: ['Timeout al registrar dispositivo'],
              );
            },
          );

      if (response.success) {
        debugPrint('✅ Dispositivo registrado en backend');
      } else {
        debugPrint(
          '⚠️ Error al registrar dispositivo (no crítico): ${response.message}',
        );
      }
    } catch (e) {
      // No propagar el error - el registro de dispositivo es opcional
      debugPrint('❌ Error al registrar dispositivo (no crítico): $e');
    }
  }

  /// Actualizar información del usuario
  Future<void> refreshUserInfo() async {
    try {
      final response = await _authService.getMe();
      if (response.success && response.data != null) {
        _usuario = response.data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al actualizar usuario: $e');
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      _setStatus(AuthStatus.loading);
      await _authService.signOut();
      _usuario = null;
      _errorMessage = null;
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
      // Aún así limpiamos la sesión local
      _usuario = null;
      _errorMessage = null;
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  /// Cambiar estado
  void _setStatus(AuthStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
