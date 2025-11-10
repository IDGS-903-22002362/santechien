import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cita_provider.dart';
import '../screens/citas/citas_screen.dart';
import '../config/app_theme.dart';

/// Widget de navegación rápida a citas en el Home
class CitasQuickAccessWidget extends StatelessWidget {
  const CitasQuickAccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CitasScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<CitaProvider>(
            builder: (context, citaProvider, child) {
              final proximasCitas = citaProvider.citasProgramadas;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Mis Citas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (proximasCitas.isEmpty)
                    Text(
                      'No tienes citas programadas',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${proximasCitas.length} ${proximasCitas.length == 1 ? 'cita próxima' : 'citas próximas'}',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toca para ver detalles',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Botón flotante para acceso rápido a nueva cita
class NuevaCitaFloatingButton extends StatelessWidget {
  const NuevaCitaFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CitasScreen()),
        );
      },
      backgroundColor: AppTheme.primaryColor,
      icon: const Icon(Icons.add),
      label: const Text('Nueva Cita'),
    );
  }
}

/// Item de menú lateral para citas
class CitasDrawerItem extends StatelessWidget {
  const CitasDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CitaProvider>(
      builder: (context, citaProvider, child) {
        final proximasCitas = citaProvider.citasProgramadas;

        return ListTile(
          leading: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
          title: const Text('Mis Citas'),
          subtitle: proximasCitas.isNotEmpty
              ? Text('${proximasCitas.length} próximas')
              : null,
          trailing: proximasCitas.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${proximasCitas.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          onTap: () {
            Navigator.pop(context); // Cerrar drawer
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CitasScreen()),
            );
          },
        );
      },
    );
  }
}
