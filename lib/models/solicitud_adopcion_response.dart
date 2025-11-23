import 'package:equatable/equatable.dart';

class MascotaFotoResponse extends Equatable {
  final String id;
  final String storageKey;
  final String mimeType;
  final int orden;
  final bool esPrincipal;

  const MascotaFotoResponse({
    required this.id,
    required this.storageKey,
    required this.mimeType,
    required this.orden,
    required this.esPrincipal,
  });

  factory MascotaFotoResponse.fromJson(Map<String, dynamic> json) {
    return MascotaFotoResponse(
      id: json['id']?.toString() ?? '',
      storageKey: json['storageKey']?.toString() ?? '',
      mimeType: json['mimeType']?.toString() ?? '',
      orden: json['orden'] ?? 0,
      esPrincipal: json['esPrincipal'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, storageKey, mimeType, orden, esPrincipal];
}

class SolicitudAdopcionResponse extends Equatable {
  final String id;
  final String usuarioId;
  final String usuarioNombre;
  final String mascotaId;
  final String mascotaNombre;
  final int estado;
  final int vivienda;
  final int numNinios;
  final bool otrasMascotas;
  final int horasDisponibilidad;
  final String direccion;
  final num ingresosMensuales;
  final String motivoAdopcion;
  final DateTime fechaSolicitud;
  final String? motivoRechazo;
  final List<MascotaFotoResponse> fotos;

  const SolicitudAdopcionResponse({
    required this.id,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.mascotaId,
    required this.mascotaNombre,
    required this.estado,
    required this.vivienda,
    required this.numNinios,
    required this.otrasMascotas,
    required this.horasDisponibilidad,
    required this.direccion,
    required this.ingresosMensuales,
    required this.motivoAdopcion,
    required this.motivoRechazo,
    required this.fechaSolicitud,
    required this.fotos,
  });

  factory SolicitudAdopcionResponse.fromJson(Map<String, dynamic> json) {
    return SolicitudAdopcionResponse(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      usuarioNombre: json['usuarioNombre'] ?? '',
      mascotaId: json['mascotaId'] ?? '',
      mascotaNombre: json['mascotaNombre'] ?? '',
      estado: json['estado'] ?? 0,
      vivienda: json['vivienda'] ?? 0,
      numNinios: json['numNinios'] ?? 0,
      otrasMascotas: json['otrasMascotas'] ?? false,
      horasDisponibilidad: json['horasDisponibilidad'] ?? 0,
      direccion: json['direccion'] ?? '',
      ingresosMensuales: json['ingresosMensuales'] ?? 0,
      motivoAdopcion: json['motivoAdopcion'] ?? '',
      motivoRechazo: json['motivoRechazo']?.toString(),
      fechaSolicitud: DateTime.parse(json['fechaSolicitud']),
      fotos: json['mascotaFotos'] != null
          ? (json['mascotaFotos'] as List)
                .map((e) => MascotaFotoResponse.fromJson(e))
                .toList()
          : [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    usuarioId,
    usuarioNombre,
    mascotaId,
    mascotaNombre,
    estado,
    vivienda,
    numNinios,
    otrasMascotas,
    horasDisponibilidad,
    direccion,
    ingresosMensuales,
    motivoAdopcion,
    motivoRechazo,
    fechaSolicitud,
    fotos,
  ];
}
