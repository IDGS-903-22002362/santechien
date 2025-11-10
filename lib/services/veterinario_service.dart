import '../models/api_response.dart';
import '../models/veterinario.dart';
import 'api_service.dart';

/// Servicio para gestión de veterinarios
class VeterinarioService {
  final ApiService _apiService = ApiService();

  /// Endpoints
  static const String _basePath = '/Veterinarios';

  /// Obtener todos los veterinarios activos
  Future<ApiResponse<List<Veterinario>>> obtenerVeterinariosActivos() async {
    try {
      final response = await _apiService.get<List<Veterinario>>(
        '$_basePath/activos',
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => Veterinario.fromJson(item)).toList();
          }
          return <Veterinario>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<Veterinario>>(
        success: false,
        message: 'Error al obtener veterinarios',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener veterinario por ID
  Future<ApiResponse<Veterinario>> obtenerVeterinarioPorId(
    String veterinarioId,
  ) async {
    try {
      final response = await _apiService.get<Veterinario>(
        '$_basePath/$veterinarioId',
        fromJson: (data) => Veterinario.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Veterinario>(
        success: false,
        message: 'Error al obtener el veterinario',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener todos los veterinarios
  Future<ApiResponse<List<Veterinario>>> obtenerTodosLosVeterinarios() async {
    try {
      final response = await _apiService.get<List<Veterinario>>(
        _basePath,
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => Veterinario.fromJson(item)).toList();
          }
          return <Veterinario>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<Veterinario>>(
        success: false,
        message: 'Error al obtener veterinarios',
        errors: [e.toString()],
      );
    }
  }
}
