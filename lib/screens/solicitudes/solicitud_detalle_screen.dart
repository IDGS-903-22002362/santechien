import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/solicitud_cita.dart';
import '../../services/solicitud_cita_service.dart';
import '../citas/cita_detalle_screen.dart';

class SolicitudDetalleScreen extends StatefulWidget {
  final String solicitudId;

  const SolicitudDetalleScreen({super.key, required this.solicitudId});

  @override
  State<SolicitudDetalleScreen> createState() => _SolicitudDetalleScreenState();
}

class _SolicitudDetalleScreenState extends State<SolicitudDetalleScreen> {
  final _solicitudService = SolicitudCitaService();

  SolicitudCita? _solicitud;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarSolicitud();
  }

  Future<void> _cargarSolicitud() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _solicitudService.obtenerSolicitudPorId(
        widget.solicitudId,
      );

      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            _solicitud = response.data;
          } else {
            _errorMessage = response.message;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Solicitud')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _cargarSolicitud,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_solicitud == null) {
      return const Center(child: Text('Solicitud no encontrada'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Estado
        _buildEstadoCard(),
        const SizedBox(height: 16),

        // Información de la solicitud
        _buildInfoCard(),
        const SizedBox(height: 16),

        // Información de la mascota
        _buildMascotaCard(),
        const SizedBox(height: 16),

        // Información del servicio
        _buildServicioCard(),
        const SizedBox(height: 16),

        // Nota informativa sobre el proceso
        _buildProcesoCard(),

        // Botón para ver cita si está confirmada
        if (_solicitud!.estado == SolicitudEstado.confirmada &&
            _solicitud!.citaId != null) ...[
          const SizedBox(height: 16),
          _buildBotonVerCita(),
        ],
      ],
    );
  }

  Widget _buildEstadoCard() {
    Color color;
    IconData icon;

    switch (_solicitud!.estado) {
      case SolicitudEstado.pendiente:
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case SolicitudEstado.enRevision:
        color = Colors.blue;
        icon = Icons.visibility;
        break;
      case SolicitudEstado.confirmada:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case SolicitudEstado.rechazada:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case SolicitudEstado.cancelada:
        color = Colors.grey;
        icon = Icons.block;
        break;
      case SolicitudEstado.pendientePago:
        color = Colors.red;
        icon = Icons.payment;
        break;
      case SolicitudEstado.pagadaPendienteConfirmacion:
        color = Colors.purple;
        icon = Icons.hourglass_empty;
        break;
      case SolicitudEstado.expirada:
        color = Colors.grey;
        icon = Icons.timer_off;
        break;
    }

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              _solicitud!.estadoNombre,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Solicitud #${_solicitud!.numeroSolicitud}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de la Solicitud',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow(
              'Fecha de Solicitud',
              DateFormat('dd/MM/yyyy HH:mm').format(_solicitud!.fechaSolicitud),
            ),
            _buildInfoRow(
              'Fecha y Hora Solicitada',
              DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(_solicitud!.fechaHoraSolicitada),
            ),
            _buildInfoRow(
              'Duración Estimada',
              '${_solicitud!.duracionEstimadaMin} minutos',
            ),
            _buildInfoRow('Motivo', _solicitud!.motivoConsulta),
            if (_solicitud!.sintomas != null &&
                _solicitud!.sintomas!.isNotEmpty)
              _buildInfoRow('Síntomas', _solicitud!.sintomas!),
            _buildInfoRow('Es Urgente', _solicitud!.esUrgente ? '🚨 Sí' : 'No'),
            const Divider(),
            _buildInfoRow(
              'Teléfono',
              _solicitud!.telefonoSolicitante ?? 'No especificado',
            ),
            _buildInfoRow('Email', _solicitud!.emailSolicitante),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotaCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de la Mascota',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('Nombre', _solicitud!.nombreMascota),
            _buildInfoRow('Especie', _solicitud!.especieMascota),
            if (_solicitud!.razaMascota != null)
              _buildInfoRow('Raza', _solicitud!.razaMascota!),
          ],
        ),
      ),
    );
  }

  Widget _buildServicioCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Servicio Solicitado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('Servicio', _solicitud!.descripcionServicio),
          ],
        ),
      ),
    );
  }

  Widget _buildProcesoCard() {
    String mensaje;
    Color backgroundColor;
    IconData icon;

    switch (_solicitud!.estado) {
      case SolicitudEstado.pendiente:
      case SolicitudEstado.enRevision:
        mensaje = '''
📋 Tu solicitud está siendo revisada por nuestro equipo médico veterinario.

📞 Te contactaremos pronto para:
• Confirmar la fecha y hora
• Informarte sobre la cita creada
• Enviarte los detalles del pago

⏰ Por favor mantén tu teléfono disponible.
''';
        backgroundColor = Colors.blue[50]!;
        icon = Icons.info_outline;
        break;

      case SolicitudEstado.confirmada:
        mensaje = '''
✅ ¡Tu solicitud ha sido confirmada!

El personal médico ha creado tu cita. Pronto recibirás:
• Información detallada de la cita
• Instrucciones para realizar el pago del anticipo (50%)
• Fecha, hora y ubicación confirmadas

📧 Revisa tu email y mantén tu teléfono disponible.
''';
        backgroundColor = Colors.green[50]!;
        icon = Icons.check_circle_outline;
        break;

      case SolicitudEstado.rechazada:
        mensaje = '''
❌ Tu solicitud no pudo ser procesada.

Esto puede deberse a:
• Disponibilidad limitada en las fechas solicitadas
• Necesidad de información adicional
• Restricciones del servicio

📞 Contacta con nosotros para más información o intenta crear una nueva solicitud.
''';
        backgroundColor = Colors.red[50]!;
        icon = Icons.error_outline;
        break;

      case SolicitudEstado.cancelada:
        mensaje = '''
🚫 Esta solicitud ha sido cancelada.

Si necesitas atención veterinaria, puedes crear una nueva solicitud.
''';
        backgroundColor = Colors.grey[200]!;
        icon = Icons.block;
        break;

      case SolicitudEstado.pendientePago:
      case SolicitudEstado.pagadaPendienteConfirmacion:
      case SolicitudEstado.expirada:
        // Estados que no deberían aparecer según documentación
        mensaje =
            '''
⚠️ Estado: ${_solicitud!.estadoNombre}

Contacta con el personal para más información.
''';
        backgroundColor = Colors.orange[100]!;
        icon = Icons.warning_amber;
        break;
    }

    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Estado del Proceso',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Text(mensaje, style: const TextStyle(fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonVerCita() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.event_available, color: Colors.green[700], size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Cita Creada!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tu solicitud fue confirmada y se creó tu cita',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CitaDetalleScreen(
                        citaId: _solicitud!.id,
                      ), // ✅ Pasar el ID de la solicitud
                    ),
                  ).then((_) => _cargarSolicitud());
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Ver Detalles de la Cita'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aquí podrás ver los detalles y realizar el pago del anticipo',
              style: TextStyle(fontSize: 12, color: Colors.green[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? color,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
