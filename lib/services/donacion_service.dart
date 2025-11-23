import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/donacion.dart';
import 'api_service.dart';

/// Servicio para gestión de donaciones con PayPal
class DonacionService {
  final ApiService _apiService = ApiService();

  /// Crear orden de PayPal para donación
  Future<ApiResponse<PayPalDonacionResponse>> crearOrdenPayPal(
    CrearDonacionPayPalRequest request,
  ) async {
    try {
      print('Creando orden de PayPal para donación...');
      print('   Monto: ${request.monto} ${request.moneda}');
      print('   Anónima: ${request.anonima}');

      final response = await _apiService.post<PayPalDonacionResponse>(
        ApiConfig.donacionesPayPalCrear,
        body: request.toJson(),
        fromJson: (data) => PayPalDonacionResponse.fromJson(data),
        requiresAuth: request.usuarioId != null,
      );

      if (response.success) {
        print('Orden de PayPal creada exitosamente');
        print('   Order ID: ${response.data?.orderId}');
        print('   Approval URL: ${response.data?.approvalUrl}');
      } else {
        print('Error al crear orden: ${response.message}');
      }

      return response;
    } catch (e) {
      print('Excepción al crear orden de PayPal: $e');
      return ApiResponse<PayPalDonacionResponse>(
        success: false,
        message: 'Error al crear orden de PayPal',
        errors: [e.toString()],
      );
    }
  }

