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
  final int? sexo; // 1 = Macho, 2 = Hembra
  final DateTime? fechaNacimiento;
  final double? peso;
  final String? foto;
  final bool activo;
  final String? propietarioId;
  final String? propietarioNombre;
  final List<MascotaFoto>? fotos;

  // Nueva propiedades
  final int estatus;
  final String? personalidad;
  final String? estadoSalud;
  final String? requisitoAdopcion;
  final String? origen;
  final String? notas;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? edadEnAnios;

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
    // NUEVAS PROPIEDADES
    required this.estatus,
    this.personalidad,
    this.estadoSalud,
    this.requisitoAdopcion,
    this.origen,
    this.notas,
    required this.createdAt,
    this.updatedAt,
    this.edadEnAnios,
  });

  /// Crear desde JSON
  factory Mascota.fromJson(Map<String, dynamic> json) {
    // Función auxiliar para parsear fechas
    DateTime? parseDateTime(dynamic date) {
      if (date == null) return null;
      try {
        return DateTime.tryParse(date.toString());
      } catch (e) {
        return null;
      }
    }

    try {
      // Parsear fotos
      List<MascotaFoto>? fotos;
      try {
        if (json['fotos'] is List) {
          fotos = (json['fotos'] as List)
              .map((foto) {
                if (foto is Map<String, dynamic>) {
                  return MascotaFoto.fromJson(foto);
                }
                return null;
              })
              .where((foto) => foto != null)
              .cast<MascotaFoto>()
              .toList();
        } else if (json['fotos'] is Map) {
          // Si es un mapa individual, convertir a lista
          fotos = [MascotaFoto.fromJson(json['fotos'] as Map<String, dynamic>)];
        }
      } catch (e) {
        print('⚠️ Error parsing fotos: $e');
        fotos = null;
      }

      return Mascota(
        id: json['id']?.toString() ?? '',
        nombre: json['nombre']?.toString() ?? '',
        especie: json['especie']?.toString() ?? '',
        raza: json['raza']?.toString(),
        color: json['color']?.toString(),
        sexo: json['sexo'] != null
            ? int.tryParse(json['sexo'].toString())
            : null,
        fechaNacimiento: parseDateTime(json['fechaNacimiento']),
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
        // NUEVAS PROPIEDADES
        estatus: json['estatus'] != null
            ? int.tryParse(json['estatus'].toString()) ?? 1
            : 1,
        personalidad: json['personalidad']?.toString(),
        estadoSalud: json['estadoSalud']?.toString(),
        requisitoAdopcion: json['requisitoAdopcion']?.toString(),
        origen: json['origen']?.toString(),
        notas: json['notas']?.toString(),
        createdAt: parseDateTime(json['createdAt']) ?? DateTime.now(),
        updatedAt: parseDateTime(json['updatedAt']),
        edadEnAnios: json['edadEnAnios'] != null
            ? int.tryParse(json['edadEnAnios'].toString())
            : json['edadEnAnio'] != null
            ? int.tryParse(json['edadEnAnio'].toString())
            : null,
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
      // NUEVAS PROPIEDADES
      'estatus': estatus,
      'personalidad': personalidad,
      'estadoSalud': estadoSalud,
      'requisitoAdopcion': requisitoAdopcion,
      'origen': origen,
      'notas': notas,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'edadEnAnios': edadEnAnios,
    };
  }

  /// Calcular edad en años (método de respaldo)
  int? get calcularEdadEnAnios {
    if (fechaNacimiento == null) return edadEnAnios;
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
    final edad = edadEnAnios ?? calcularEdadEnAnios;
    if (edad == null) return 'Edad desconocida';
    if (edad == 0) return 'Menos de 1 año';
    if (edad == 1) return '1 año';
    return '$edad años';
  }

  /// Obtener texto del estatus
  String get estatusTexto {
    switch (estatus) {
      case 1:
        return 'Disponible';
      case 2:
        return 'En proceso';
      case 3:
        return 'Adoptado';
      case 4:
        return 'No disponible';
      default:
        return 'Desconocido';
    }
  }

  /// Verificar si está disponible para adopción
  bool get estaDisponible => estatus == 1;

  /// Obtener texto del sexo
  String get sexoTexto {
    if (sexo == null) return 'No especificado';
    return sexo == 1 ? 'Macho' : 'Hembra';
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
    estatus,
    personalidad,
    estadoSalud,
    requisitoAdopcion,
    origen,
    notas,
    createdAt,
    updatedAt,
    edadEnAnios,
  ];
}
