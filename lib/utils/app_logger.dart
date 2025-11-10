import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Clase para logging que funciona en debug Y release
class AppLogger {
  static bool enableReleaseLogging = true; // Cambiar a false en producción

  /// Log de información general
  static void info(String message, {String? tag}) {
    _log('ℹ️ INFO', message, tag: tag);
  }

  /// Log de éxito
  static void success(String message, {String? tag}) {
    _log('✅ SUCCESS', message, tag: tag);
  }

  /// Log de advertencia
  static void warning(String message, {String? tag}) {
    _log('⚠️ WARNING', message, tag: tag);
  }

  /// Log de error
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('❌ ERROR', message, tag: tag);
    if (error != null) {
      _log('', '   Error: $error', tag: tag);
    }
    if (stackTrace != null) {
      _log('', '   StackTrace: $stackTrace', tag: tag);
    }
  }

  /// Log de debug (solo en modo debug)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      _log('🔍 DEBUG', message, tag: tag);
    }
  }

  /// Log interno
  static void _log(String level, String message, {String? tag}) {
    final timestamp = DateTime.now().toIso8601String();
    final tagStr = tag != null ? '[$tag]' : '';
    final logMessage = '$timestamp $level $tagStr $message';

    // En debug mode, usar print
    if (kDebugMode) {
      print(logMessage);
    }
    // En release mode, usar developer.log que SÍ aparece en logcat
    else if (enableReleaseLogging) {
      developer.log(
        message,
        name: 'AdoPets${tag != null ? '.$tag' : ''}',
        level: _getLogLevel(level),
        time: DateTime.now(),
      );
    }
  }

  /// Obtener nivel de log para developer.log
  static int _getLogLevel(String level) {
    if (level.contains('ERROR')) return 1000;
    if (level.contains('WARNING')) return 900;
    if (level.contains('INFO')) return 800;
    return 700;
  }
}
