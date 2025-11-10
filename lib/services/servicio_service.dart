import '../models/api_response.dart';
import '../models/solicitud_cita.dart';
import 'api_service.dart';

/// Servicio para gestión de servicios veterinarios
/// Incluye endpoints públicos y administrativos
class ServicioService {
  final ApiService _apiService = ApiService();

  /// Endpoint base
  static const String _basePath = '/Servicios';

  /// ========================================
  /// ENDPOINTS PÚBLICOS (No requieren Auth)
  /// ========================================

  /// Obtener servicios activos (público)
  /// GET /api/v1/Servicios
  /// Permisos: Público (AllowAnonymous)
  Future<ApiResponse<List<Servicio>>> obtenerServiciosActivos() async {
    try {
      final response = await _apiService.get<List<Servicio>>(
        _basePath,
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
        message: 'Error al obtener servicios activos',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener servicio por ID (público)
  /// GET /api/v1/Servicios/{id}
  /// Permisos: Público (AllowAnonymous)
  Future<ApiResponse<Servicio>> obtenerServicioPorId(String servicioId) async {
    try {
      final response = await _apiService.get<Servicio>(
        '$_basePath/$servicioId',
        requiresAuth: false, // ✅ Endpoint público
        fromJson: (data) => Servicio.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Servicio>(
        success: false,
        message: 'Error al obtener el servicio',
        errors: [e.toString()],
      );
    }
  }

  /// ========================================
  /// ENDPOINTS ADMINISTRATIVOS (Requieren Auth + Role Admin)
  /// ========================================

  /// Obtener todos los servicios (incluyendo inactivos)
  /// GET /api/v1/Servicios/todos
  /// Permisos: Solo Admin
  Future<ApiResponse<List<Servicio>>> obtenerTodosLosServicios() async {
    try {
      final response = await _apiService.get<List<Servicio>>(
        '$_basePath/todos',
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
        message: 'Error al obtener todos los servicios',
        errors: [e.toString()],
      );
    }
  }

  /// Crear nuevo servicio
  /// POST /api/v1/Servicios
  /// Permisos: Solo Admin
  Future<ApiResponse<Servicio>> crearServicio(
    CrearServicioRequest request,
  ) async {
    try {
      final response = await _apiService.post<Servicio>(
        _basePath,
        body: request.toJson(),
        fromJson: (data) => Servicio.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Servicio>(
        success: false,
        message: 'Error al crear servicio',
        errors: [e.toString()],
      );
    }
  }

  /// Actualizar servicio existente
  /// PUT /api/v1/Servicios/{id}
  /// Permisos: Solo Admin
  Future<ApiResponse<Servicio>> actualizarServicio({
    required String servicioId,
    required ActualizarServicioRequest request,
  }) async {
    try {
      final response = await _apiService.put<Servicio>(
        '$_basePath/$servicioId',
        body: request.toJson(),
        fromJson: (data) => Servicio.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Servicio>(
        success: false,
        message: 'Error al actualizar servicio',
        errors: [e.toString()],
      );
    }
  }

  /// Desactivar servicio (soft delete)
  /// DELETE /api/v1/Servicios/{id}
  /// Permisos: Solo Admin
  Future<ApiResponse<void>> desactivarServicio(String servicioId) async {
    try {
      final response = await _apiService.delete<void>(
        '$_basePath/$servicioId',
        fromJson: (_) => null,
      );

      return response;
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Error al desactivar servicio',
        errors: [e.toString()],
      );
    }
  }

  /// Activar servicio desactivado
  /// PATCH /api/v1/Servicios/{id}/activar
  /// Permisos: Solo Admin
  Future<ApiResponse<Servicio>> activarServicio(String servicioId) async {
    try {
      final response = await _apiService.patch<Servicio>(
        '$_basePath/$servicioId/activar',
        fromJson: (data) => Servicio.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Servicio>(
        success: false,
        message: 'Error al activar servicio',
        errors: [e.toString()],
      );
    }
  }
}

/// Request para crear servicio
class CrearServicioRequest {
  final String descripcion;
  final int categoria;
  final int duracionMinDefault;
  final double precioSugerido;
  final bool activo;

  CrearServicioRequest({
    required this.descripcion,
    required this.categoria,
    required this.duracionMinDefault,
    required this.precioSugerido,
    this.activo = true,
  });

  Map<String, dynamic> toJson() => {
    'descripcion': descripcion,
    'categoria': categoria,
    'duracionMinDefault': duracionMinDefault,
    'precioSugerido': precioSugerido,
    'activo': activo,
  };
}

/// Request para actualizar servicio
class ActualizarServicioRequest {
  final String? descripcion;
  final int? categoria;
  final int? duracionMinDefault;
  final double? precioSugerido;
  final bool? activo;

  ActualizarServicioRequest({
    this.descripcion,
    this.categoria,
    this.duracionMinDefault,
    this.precioSugerido,
    this.activo,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (descripcion != null) map['descripcion'] = descripcion;
    if (categoria != null) map['categoria'] = categoria;
    if (duracionMinDefault != null) {
      map['duracionMinDefault'] = duracionMinDefault;
    }
    if (precioSugerido != null) map['precioSugerido'] = precioSugerido;
    if (activo != null) map['activo'] = activo;
    return map;
  }
}
