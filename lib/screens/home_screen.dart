import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';

/// Pantalla principal (Home)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleSignOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signOut();

      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdoPets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleSignOut(context),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      drawer: Drawer(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final usuario = authProvider.usuario;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient(),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      usuario?.iniciales ?? '??',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  accountName: Text(
                    usuario?.nombreCompleto ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(usuario?.email ?? ''),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Inicio'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Mis Citas'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/citas');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event_available),
                  title: const Text('Solicitar Cita'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/solicitar-cita');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment),
                  title: const Text('Mis Solicitudes'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/mis-solicitudes');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.pets),
                  title: const Text('Mis Mascotas'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/mis-mascotas');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('Mis Favoritos'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navegar a favoritos
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Mis Adopciones'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navegar a adopciones
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Mi Perfil'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navegar a perfil
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configuración'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navegar a configuración
                  },
                ),
                const Divider(),
                // Solo en desarrollo
                ListTile(
                  leading: const Icon(Icons.bug_report, color: Colors.orange),
                  title: const Text(
                    '🔍 Debug Auth',
                    style: TextStyle(color: Colors.orange),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/debug-auth');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.article, color: Colors.blue),
                  title: const Text(
                    '📋 Ver Logs',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/ui-logs');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppTheme.errorColor),
                  title: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleSignOut(context);
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final usuario = authProvider.usuario;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar grande
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient(),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        usuario?.iniciales ?? '??',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nombre
                  Text(
                    '¡Hola, ${usuario?.nombre ?? 'Usuario'}!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Email
                  Text(
                    usuario?.email ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Roles
                  if (usuario?.roles.isNotEmpty ?? false)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: usuario!.roles.map((rol) {
                        return Chip(
                          label: Text(rol),
                          backgroundColor: AppTheme.primaryLight,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 48),

                  // Mensaje de bienvenida
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.pets,
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Bienvenido a AdoPets',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Gestiona las citas de tus mascotas de manera fácil y rápida.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/mis-mascotas');
                                },
                                icon: const Icon(Icons.pets),
                                label: const Text('Mis Mascotas'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/solicitar-cita',
                                  );
                                },
                                icon: const Icon(Icons.add_circle),
                                label: const Text('Solicitar Cita'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
