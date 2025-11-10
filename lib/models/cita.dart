import 'package:equatable/equatable.dart';

/// Estado de la cita
enum CitaStatus {
  programada(0, 'Programada'),
  confirmada(1, 'Confirmada'),
  enProceso(2, 'En Proceso'),
  completada(3, 'Completada'),
  cancelada(4, 'Cancelada'),
  noAsistio(5, 'No Asistió');

  final int value;
  final String label;

  const CitaStatus(this.value, this.label);

  static CitaStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'programada':
        return CitaStatus.programada;
      case 'confirmada':
        return CitaStatus.confirmada;
      case 'enproceso':
      case 'en proceso':
        return CitaStatus.enProceso;
      case 'completada':
        return CitaStatus.completada;
      case 'cancelada':
        return CitaStatus.cancelada;
      case 'noasistio':
      case 'no asistió':
        return CitaStatus.noAsistio;
      default:
        return CitaStatus.programada;
    }
  }
}

/// Modelo de cita veterinaria
class Cita extends Equatable {
  final String id;
  final DateTime fechaHora;
  final int duracionMinutos;
  final CitaStatus status;
  final String tipoConsulta;
  final String? motivo;
  final String? notas;
  final String? diagnostico;
  final String? tratamiento;
  final DateTime? proximaRevision;
  final String? motivoCancelacion;

  // Relaciones
  final String mascotaId;
  final String? mascotaNombre;
  final String veterinarioId;
  final String? veterinarioNombre;
  final String? salaId;
  final String? salaNombre;
  final String? numeroTicket;

  // Información de pago
  final double? costoTotal;
  final double? montoAnticipo;
  final bool requierePago;
  final bool pagoCompletado;

  // Información de auditoría
  final String? creadoPor;
  final DateTime? fechaCreacion;
  final String? modificadoPor;
  final DateTime? fechaModificacion;

  // Recordatorios
  final bool enviarRecordatorio;

  const Cita({
    required this.id,
    required this.fechaHora,
    required this.duracionMinutos,
    required this.status,
    required this.tipoConsulta,
    this.motivo,
    this.notas,
    this.diagnostico,
    this.tratamiento,
    this.proximaRevision,
    this.motivoCancelacion,
    required this.mascotaId,
    this.mascotaNombre,
    required this.veterinarioId,
    this.veterinarioNombre,
    this.salaId,
    this.salaNombre,
    this.numeroTicket,
    this.costoTotal,
    this.montoAnticipo,
    this.requierePago = false,
    this.pagoCompletado = false,
    this.creadoPor,
    this.fechaCreacion,
    this.modificadoPor,
    this.fechaModificacion,
    this.enviarRecordatorio = true,
  });

