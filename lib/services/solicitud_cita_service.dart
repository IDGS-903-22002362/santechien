import '../models/api_response.dart';
import '../models/solicitud_cita.dart';
import 'api_service.dart';

/// Servicio para gestión de solicitudes de citas digitales
class SolicitudCitaService {
  final ApiService _apiService = ApiService();

  /// Endpoints
  static const String _basePath = '/SolicitudesCitasDigitales';
  static const String _serviciosPath =
      '/Servicios'; // ✅ Endpoint público (AllowAnonymous)

  /// Obtener servicios disponibles (activos)
  /// Endpoint: GET /api/v1/Servicios
  /// Permisos: Público (AllowAnonymous) - No requiere autenticación
  Future<ApiResponse<List<Servicio>>> obtenerServicios() async {
    try {
      final response = await _apiService.get<List<Servicio>>(
        _serviciosPath,
        requiresAuth: false, // ✅ Endpoint público
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => Servicio.fromJson(item)).toList();
          }
          return <Servicio>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<Servicio>>(
        success: false,
        message: 'Error al obtener servicios',
        errors: [e.toString()],
      );
    }
  }

  /// Crear solicitud de cita
  Future<ApiResponse<SolicitudCita>> crearSolicitud(
    CrearSolicitudCitaRequest request,
  ) async {
    try {
      final response = await _apiService.post<SolicitudCita>(
        _basePath,
        body: request.toJson(),
        fromJson: (data) => SolicitudCita.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<SolicitudCita>(
        success: false,
        message: 'Error al crear solicitud de cita',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener solicitud por ID (respuesta básica)
  Future<ApiResponse<SolicitudCita>> obtenerSolicitudPorId(
    String solicitudId,
  ) async {
    try {
      final response = await _apiService.get<SolicitudCita>(
        '$_basePath/$solicitudId',
        fromJson: (data) => SolicitudCita.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<SolicitudCita>(
        success: false,
        message: 'Error al obtener la solicitud',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener detalles completos de la solicitud por ID
  /// Incluye información de cita confirmada y pago de anticipo
  /// Endpoint: GET /api/solicitudescitasdigitales/{solicitudId}
  Future<ApiResponse<SolicitudCitaDetallada>> obtenerSolicitudDetalladaPorId(
    String solicitudId,
  ) async {
    try {
      print('🔍 Obteniendo solicitud detallada: $solicitudId');
      final response = await _apiService.get<SolicitudCitaDetallada>(
        '$_basePath/$solicitudId',
        fromJson: (data) {
          print('📦 Response data recibido:');
          print('   keys: ${data.keys}');
          return SolicitudCitaDetallada.fromJson(data);
        },
      );

      print('✅ Solicitud detallada obtenida: ${response.success}');
      return response;
    } catch (e, stackTrace) {
      print('❌ Error al obtener solicitud detallada: $e');
      print('   Stack trace: $stackTrace');
      return ApiResponse<SolicitudCitaDetallada>(
        success: false,
        message: 'Error al obtener los detalles de la solicitud',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener mis solicitudes
  Future<ApiResponse<List<SolicitudCita>>> obtenerMisSolicitudes(
    String usuarioId,
  ) async {
    try {
      final response = await _apiService.get<List<SolicitudCita>>(
        '$_basePath/usuario/$usuarioId',
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => SolicitudCita.fromJson(item)).toList();
          }
          return <SolicitudCita>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<SolicitudCita>>(
        success: false,
        message: 'Error al obtener mis solicitudes',
        errors: [e.toString()],
      );
    }
  }

  /// Verificar disponibilidad antes de crear solicitud
  Future<ApiResponse<Map<String, dynamic>>> verificarDisponibilidad({
    required DateTime fechaHoraInicio,
    required int duracionMin,
    String? veterinarioId,
    String? salaId,
  }) async {
    try {
      final body = {
        'fechaHoraInicio': fechaHoraInicio.toIso8601String(),
        'duracionMin': duracionMin,
        if (veterinarioId != null) 'veterinarioId': veterinarioId,
        if (salaId != null) 'salaId': salaId,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        '$_basePath/verificar-disponibilidad',
        body: body,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error al verificar disponibilidad',
        errors: [e.toString()],
      );
    }
  }

  /// Cancelar solicitud
  Future<ApiResponse<SolicitudCita>> cancelarSolicitud({
    required String solicitudId,
    required String motivo,
  }) async {
    try {
      final response = await _apiService.put<SolicitudCita>(
        '$_basePath/$solicitudId/cancelar',
        body: {'motivo': motivo},
        fromJson: (data) => SolicitudCita.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<SolicitudCita>(
        success: false,
        message: 'Error al cancelar la solicitud',
        errors: [e.toString()],
      );
    }
  }
}
