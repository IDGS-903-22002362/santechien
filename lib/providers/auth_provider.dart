import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

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