  /// Crear desde JSON
  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'] as String,
      fechaHora: DateTime.parse(json['fechaHora'] as String),
      duracionMinutos: json['duracionMinutos'] as int? ?? 30,
      status: CitaStatus.fromString(json['status'] as String? ?? 'Programada'),
      tipoConsulta: json['tipoConsulta'] as String,
      motivo: json['motivo'] as String?,
      notas: json['notas'] as String?,
      diagnostico: json['diagnostico'] as String?,
      tratamiento: json['tratamiento'] as String?,
      proximaRevision: json['proximaRevision'] != null
          ? DateTime.parse(json['proximaRevision'] as String)
          : null,
      motivoCancelacion: json['motivoCancelacion'] as String?,
      mascotaId: json['mascotaId'] as String,
      mascotaNombre: json['mascotaNombre'] as String?,
      veterinarioId: json['veterinarioId'] as String,
      veterinarioNombre: json['veterinarioNombre'] as String?,
      salaId: json['salaId'] as String?,
      salaNombre: json['salaNombre'] as String?,
      numeroTicket: json['numeroTicket'] as String?,
      costoTotal: json['costoTotal'] != null
          ? (json['costoTotal'] as num).toDouble()
          : null,
      montoAnticipo: json['montoAnticipo'] != null
          ? (json['montoAnticipo'] as num).toDouble()
          : null,
      requierePago: json['requierePago'] as bool? ?? false,
      pagoCompletado: json['pagoCompletado'] as bool? ?? false,
      creadoPor: json['creadoPor'] as String?,
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'] as String)
          : null,
      modificadoPor: json['modificadoPor'] as String?,
      fechaModificacion: json['fechaModificacion'] != null
          ? DateTime.parse(json['fechaModificacion'] as String)
          : null,
      enviarRecordatorio: json['enviarRecordatorio'] as bool? ?? true,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fechaHora': fechaHora.toIso8601String(),
      'duracionMinutos': duracionMinutos,
      'status': status.label,
      'tipoConsulta': tipoConsulta,
      'motivo': motivo,
      'notas': notas,
      'diagnostico': diagnostico,
      'tratamiento': tratamiento,
      'proximaRevision': proximaRevision?.toIso8601String(),
      'motivoCancelacion': motivoCancelacion,
      'mascotaId': mascotaId,
      'mascotaNombre': mascotaNombre,
      'veterinarioId': veterinarioId,
      'veterinarioNombre': veterinarioNombre,
      'salaId': salaId,
      'salaNombre': salaNombre,
      'numeroTicket': numeroTicket,
      'costoTotal': costoTotal,
      'montoAnticipo': montoAnticipo,
      'requierePago': requierePago,
      'pagoCompletado': pagoCompletado,
      'creadoPor': creadoPor,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'modificadoPor': modificadoPor,
      'fechaModificacion': fechaModificacion?.toIso8601String(),
      'enviarRecordatorio': enviarRecordatorio,
    };
  }

  /// Obtener fecha de fin de la cita
  DateTime get fechaHoraFin {
    return fechaHora.add(Duration(minutes: duracionMinutos));
  }

  /// Verificar si la cita ya pasó
  bool get yaPaso {
    return DateTime.now().isAfter(fechaHoraFin);
  }

  /// Verificar si la cita es hoy
  bool get esHoy {
    final ahora = DateTime.now();
    return fechaHora.year == ahora.year &&
        fechaHora.month == ahora.month &&
        fechaHora.day == ahora.day;
  }

  /// Verificar si puede ser cancelada
  bool get puedeCancelarse {
    return status == CitaStatus.programada || status == CitaStatus.confirmada;
  }

  /// Verificar si requiere pago de anticipo
  bool get requiereAnticipo {
    return requierePago && !pagoCompletado && costoTotal != null;
  }

  /// Calcular monto del anticipo (50%)
  double? get calculoAnticipo {
    return costoTotal != null ? costoTotal! * 0.5 : null;
  }

  /// Crear copia con cambios
  Cita copyWith({
    String? id,
    DateTime? fechaHora,
    int? duracionMinutos,
    CitaStatus? status,
    String? tipoConsulta,
    String? motivo,
    String? notas,
    String? diagnostico,
    String? tratamiento,
    DateTime? proximaRevision,
    String? motivoCancelacion,
    String? mascotaId,
    String? mascotaNombre,
    String? veterinarioId,
    String? veterinarioNombre,
    String? salaId,
    String? salaNombre,
    String? numeroTicket,
    double? costoTotal,
    double? montoAnticipo,
    bool? requierePago,
    bool? pagoCompletado,
    String? creadoPor,
    DateTime? fechaCreacion,
    String? modificadoPor,
    DateTime? fechaModificacion,
    bool? enviarRecordatorio,
  }) {
    return Cita(
      id: id ?? this.id,
      fechaHora: fechaHora ?? this.fechaHora,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      status: status ?? this.status,
      tipoConsulta: tipoConsulta ?? this.tipoConsulta,
      motivo: motivo ?? this.motivo,
      notas: notas ?? this.notas,
      diagnostico: diagnostico ?? this.diagnostico,
      tratamiento: tratamiento ?? this.tratamiento,
      proximaRevision: proximaRevision ?? this.proximaRevision,
      motivoCancelacion: motivoCancelacion ?? this.motivoCancelacion,
      mascotaId: mascotaId ?? this.mascotaId,
      mascotaNombre: mascotaNombre ?? this.mascotaNombre,
      veterinarioId: veterinarioId ?? this.veterinarioId,
      veterinarioNombre: veterinarioNombre ?? this.veterinarioNombre,
      salaId: salaId ?? this.salaId,
      salaNombre: salaNombre ?? this.salaNombre,
      numeroTicket: numeroTicket ?? this.numeroTicket,
      costoTotal: costoTotal ?? this.costoTotal,
      montoAnticipo: montoAnticipo ?? this.montoAnticipo,
      requierePago: requierePago ?? this.requierePago,
      pagoCompletado: pagoCompletado ?? this.pagoCompletado,
      creadoPor: creadoPor ?? this.creadoPor,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      modificadoPor: modificadoPor ?? this.modificadoPor,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      enviarRecordatorio: enviarRecordatorio ?? this.enviarRecordatorio,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fechaHora,
    duracionMinutos,
    status,
    tipoConsulta,
    motivo,
    notas,
    diagnostico,
    tratamiento,
    proximaRevision,
    motivoCancelacion,
    mascotaId,
    mascotaNombre,
    veterinarioId,
    veterinarioNombre,
    salaId,
    salaNombre,
    numeroTicket,
    costoTotal,
    montoAnticipo,
    requierePago,
    pagoCompletado,
    creadoPor,
    fechaCreacion,
    modificadoPor,
    fechaModificacion,
    enviarRecordatorio,
  ];
}

