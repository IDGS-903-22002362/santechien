import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_constants.dart';
import '../models/usuario.dart';

/// Servicio para almacenamiento local
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  /// Inicializar SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ==================== TOKENS ====================

  /// Guardar access token (seguro)
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: AppConstants.keyAccessToken, value: token);
  }

  /// Obtener access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.keyAccessToken);
  }

  /// Guardar refresh token (seguro)
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.keyRefreshToken, value: token);
  }

  /// Obtener refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.keyRefreshToken);
  }

  /// Eliminar tokens
  Future<void> deleteTokens() async {
    await _secureStorage.delete(key: AppConstants.keyAccessToken);
    await _secureStorage.delete(key: AppConstants.keyRefreshToken);
  }

  // ==================== USUARIO ====================

  /// Guardar datos del usuario
  Future<void> saveUsuario(Usuario usuario) async {
    await init();
    final jsonString = jsonEncode(usuario.toJson());
    await _prefs!.setString(AppConstants.keyUserData, jsonString);
  }

  /// Obtener datos del usuario
  Future<Usuario?> getUsuario() async {
    await init();
    final jsonString = _prefs!.getString(AppConstants.keyUserData);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Usuario.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Eliminar datos del usuario
  Future<void> deleteUsuario() async {
    await init();
    await _prefs!.remove(AppConstants.keyUserData);
  }

  // ==================== REMEMBER ME ====================

  /// Guardar opción "Recordarme"
  Future<void> saveRememberMe(bool value) async {
    await init();
    await _prefs!.setBool(AppConstants.keyRememberMe, value);
  }

  /// Obtener opción "Recordarme"
  Future<bool> getRememberMe() async {
    await init();
    return _prefs!.getBool(AppConstants.keyRememberMe) ?? false;
  }

  // ==================== LIMPIAR TODO ====================

  /// Limpiar toda la información de sesión
  Future<void> clearAll() async {
    await deleteTokens();
    await deleteUsuario();
    await init();
    await _prefs!.remove(AppConstants.keyRememberMe);
  }

  /// Verificar si hay sesión activa
  Future<bool> hasActiveSession() async {
    final token = await getAccessToken();
    final usuario = await getUsuario();
    return token != null && usuario != null;
  }
}
