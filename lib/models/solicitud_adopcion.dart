import 'package:equatable/equatable.dart';

class Adopcion extends Equatable {
  String usuarioId;
  final String mascotaId;
  final int vivienda;
  final int numNinios;
  final bool otrasMascotas;
  final num horasDisponibilidad;
  final String direccion;
  final num ingresosMensuales;
  final String motivoAdopcion;
  final DateTime fechaSolicitud;
  final int estado;

  Adopcion({
    required this.usuarioId,
    required this.mascotaId,
    required this.vivienda,
    required this.numNinios,
    required this.otrasMascotas,
    required this.horasDisponibilidad,
    required this.direccion,
    required this.ingresosMensuales,
    required this.motivoAdopcion,
    required this.fechaSolicitud,
    required this.estado,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'mascotaId': mascotaId,
      'vivienda': vivienda,
      'numNinios': numNinios,
      'otrasMascotas': otrasMascotas,
      'horasDisponibilidad': horasDisponibilidad,
      'direccion': direccion,
      'ingresosMensuales': ingresosMensuales,
      'motivoAdopcion': motivoAdopcion,
      'fechaSolicitud': fechaSolicitud.toIso8601String(),
      'estado': estado,
    };
  }

  @override
  List<Object?> get props => [
    usuarioId,
    mascotaId,
    vivienda,
    numNinios,
    otrasMascotas,
    horasDisponibilidad,
    direccion,
    ingresosMensuales,
    motivoAdopcion,
    fechaSolicitud,
    estado,
  ];
}
