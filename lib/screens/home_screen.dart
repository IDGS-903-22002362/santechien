import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Pantalla principal (Home)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<RemoteMessage>? _notificationSubscription;
  final NotificationService _notificationService = NotificationService();
  late final AnimationController _chatFabController;
  late final Animation<double> _chatScaleAnimation;
  late final Animation<double> _chatRotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
    _chatFabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _chatScaleAnimation = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(
        parent: _chatFabController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );
    _chatRotationAnimation = Tween<double>(begin: 0, end: 0.07).animate(
      CurvedAnimation(
        parent: _chatFabController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _chatFabController.dispose();
    super.dispose();
  }

  void _setupNotificationListener() {
    // Escuchar notificaciones en foreground y cuando se toca una notificación
    _notificationSubscription = _notificationService.notificationStream.listen((
      message,
    ) {
      print('📬 Nueva notificación recibida en HomeScreen');

      // Mostrar snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification?.body ?? 'Nueva notificación'),
            action: SnackBarAction(
              label: 'Ver',
              onPressed: () => _handleNotificationTap(message),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
  }

  void _handleNotificationTap(RemoteMessage message) {
    final tipo = message.data['tipo'];

    print('👆 Navegando según tipo: $tipo');

    switch (tipo) {
      case 'recordatorio_cita':
      case 'cita_confirmada':
      case 'cita_cancelada':
        // Navegar a la pantalla de citas
        if (mounted) {
          Navigator.pushNamed(context, '/citas');
        }
        break;

      default:
        print('Tipo de notificación no manejado: $tipo');
    }
  }

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
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text('Chat AdoPets'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/chat');
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
                  leading: const Icon(Icons.pets),
                  title: const Text('Mascotas adopción'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/mascotas');
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
                  leading: const Icon(Icons.history),
                  title: const Text('Mis Adopciones'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/mis-solicitudes-adopcion');
                    // TODO: Navegar a adopciones
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.volunteer_activism),
                  title: const Text('Hacer Donación'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/donaciones');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('Historial Donaciones'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/donaciones/historial');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Mi Perfil'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/perfil');
                  },
                ),
                const Divider(),
                // Solo en desarrollo
                ListTile(
                  leading: const Icon(Icons.bug_report, color: Colors.orange),
                  title: const Text(
                    'Debug Auth',
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
                    'Ver Logs',
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

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final minHeight = constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : MediaQuery.of(context).size.height;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 124,
                          height: 124,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient(),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              usuario?.iniciales ?? '??',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          '¡Hola, ${usuario?.nombre ?? 'Usuario'}!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          usuario?.email ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: 24),
                        if (usuario?.roles.isNotEmpty ?? false)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: usuario!.roles.map((rol) {
                              return Chip(
                                label: Text(
                                  rol,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                backgroundColor: AppTheme.primaryLight
                                    .withOpacity(0.3),
                                side: BorderSide(color: AppTheme.primaryColor),
                              );
                            }).toList(),
                          ),
                        SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 30,
                                offset: Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight.withOpacity(
                                    0.35,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.pets,
                                  size: 32,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Bienvenido a AdoPets',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Gestiona las citas de tus mascotas de manera fácil y rápida.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 24),
                              _HomeActionButtons(
                                onMisMascotas: () {
                                  Navigator.pushNamed(context, '/mis-mascotas');
                                },
                                onSolicitarCita: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/solicitar-cita',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: _ChatFloatingButton(
        scaleAnimation: _chatScaleAnimation,
        rotationAnimation: _chatRotationAnimation,
        onTap: _handleChatTap,
      ),
    );
  }

  Future<void> _handleChatTap() async {
    try {
      await _chatFabController.forward();
    } finally {
      if (mounted) {
        Navigator.pushNamed(context, '/chat');
        _chatFabController.reverse();
      }
    }
  }
}

class _HomeActionButtons extends StatelessWidget {
  const _HomeActionButtons({
    required this.onMisMascotas,
    required this.onSolicitarCita,
  });

  final VoidCallback onMisMascotas;
  final VoidCallback onSolicitarCita;

  @override
  Widget build(BuildContext context) {
    final primary = _HomeActionButton(
      icon: Icons.pets,
      label: 'Mis Mascotas',
      onPressed: onMisMascotas,
    );
    final secondary = _HomeActionButton(
      icon: Icons.add_circle,
      label: 'Solicitar Cita',
      onPressed: onSolicitarCita,
      isOutlined: true,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        if (isCompact) {
          return Column(
            children: [primary, const SizedBox(height: 12), secondary],
          );
        }

        return Row(
          children: [
            Expanded(child: primary),
            const SizedBox(width: 12),
            Expanded(child: secondary),
          ],
        );
      },
    );
  }
}

class _HomeActionButton extends StatelessWidget {
  const _HomeActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      backgroundColor: isOutlined ? Colors.white : AppTheme.primaryColor,
      foregroundColor: isOutlined ? AppTheme.primaryColor : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isOutlined
            ? const BorderSide(color: AppTheme.primaryColor, width: 1.5)
            : BorderSide.none,
      ),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    );

    return ElevatedButton.icon(
      style: style,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, overflow: TextOverflow.ellipsis),
    );
  }
}

class _ChatFloatingButton extends StatelessWidget {
  const _ChatFloatingButton({
    required this.scaleAnimation,
    required this.rotationAnimation,
    required this.onTap,
  });

  final Animation<double> scaleAnimation;
  final Animation<double> rotationAnimation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
      child: ScaleTransition(
        scale: scaleAnimation,
        child: RotationTransition(
          turns: rotationAnimation,
          child: FloatingActionButton.small(
            heroTag: 'chat-fab',
            backgroundColor: color,
            foregroundColor: Colors.white,
            onPressed: onTap,
            elevation: 6,
            child: const Icon(Icons.chat_rounded),
          ),
        ),
      ),
    );
  }
}
