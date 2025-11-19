import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/solicitud_cita.dart';
import '../../services/solicitud_cita_service.dart';
import '../../providers/auth_provider.dart';
import 'solicitud_detalle_screen.dart';

class MisSolicitudesScreen extends StatefulWidget {
  const MisSolicitudesScreen({super.key});

  @override
  State<MisSolicitudesScreen> createState() => _MisSolicitudesScreenState();
}

class _MisSolicitudesScreenState extends State<MisSolicitudesScreen> {
  final _solicitudService = SolicitudCitaService();
  List<SolicitudCita> _solicitudes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
  }

  Future<void> _cargarSolicitudes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final usuario = authProvider.usuario;

      if (usuario == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _solicitudService.obtenerMisSolicitudes(
        usuario.id,
      );

      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            _solicitudes = response.data!;
            // Ordenar por fecha de solicitud (más recientes primero)
            _solicitudes.sort(
              (a, b) => b.fechaSolicitud.compareTo(a.fechaSolicitud),
            );
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
      appBar: AppBar(
        title: const Text('Mis Solicitudes de Cita'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarSolicitudes,
            tooltip: 'Recargar',
          ),
        ],
      ),
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
              onPressed: _cargarSolicitudes,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_solicitudes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No tienes solicitudes de cita',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Tus solicitudes de cita aparecerán aquí',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarSolicitudes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _solicitudes.length,
        itemBuilder: (context, index) {
          final solicitud = _solicitudes[index];
          return _SolicitudCard(
            solicitud: solicitud,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SolicitudDetalleScreen(solicitudId: solicitud.id),
                ),
              ).then((_) => _cargarSolicitudes()); // Recargar al volver
            },
          );
        },
      ),
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  final SolicitudCita solicitud;
  final VoidCallback onTap;

  const _SolicitudCard({required this.solicitud, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: N?mero y estado
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      solicitud.numeroSolicitud,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _buildEstadoChip(),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),

              // Mascota y servicio
              Row(
                children: [
                  const Icon(Icons.pets, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${solicitud.nombreMascota} (${solicitud.especieMascota})',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.medical_services,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      solicitud.descripcionServicio,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Fecha y hora solicitada
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat(
                      'dd/MM/yyyy HH:mm',
                    ).format(solicitud.fechaHoraSolicitada),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Motivo
              Row(
                children: [
                  const Icon(Icons.description, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      solicitud.motivoConsulta,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Indicadores
              const SizedBox(height: 8),
              Row(
                children: [
                  // Indicador de urgencia
                  if (solicitud.esUrgente)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.warning, size: 16, color: Colors.red),
                          SizedBox(width: 4),
                          Text(
                            'URGENTE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Indicador de cita creada
                  if (solicitud.estado == SolicitudEstado.confirmada &&
                      solicitud.citaId != null) ...[
                    if (solicitud.esUrgente) const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.event_available,
                              size: 16,
                              color: Colors.green,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'CITA CREADA',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoChip() {
    Color color;
    IconData icon;

    switch (solicitud.estado) {
      case SolicitudEstado.pendiente:
        color = AppTheme.warningColor;
        icon = Icons.schedule;
        break;
      case SolicitudEstado.enRevision:
        color = AppTheme.infoColor;
        icon = Icons.visibility;
        break;
      case SolicitudEstado.pendientePago:
        color = AppTheme.errorColor;
        icon = Icons.payment;
        break;
      case SolicitudEstado.pagadaPendienteConfirmacion:
        color = AppTheme.primaryDark;
        icon = Icons.hourglass_empty;
        break;
      case SolicitudEstado.confirmada:
        color = AppTheme.successColor;
        icon = Icons.check_circle;
        break;
      case SolicitudEstado.rechazada:
        color = AppTheme.errorColor;
        icon = Icons.cancel;
        break;
      case SolicitudEstado.cancelada:
        color = AppTheme.textSecondary;
        icon = Icons.block;
        break;
      case SolicitudEstado.expirada:
        color = AppTheme.textSecondary;
        icon = Icons.timer_off;
        break;
    }

    final label = solicitud.estadoNombre.isNotEmpty
        ? solicitud.estadoNombre
        : solicitud.estado.label;

    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
