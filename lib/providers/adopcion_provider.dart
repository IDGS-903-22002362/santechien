import 'package:adopets_app/models/solicitud_adopcion_response.dart';
import 'package:flutter/foundation.dart';
import '../models/solicitud_adopcion.dart';
import '../services/adopcion_service.dart';
import '../services/auth_service.dart';

class AdopcionProvider with ChangeNotifier {
  final AdopcionService _adopcionService = AdopcionService();
  final AuthService _authService = AuthService();

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _solicitudEnviada = false;
  bool get solicitudEnviada => _solicitudEnviada;

  dynamic _responseData;
  dynamic get responseData => _responseData;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// Enviar solicitud de adopción con usuarioId incluido
  Future<void> enviarSolicitud(Adopcion solicitud) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      _solicitudEnviada = false;
      _responseData = null;

      // 1️⃣ Obtener usuario actual
      final usuario = await _authService.getCurrentUser();

      if (usuario == null) {
        _errorMessage = "No se encontró el usuario logueado";
        return;
      }

      // 2️⃣ Agregar userId a la solicitud
      solicitud.usuarioId = usuario.id;

      // 3️⃣ Enviar solicitud
      final response = await _adopcionService.crearSolicitud(solicitud);

      if (response.success) {
        _solicitudEnviada = true;
        _responseData = response.data; // 👈 Guardamos la respuesta del backend
      } else {
        _errorMessage = response.message ?? "Error desconocido";
      }
    } catch (e) {
      _errorMessage = "Error: $e";
    } finally {
      _setLoading(false);
    }
  }

  List<SolicitudAdopcionResponse> _misSolicitudes = [];
  List<SolicitudAdopcionResponse> get misSolicitudes => _misSolicitudes;

  Future<void> cargarMisSolicitudes() async {
    try {
      _setLoading(true);

      final usuario = await _authService.getCurrentUser();

      if (usuario == null) {
        _errorMessage = "No se encontró el usuario";
        return;
      }

      final response = await _adopcionService.obtenerMisSolicitudes(usuario.id);

      if (response.success) {
        _misSolicitudes = response.data ?? [];
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = "Error: $e";
    } finally {
      _setLoading(false);
    }
  }
}
