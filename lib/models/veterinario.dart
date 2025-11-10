import 'package:equatable/equatable.dart';

/// Modelo de veterinario
class Veterinario extends Equatable {
  final String id;
  final String nombre;
  final String? apellidoPaterno;
  final String? apellidoMaterno;
  final String email;
  final String? telefono;
  final String? especialidad;
  final String? cedulaProfesional;
  final String? foto;
  final bool activo;

  const Veterinario({
    required this.id,
    required this.nombre,
    this.apellidoPaterno,
    this.apellidoMaterno,
    required this.email,
    this.telefono,
    this.especialidad,
    this.cedulaProfesional,
    this.foto,
    this.activo = true,
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

  /// Obtener título profesional
  String get titulo {
    return 'Dr. ${apellidoPaterno ?? nombre}';
  }

  /// Crear desde JSON
  factory Veterinario.fromJson(Map<String, dynamic> json) {
    return Veterinario(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      apellidoPaterno: json['apellidoPaterno'] as String?,
      apellidoMaterno: json['apellidoMaterno'] as String?,
      email: json['email'] as String,
      telefono: json['telefono'] as String?,
      especialidad: json['especialidad'] as String?,
      cedulaProfesional: json['cedulaProfesional'] as String?,
      foto: json['foto'] as String?,
      activo: json['activo'] as bool? ?? true,
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
      'especialidad': especialidad,
      'cedulaProfesional': cedulaProfesional,
      'foto': foto,
      'activo': activo,
    };
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    apellidoPaterno,
    apellidoMaterno,
    email,
    telefono,
    especialidad,
    cedulaProfesional,
    foto,
    activo,
  ];
}
