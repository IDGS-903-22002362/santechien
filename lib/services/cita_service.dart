import '../models/api_response.dart';
import '../models/cita.dart';
import 'api_service.dart';

/// Servicio para gestión de citas
class CitaService {
  final ApiService _apiService = ApiService();

  /// Endpoints
  static const String _basePath = '/Citas';

  /// Obtener todas las citas (endpoint genérico)
  Future<ApiResponse<List<Cita>>> obtenerTodasLasCitas() async {
    try {
      final response = await _apiService.get<List<Cita>>(
        _basePath,
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => Cita.fromJson(item)).toList();
          }
          return <Cita>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<Cita>>(
        success: false,
        message: 'Error al obtener citas',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener citas del propietario actual (usa userId del token JWT)
  /// Nota: El backend debe tener un endpoint que extraiga el userId del token
  Future<ApiResponse<List<Cita>>> obtenerMisCitas() async {
    try {
      // Intenta primero el endpoint específico para "me"
      final response = await _apiService.get<List<Cita>>(
        '$_basePath/propietario/me',
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => Cita.fromJson(item)).toList();
          }
          return <Cita>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<Cita>>(
        success: false,
        message: 'Error al obtener mis citas',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener citas por propietario (requiere propietarioId explícito)
  Future<ApiResponse<List<Cita>>> obtenerCitasPorPropietario(
    String propietarioId,
  ) async {
    try {
      final response = await _apiService.get<List<Cita>>(
        '$_basePath/propietario/$propietarioId',
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => Cita.fromJson(item)).toList();
          }
          return <Cita>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<Cita>>(
        success: false,
        message: 'Error al obtener citas del propietario',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener citas por veterinario
  Future<ApiResponse<List<Cita>>> obtenerCitasPorVeterinario({
    required String veterinarioId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String url = '$_basePath/veterinario/$veterinarioId';

      // Agregar parámetros opcionales de fecha
      if (startDate != null || endDate != null) {
        final params = <String>[];
        if (startDate != null) {
          params.add('startDate=${startDate.toIso8601String()}');
        }
        if (endDate != null) {
          params.add('endDate=${endDate.toIso8601String()}');
        }
        url += '?${params.join('&')}';
      }

      final response = await _apiService.get<List<Cita>>(
        url,
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => Cita.fromJson(item)).toList();
          }
          return <Cita>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<Cita>>(
        success: false,
        message: 'Error al obtener citas del veterinario',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener citas por mascota
  Future<ApiResponse<List<Cita>>> obtenerCitasPorMascota(
    String mascotaId,
  ) async {
    try {
      final response = await _apiService.get<List<Cita>>(
        '$_basePath/mascota/$mascotaId',
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => Cita.fromJson(item)).toList();
          }
          return <Cita>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<Cita>>(
        success: false,
        message: 'Error al obtener citas de la mascota',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener cita por ID
  Future<ApiResponse<Cita>> obtenerCitaPorId(String citaId) async {
    try {
      final response = await _apiService.get<Cita>(
        '$_basePath/$citaId',
        fromJson: (data) => Cita.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Cita>(
        success: false,
        message: 'Error al obtener la cita',
        errors: [e.toString()],
      );
    }
  }

  /// Verificar disponibilidad de horarios
  /// Retorna información completa de horarios disponibles y ocupados
  Future<ApiResponse<DisponibilidadResponse>> verificarDisponibilidad({
    required String veterinarioId,
    required DateTime fecha,
    required int duracionMinutos,
  }) async {
    try {
      final fechaStr = fecha.toIso8601String();
      final queryParams =
          'veterinarioId=$veterinarioId&fecha=$fechaStr&duracionMinutos=$duracionMinutos';

      final response = await _apiService.get<DisponibilidadResponse>(
        '$_basePath/disponibilidad?$queryParams',
        fromJson: (data) => DisponibilidadResponse.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<DisponibilidadResponse>(
        success: false,
        message: 'Error al verificar disponibilidad',
        errors: [e.toString()],
      );
    }
  }

  /// Verificar disponibilidad (método legacy - retorna Map)
  @Deprecated('Usar verificarDisponibilidad en su lugar')
  Future<ApiResponse<Map<String, dynamic>>> verificarDisponibilidadLegacy({
    required String veterinarioId,
    required DateTime fecha,
    required int duracionMinutos,
  }) async {
    try {
      final fechaStr = fecha.toIso8601String();
      final queryParams =
          'veterinarioId=$veterinarioId&fecha=$fechaStr&duracionMinutos=$duracionMinutos';

      final response = await _apiService.get<Map<String, dynamic>>(
        '$_basePath/disponibilidad?$queryParams',
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

  /// Crear nueva cita
  Future<ApiResponse<Cita>> crearCita(CrearCitaRequest request) async {
    try {
      final response = await _apiService.post<Cita>(
        _basePath,
        body: request.toJson(),
        fromJson: (data) => Cita.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Cita>(
        success: false,
        message: 'Error al crear la cita',
        errors: [e.toString()],
      );
    }
  }

  /// Actualizar cita
  Future<ApiResponse<Cita>> actualizarCita({
    required String citaId,
    required Map<String, dynamic> datos,
  }) async {
    try {
      final response = await _apiService.put<Cita>(
        '$_basePath/$citaId',
        body: datos,
        fromJson: (data) => Cita.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Cita>(
        success: false,
        message: 'Error al actualizar la cita',
        errors: [e.toString()],
      );
    }
  }

  /// Cancelar cita
  Future<ApiResponse<Cita>> cancelarCita({
    required String citaId,
    required String motivo,
    String? notas,
  }) async {
    try {
      final response = await _apiService.put<Cita>(
        '$_basePath/$citaId/cancelar',
        body: {'motivo': motivo, if (notas != null) 'notas': notas},
        fromJson: (data) => Cita.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Cita>(
        success: false,
        message: 'Error al cancelar la cita',
        errors: [e.toString()],
      );
    }
  }

  /// Completar cita (solo veterinarios)
  Future<ApiResponse<Cita>> completarCita({
    required String citaId,
    String? diagnostico,
    String? tratamiento,
    DateTime? proximaRevision,
    String? notas,
  }) async {
    try {
      final response = await _apiService.put<Cita>(
        '$_basePath/$citaId/completar',
        body: {
          if (diagnostico != null) 'diagnostico': diagnostico,
          if (tratamiento != null) 'tratamiento': tratamiento,
          if (proximaRevision != null)
            'proximaRevision': proximaRevision.toIso8601String(),
          if (notas != null) 'notas': notas,
        },
        fromJson: (data) => Cita.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Cita>(
        success: false,
        message: 'Error al completar la cita',
        errors: [e.toString()],
      );
    }
  }

  /// Confirmar cita
  /// Cambia el estado de la cita a "Confirmada" (generalmente después del pago)
  Future<ApiResponse<Cita>> confirmarCita({
    required String citaId,
    String? notas,
  }) async {
    try {
      final response = await _apiService.put<Cita>(
        '$_basePath/$citaId/confirmar',
        body: {if (notas != null) 'notas': notas},
        fromJson: (data) => Cita.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Cita>(
        success: false,
        message: 'Error al confirmar la cita',
        errors: [e.toString()],
      );
    }
  }

  /// Reagendar cita
  /// Cambia la fecha/hora de una cita existente
  Future<ApiResponse<Cita>> reagendarCita({
    required String citaId,
    required DateTime nuevaFechaHora,
    int? nuevaDuracionMinutos,
    String? motivo,
    String? notas,
  }) async {
    try {
      final response = await _apiService.put<Cita>(
        '$_basePath/$citaId/reagendar',
        body: {
          'fechaHora': nuevaFechaHora.toIso8601String(),
          if (nuevaDuracionMinutos != null)
            'duracionMinutos': nuevaDuracionMinutos,
          if (motivo != null) 'motivo': motivo,
          if (notas != null) 'notas': notas,
        },
        fromJson: (data) => Cita.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Cita>(
        success: false,
        message: 'Error al reagendar la cita',
        errors: [e.toString()],
      );
    }
  }

  /// Eliminar cita (solo Admin)
  Future<ApiResponse<void>> eliminarCita(String citaId) async {
    try {
      final response = await _apiService.delete<void>(
        '$_basePath/$citaId',
        fromJson: (_) => null,
      );

      return response;
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Error al eliminar la cita',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener citas por rango de fechas
  Future<ApiResponse<List<Cita>>> obtenerCitasPorRango({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startStr = startDate.toIso8601String();
      final endStr = endDate.toIso8601String();
      final queryParams = 'startDate=$startStr&endDate=$endStr';

      final response = await _apiService.get<List<Cita>>(
        '$_basePath/rango?$queryParams',
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => Cita.fromJson(item)).toList();
          }
          return <Cita>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<Cita>>(
        success: false,
        message: 'Error al obtener citas por rango',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener citas por estado
  Future<ApiResponse<List<Cita>>> obtenerCitasPorEstado(
    CitaStatus status,
  ) async {
    try {
      final response = await _apiService.get<List<Cita>>(
        '$_basePath/estado/${status.label}',
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => Cita.fromJson(item)).toList();
          }
          return <Cita>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<Cita>>(
        success: false,
        message: 'Error al obtener citas por estado',
        errors: [e.toString()],
      );
    }
  }
}
