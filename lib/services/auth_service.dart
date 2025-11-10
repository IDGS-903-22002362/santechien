import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/auth_response.dart';
import '../models/usuario.dart';
import '../utils/ui_logger.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Servicio de autenticación
class AuthService {
  final _apiService = ApiService();
  final _storageService = StorageService();
  final _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  // GoogleSignIn con configuración para web
  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // ==================== FIREBASE AUTH (MÓVIL Y WEB) ====================

  /// Iniciar sesión con Google
  Future<ApiResponse<AuthResponse>> signInWithGoogle() async {
    try {
      firebase_auth.UserCredential? userCredential;

      if (kIsWeb) {
        // ===== FLUJO PARA WEB =====
        // En web, usamos signInWithPopup
        final googleProvider = firebase_auth.GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // ===== FLUJO PARA MÓVIL (Android/iOS) =====
        // 1. Sign in con Google
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return const ApiResponse<AuthResponse>(
            success: false,
            message: 'Inicio de sesión cancelado',
          );
        }

        // 2. Obtener credenciales de Google
        final googleAuth = await googleUser.authentication;

        // 3. Crear credencial de Firebase
        final credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // 4. Sign in con Firebase
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }

      // 5. Obtener Firebase ID Token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        return const ApiResponse<AuthResponse>(
          success: false,
          message: 'No se pudo obtener el token de Firebase',
        );
      }

      // 6. Intercambiar Firebase token por JWT de AdoPets
      return await _exchangeFirebaseToken(idToken);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        message: _getFirebaseErrorMessage(e.code),
        errors: [e.message ?? e.code],
      );
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Error al iniciar sesión con Google: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  /// Intercambiar Firebase token por JWT de AdoPets
  Future<ApiResponse<AuthResponse>> _exchangeFirebaseToken(
    String idToken,
  ) async {
    final logger = UILogger();

    final msg1 = '🔄 Intercambiando token de Firebase por token de AdoPets...';
    print(msg1);
    logger.info(msg1);

    final msg2 = '   Firebase Token: ${idToken.substring(0, 30)}...';
    print(msg2);
    logger.info(msg2);

    final msg3 = '   Endpoint: ${ApiConfig.baseUrl}${ApiConfig.authFirebase}';
    print(msg3);
    logger.info(msg3);

    final response = await _apiService.post<AuthResponse>(
      ApiConfig.authFirebase,
      body: {'idToken': idToken},
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
      requiresAuth: false,
    );

    print('📦 Respuesta del backend:');
    logger.info('📦 Respuesta del backend:');
    print('   success: ${response.success}');
    logger.info('   success: ${response.success}');
    print('   message: ${response.message}');
    logger.info('   message: ${response.message}');
    print('   data: ${response.data != null ? 'PRESENTE' : 'NULL'}');
    logger.info('   data: ${response.data != null ? 'PRESENTE' : 'NULL'}');

    if (response.success && response.data != null) {
      final msg4 = '✅ Token intercambiado exitosamente';
      print(msg4);
      logger.success(msg4);

      final msg5 = '   Usuario: ${response.data!.usuario.email}';
      print(msg5);
      logger.success(msg5);

      print(
        '   AccessToken length: ${response.data!.accessToken.length} chars',
      );
      logger.success(
        '   AccessToken length: ${response.data!.accessToken.length} chars',
      );

      print(
        '   RefreshToken length: ${response.data!.refreshToken.length} chars',
      );
      logger.success(
        '   RefreshToken length: ${response.data!.refreshToken.length} chars',
      );

      print('   TokenType: ${response.data!.tokenType}');
      logger.success('   TokenType: ${response.data!.tokenType}');

      await _saveSession(response.data!);
    } else {
      final errMsg = '❌ Error al intercambiar token: ${response.message}';
      print(errMsg);
      logger.error(errMsg);

      if (response.errors.isNotEmpty) {
        final errDetail = '   Errores: ${response.errors.join(', ')}';
        print(errDetail);
        logger.error(errDetail);
      }
    }

    return response;
  }

  // ==================== TRADITIONAL AUTH (WEB - NO USADO EN MÓVIL) ====================

  /// Iniciar sesión con email y contraseña (para futuro uso web)
  Future<ApiResponse<AuthResponse>> signInWithEmailPassword({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final response = await _apiService.post<AuthResponse>(
      ApiConfig.authLogin,
      body: {'email': email, 'password': password, 'rememberMe': rememberMe},
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
      requiresAuth: false,
    );

    if (response.success && response.data != null) {
      await _saveSession(response.data!);
      await _storageService.saveRememberMe(rememberMe);
    }

    return response;
  }

  /// Registrar nuevo usuario (para futuro uso web)
  Future<ApiResponse<AuthResponse>> register({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String email,
    required String telefono,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _apiService.post<AuthResponse>(
      ApiConfig.authRegister,
      body: {
        'nombre': nombre,
        'apellidoPaterno': apellidoPaterno,
        'apellidoMaterno': apellidoMaterno,
        'email': email,
        'telefono': telefono,
        'password': password,
        'confirmPassword': confirmPassword,
        'aceptaPoliticas': true,
      },
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
      requiresAuth: false,
    );

    if (response.success && response.data != null) {
      await _saveSession(response.data!);
    }

    return response;
  }

  // ==================== SESSION MANAGEMENT ====================

  /// Guardar sesión
  Future<void> _saveSession(AuthResponse authResponse) async {
    final logger = UILogger();

    final msg1 = '💾 Guardando tokens en storage...';
    print(msg1);
    logger.info(msg1);

    print('   AccessToken: ${authResponse.accessToken.substring(0, 20)}...');
    logger.info(
      '   AccessToken: ${authResponse.accessToken.substring(0, 20)}...',
    );

    print('   RefreshToken: ${authResponse.refreshToken.substring(0, 20)}...');
    logger.info(
      '   RefreshToken: ${authResponse.refreshToken.substring(0, 20)}...',
    );

    await _storageService.saveAccessToken(authResponse.accessToken);
    await _storageService.saveRefreshToken(authResponse.refreshToken);
    await _storageService.saveUsuario(authResponse.usuario);

    final msg2 = '✅ Sesión guardada correctamente';
    print(msg2);
    logger.success(msg2);

    // Verificar que se guardó
    final savedToken = await _storageService.getAccessToken();
    final msg3 =
        '🔍 Verificación - Token guardado: ${savedToken != null ? 'SÍ' : 'NO'}';
    print(msg3);
    if (savedToken != null) {
      logger.success(msg3);
    } else {
      logger.error(msg3);
    }
  }

  /// Obtener usuario actual desde storage
  Future<Usuario?> getCurrentUser() async {
    return await _storageService.getUsuario();
  }

  /// Verificar si hay sesión activa
  Future<bool> isAuthenticated() async {
    return await _storageService.hasActiveSession();
  }

  /// Obtener información del usuario actual desde el servidor
  Future<ApiResponse<Usuario>> getMe() async {
    final response = await _apiService.get<Usuario>(
      ApiConfig.authMe,
      fromJson: (json) => Usuario.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      await _storageService.saveUsuario(response.data!);
    }

    return response;
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      // Cerrar sesión en Firebase
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();

      // Notificar al backend (opcional)
      await _apiService.post(ApiConfig.authLogout, requiresAuth: true);
    } catch (_) {
      // Ignorar errores de logout en backend
    } finally {
      // Limpiar storage local
      await _storageService.clearAll();
    }
  }

  /// Refrescar token
  Future<ApiResponse<AuthResponse>> refreshToken() async {
    final refreshToken = await _storageService.getRefreshToken();
    if (refreshToken == null) {
      return const ApiResponse<AuthResponse>(
        success: false,
        message: 'No hay refresh token',
      );
    }

    final response = await _apiService.post<AuthResponse>(
      ApiConfig.authRefresh,
      body: {'refreshToken': refreshToken},
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
      requiresAuth: false,
    );

    if (response.success && response.data != null) {
      await _saveSession(response.data!);
    }

    return response;
  }

  // ==================== HELPER METHODS ====================

  /// Obtener mensaje de error de Firebase
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con este email usando otro método de inicio de sesión';
      case 'invalid-credential':
        return 'Las credenciales son inválidas';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'user-not-found':
        return 'No se encontró ninguna cuenta con este email';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Este email ya está en uso';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      default:
        return 'Error al autenticar: $code';
    }
  }
}
