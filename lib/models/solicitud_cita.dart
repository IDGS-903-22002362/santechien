import 'package:equatable/equatable.dart';

/// Estados de solicitud de cita
enum SolicitudEstado {
  pendiente(1, 'Pendiente'),
  enRevision(2, 'En Revisión'),
  pendientePago(3, 'Pendiente Pago'),
  pagadaPendienteConfirmacion(4, 'Pagada - Pendiente Confirmación'),
  confirmada(5, 'Confirmada'),
  rechazada(6, 'Rechazada'),
  cancelada(7, 'Cancelada'),
  expirada(8, 'Expirada');

  final int value;
  final String label;

  const SolicitudEstado(this.value, this.label);

  static SolicitudEstado fromValue(int value) {
    switch (value) {
      case 1:
        return SolicitudEstado.pendiente;
      case 2:
        return SolicitudEstado.enRevision;
      case 3:
        return SolicitudEstado.pendientePago;
      case 4:
        return SolicitudEstado.pagadaPendienteConfirmacion;
      case 5:
        return SolicitudEstado.confirmada;
      case 6:
        return SolicitudEstado.rechazada;
      case 7:
        return SolicitudEstado.cancelada;
      case 8:
        return SolicitudEstado.expirada;
      default:
        return SolicitudEstado.pendiente;
    }
  }

  static SolicitudEstado fromString(String str) {
    switch (str.toLowerCase()) {
      case 'pendiente':
        return SolicitudEstado.pendiente;
      case 'enrevision':
      case 'en revisión':
        return SolicitudEstado.enRevision;
      case 'pendientepago':
      case 'pendiente pago':
        return SolicitudEstado.pendientePago;
      case 'pagadapendienteconfirmacion':
      case 'pagada - pendiente confirmación':
        return SolicitudEstado.pagadaPendienteConfirmacion;
      case 'confirmada':
        return SolicitudEstado.confirmada;
      case 'rechazada':
        return SolicitudEstado.rechazada;
      case 'cancelada':
        return SolicitudEstado.cancelada;
      case 'expirada':
        return SolicitudEstado.expirada;
      default:
        return SolicitudEstado.pendiente;
    }
  }
}

/// Modelo de solicitud de cita
class SolicitudCita extends Equatable {
  final String id;
  final String numeroSolicitud;
  final String solicitanteId;
  final String nombreSolicitante;
  final String emailSolicitante;
  final String? telefonoSolicitante;

  // Datos de la mascota
  final String mascotaId;
  final String nombreMascota;
  final String especieMascota;
  final String? razaMascota;

  // Datos del servicio
  final String servicioId;
  final String descripcionServicio;
  final String motivoConsulta;
  final String? sintomas;
  final bool esUrgente;

  // Datos de la cita
  final DateTime fechaHoraSolicitada;
  final int duracionEstimadaMin;
  final String? veterinarioPreferidoId;
  final String? salaPreferidaId;

  // Costos
  final double costoEstimado;
  final double montoAnticipo;

  // Estado
  final SolicitudEstado estado;
  final String estadoNombre;
  final DateTime fechaSolicitud;
  final DateTime? fechaRespuesta;
  final String? motivoRechazo;

  // Referencias
  final String? pagoAnticipoId;
  final String? citaId;

  // Validaciones
  final bool disponibilidadVerificada;
  final String? notasInternas;

  const SolicitudCita({
    required this.id,
    required this.numeroSolicitud,
    required this.solicitanteId,
    required this.nombreSolicitante,
    required this.emailSolicitante,
    this.telefonoSolicitante,
    required this.mascotaId,
    required this.nombreMascota,
    required this.especieMascota,
    this.razaMascota,
    required this.servicioId,
    required this.descripcionServicio,
    required this.motivoConsulta,
    this.sintomas,
    this.esUrgente = false,
    required this.fechaHoraSolicitada,
    required this.duracionEstimadaMin,
    this.veterinarioPreferidoId,
    this.salaPreferidaId,
    required this.costoEstimado,
    required this.montoAnticipo,
    required this.estado,
    required this.estadoNombre,
    required this.fechaSolicitud,
    this.fechaRespuesta,
    this.motivoRechazo,
    this.pagoAnticipoId,
    this.citaId,
    this.disponibilidadVerificada = false,
    this.notasInternas,
  });

