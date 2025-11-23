import '../models/api_response.dart';
import '../models/mascota.dart';
import '../models/solicitud_cita.dart';
import 'api_service.dart';

/// Servicio para gestión de mascotas
class MascotaService {
  final ApiService _apiService = ApiService();

  /// Endpoints
  static const String _basePath = '/Mascota';
  static const String _misMascotasPath = '/MisMascotas';

  /// Obtener todas las mascotas del propietario actual
  Future<ApiResponse<List<Mascota>>> obtenerMisMascotas() async {
    try {
      print('🐾 Obteniendo mis mascotas...');
      final response = await _apiService.get<List<Mascota>>(
        _misMascotasPath,
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => Mascota.fromJson(item)).toList();
          }
          return <Mascota>[];
        },
      );

      print(
        '✅ Respuesta de mis mascotas: ${response.success ? 'SUCCESS' : 'FAIL'}',
      );
      return response;
    } catch (e) {
      print('❌ Error al obtener mascotas: $e');
      return ApiResponse<List<Mascota>>(
        success: false,
        message: 'Error al obtener mascotas',
        errors: [e.toString()],
      );
    }
  }

  /// Registrar nueva mascota propia
  Future<ApiResponse<Mascota>> registrarMascota(
    RegistrarMascotaRequest request,
  ) async {
    try {
      print('\n🐾🐾🐾 REGISTRANDO NUEVA MASCOTA 🐾🐾🐾');
      print('   Endpoint: $_misMascotasPath');
      print('   ⚠️ NO SE ESPECIFICA requiresAuth, debe usar DEFAULT = true');
      print('   Request body: ${request.toJson()}');
      print('   Llamando a _apiService.post...\n');

      final response = await _apiService.post<Mascota>(
        _misMascotasPath,
        body: request.toJson(),
        // ⚠️ NOTA: NO se especifica requiresAuth aquí
        // Por lo tanto debe usar el valor por defecto = true
        fromJson: (data) {
          print('🔍 Parseando respuesta de mascota...');
          print('   Tipo de data: ${data.runtimeType}');

          if (data == null) {
            print('⚠️ Data es null');
            throw Exception('No se recibió data del servidor');
          }

          try {
            // Convertir a Map si no lo es
            Map<String, dynamic> mascotaJson;

            if (data is Map<String, dynamic>) {
              mascotaJson = data;
            } else if (data is Map) {
              mascotaJson = Map<String, dynamic>.from(data);
            } else {
              print('❌ Data no es un Map: ${data.runtimeType}');
              throw Exception(
                'Formato de respuesta inválido: ${data.runtimeType}',
              );
            }

            print('   Keys recibidas: ${mascotaJson.keys.join(', ')}');

            // Parsear la mascota
            final mascota = Mascota.fromJson(mascotaJson);
            print('   ✅ Mascota parseada: ${mascota.nombre} (${mascota.id})');

            return mascota;
          } catch (e, stackTrace) {
            print('❌ Error al parsear Mascota: $e');
            print('   Data recibida: $data');
            print('   Stack trace: $stackTrace');
            rethrow;
          }
        },
      );

      print(
        '✅ Respuesta de registro: ${response.success ? 'SUCCESS' : 'FAIL'}',
      );
      if (!response.success) {
        print('❌ Error: ${response.message}');
        print('   Errores: ${response.errors}');
      }

      return response;
    } catch (e, stackTrace) {
      print('❌ Exception en registrarMascota: $e');
      print('   Stack trace: $stackTrace');
      return ApiResponse<Mascota>(
        success: false,
        message: 'Error al registrar mascota',
        errors: [e.toString()],
      );
    }
  }

  /// Agregar fotos a mascota
  Future<ApiResponse<void>> agregarFotos({
    required String mascotaId,
    required List<Map<String, dynamic>> fotos,
  }) async {
    try {
      final response = await _apiService.post<void>(
        '$_misMascotasPath/$mascotaId/fotos',
        body: {'fotos': fotos},
        fromJson: (_) => null,
      );

      return response;
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Error al agregar fotos',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener mascota por ID
  Future<ApiResponse<Mascota>> obtenerMascotaPorId(String mascotaId) async {
    try {
      final response = await _apiService.get<Mascota>(
        '$_basePath/$mascotaId',
        fromJson: (data) => Mascota.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Mascota>(
        success: false,
        message: 'Error al obtener la mascota',
        errors: [e.toString()],
      );
    }
  }

  // En MascotaService, actualiza el método obtenerMascotasDisponibles:

  Future<ApiResponse<List<Mascota>>> obtenerMascotasDisponibles({
    Map<String, String>? filtros,
    bool soloDisponibles = true, // SIEMPRE será true ahora
  }) async {
    try {
      print('🐾 Obteniendo mascotas disponibles...');

      String endpoint = _basePath;

      // Preparar filtros
      Map<String, String> filtrosFinal = filtros ?? {};

      // SIEMPRE filtrar solo mascotas disponibles
      filtrosFinal['estatus'] = '1'; // 1 => disponible
      print('   Filtrando solo mascotas con estatus: 1 (disponible)');

      // Mapear filtros amigables a nombres de campo de la API
      if (filtrosFinal.isNotEmpty) {
        final Map<String, String> filtrosMapeados = {};

        for (var entry in filtrosFinal.entries) {
          switch (entry.key) {
            case 'especie':
              filtrosMapeados['especie'] = entry.value;
              break;
            case 'raza':
              filtrosMapeados['raza'] = entry.value;
              break;
            case 'sexo':
              // Convertir texto a número para la API
              filtrosMapeados['sexo'] = entry.value == 'Macho' ? '1' : '2';
              break;
            case 'edad':
              // Usar el valor numérico directamente (1, 2, 3, etc.)
              filtrosMapeados['edadEnAnios'] = entry.value;
              break;
            default:
              filtrosMapeados[entry.key] = entry.value;
          }
        }

        final queryParams = filtrosMapeados.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint = '$endpoint?$queryParams';
        print('   Filtros finales: $filtrosMapeados');
      }

      final response = await _apiService.getList<List<Mascota>>(
        endpoint,
        fromJson: (data) {
          if (data is List) {
            return data.map((item) {
              if (item is Map<String, dynamic>) {
                return Mascota.fromJson(item);
              } else if (item is Map) {
                return Mascota.fromJson(Map<String, dynamic>.from(item));
              } else {
                throw Exception('Formato de elemento inválido');
              }
            }).toList();
          } else {
            return <Mascota>[];
          }
        },
        requiresAuth: true,
      );

      print('✅ Mascotas disponibles obtenidas: ${response.data?.length ?? 0}');
      return response;
    } catch (e) {
      print('❌ Error al obtener mascotas disponibles: $e');
      return ApiResponse<List<Mascota>>(
        success: false,
        message: 'Error al obtener mascotas disponibles',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener mascota por ID
  Future<ApiResponse<Mascota>> obtenerMascotasPorId(String id) async {
    try {
      final response = await _apiService.get<Mascota>(
        '$_basePath/$id',
        fromJson: (data) {
          if (data is Map<String, dynamic>) {
            return Mascota.fromJson(data);
          }

          // Si la respuesta no es un mapa, lanzar error
          throw Exception('Formato de respuesta inválido: ${data.runtimeType}');
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<Mascota>(
        success: false,
        message: 'Error al obtener la mascota',
        errors: [e.toString()],
      );
    }
  }
}
