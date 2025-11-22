import 'package:flutter/foundation.dart';
import '../models/mascota.dart';
import '../services/mascota_service.dart';
import '../config/api_config.dart';

/// Provider para gestión de mascotas disponibles
class MascotaProvider with ChangeNotifier {
  final MascotaService _mascotaService = MascotaService();

  // Estado privado
  List<Mascota> _mascotasDisponibles = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters públicos
  List<Mascota> get mascotasDisponibles => _mascotasDisponibles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Cargar mascotas (por defecto solo disponibles)
  Future<void> cargarMascotasDisponibles({
    Map<String, String>? filtros,
    bool soloDisponibles = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _mascotaService.obtenerMascotasDisponibles(
        filtros: filtros,
        soloDisponibles: soloDisponibles,
      );

      if (response.success && response.data != null) {
        _mascotasDisponibles = response.data!;
        _errorMessage = null;
      } else {
        _mascotasDisponibles = [];
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _mascotasDisponibles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener primera foto de una mascota (o placeholder)
  /// Normaliza URLs que apunten a localhost para que funcionen desde el emulador.
  String obtenerFotoPrincipal(Mascota mascota) {
    // Primero intenta con la lista de fotos
    String? fotoUrl;
    if (mascota.fotos != null && mascota.fotos!.isNotEmpty) {
      // Preferir la foto marcada como principal
      try {
        final principal = mascota.fotos!.firstWhere(
          (f) => (f as dynamic).esPrincipal == true,
          orElse: () => mascota.fotos!.first,
        );
        fotoUrl = (principal as dynamic).storageKey as String?;
      } catch (_) {
        fotoUrl = mascota.fotos!.first.storageKey;
      }
    }

    // Luego intenta con el campo foto individual
    if ((fotoUrl == null || fotoUrl.isEmpty) &&
        mascota.foto != null &&
        mascota.foto!.isNotEmpty) {
      fotoUrl = mascota.foto!;
    }

    if (fotoUrl == null || fotoUrl.isEmpty) {
      return '';
    }

    // Normalizar hosts que apuntan a localhost (no accesibles desde emulador)
    try {
      final baseOrigin = Uri.parse(
        ApiConfig.baseUrl,
      ).origin; // e.g. http://10.0.2.2:5151

      if (fotoUrl.startsWith('http://localhost') ||
          fotoUrl.startsWith('https://localhost')) {
        fotoUrl = fotoUrl.replaceFirst(
          RegExp(r'^https?://localhost(:\d+)?'),
          baseOrigin,
        );
      }

      if (fotoUrl.startsWith('http://127.0.0.1') ||
          fotoUrl.startsWith('https://127.0.0.1')) {
        fotoUrl = fotoUrl.replaceFirst(
          RegExp(r'^https?://127\.0\.0\.1(:\d+)?'),
          baseOrigin,
        );
      }
    } catch (e) {
      print('⚠️ Error al normalizar URL de foto: $e');
    }

    return fotoUrl ?? '';
  }
}
