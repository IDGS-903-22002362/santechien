import 'package:adopets_app/models/api_response.dart';
import 'package:adopets_app/models/solicitud_adopcion.dart';
import 'package:adopets_app/models/solicitud_adopcion_response.dart';
import 'package:adopets_app/services/api_service.dart';

class AdopcionService {
  final ApiService _apiService = ApiService();

  // Endpoint para crear solicitud
  static const String _basePath = '/Adopcion/crear-solicitud';

  /// ================================
  /// CREAR SOLICITUD DE ADOPCIÓN
  /// ================================
  Future<ApiResponse<dynamic>> crearSolicitud(Adopcion adopcion) async {
    print('📤 Enviando solicitud de adopción...');
    print('   Datos enviados: ${adopcion.toJson()}');

    final response = await _apiService.post(
      _basePath,
      body: adopcion.toJson(),
      fromJson: (json) => json,
      requiresAuth: true,
    );

    print('🔍 message=${response.message}');

    if (response.success == null) {
      print("⚠️ Backend devolvió 'success: null'. Ajustando respuesta...");

      return ApiResponse(
        success: true,
        message: response.message ?? "Solicitud enviada",
      );
    }

    return response;
  }

  /// ================================
  /// OBTENER MIS SOLICITUDES
  /// ================================
  Future<ApiResponse<List<SolicitudAdopcionResponse>>> obtenerMisSolicitudes(
    String usuarioId,
  ) async {
    final path = "/Adopcion/Solicitud/$usuarioId";

    print("📡 GET List -> $path");

    // Usamos getList en lugar de get
    final response = await _apiService.getList<List<SolicitudAdopcionResponse>>(
      path,
      fromJson: (json) {
        print("📦 Parseando lista de solicitudes...");
        // json aquí es List<dynamic>
        return (json as List)
            .map((item) => SolicitudAdopcionResponse.fromJson(item))
            .toList();
      },
      requiresAuth: true,
    );

    return ApiResponse(
      success: response.success,
      message: response.message,
      data: response.data,
    );
  }
}
