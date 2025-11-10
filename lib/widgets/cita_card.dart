import 'package:flutter/material.dart';
import '../models/cita.dart';
import '../config/app_theme.dart';
import 'package:intl/intl.dart';

/// Widget de tarjeta de cita
class CitaCard extends StatelessWidget {
  final Cita cita;
  final VoidCallback? onTap;
  final VoidCallback? onPagar;
  final VoidCallback? onCancelar;

  const CitaCard({
    super.key,
    required this.cita,
    this.onTap,
    this.onPagar,
    this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusBadge(),
                  Text(
                    _formatFecha(cita.fechaHora),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Información principal
              Row(
                children: [
                  Icon(Icons.pets, color: AppTheme.primaryColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cita.mascotaNombre ?? 'Mascota',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cita.tipoConsulta,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Veterinario y hora
              Row(
                children: [
                  Icon(
                    Icons.medical_services,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cita.veterinarioNombre ?? 'Veterinario',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ),
                  Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _formatHora(cita.fechaHora),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Motivo
              if (cita.motivo != null) ...[
                const SizedBox(height: 8),
                Text(
                  cita.motivo!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Información de pago
              if (cita.requiereAnticipo) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.payment, color: Colors.orange[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Requiere pago de anticipo: \$${cita.calculoAnticipo?.toStringAsFixed(2) ?? '0.00'} MXN',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Botones de acción
              if ((cita.puedeCancelarse && onCancelar != null) ||
                  (cita.requiereAnticipo && onPagar != null)) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (cita.puedeCancelarse && onCancelar != null)
                      TextButton.icon(
                        onPressed: onCancelar,
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('Cancelar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    if (cita.requiereAnticipo && onPagar != null) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: onPagar,
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text('Pagar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    IconData icon;

    switch (cita.status) {
      case CitaStatus.programada:
        color = Colors.blue;
        icon = Icons.schedule;
        break;
      case CitaStatus.confirmada:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case CitaStatus.enProceso:
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case CitaStatus.completada:
        color = Colors.purple;
        icon = Icons.done_all;
        break;
      case CitaStatus.cancelada:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case CitaStatus.noAsistio:
        color = Colors.grey;
        icon = Icons.event_busy;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            cita.status.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = fecha.difference(ahora).inDays;

    if (diferencia == 0) {
      return 'Hoy';
    } else if (diferencia == 1) {
      return 'Mañana';
    } else if (diferencia == -1) {
      return 'Ayer';
    } else {
      return DateFormat('dd/MM/yyyy', 'es').format(fecha);
    }
  }

  String _formatHora(DateTime fecha) {
    return DateFormat('HH:mm', 'es').format(fecha);
  }
}
