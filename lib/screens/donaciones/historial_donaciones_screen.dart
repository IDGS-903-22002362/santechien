import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/donacion_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/donacion.dart';

/// Pantalla para ver el historial de donaciones
class HistorialDonacionesScreen extends StatefulWidget {
  const HistorialDonacionesScreen({super.key});

  @override
  State<HistorialDonacionesScreen> createState() =>
      _HistorialDonacionesScreenState();
}

class _HistorialDonacionesScreenState extends State<HistorialDonacionesScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar donaciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final usuarioId = authProvider.usuario?.id;
      if (usuarioId != null) {
        Provider.of<DonacionProvider>(
          context,
          listen: false,
        ).cargarMisDonaciones(usuarioId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Donaciones'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final usuarioId = authProvider.usuario?.id;
          if (usuarioId != null) {
            await Provider.of<DonacionProvider>(
              context,
              listen: false,
            ).cargarMisDonaciones(usuarioId);
          }
        },
        child: Consumer<DonacionProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null) {
              return _buildError(provider.errorMessage!);
            }

            if (provider.misDonaciones.isEmpty) {
              return _buildEmpty();
            }

            return Column(
              children: [
                _buildResumen(provider),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.misDonaciones.length,
                    itemBuilder: (context, index) {
                      final donacion = provider.misDonaciones[index];
                      return _buildDonacionCard(donacion);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildResumen(DonacionProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildResumenItem(
              'Total Donado',
              '\$${provider.totalDonado.toStringAsFixed(2)} MXN',
              Icons.attach_money,
            ),
          ),
          Container(width: 1, height: 50, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: _buildResumenItem(
              'Donaciones',
              '${provider.numeroCompletadas}',
              Icons.favorite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenItem(String label, String valor, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildDonacionCard(Donacion donacion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _mostrarDetalles(donacion),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono de estado
                  _buildEstadoIcon(donacion.statusEnum),
                  const SizedBox(width: 12),

                  // Información principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${donacion.monto.toStringAsFixed(2)} ${donacion.moneda}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatearFecha(donacion.createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badge de estado
                  _buildEstadoBadge(donacion.statusEnum, donacion.statusNombre),
                ],
              ),

              // Mensaje si existe
              if (donacion.mensaje != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.message_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        donacion.mensaje!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Anónima
              if (donacion.anonima) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.visibility_off,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Donación anónima',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoIcon(StatusDonacion status) {
    IconData icon;
    Color color;

    switch (status) {
      case StatusDonacion.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case StatusDonacion.pending:
        icon = Icons.pending;
        color = Colors.orange;
        break;
      case StatusDonacion.processing:
        icon = Icons.hourglass_empty;
        color = Colors.blue;
        break;
      case StatusDonacion.cancelled:
        icon = Icons.cancel;
        color = Colors.grey;
        break;
      case StatusDonacion.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildEstadoBadge(StatusDonacion status, String statusNombre) {
    Color color;

    switch (status) {
      case StatusDonacion.completed:
        color = Colors.green;
        break;
      case StatusDonacion.pending:
        color = Colors.orange;
        break;
      case StatusDonacion.processing:
        color = Colors.blue;
        break;
      case StatusDonacion.cancelled:
        color = Colors.grey;
        break;
      case StatusDonacion.failed:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        statusNombre,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Aún no has realizado donaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '¡Ayuda a las mascotas realizando tu primera donación!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.volunteer_activism),
              label: const Text('Hacer Donación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String mensaje) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                final usuarioId = authProvider.usuario?.id;
                if (usuarioId != null) {
                  Provider.of<DonacionProvider>(
                    context,
                    listen: false,
                  ).cargarMisDonaciones(usuarioId);
                }
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final formatter = DateFormat('dd MMM yyyy, HH:mm', 'es');
    return formatter.format(fecha);
  }

  void _mostrarDetalles(Donacion donacion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Detalles de la Donación',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildDetalleItem(
                  'Monto',
                  '\$${donacion.monto.toStringAsFixed(2)} ${donacion.moneda}',
                ),
                _buildDetalleItem('Estado', donacion.statusNombre),
                _buildDetalleItem('Fecha', _formatearFecha(donacion.createdAt)),

                if (donacion.payPalOrderId != null)
                  _buildDetalleItem('PayPal Order ID', donacion.payPalOrderId!),

                if (donacion.mensaje != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Mensaje:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(donacion.mensaje!, style: const TextStyle(fontSize: 15)),
                ],

                if (donacion.anonima) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.visibility_off, color: Colors.grey[700]),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Esta donación es anónima',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetalleItem(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
