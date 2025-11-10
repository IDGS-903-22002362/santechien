import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/cita_provider.dart';
import '../../models/cita.dart';
import '../../config/app_theme.dart';
import 'pagar_cita_screen.dart';

/// Pantalla de detalle de una cita
class CitaDetalleScreen extends StatefulWidget {
  final String citaId;

  const CitaDetalleScreen({super.key, required this.citaId});

  @override
  State<CitaDetalleScreen> createState() => _CitaDetalleScreenState();
}

class _CitaDetalleScreenState extends State<CitaDetalleScreen> {
  Cita? _cita;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCita();
  }

  Future<void> _cargarCita() async {
    setState(() => _isLoading = true);
    final citaProvider = context.read<CitaProvider>();
    final cita = await citaProvider.obtenerCitaPorId(widget.citaId);

    if (mounted) {
      setState(() {
        _cita = cita;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Cita')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cita == null
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
            onPressed: _cargarCita,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalle() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEstadoCard(),
          const SizedBox(height: 16),
          _buildInformacionCard(),
          const SizedBox(height: 16),
          _buildMascotaCard(),
          const SizedBox(height: 16),
          _buildVeterinarioCard(),
          if (_cita!.motivo != null) ...[
            const SizedBox(height: 16),
            _buildMotivoCard(),
          ],
          if (_cita!.notas != null) ...[
            const SizedBox(height: 16),
            _buildNotasCard(),
          ],
          if (_cita!.diagnostico != null) ...[
            const SizedBox(height: 16),
            _buildDiagnosticoCard(),
          ],
          if (_cita!.requiereAnticipo) ...[
            const SizedBox(height: 16),
            _buildPagoCard(),
          ],
          if (_cita!.puedeCancelarse) ...[
            const SizedBox(height: 24),
            _buildBotonCancelar(),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEstadoCard() {
    Color color;
    IconData icon;
    String descripcion;

    switch (_cita!.status) {
      case CitaStatus.programada:
        color = Colors.blue;
        icon = Icons.schedule;
        descripcion = 'Tu cita ha sido programada';
        break;
      case CitaStatus.confirmada:
        color = Colors.green;
        icon = Icons.check_circle;
        descripcion = 'Tu cita ha sido confirmada';
        break;
      case CitaStatus.enProceso:
        color = Colors.orange;
        icon = Icons.pending;
        descripcion = 'Tu cita está en proceso';
        break;
      case CitaStatus.completada:
        color = Colors.purple;
        icon = Icons.done_all;
        descripcion = 'Tu cita ha sido completada';
        break;
      case CitaStatus.cancelada:
        color = Colors.red;
        icon = Icons.cancel;
        descripcion = 'Esta cita fue cancelada';
        break;
      case CitaStatus.noAsistio:
        color = Colors.grey;
        icon = Icons.event_busy;
        descripcion = 'No asististe a esta cita';
        break;
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
                    _cita!.status.label,
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

  Widget _buildInformacionCard() {
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
              DateFormat('EEEE, d MMMM yyyy', 'es').format(_cita!.fechaHora),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.access_time,
              'Hora',
              DateFormat('HH:mm', 'es').format(_cita!.fechaHora),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.timer,
              'Duración',
              '${_cita!.duracionMinutos} minutos',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.medical_services,
              'Tipo de Consulta',
              _cita!.tipoConsulta,
            ),
            if (_cita!.numeroTicket != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                Icons.confirmation_number,
                'Número de Ticket',
                _cita!.numeroTicket!,
              ),
            ],
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
              _cita!.mascotaNombre ?? 'N/A',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVeterinarioCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Veterinario',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _cita!.veterinarioNombre ?? 'N/A',
              style: const TextStyle(fontSize: 16),
            ),
            if (_cita!.salaNombre != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.meeting_room, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _cita!.salaNombre!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMotivoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Motivo de la Consulta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_cita!.motivo!, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotasCard() {
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
                  'Notas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_cita!.notas!, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticoCard() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Diagnóstico',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_cita!.diagnostico!, style: const TextStyle(fontSize: 14)),
            if (_cita!.tratamiento != null) ...[
              const Divider(height: 24),
              const Text(
                'Tratamiento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(_cita!.tratamiento!, style: const TextStyle(fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPagoCard() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Información de Pago',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Costo total: \$${_cita!.costoTotal?.toStringAsFixed(2) ?? '0.00'} MXN',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Anticipo requerido (50%): \$${_cita!.calculoAnticipo?.toStringAsFixed(2) ?? '0.00'} MXN',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PagarCitaScreen(cita: _cita!),
                    ),
                  ).then((_) => _cargarCita());
                },
                icon: const Icon(Icons.payment),
                label: const Text('Pagar Ahora'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonCancelar() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _mostrarDialogoCancelar,
        icon: const Icon(Icons.cancel),
        label: const Text('Cancelar Cita'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
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

  void _mostrarDialogoCancelar() {
    final motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que deseas cancelar esta cita?',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo de cancelación',
                hintText: 'Ingresa el motivo',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver'),
          ),
          ElevatedButton(
            onPressed: () async {
              final motivo = motivoController.text.trim();
              if (motivo.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debes ingresar un motivo de cancelación'),
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _cancelarCita(motivo);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancelar Cita'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelarCita(String motivo) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final citaProvider = context.read<CitaProvider>();
    final exito = await citaProvider.cancelarCita(
      citaId: _cita!.id,
      motivo: motivo,
    );

    if (mounted) {
      Navigator.pop(context); // Cerrar loading

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita cancelada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Volver a la lista
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              citaProvider.errorMessage ?? 'Error al cancelar la cita',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
