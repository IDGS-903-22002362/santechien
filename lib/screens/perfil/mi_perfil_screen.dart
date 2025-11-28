import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';

class MiPerfilScreen extends StatefulWidget {
  const MiPerfilScreen({super.key});

  @override
  State<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends State<MiPerfilScreen> {
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _load() async {
    setState(() => _refreshing = true);
    try {
      await context.read<AuthProvider>().refreshUserInfo();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _refreshing ? null : _load,
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final u = auth.usuario;

          if (u == null) {
            return const Center(child: Text('No hay usuario autenticado'));
          }

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient(),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        u.iniciales,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    u.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    u.email,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),
                _InfoTile(icon: Icons.badge, title: 'Nombre', value: u.nombre),
                _InfoTile(
                  icon: Icons.person_outline,
                  title: 'Apellido paterno',
                  value: u.apellidoPaterno ?? 'No registrado',
                ),
                _InfoTile(
                  icon: Icons.person_outline,
                  title: 'Apellido materno',
                  value: u.apellidoMaterno ?? 'No registrado',
                ),
                const SizedBox(height: 8),
                _InfoTile(
                  icon: Icons.phone,
                  title: 'Teléfono',
                  value: u.telefono ?? 'No registrado',
                ),
                _InfoTile(
                  icon: Icons.verified_user,
                  title: 'Estado',
                  value: u.activo ? 'Activo' : 'Inactivo',
                ),
                if (u.roles.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.only(top: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Roles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: u.roles
                                .map(
                                  (r) => Chip(
                                    label: Text(r),
                                    backgroundColor: AppTheme.primaryLight
                                        .withOpacity(0.25),
                                    side: const BorderSide(
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