/// Modelo de respuesta de disponibilidad
class DisponibilidadResponse extends Equatable {
  final bool disponible;
  final List<HorarioDisponible> horariosDisponibles;
  final List<HorarioOcupado> horariosOcupados;

  const DisponibilidadResponse({
    required this.disponible,
    required this.horariosDisponibles,
    required this.horariosOcupados,
  });

  factory DisponibilidadResponse.fromJson(Map<String, dynamic> json) {
    return DisponibilidadResponse(
      disponible: json['disponible'] as bool? ?? false,
      horariosDisponibles:
          (json['horariosDisponibles'] as List?)
              ?.map((item) => HorarioDisponible.fromJson(item))
              .toList() ??
          [],
      horariosOcupados:
          (json['horariosOcupados'] as List?)
              ?.map((item) => HorarioOcupado.fromJson(item))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    disponible,
    horariosDisponibles,
    horariosOcupados,
  ];
}

/// Modelo de horario disponible
class HorarioDisponible extends Equatable {
  final DateTime inicio;
  final DateTime fin;

  const HorarioDisponible({required this.inicio, required this.fin});

  factory HorarioDisponible.fromJson(Map<String, dynamic> json) {
    return HorarioDisponible(
      inicio: DateTime.parse(json['inicio'] as String),
      fin: DateTime.parse(json['fin'] as String),
    );
  }

  @override
  List<Object?> get props => [inicio, fin];
}

/// Modelo de horario ocupado
class HorarioOcupado extends Equatable {
  final DateTime inicio;
  final DateTime fin;
  final String? citaId;
  final String? mascota;

  const HorarioOcupado({
    required this.inicio,
    required this.fin,
    this.citaId,
    this.mascota,
  });

  factory HorarioOcupado.fromJson(Map<String, dynamic> json) {
    return HorarioOcupado(
      inicio: DateTime.parse(json['inicio'] as String),
      fin: DateTime.parse(json['fin'] as String),
      citaId: json['citaId'] as String?,
      mascota: json['mascota'] as String?,
    );
  }

  @override
  List<Object?> get props => [inicio, fin, citaId, mascota];
}

/// Modelo de disponibilidad de horarios (deprecated - usar DisponibilidadResponse)
@Deprecated('Usar DisponibilidadResponse en su lugar')
class DisponibilidadHorario extends Equatable {
  final DateTime inicio;
  final DateTime fin;
  final bool disponible;

  const DisponibilidadHorario({
    required this.inicio,
    required this.fin,
    required this.disponible,
  });

  factory DisponibilidadHorario.fromJson(Map<String, dynamic> json) {
    return DisponibilidadHorario(
      inicio: DateTime.parse(json['inicio'] as String),
      fin: DateTime.parse(json['fin'] as String),
      disponible: json['disponible'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [inicio, fin, disponible];
}

/// Modelo para crear una cita
class CrearCitaRequest {
  final String mascotaId;
  final String veterinarioId;
  final String? salaId;
  final DateTime fechaHora;
  final int duracionMinutos;
  final String tipoConsulta;
  final String motivo;
  final String? notas;
  final bool enviarRecordatorio;

  const CrearCitaRequest({
    required this.mascotaId,
    required this.veterinarioId,
    this.salaId,
    required this.fechaHora,
    required this.duracionMinutos,
    required this.tipoConsulta,
    required this.motivo,
    this.notas,
    this.enviarRecordatorio = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'mascotaId': mascotaId,
      'veterinarioId': veterinarioId,
      'salaId': salaId,
      'fechaHora': fechaHora.toIso8601String(),
      'duracionMinutos': duracionMinutos,
      'tipoConsulta': tipoConsulta,
      'motivo': motivo,
      'notas': notas,
      'enviarRecordatorio': enviarRecordatorio,
    };
  }
}
