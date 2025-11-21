import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/cita_provider.dart';
import '../../models/solicitud_cita.dart';
import '../../config/app_theme.dart';

/// Pantalla de detalle de una cita
/// Muestra información completa de la solicitud de cita confirmada
class CitaDetalleScreen extends StatefulWidget {
  final String citaId; // En realidad es el solicitudId

  const CitaDetalleScreen({super.key, required this.citaId});

  @override
  State<CitaDetalleScreen> createState() => _CitaDetalleScreenState();
}

class _CitaDetalleScreenState extends State<CitaDetalleScreen> {
  SolicitudCitaDetallada? _solicitudDetalle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDetalleSolicitud();
  }

  Future<void> _cargarDetalleSolicitud() async {
    setState(() => _isLoading = true);

    final citaProvider = context.read<CitaProvider>();
    print('🔍 Cargando detalles de solicitud: ${widget.citaId}');

    final solicitudDetalle = await citaProvider.obtenerSolicitudDetallePorId(
      widget.citaId,
    );

    if (mounted) {
      setState(() {
        _solicitudDetalle = solicitudDetalle;
        _isLoading = false;
      });

      if (solicitudDetalle != null) {
        print('✅ Detalles cargados: ${solicitudDetalle.numeroSolicitud}');
      } else {
        print('❌ No se pudo cargar los detalles');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Cita')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _solicitudDetalle == null
          ? _buildError()
          : _buildDetalle(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text(
            'No se pudo cargar la cita',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _cargarDetalleSolicitud,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalle() {
    final solicitud = _solicitudDetalle!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEstadoCard(),
          const SizedBox(height: 16),
          _buildInformacionSolicitudCard(),
          const SizedBox(height: 16),
          _buildInformacionCard(),
          const SizedBox(height: 16),
          _buildMascotaCard(),
          const SizedBox(height: 16),
          if (solicitud.cita != null) ...[
            _buildCitaConfirmadaCard(),
            const SizedBox(height: 16),
          ],
          if (solicitud.pagoAnticipo != null) ...[
            _buildPagoAnticipoCard(),
            const SizedBox(height: 16),
          ],
          if (solicitud.observaciones != null) ...[
            _buildObservacionesCard(),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEstadoCard() {
    final solicitud = _solicitudDetalle!;
    Color color;
    IconData icon;
    String descripcion;

    // Usar el estado de la solicitud
    final estadoNombre = solicitud.estadoNombre;

    switch (estadoNombre.toLowerCase()) {
      case 'confirmada':
        color = Colors.green;
        icon = Icons.check_circle;
        descripcion = 'Tu cita ha sido confirmada';
        break;
      case 'pendiente pago':
        color = Colors.orange;
        icon = Icons.payment;
        descripcion = 'Pendiente de pago';
        break;
      case 'pagada - pendiente confirmación':
        color = Colors.blue;
        icon = Icons.pending;
        descripcion = 'Pago completado, esperando confirmación';
        break;
      case 'cancelada':
        color = Colors.red;
        icon = Icons.cancel;
        descripcion = 'Esta cita fue cancelada';
        break;
      case 'rechazada':
        color = Colors.red;
        icon = Icons.block;
        descripcion = 'Esta solicitud fue rechazada';
        break;
      default:
        color = Colors.blue;
        icon = Icons.schedule;
        descripcion = 'Solicitud en proceso';
    }

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    estadoNombre,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: TextStyle(
                      fontSize: 14,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionSolicitudCard() {
    final solicitud = _solicitudDetalle!;

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
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.confirmation_number,
              'Número de Solicitud',
              solicitud.numeroSolicitud,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha de Solicitud',
              DateFormat(
                'd MMMM yyyy, HH:mm',
                'es',
              ).format(solicitud.fechaSolicitud),
            ),
            if (solicitud.fechaConfirmacion != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                Icons.check_circle,
                'Fecha de Confirmación',
                DateFormat(
                  'd MMMM yyyy, HH:mm',
                  'es',
                ).format(solicitud.fechaConfirmacion!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionCard() {
    final solicitud = _solicitudDetalle!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de la Cita',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha',
              DateFormat(
                'EEEE, d MMMM yyyy',
                'es',
              ).format(solicitud.fechaHoraSolicitada),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.access_time,
              'Hora',
              DateFormat('HH:mm', 'es').format(solicitud.fechaHoraSolicitada),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.timer,
              'Duración Estimada',
              '${solicitud.duracionEstimadaMin} minutos',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.medical_services,
              'Servicio',
              solicitud.descripcionServicio,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.description,
              'Motivo de Consulta',
              solicitud.motivoConsulta,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.attach_money,
              'Costo Estimado',
              '\$${solicitud.costoEstimado.toStringAsFixed(2)} MXN',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.payment,
              'Anticipo (50%)',
              '\$${solicitud.montoAnticipo.toStringAsFixed(2)} MXN',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotaCard() {
    final solicitud = _solicitudDetalle!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Mascota',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              solicitud.nombreMascota,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '${solicitud.especieMascota}${solicitud.razaMascota != null ? ' - ${solicitud.razaMascota}' : ''}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCitaConfirmadaCard() {
    final cita = _solicitudDetalle!.cita!;

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_available, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Cita Confirmada',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha y Hora de Inicio',
              DateFormat(
                'EEEE, d MMMM yyyy - HH:mm',
                'es',
              ).format(cita.fechaHoraInicio),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.access_time,
              'Hora de Fin',
              DateFormat('HH:mm', 'es').format(cita.fechaHoraFin),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.check_circle,
              'Estado de la Cita',
              cita.estadoNombre,
            ),
            if (cita.veterinario != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                Icons.person,
                'Veterinario Asignado',
                cita.veterinario!.nombre,
              ),
            ],
            if (cita.sala != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                Icons.meeting_room,
                'Sala Asignada',
                cita.sala!.nombre,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPagoAnticipoCard() {
    final pago = _solicitudDetalle!.pagoAnticipo!;

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Información de Pago',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.confirmation_number,
              'Número de Pago',
              pago.numeroPago,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.attach_money,
              'Monto',
              '\$${pago.monto.toStringAsFixed(2)} ${pago.moneda}',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.credit_card,
              'Método de Pago',
              pago.metodoNombre,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.check_circle,
              'Estado del Pago',
              pago.estadoNombre,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha de Pago',
              DateFormat('d MMMM yyyy, HH:mm', 'es').format(pago.fechaPago),
            ),
            if (pago.payPalOrderId != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                Icons.receipt,
                'PayPal Order ID',
                pago.payPalOrderId!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildObservacionesCard() {
    final solicitud = _solicitudDetalle!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Observaciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              solicitud.observaciones!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
