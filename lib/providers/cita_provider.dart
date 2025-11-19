import 'package:flutter/foundation.dart';
import '../models/cita.dart';
import '../models/mascota.dart';
import '../models/veterinario.dart';
import '../models/solicitud_cita.dart';
import '../services/cita_service.dart';
import '../services/mascota_service.dart';
import '../services/veterinario_service.dart';
import '../services/solicitud_cita_service.dart';
import 'auth_provider.dart';

/// Provider para gestión de citas
class CitaProvider with ChangeNotifier {
  final CitaService _citaService = CitaService();
  final MascotaService _mascotaService = MascotaService();
  final VeterinarioService _veterinarioService = VeterinarioService();
  final SolicitudCitaService _solicitudService = SolicitudCitaService();

  // Estado
  List<Cita> _citas = [];
  List<SolicitudCita> _solicitudesConfirmadas = [];
  List<Mascota> _mascotas = [];
  List<Veterinario> _veterinarios = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Cita> get citas => _citas;
  List<Mascota> get mascotas => _mascotas;
  List<Veterinario> get veterinarios => _veterinarios;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Obtener citas del propietario actual (desde solicitudes confirmadas)
  /// Usa GET /api/v1/SolicitudesCitasDigitales/usuario/{usuarioId}
  /// Filtra solo las confirmadas (estado = 5)
  Future<bool> cargarMisCitas({String? usuarioId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📅 Cargando mis citas desde solicitudes confirmadas...');

      if (usuarioId == null || usuarioId.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _solicitudService.obtenerMisSolicitudes(usuarioId);

      print('📦 Respuesta solicitudes:');
      print('   success: ${response.success}');
      print('   message: ${response.message}');
      print('   data count: ${response.data?.length ?? 0}');

      if (response.success && response.data != null) {
        // Filtrar solo las solicitudes CONFIRMADAS (estado = 5)
        _solicitudesConfirmadas = response.data!
            .where(
              (solicitud) => solicitud.estado == SolicitudEstado.confirmada,
            )
            .toList();

        print('✅ Solicitudes confirmadas: ${_solicitudesConfirmadas.length}');

        // Convertir solicitudes confirmadas a Citas para mantener compatibilidad
        _citas = _solicitudesConfirmadas.map((solicitud) {
          return Cita(
            id: solicitud.citaId ?? solicitud.id,
            fechaHora: solicitud.fechaHoraSolicitada,
            duracionMinutos: solicitud.duracionEstimadaMin,
            status: CitaStatus.confirmada,
            tipoConsulta: solicitud.descripcionServicio,
            motivo: solicitud.motivoConsulta,
            mascotaId: solicitud.mascotaId,
            mascotaNombre: solicitud.nombreMascota,
            veterinarioId: solicitud.veterinarioPreferidoId ?? '',
            costoTotal: solicitud.costoEstimado,
            montoAnticipo: solicitud.montoAnticipo,
            requierePago: false,
            pagoCompletado: true,
          );
        }).toList();

        _citas.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
        print('✅ Citas cargadas: ${_citas.length}');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _citas = [];
        _solicitudesConfirmadas = [];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Error al cargar citas: $e');
      print('   Stack trace: $stackTrace');

      _errorMessage = 'Error al cargar citas: $e';
      _citas = [];
      _solicitudesConfirmadas = [];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Obtener citas programadas (futuras)
  List<Cita> get citasProgramadas {
    final ahora = DateTime.now();
    return _citas
        .where(
          (cita) =>
              cita.fechaHora.isAfter(ahora) &&
              (cita.status == CitaStatus.programada ||
                  cita.status == CitaStatus.confirmada),
        )
        .toList();
  }

  /// Obtener citas pasadas
  List<Cita> get citasPasadas {
    final ahora = DateTime.now();
    return _citas
        .where(
          (cita) =>
              cita.fechaHora.isBefore(ahora) ||
              cita.status == CitaStatus.completada,
        )
        .toList();
  }

  /// Obtener citas canceladas
  List<Cita> get citasCanceladas {
    return _citas.where((cita) => cita.status == CitaStatus.cancelada).toList();
  }

  /// Cargar mascotas del propietario
  Future<bool> cargarMisMascotas() async {
    try {
      final response = await _mascotaService.obtenerMisMascotas();

      if (response.success && response.data != null) {
        _mascotas = response.data!;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al cargar mascotas: $e';
      notifyListeners();
      return false;
    }
  }

  /// Cargar veterinarios disponibles
  Future<bool> cargarVeterinarios() async {
    try {
      final response = await _veterinarioService.obtenerVeterinariosActivos();

      if (response.success && response.data != null) {
        _veterinarios = response.data!;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al cargar veterinarios: $e';
      notifyListeners();
      return false;
    }
  }

  /// Crear nueva cita
  Future<Cita?> crearCita(CrearCitaRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _citaService.crearCita(request);

      if (response.success && response.data != null) {
        _citas.insert(0, response.data!);
        _citas.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
        _isLoading = false;
        notifyListeners();
        return response.data;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error al crear la cita: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Cancelar cita
  Future<bool> cancelarCita({
    required String citaId,
    required String motivo,
    String? notas,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _citaService.cancelarCita(
        citaId: citaId,
        motivo: motivo,
        notas: notas,
      );

      if (response.success && response.data != null) {
        // Actualizar la cita en la lista
        final index = _citas.indexWhere((c) => c.id == citaId);
        if (index != -1) {
          _citas[index] = response.data!;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al cancelar la cita: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Confirmar cita
  /// Cambia el estado de la cita a "Confirmada" (generalmente después del pago)
  Future<bool> confirmarCita({required String citaId, String? notas}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _citaService.confirmarCita(
        citaId: citaId,
        notas: notas,
      );

      if (response.success && response.data != null) {
        // Actualizar la cita en la lista
        final index = _citas.indexWhere((c) => c.id == citaId);
        if (index != -1) {
          _citas[index] = response.data!;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al confirmar la cita: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reagendar cita
  /// Cambia la fecha/hora de una cita existente
  Future<bool> reagendarCita({
    required String citaId,
    required DateTime nuevaFechaHora,
    int? nuevaDuracionMinutos,
    String? motivo,
    String? notas,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _citaService.reagendarCita(
        citaId: citaId,
        nuevaFechaHora: nuevaFechaHora,
        nuevaDuracionMinutos: nuevaDuracionMinutos,
        motivo: motivo,
        notas: notas,
      );

      if (response.success && response.data != null) {
        // Actualizar la cita en la lista
        final index = _citas.indexWhere((c) => c.id == citaId);
        if (index != -1) {
          _citas[index] = response.data!;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al reagendar la cita: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Obtener cita por ID
  Future<Cita?> obtenerCitaPorId(String citaId) async {
    try {
      final response = await _citaService.obtenerCitaPorId(citaId);

      if (response.success && response.data != null) {
        return response.data;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error al obtener la cita: $e';
      notifyListeners();
      return null;
    }
  }

  /// Verificar disponibilidad de horarios
  /// Retorna la respuesta completa de disponibilidad con horarios disponibles y ocupados
  Future<DisponibilidadResponse?> verificarDisponibilidad({
    required String veterinarioId,
    required DateTime fecha,
    required int duracionMinutos,
  }) async {
    try {
      final response = await _citaService.verificarDisponibilidad(
        veterinarioId: veterinarioId,
        fecha: fecha,
        duracionMinutos: duracionMinutos,
      );

      if (response.success && response.data != null) {
        return response.data;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error al verificar disponibilidad: $e';
      notifyListeners();
      return null;
    }
  }

  /// Verificar disponibilidad (método legacy - retorna Map)
  /// @deprecated Usar verificarDisponibilidad en su lugar
  @Deprecated('Usar verificarDisponibilidad que retorna DisponibilidadResponse')
  Future<Map<String, dynamic>?> verificarDisponibilidadLegacy({
    required String veterinarioId,
    required DateTime fecha,
    required int duracionMinutos,
  }) async {
    try {
      final response = await _citaService.verificarDisponibilidadLegacy(
        veterinarioId: veterinarioId,
        fecha: fecha,
        duracionMinutos: duracionMinutos,
      );

      if (response.success && response.data != null) {
        return response.data;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error al verificar disponibilidad: $e';
      notifyListeners();
      return null;
    }
  }

  /// Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refrescar datos
  Future<void> refresh() async {
    await cargarMisCitas();
    await cargarMisMascotas();
    await cargarVeterinarios();
  }
}
