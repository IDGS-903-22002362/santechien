import 'package:equatable/equatable.dart';

/// Enums para Status de Donación
/// Debe coincidir con el enum del backend: StatusDonacion
enum StatusDonacion {
  pending(0, 'Pendiente'),
  processing(1, 'Procesando'),
  completed(2, 'Completada'),
  cancelled(3, 'Cancelada'),
  failed(4, 'Fallida');

  final int value;
  final String label;
  const StatusDonacion(this.value, this.label);

  static StatusDonacion fromInt(int value) {
    switch (value) {
      case 0:
        return StatusDonacion.pending;
      case 1:
        return StatusDonacion.processing;
      case 2:
        return StatusDonacion.completed;
      case 3:
        return StatusDonacion.cancelled;
      case 4:
        return StatusDonacion.failed;
      default:
        return StatusDonacion.pending;
    }
  }

  static StatusDonacion fromString(String label) {
    switch (label.toLowerCase()) {
      case 'pendiente':
      case 'pending':
        return StatusDonacion.pending;
      case 'procesando':
      case 'processing':
        return StatusDonacion.processing;
      case 'completada':
      case 'completed':
        return StatusDonacion.completed;
      case 'cancelada':
      case 'cancelled':
        return StatusDonacion.cancelled;
      case 'fallida':
      case 'failed':
        return StatusDonacion.failed;
      default:
        return StatusDonacion.pending;
    }
  }
}

/// Enums para Source de Donación
/// Debe coincidir con el enum del backend: SourceDonacion
enum SourceDonacion {
  checkout(0, 'Checkout'),
  webhook(1, 'Webhook'),
  manual(2, 'Manual');

  final int value;
  final String label;
  const SourceDonacion(this.value, this.label);

  static SourceDonacion fromInt(int value) {
    switch (value) {
      case 0:
        return SourceDonacion.checkout;
      case 1:
        return SourceDonacion.webhook;
      case 2:
        return SourceDonacion.manual;
      default:
        return SourceDonacion.checkout;
    }
  }

  static SourceDonacion fromString(String label) {
    switch (label.toLowerCase()) {
      case 'checkout':
        return SourceDonacion.checkout;
      case 'webhook':
        return SourceDonacion.webhook;
      case 'manual':
        return SourceDonacion.manual;
      default:
        return SourceDonacion.checkout;
    }
  }
}

/// Modelo principal de Donación
/// Corresponde a: DonacionDto
class Donacion extends Equatable {
  final String id;
  final String? usuarioId;
  final String? nombreUsuario;
  final double monto;
  final String moneda;
  final int status;
  final String statusNombre;
  final int source;
  final String sourceNombre;
  final String? mensaje;
  final bool anonima;
  final String? payPalOrderId;
  final String? payPalCaptureId;
  final String? payPalPayerEmail;
  final String? payPalPayerName;
  final DateTime? capturedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;

  const Donacion({
    required this.id,
    this.usuarioId,
    this.nombreUsuario,
    required this.monto,
    this.moneda = 'MXN',
    required this.status,
    required this.statusNombre,
    required this.source,
    required this.sourceNombre,
    this.mensaje,
    this.anonima = false,
    this.payPalOrderId,
    this.payPalCaptureId,
    this.payPalPayerEmail,
    this.payPalPayerName,
    this.capturedAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
  });