  /// Crear desde JSON
  factory SolicitudCita.fromJson(Map<String, dynamic> json) {
    return SolicitudCita(
      id: json['id'] as String? ?? '',
      numeroSolicitud: json['numeroSolicitud'] as String? ?? '',
      solicitanteId: json['solicitanteId'] as String? ?? '',
      nombreSolicitante: json['nombreSolicitante'] as String? ?? '',
      emailSolicitante: json['emailSolicitante'] as String? ?? '',
      telefonoSolicitante: json['telefonoSolicitante'] as String?,
      mascotaId: json['mascotaId'] as String? ?? '',
      nombreMascota: json['nombreMascota'] as String? ?? '',
      especieMascota: json['especieMascota'] as String? ?? '',
      razaMascota: json['razaMascota'] as String?,
      servicioId: json['servicioId'] as String? ?? '',
      descripcionServicio: json['descripcionServicio'] as String? ?? '',
      motivoConsulta: json['motivoConsulta'] as String? ?? '',
      sintomas: json['sintomas'] as String?,
      esUrgente: json['esUrgente'] as bool? ?? false,
      fechaHoraSolicitada: json['fechaHoraSolicitada'] != null
          ? DateTime.parse(json['fechaHoraSolicitada'] as String)
          : DateTime.now(),
      duracionEstimadaMin: json['duracionEstimadaMin'] as int? ?? 30,
      veterinarioPreferidoId: json['veterinarioPreferidoId'] as String?,
      salaPreferidaId: json['salaPreferidaId'] as String?,
      costoEstimado: (json['costoEstimado'] as num?)?.toDouble() ?? 0.0,
      montoAnticipo: (json['montoAnticipo'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado'] != null
          ? SolicitudEstado.fromValue(json['estado'] as int)
          : SolicitudEstado.pendiente,
      estadoNombre: json['estadoNombre'] as String? ?? 'Pendiente',
      fechaSolicitud: json['fechaSolicitud'] != null
          ? DateTime.parse(json['fechaSolicitud'] as String)
          : DateTime.now(),
      fechaRespuesta: json['fechaRespuesta'] != null
          ? DateTime.parse(json['fechaRespuesta'] as String)
          : null,
      motivoRechazo: json['motivoRechazo'] as String?,
      pagoAnticipoId: json['pagoAnticipoId'] as String?,
      citaId: json['citaId'] as String?,
      disponibilidadVerificada:
          json['disponibilidadVerificada'] as bool? ?? false,
      notasInternas: json['notasInternas'] as String?,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numeroSolicitud': numeroSolicitud,
      'solicitanteId': solicitanteId,
      'nombreSolicitante': nombreSolicitante,
      'emailSolicitante': emailSolicitante,
      'telefonoSolicitante': telefonoSolicitante,
      'mascotaId': mascotaId,
      'nombreMascota': nombreMascota,
      'especieMascota': especieMascota,
      'razaMascota': razaMascota,
      'servicioId': servicioId,
      'descripcionServicio': descripcionServicio,
      'motivoConsulta': motivoConsulta,
      'sintomas': sintomas,
      'esUrgente': esUrgente,
      'fechaHoraSolicitada': fechaHoraSolicitada.toIso8601String(),
      'duracionEstimadaMin': duracionEstimadaMin,
      'veterinarioPreferidoId': veterinarioPreferidoId,
      'salaPreferidaId': salaPreferidaId,
      'costoEstimado': costoEstimado,
      'montoAnticipo': montoAnticipo,
      'estado': estado.value,
      'estadoNombre': estadoNombre,
      'fechaSolicitud': fechaSolicitud.toIso8601String(),
      'fechaRespuesta': fechaRespuesta?.toIso8601String(),
      'motivoRechazo': motivoRechazo,
      'pagoAnticipoId': pagoAnticipoId,
      'citaId': citaId,
      'disponibilidadVerificada': disponibilidadVerificada,
      'notasInternas': notasInternas,
    };
  }

  /// Verificar si requiere pago
  bool get requierePago {
    return estado == SolicitudEstado.pendientePago;
  }

  /// Verificar si el pago fue completado
  bool get pagoCompletado {
    return estado == SolicitudEstado.pagadaPendienteConfirmacion ||
        estado == SolicitudEstado.confirmada;
  }

  /// Verificar si puede cancelarse
  bool get puedeCancelarse {
    return estado != SolicitudEstado.confirmada &&
        estado != SolicitudEstado.cancelada &&
        estado != SolicitudEstado.rechazada &&
        estado != SolicitudEstado.expirada;
  }

  /// Calcular monto restante
  double get montoRestante {
    return costoEstimado - montoAnticipo;
  }

  @override
  List<Object?> get props => [
    id,
    numeroSolicitud,
    solicitanteId,
    nombreSolicitante,
    emailSolicitante,
    telefonoSolicitante,
    mascotaId,
    nombreMascota,
    especieMascota,
    razaMascota,
    servicioId,
    descripcionServicio,
    motivoConsulta,
    sintomas,
    esUrgente,
    fechaHoraSolicitada,
    duracionEstimadaMin,
    veterinarioPreferidoId,
    salaPreferidaId,
    costoEstimado,
    montoAnticipo,
    estado,
    estadoNombre,
    fechaSolicitud,
    fechaRespuesta,
    motivoRechazo,
    pagoAnticipoId,
    citaId,
    disponibilidadVerificada,
    notasInternas,
  ];
}

/// Request para crear solicitud de cita (según documentación API)
class CrearSolicitudCitaRequest {
  // ✅ Campos REQUERIDOS por el API
  final String solicitanteId; // Usuario que solicita
  final String mascotaId; // ID de la mascota
  final String nombreMascota; // Nombre de la mascota
  final String especieMascota; // Especie (Perro, Gato, etc.)
  final String? razaMascota; // Raza (opcional)
  final String servicioId; // ID del servicio
  final String descripcionServicio; // Descripción del servicio
  final String motivoConsulta; // Motivo de la consulta
  final String fechaHoraSolicitada; // Fecha/hora en formato ISO 8601
  final int duracionEstimadaMin; // Duración estimada en minutos
  final double costoEstimado; // Costo estimado del servicio

  const CrearSolicitudCitaRequest({
    required this.solicitanteId,
    required this.mascotaId,
    required this.nombreMascota,
    required this.especieMascota,
    this.razaMascota,
    required this.servicioId,
    required this.descripcionServicio,
    required this.motivoConsulta,
    required this.fechaHoraSolicitada,
    required this.duracionEstimadaMin,
    required this.costoEstimado,
  });

  Map<String, dynamic> toJson() {
    return {
      'solicitanteId': solicitanteId,
      'mascotaId': mascotaId,
      'nombreMascota': nombreMascota,
      'especieMascota': especieMascota,
      'razaMascota': razaMascota,
      'servicioId': servicioId,
      'descripcionServicio': descripcionServicio,
      'motivoConsulta': motivoConsulta,
      'fechaHoraSolicitada': fechaHoraSolicitada,
      'duracionEstimadaMin': duracionEstimadaMin,
      'costoEstimado': costoEstimado,
    };
  }
}

/// Modelo de servicio veterinario
class Servicio extends Equatable {
  final String id;
  final String descripcion;
  final int categoria;
  final int duracionMinDefault;
  final double precioSugerido;
  final bool activo;

  const Servicio({
    required this.id,
    required this.descripcion,
    required this.categoria,
    required this.duracionMinDefault,
    required this.precioSugerido,
    required this.activo,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    try {
      return Servicio(
        id: json['id']?.toString() ?? '',
        descripcion: json['descripcion']?.toString() ?? '',
        categoria: json['categoria'] is int
            ? json['categoria']
            : int.tryParse(json['categoria']?.toString() ?? '0') ?? 0,
        duracionMinDefault: json['duracionMinDefault'] is int
            ? json['duracionMinDefault']
            : int.tryParse(json['duracionMinDefault']?.toString() ?? '0') ?? 0,
        precioSugerido: json['precioSugerido'] != null
            ? double.tryParse(json['precioSugerido'].toString()) ?? 0.0
            : 0.0,
        activo:
            json['activo'] == true ||
            json['activo']?.toString().toLowerCase() == 'true',
      );
    } catch (e) {
      print('❌ Error en Servicio.fromJson: $e');
      print('   JSON recibido: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'categoria': categoria,
      'duracionMinDefault': duracionMinDefault,
      'precioSugerido': precioSugerido,
      'activo': activo,
    };
  }

  @override
  List<Object?> get props => [
    id,
    descripcion,
    categoria,
    duracionMinDefault,
    precioSugerido,
    activo,
  ];
}

/// Request para registrar mascota propia
class RegistrarMascotaRequest {
  final String nombre;
  final String especie;
  final String? raza;
  final DateTime? fechaNacimiento;
  final int sexo; // 1 = Macho, 2 = Hembra
  final String? personalidad;
  final String? estadoSalud;
  final String? notas;

  const RegistrarMascotaRequest({
    required this.nombre,
    required this.especie,
    this.raza,
    this.fechaNacimiento,
    required this.sexo,
    this.personalidad,
    this.estadoSalud,
    this.notas,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'sexo': sexo,
      'personalidad': personalidad,
      'estadoSalud': estadoSalud,
      'notas': notas,
    };
  }
}
