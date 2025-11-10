import 'package:equatable/equatable.dart';

/// Métodos de pago disponibles
enum MetodoPago {
  paypal('PayPal'),
  efectivo('Efectivo'),
  tarjetaCredito('TarjetaCredito'),
  tarjetaDebito('TarjetaDebito'),
  transferencia('Transferencia');

  final String value;
  const MetodoPago(this.value);

  static MetodoPago fromString(String value) {
    switch (value.toLowerCase()) {
      case 'paypal':
        return MetodoPago.paypal;
      case 'efectivo':
        return MetodoPago.efectivo;
      case 'tarjetacredito':
      case 'tarjeta credito':
        return MetodoPago.tarjetaCredito;
      case 'tarjetadebito':
      case 'tarjeta debito':
        return MetodoPago.tarjetaDebito;
      case 'transferencia':
        return MetodoPago.transferencia;
      default:
        return MetodoPago.efectivo;
    }
  }
}

/// Tipos de pago
enum TipoPago {
  anticipo('Anticipo'),
  completo('Completo');

  final String value;
  const TipoPago(this.value);

  static TipoPago fromString(String value) {
    return value.toLowerCase() == 'anticipo'
        ? TipoPago.anticipo
        : TipoPago.completo;
  }
}

/// Estados de pago
enum PagoStatus {
  pendiente('Pendiente'),
  completado('Completado'),
  fallido('Fallido'),
  cancelado('Cancelado'),
  reembolsado('Reembolsado');

  final String value;
  const PagoStatus(this.value);

  static PagoStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pendiente':
        return PagoStatus.pendiente;
      case 'completado':
        return PagoStatus.completado;
      case 'fallido':
        return PagoStatus.fallido;
      case 'cancelado':
        return PagoStatus.cancelado;
      case 'reembolsado':
        return PagoStatus.reembolsado;
      default:
        return PagoStatus.pendiente;
    }
  }
}

/// Modelo de pago
class Pago extends Equatable {
  final String id;
  final String folioPago;
  final DateTime fecha;
  final double monto;
  final MetodoPago metodoPago;
  final TipoPago tipoPago;
  final PagoStatus status;
  final String conceptoPago;
  final String? referencia;
  final String? citaId;
  final String? usuarioId;
  final String? paypalOrderId;
  final String? paypalCaptureId;
  final String? emailPagador;
  final String? nombrePagador;
  final String? notas;
  final DateTime? fechaCancelacion;
  final String? motivoCancelacion;

  const Pago({
    required this.id,
    required this.folioPago,
    required this.fecha,
    required this.monto,
    required this.metodoPago,
    required this.tipoPago,
    required this.status,
    required this.conceptoPago,
    this.referencia,
    this.citaId,
    this.usuarioId,
    this.paypalOrderId,
    this.paypalCaptureId,
    this.emailPagador,
    this.nombrePagador,
    this.notas,
    this.fechaCancelacion,
    this.motivoCancelacion,
  });

  /// Crear desde JSON
  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: json['id'] as String,
      folioPago: json['folioPago'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      monto: (json['monto'] as num).toDouble(),
      metodoPago: MetodoPago.fromString(json['metodoPago'] as String),
      tipoPago: TipoPago.fromString(json['tipoPago'] as String),
      status: PagoStatus.fromString(json['status'] as String),
      conceptoPago: json['conceptoPago'] as String,
      referencia: json['referencia'] as String?,
      citaId: json['citaId'] as String?,
      usuarioId: json['usuarioId'] as String?,
      paypalOrderId: json['paypalOrderId'] as String?,
      paypalCaptureId: json['paypalCaptureId'] as String?,
      emailPagador: json['emailPagador'] as String?,
      nombrePagador: json['nombrePagador'] as String?,
      notas: json['notas'] as String?,
      fechaCancelacion: json['fechaCancelacion'] != null
          ? DateTime.parse(json['fechaCancelacion'] as String)
          : null,
      motivoCancelacion: json['motivoCancelacion'] as String?,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folioPago': folioPago,
      'fecha': fecha.toIso8601String(),
      'monto': monto,
      'metodoPago': metodoPago.value,
      'tipoPago': tipoPago.value,
      'status': status.value,
      'conceptoPago': conceptoPago,
      'referencia': referencia,
      'citaId': citaId,
      'usuarioId': usuarioId,
      'paypalOrderId': paypalOrderId,
      'paypalCaptureId': paypalCaptureId,
      'emailPagador': emailPagador,
      'nombrePagador': nombrePagador,
      'notas': notas,
      'fechaCancelacion': fechaCancelacion?.toIso8601String(),
      'motivoCancelacion': motivoCancelacion,
    };
  }

  @override
  List<Object?> get props => [
    id,
    folioPago,
    fecha,
    monto,
    metodoPago,
    tipoPago,
    status,
    conceptoPago,
    referencia,
    citaId,
    usuarioId,
    paypalOrderId,
    paypalCaptureId,
    emailPagador,
    nombrePagador,
    notas,
    fechaCancelacion,
    motivoCancelacion,
  ];
}

/// Respuesta de creación de orden de PayPal
class PayPalOrderResponse extends Equatable {
  final String orderId;
  final String approvalUrl;
  final String status;
  final String? pagoId;
  final String? folioPago;

  const PayPalOrderResponse({
    required this.orderId,
    required this.approvalUrl,
    required this.status,
    this.pagoId,
    this.folioPago,
  });

  factory PayPalOrderResponse.fromJson(Map<String, dynamic> json) {
    return PayPalOrderResponse(
      orderId: json['orderId'] as String,
      approvalUrl: json['approvalUrl'] as String,
      status: json['status'] as String,
      pagoId: json['pagoId'] as String?,
      folioPago: json['folioPago'] as String?,
    );
  }

  @override
  List<Object?> get props => [orderId, approvalUrl, status, pagoId, folioPago];
}

/// Request para crear orden de PayPal
class CrearOrdenPayPalRequest {
  final String? citaId;
  final double monto;
  final TipoPago tipoPago;
  final String conceptoPago;
  final String? descripcionDetallada;

  const CrearOrdenPayPalRequest({
    this.citaId,
    required this.monto,
    required this.tipoPago,
    required this.conceptoPago,
    this.descripcionDetallada,
  });

  Map<String, dynamic> toJson() {
    return {
      'citaId': citaId,
      'monto': monto,
      'tipoPago': tipoPago.value,
      'conceptoPago': conceptoPago,
      'descripcionDetallada': descripcionDetallada,
    };
  }
}

/// Request para capturar pago de PayPal
class CapturarPagoPayPalRequest {
  final String orderId;

  const CapturarPagoPayPalRequest({required this.orderId});

  Map<String, dynamic> toJson() {
    return {'orderId': orderId};
  }
}