  /// Convertir desde JSON
  factory Donacion.fromJson(Map<String, dynamic> json) {
    return Donacion(
      id: json['id'] as String,
      usuarioId: json['usuarioId'] as String?,
      nombreUsuario: json['nombreUsuario'] as String?,
      monto: (json['monto'] as num).toDouble(),
      moneda: json['moneda'] as String? ?? 'MXN',
      status: json['status'] as int,
      statusNombre: json['statusNombre'] as String,
      source: json['source'] as int,
      sourceNombre: json['sourceNombre'] as String,
      mensaje: json['mensaje'] as String?,
      anonima: json['anonima'] as bool? ?? false,
      payPalOrderId: json['payPalOrderId'] as String?,
      payPalCaptureId: json['payPalCaptureId'] as String?,
      payPalPayerEmail: json['payPalPayerEmail'] as String?,
      payPalPayerName: json['payPalPayerName'] as String?,
      capturedAt: json['capturedAt'] != null
          ? DateTime.parse(json['capturedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'monto': monto,
      'moneda': moneda,
      'status': status,
      'statusNombre': statusNombre,
      'source': source,
      'sourceNombre': sourceNombre,
      'mensaje': mensaje,
      'anonima': anonima,
      'payPalOrderId': payPalOrderId,
      'payPalCaptureId': payPalCaptureId,
      'payPalPayerEmail': payPalPayerEmail,
      'payPalPayerName': payPalPayerName,
      'capturedAt': capturedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Obtener el enum de status
  StatusDonacion get statusEnum => StatusDonacion.fromInt(status);

  /// Obtener el enum de source
  SourceDonacion get sourceEnum => SourceDonacion.fromInt(source);

  /// Verificar si la donación está completada
  bool get isCompleted => status == StatusDonacion.completed.value;

  /// Verificar si la donación está pendiente
  bool get isPending => status == StatusDonacion.pending.value;

  /// Verificar si la donación está cancelada
  bool get isCancelled => status == StatusDonacion.cancelled.value;

  /// Copiar con modificaciones
  Donacion copyWith({
    String? id,
    String? usuarioId,
    String? nombreUsuario,
    double? monto,
    String? moneda,
    int? status,
    String? statusNombre,
    int? source,
    String? sourceNombre,
    String? mensaje,
    bool? anonima,
    String? payPalOrderId,
    String? payPalCaptureId,
    String? payPalPayerEmail,
    String? payPalPayerName,
    DateTime? capturedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
  }) {
    return Donacion(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      monto: monto ?? this.monto,
      moneda: moneda ?? this.moneda,
      status: status ?? this.status,
      statusNombre: statusNombre ?? this.statusNombre,
      source: source ?? this.source,
      sourceNombre: sourceNombre ?? this.sourceNombre,
      mensaje: mensaje ?? this.mensaje,
      anonima: anonima ?? this.anonima,
      payPalOrderId: payPalOrderId ?? this.payPalOrderId,
      payPalCaptureId: payPalCaptureId ?? this.payPalCaptureId,
      payPalPayerEmail: payPalPayerEmail ?? this.payPalPayerEmail,
      payPalPayerName: payPalPayerName ?? this.payPalPayerName,
      capturedAt: capturedAt ?? this.capturedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    usuarioId,
    nombreUsuario,
    monto,
    moneda,
    status,
    statusNombre,
    source,
    sourceNombre,
    mensaje,
    anonima,
    payPalOrderId,
    payPalCaptureId,
    payPalPayerEmail,
    payPalPayerName,
    capturedAt,
    cancelledAt,
    cancellationReason,
    createdAt,
  ];

  @override
  String toString() {
    return 'Donacion(id: $id, monto: $monto $moneda, status: $statusNombre, anonima: $anonima)';
  }
}

/// Request para crear una donación con PayPal
/// Corresponde a: CreatePayPalDonacionDto
class CrearDonacionPayPalRequest extends Equatable {
  final String? usuarioId;
  final double monto;
  final String moneda;
  final String concepto;
  final String? mensaje;
  final bool anonima;
  final String returnUrl;
  final String cancelUrl;

  const CrearDonacionPayPalRequest({
    this.usuarioId,
    required this.monto,
    this.moneda = 'MXN',
    this.concepto = 'Donación para AdoPets',
    this.mensaje,
    this.anonima = false,
    required this.returnUrl,
    required this.cancelUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'monto': monto,
      'moneda': moneda,
      'concepto': concepto,
      'mensaje': mensaje,
      'anonima': anonima,
      'returnUrl': returnUrl,
      'cancelUrl': cancelUrl,
    };
  }

  @override
  List<Object?> get props => [
    usuarioId,
    monto,
    moneda,
    concepto,
    mensaje,
    anonima,
    returnUrl,
    cancelUrl,
  ];
}

/// Response de PayPal al crear donación
/// Corresponde a: PayPalDonacionResponseDto
class PayPalDonacionResponse extends Equatable {
  final String donacionId;
  final String orderId;
  final String approvalUrl;
  final String status;

  const PayPalDonacionResponse({
    required this.donacionId,
    required this.orderId,
    required this.approvalUrl,
    required this.status,
  });

  factory PayPalDonacionResponse.fromJson(Map<String, dynamic> json) {
    return PayPalDonacionResponse(
      donacionId: json['donacionId'] as String,
      orderId: json['orderId'] as String,
      approvalUrl: json['approvalUrl'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'donacionId': donacionId,
      'orderId': orderId,
      'approvalUrl': approvalUrl,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [donacionId, orderId, approvalUrl, status];
}

/// Request para capturar pago de PayPal
/// Corresponde a: CapturePayPalDonacionDto
class CapturarPagoPayPalRequest extends Equatable {
  final String orderId;

  const CapturarPagoPayPalRequest({required this.orderId});

  Map<String, dynamic> toJson() {
    return {'orderId': orderId};
  }

  @override
  List<Object?> get props => [orderId];
}

/// Request para crear donación básica
/// Corresponde a: CreateDonacionDto
class CrearDonacionRequest extends Equatable {
  final String? usuarioId;
  final double monto;
  final String moneda;
  final int status;
  final int source;
  final String? mensaje;
  final bool anonima;

  const CrearDonacionRequest({
    this.usuarioId,
    required this.monto,
    this.moneda = 'MXN',
    this.status = 0, // PENDING por defecto
    this.source = 0, // Checkout por defecto
    this.mensaje,
    this.anonima = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'monto': monto,
      'moneda': moneda,
      'status': status,
      'source': source,
      'mensaje': mensaje,
      'anonima': anonima,
    };
  }

  @override
  List<Object?> get props => [
    usuarioId,
    monto,
    moneda,
    status,
    source,
    mensaje,
    anonima,
  ];
}

/// Webhook de PayPal para donaciones
/// Corresponde a: PayPalWebhookDonacionDto
class PayPalWebhookDonacion extends Equatable {
  final String eventType;
  final String eventId;
  final Map<String, dynamic> resource;

  const PayPalWebhookDonacion({
    required this.eventType,
    required this.eventId,
    required this.resource,
  });

  factory PayPalWebhookDonacion.fromJson(Map<String, dynamic> json) {
    return PayPalWebhookDonacion(
      eventType: json['eventType'] as String,
      eventId: json['eventId'] as String,
      resource: json['resource'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {'eventType': eventType, 'eventId': eventId, 'resource': resource};
  }

  @override
  List<Object?> get props => [eventType, eventId, resource];
}
