import '../models/api_response.dart';
import '../models/pago.dart';
import 'api_service.dart';

/// Servicio para gestión de pagos con PayPal
class PagoService {
  final ApiService _apiService = ApiService();

  /// Endpoints
  static const String _basePath = '/Pagos';

  /// Crear orden de PayPal
  Future<ApiResponse<PayPalOrderResponse>> crearOrdenPayPal(
    CrearOrdenPayPalRequest request,
  ) async {
    try {
      final response = await _apiService.post<PayPalOrderResponse>(
        '$_basePath/paypal/create-order',
        body: request.toJson(),
        fromJson: (data) => PayPalOrderResponse.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<PayPalOrderResponse>(
        success: false,
        message: 'Error al crear orden de PayPal',
        errors: [e.toString()],
      );
    }
  }

  /// Capturar pago de PayPal
  Future<ApiResponse<Pago>> capturarPagoPayPal(
    CapturarPagoPayPalRequest request,
  ) async {
    try {
      final response = await _apiService.post<Pago>(
        '$_basePath/paypal/capture',
        body: request.toJson(),
        fromJson: (data) => Pago.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Pago>(
        success: false,
        message: 'Error al capturar pago de PayPal',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener pago por ID
  Future<ApiResponse<Pago>> obtenerPagoPorId(String pagoId) async {
    try {
      final response = await _apiService.get<Pago>(
        '$_basePath/$pagoId',
        fromJson: (data) => Pago.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Pago>(
        success: false,
        message: 'Error al obtener el pago',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener pagos por usuario
  Future<ApiResponse<List<Pago>>> obtenerPagosPorUsuario(
    String usuarioId,
  ) async {
    try {
      final response = await _apiService.get<List<Pago>>(
        '$_basePath/usuario/$usuarioId',
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => Pago.fromJson(item)).toList();
          }
          return <Pago>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<Pago>>(
        success: false,
        message: 'Error al obtener pagos del usuario',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener mis pagos
  Future<ApiResponse<List<Pago>>> obtenerMisPagos() async {
    try {
      final response = await _apiService.get<List<Pago>>(
        '$_basePath/usuario/me',
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => Pago.fromJson(item)).toList();
          }
          return <Pago>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<Pago>>(
        success: false,
        message: 'Error al obtener mis pagos',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener pago por PayPal Order ID
  Future<ApiResponse<Pago>> obtenerPagoPorPayPalOrderId(String orderId) async {
    try {
      final response = await _apiService.get<Pago>(
        '$_basePath/paypal/$orderId',
        fromJson: (data) => Pago.fromJson(data),
      );

      return response;
    } catch (e) {
      return ApiResponse<Pago>(
        success: false,
        message: 'Error al obtener el pago de PayPal',
        errors: [e.toString()],
      );
    }
  }
}
