import 'package:flutter/foundation.dart';
import '../models/donacion.dart';
import '../services/donacion_service.dart';

/// Provider para gestión de estado de donaciones
class DonacionProvider with ChangeNotifier {
  final DonacionService _donacionService = DonacionService();

  List<Donacion> _misDonaciones = [];
  List<Donacion> _donacionesPublicas = [];
  Map<String, dynamic>? _estadisticas;

  bool _isLoading = false;
  bool _isCreatingOrder = false;
  bool _isCapturingPayment = false;
  String? _errorMessage;

  // Orden de PayPal actual
  PayPalDonacionResponse? _currentPayPalOrder;

  List<Donacion> get misDonaciones => _misDonaciones;
  List<Donacion> get donacionesPublicas => _donacionesPublicas;
  Map<String, dynamic>? get estadisticas => _estadisticas;
  bool get isLoading => _isLoading;
  bool get isCreatingOrder => _isCreatingOrder;
  bool get isCapturingPayment => _isCapturingPayment;
  String? get errorMessage => _errorMessage;
  PayPalDonacionResponse? get currentPayPalOrder => _currentPayPalOrder;

  /// Total donado por el usuario
  double get totalDonado {
    return _misDonaciones
        .where((d) => d.isCompleted)
        .fold(0.0, (sum, d) => sum + d.monto);
  }

  /// Número de donaciones completadas
  int get numeroCompletadas {
    return _misDonaciones.where((d) => d.isCompleted).length;
  }

  /// Última donación
  Donacion? get ultimaDonacion {
    if (_misDonaciones.isEmpty) return null;
    return _misDonaciones.first;
  }

  Future<PayPalDonacionResponse?> crearOrdenPayPal({
    required double monto,
    String? usuarioId,
    String moneda = 'MXN',
    String concepto = 'Donación para AdoPets',
    String? mensaje,
    bool anonima = false,
    required String returnUrl,
    required String cancelUrl,
  }) async {
    try {
      _isCreatingOrder = true;
      _errorMessage = null;
      _currentPayPalOrder = null;
      notifyListeners();

      final request = CrearDonacionPayPalRequest(
        usuarioId: usuarioId,
        monto: monto,
        moneda: moneda,
        concepto: concepto,
        mensaje: mensaje,
        anonima: anonima,
        returnUrl: returnUrl,
        cancelUrl: cancelUrl,
      );

      final response = await _donacionService.crearOrdenPayPal(request);

      if (response.success && response.data != null) {
        _currentPayPalOrder = response.data;
        debugPrint('Orden de PayPal creada: ${_currentPayPalOrder!.orderId}');
        _isCreatingOrder = false;
        notifyListeners();
        return _currentPayPalOrder;
      } else {
        _errorMessage = response.message;
        _isCreatingOrder = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error al crear orden: ${e.toString()}';
      _isCreatingOrder = false;
      notifyListeners();
      return null;
    }
  }

  /// Capturar pago de PayPal (completar donación)
  Future<Donacion?> capturarPagoPayPal(String orderId) async {
    try {
      _isCapturingPayment = true;
      _errorMessage = null;
      notifyListeners();

      final request = CapturarPagoPayPalRequest(orderId: orderId);
      final response = await _donacionService.capturarPagoPayPal(request);

      if (response.success && response.data != null) {
        final donacion = response.data!;

        _misDonaciones.insert(0, donacion);

        _currentPayPalOrder = null;

        debugPrint('Pago capturado: ${donacion.id}');
        _isCapturingPayment = false;
        notifyListeners();
        return donacion;
      } else {
        _errorMessage = response.message;
        _isCapturingPayment = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error al capturar pago: ${e.toString()}';
      _isCapturingPayment = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> cargarMisDonaciones(String usuarioId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _donacionService.obtenerMisDonaciones(usuarioId);

      if (response.success && response.data != null) {
        _misDonaciones = response.data!;
        debugPrint('mis donaciones cargadas: ${_misDonaciones.length}');
      } else {
        _errorMessage = response.message;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar donaciones: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarDonacionesPublicas({int? limit}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _donacionService.obtenerDonacionesPublicas(
        limit: limit,
      );

      if (response.success && response.data != null) {
        _donacionesPublicas = response.data!;
        debugPrint(
          'Donaciones públicas cargadas: ${_donacionesPublicas.length}',
        );
      } else {
        _errorMessage = response.message;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar donaciones públicas: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Donacion?> obtenerDonacionPorId(String donacionId) async {
    try {
      final response = await _donacionService.obtenerDonacionPorId(donacionId);

      if (response.success && response.data != null) {
        return response.data;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error al obtener donación: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Refrescar todas las donaciones (requiere usuarioId)
  Future<void> refrescarDonaciones(String usuarioId) async {
    await Future.wait([
      cargarMisDonaciones(usuarioId),
      cargarDonacionesPublicas(limit: 10),
    ]);
  }

  /// Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpiar orden actual
  void clearCurrentOrder() {
    _currentPayPalOrder = null;
    notifyListeners();
  }

  /// Reset completo
  void reset() {
    _misDonaciones = [];
    _donacionesPublicas = [];
    _estadisticas = null;
    _currentPayPalOrder = null;
    _isLoading = false;
    _isCreatingOrder = false;
    _isCapturingPayment = false;
    _errorMessage = null;
    notifyListeners();
  }
}
