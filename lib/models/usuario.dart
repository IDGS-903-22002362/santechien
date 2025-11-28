import 'package:equatable/equatable.dart';

/// Modelo de usuario
class Usuario extends Equatable {
  final String id;
  final String nombre;
  final String? apellidoPaterno;
  final String? apellidoMaterno;
  final String email;
  final String? telefono;
  final List<String> roles;
  final bool activo;
  final DateTime? fechaRegistro;

  const Usuario({
    required this.id,
    required this.nombre,
    this.apellidoPaterno,
    this.apellidoMaterno,
    required this.email,
    this.telefono,
    required this.roles,
    required this.activo,
    this.fechaRegistro,
  });

  /// Obtener nombre completo
  String get nombreCompleto {
    final parts = [
      nombre,
      if (apellidoPaterno != null) apellidoPaterno,
      if (apellidoMaterno != null) apellidoMaterno,
    ];
    return parts.join(' ');
  }

  /// Obtener iniciales
  String get iniciales {
    final nombreInicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '';
    final apellidoInicial =
        apellidoPaterno != null && apellidoPaterno!.isNotEmpty
        ? apellidoPaterno![0].toUpperCase()
        : '';
    return '$nombreInicial$apellidoInicial';
  }

  /// Crear desde JSON
  factory Usuario.fromJson(Map<String, dynamic> json) {
    final rolesList =
        (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [];

    final estatus = json['estatus'];
    final activoCalc = estatus is num
        ? estatus == 1
        : (json['activo'] as bool? ?? true);

    final fechaStr =
        (json['fechaRegistro'] as String?) ?? (json['createdAt'] as String?);

    return Usuario(
      id: json['id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      apellidoPaterno: json['apellidoPaterno'] as String?,
      apellidoMaterno: json['apellidoMaterno'] as String?,
      email: json['email'] as String? ?? '',
      telefono: json['telefono'] as String?,
      roles: rolesList,
      activo: activoCalc,
      fechaRegistro: fechaStr != null ? DateTime.parse(fechaStr) : null,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'email': email,
      'telefono': telefono,
      'roles': roles,
      'activo': activo,
      'fechaRegistro': fechaRegistro?.toIso8601String(),
    };
  }

  /// Crear copia con cambios
  Usuario copyWith({
    String? id,
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? email,
    String? telefono,
    List<String>? roles,
    bool? activo,
    DateTime? fechaRegistro,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      roles: roles ?? this.roles,
      activo: activo ?? this.activo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    apellidoPaterno,
    apellidoMaterno,
    email,
    telefono,
    roles,
    activo,
    fechaRegistro,
  ];
}
