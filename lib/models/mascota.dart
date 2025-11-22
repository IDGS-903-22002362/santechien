import 'package:equatable/equatable.dart';

/// Modelo de foto de mascota
class MascotaFoto extends Equatable {
  final String storageKey;
  final String? descripcion;

  const MascotaFoto({required this.storageKey, this.descripcion});

  factory MascotaFoto.fromJson(Map<String, dynamic> json) {
    return MascotaFoto(
      storageKey: json['storageKey']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'storageKey': storageKey, 'descripcion': descripcion};
  }

  @override
  List<Object?> get props => [storageKey, descripcion];
}

/// Modelo de mascota
class Mascota extends Equatable {
  final String id;
  final String nombre;
  final String especie;
  final String? raza;
  final String? color;
  final String? sexo;
  final DateTime? fechaNacimiento;
  final double? peso;
  final String? foto;
  final bool activo;
  final String? propietarioId;
  final String? propietarioNombre;
  final List<MascotaFoto>? fotos;

  const Mascota({
    required this.id,
    required this.nombre,
    required this.especie,
    this.raza,
    this.color,
    this.sexo,
    this.fechaNacimiento,
    this.peso,
    this.foto,
    this.activo = true,
    this.propietarioId,
    this.propietarioNombre,
    this.fotos,
  });

  /// Crear desde JSON
  factory Mascota.fromJson(Map<String, dynamic> json) {
    try {
      // Parsear fotos
      List<MascotaFoto>? fotos;
      if (json['fotos'] is List) {
        fotos = (json['fotos'] as List)
            .map((foto) => MascotaFoto.fromJson(foto))
            .toList();
      }

      return Mascota(
        id: json['id']?.toString() ?? '',
        nombre: json['nombre']?.toString() ?? '',
        especie: json['especie']?.toString() ?? '',
        raza: json['raza']?.toString(),
        color: json['color']?.toString(),
        sexo: json['sexo']?.toString(),
        fechaNacimiento: json['fechaNacimiento'] != null
            ? DateTime.tryParse(json['fechaNacimiento'].toString())
            : null,
        peso: json['peso'] != null
            ? double.tryParse(json['peso'].toString())
            : null,
        foto: json['foto']?.toString(),
        activo:
            json['activo'] == true ||
            json['activo']?.toString().toLowerCase() == 'true',
        propietarioId: json['propietarioId']?.toString(),
        propietarioNombre: json['propietarioNombre']?.toString(),
        fotos: fotos,
      );
    } catch (e) {
      print('❌ Error en Mascota.fromJson: $e');
      print('   JSON recibido: $json');
      rethrow;
    }
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'color': color,
      'sexo': sexo,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'peso': peso,
      'foto': foto,
      'activo': activo,
      'propietarioId': propietarioId,
      'propietarioNombre': propietarioNombre,
      'fotos': fotos?.map((f) => f.toJson()).toList(),
    };
  }

  /// Calcular edad en años
  int? get edadEnAnios {
    if (fechaNacimiento == null) return null;
    final ahora = DateTime.now();
    int edad = ahora.year - fechaNacimiento!.year;
    if (ahora.month < fechaNacimiento!.month ||
        (ahora.month == fechaNacimiento!.month &&
            ahora.day < fechaNacimiento!.day)) {
      edad--;
    }
    return edad;
  }

  /// Obtener descripción de edad
  String get descripcionEdad {
    final edad = edadEnAnios;
    if (edad == null) return 'Edad desconocida';
    if (edad == 0) return 'Menos de 1 año';
    if (edad == 1) return '1 año';
    return '$edad años';
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    especie,
    raza,
    color,
    sexo,
    fechaNacimiento,
    peso,
    foto,
    activo,
    propietarioId,
    propietarioNombre,
    fotos,
  ];
}