  /// Capturar pago de PayPal (completar donación)
  Future<ApiResponse<Donacion>> capturarPagoPayPal(
    CapturarPagoPayPalRequest request,
  ) async {
    try {
      print('Capturando pago de PayPal...');
      print('   Order ID: ${request.orderId}');

      final response = await _apiService.post<Donacion>(
        ApiConfig.donacionesPayPalCapturar,
        body: request.toJson(),
        fromJson: (data) => Donacion.fromJson(data),
        requiresAuth: false, // El orderId identifica la donación
      );

      if (response.success) {
        print('Pago capturado exitosamente');
        print('   Donación ID: ${response.data?.id}');
        print('   Monto: ${response.data?.monto} ${response.data?.moneda}');
      } else {
        print('Error al capturar pago: ${response.message}');
      }

      return response;
    } catch (e) {
      print('Excepción al capturar pago de PayPal: $e');
      return ApiResponse<Donacion>(
        success: false,
        message: 'Error al capturar pago de PayPal',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener donación por ID
  Future<ApiResponse<Donacion>> obtenerDonacionPorId(String donacionId) async {
    try {
      print('Obteniendo donación por ID: $donacionId');

      final response = await _apiService.get<Donacion>(
        ApiConfig.donacionById(donacionId),
        fromJson: (data) => Donacion.fromJson(data),
        requiresAuth: true,
      );

      if (response.success) {
        print('Donación obtenida exitosamente');
      } else {
        print('Error al obtener donación: ${response.message}');
      }

      return response;
    } catch (e) {
      print('Excepción al obtener donación: $e');
      return ApiResponse<Donacion>(
        success: false,
        message: 'Error al obtener la donación',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener mis donaciones (del usuario autenticado)
  Future<ApiResponse<List<Donacion>>> obtenerMisDonaciones(
    String usuarioId,
  ) async {
    try {
      print('Obteniendo mis donaciones...');
      print('   Usuario ID: $usuarioId');

      // Usar el método obtenerDonacionesPorUsuario que ya funciona
      return await obtenerDonacionesPorUsuario(usuarioId);
    } catch (e) {
      print('Excepción al obtener mis donaciones: $e');
      return ApiResponse<List<Donacion>>(
        success: false,
        message: 'Error al obtener tus donaciones',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener donaciones de un usuario específico
  Future<ApiResponse<List<Donacion>>> obtenerDonacionesPorUsuario(
    String usuarioId,
  ) async {
    try {
      print('Obteniendo donaciones del usuario: $usuarioId');

      final response = await _apiService.getList<List<Donacion>>(
        ApiConfig.donacionesByUsuario(usuarioId),
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => Donacion.fromJson(item)).toList();
          }
          return <Donacion>[];
        },
        requiresAuth: true,
      );

      if (response.success) {
        final count = response.data?.length ?? 0;
        print('Donaciones del usuario obtenidas: $count');
      } else {
        print('Error al obtener donaciones del usuario: ${response.message}');
      }

      return response;
    } catch (e) {
      print('Excepción al obtener donaciones del usuario: $e');
      return ApiResponse<List<Donacion>>(
        success: false,
        message: 'Error al obtener las donaciones del usuario',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener donaciones públicas (no anónimas)
  Future<ApiResponse<List<Donacion>>> obtenerDonacionesPublicas({
    int? limit,
  }) async {
    try {
      print('Obteniendo donaciones públicas...');

      final endpoint = limit != null
          ? '${ApiConfig.donacionesPublicas}?limit=$limit'
          : ApiConfig.donacionesPublicas;

      final response = await _apiService.getList<List<Donacion>>(
        endpoint,
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => Donacion.fromJson(item)).toList();
          }
          return <Donacion>[];
        },
        requiresAuth: false,
      );

      if (response.success) {
        final count = response.data?.length ?? 0;
        print('Donaciones públicas obtenidas: $count');
      } else {
        print('Error al obtener donaciones públicas: ${response.message}');
      }

      return response;
    } catch (e) {
      print('Excepción al obtener donaciones públicas: $e');
      return ApiResponse<List<Donacion>>(
        success: false,
        message: 'Error al obtener las donaciones públicas',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener donación por PayPal Order ID
  Future<ApiResponse<Donacion>> obtenerDonacionPorPayPalOrderId(
    String orderId,
  ) async {
    try {
      print('Obteniendo donación por PayPal Order ID: $orderId');

      final response = await _apiService.get<Donacion>(
        ApiConfig.donacionByPayPalOrderId(orderId),
        fromJson: (data) => Donacion.fromJson(data),
        requiresAuth: false,
      );

      if (response.success) {
        print('Donación obtenida exitosamente');
      } else {
        print('Error al obtener donación: ${response.message}');
      }

      return response;
    } catch (e) {
      print('Excepción al obtener donación por OrderId: $e');
      return ApiResponse<Donacion>(
        success: false,
        message: 'Error al obtener la donación',
        errors: [e.toString()],
      );
    }
  }

  /// Cancelar donación
  Future<ApiResponse<Donacion>> cancelarDonacion(
    String donacionId,
    String motivo,
  ) async {
    try {
      print('Cancelando donación: $donacionId');
      print('   Motivo: $motivo');

      final response = await _apiService.put<Donacion>(
        ApiConfig.donacionCancelar(donacionId),
        body: {'motivo': motivo},
        fromJson: (data) => Donacion.fromJson(data),
        requiresAuth: true,
      );

      if (response.success) {
        print('Donación cancelada exitosamente');
      } else {
        print('Error al cancelar donación: ${response.message}');
      }

      return response;
    } catch (e) {
      print('Excepción al cancelar donación: $e');
      return ApiResponse<Donacion>(
        success: false,
        message: 'Error al cancelar la donación',
        errors: [e.toString()],
      );
    }
  }

  /// Crear donación básica (sin PayPal)
  Future<ApiResponse<Donacion>> crearDonacion(
    CrearDonacionRequest request,
  ) async {
    try {
      print('Creando donación básica...');
      print('   Monto: ${request.monto} ${request.moneda}');

      final response = await _apiService.post<Donacion>(
        ApiConfig.donaciones,
        body: request.toJson(),
        fromJson: (data) => Donacion.fromJson(data),
        requiresAuth: request.usuarioId != null,
      );

      if (response.success) {
        print('Donación creada exitosamente');
        print('   Donación ID: ${response.data?.id}');
      } else {
        print('Error al crear donación: ${response.message}');
      }

      return response;
    } catch (e) {
      print('Excepción al crear donación: $e');
      return ApiResponse<Donacion>(
        success: false,
        message: 'Error al crear la donación',
        errors: [e.toString()],
      );
    }
  }
}
