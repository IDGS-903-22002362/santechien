import 'donacion.dart';

/// Response wrapper para operaciones de donaciones
class DonacionResponse {
  final bool success;
  final String message;
  final Donacion? donacion;
  final List<String> errors;

  const DonacionResponse({
    required this.success,
    required this.message,
    this.donacion,
    this.errors = const [],
  });

  factory DonacionResponse.fromJson(Map<String, dynamic> json) {
    return DonacionResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      donacion: json['data'] != null
          ? Donacion.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'] != null
          ? List<String>.from(json['errors'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': donacion?.toJson(),
      'errors': errors,
    };
  }
}

/// Response wrapper para lista de donaciones
class DonacionListResponse {
  final bool success;
  final String message;
  final List<Donacion> donaciones;
  final int total;
  final List<String> errors;

  const DonacionListResponse({
    required this.success,
    required this.message,
    this.donaciones = const [],
    this.total = 0,
    this.errors = const [],
  });

  factory DonacionListResponse.fromJson(Map<String, dynamic> json) {
    return DonacionListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      donaciones: json['data'] != null
          ? (json['data'] as List)
                .map((item) => Donacion.fromJson(item as Map<String, dynamic>))
                .toList()
          : [],
      total: json['total'] as int? ?? 0,
      errors: json['errors'] != null
          ? List<String>.from(json['errors'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': donaciones.map((d) => d.toJson()).toList(),
      'total': total,
      'errors': errors,
    };
  }
}

/// Response para creación de orden PayPal
class PayPalOrdenResponse {
  final bool success;
  final String message;
  final PayPalDonacionResponse? data;
  final List<String> errors;

  const PayPalOrdenResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors = const [],
  });

  factory PayPalOrdenResponse.fromJson(Map<String, dynamic> json) {
    return PayPalOrdenResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null
          ? PayPalDonacionResponse.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
      errors: json['errors'] != null
          ? List<String>.from(json['errors'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'errors': errors,
    };
  }
}

/// Response para captura de pago PayPal
class CapturaPagoResponse {
  final bool success;
  final String message;
  final Donacion? donacion;
  final List<String> errors;

  const CapturaPagoResponse({
    required this.success,
    required this.message,
    this.donacion,
    this.errors = const [],
  });

  factory CapturaPagoResponse.fromJson(Map<String, dynamic> json) {
    return CapturaPagoResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      donacion: json['data'] != null
          ? Donacion.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'] != null
          ? List<String>.from(json['errors'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': donacion?.toJson(),
      'errors': errors,
    };
  }
}
