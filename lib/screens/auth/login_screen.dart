import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/alert_widgets.dart';
import '../../widgets/loading_overlay.dart';

/// Pantalla de inicio de sesión
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // El error ya está en el provider
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Iniciando sesión...',
        child: Container(
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient()),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo o icono de la app
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withAlpha(
                                  (0.1 * 255).round(),
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.pets,
                                size: 50,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Título
                            const Text(
                              'Bienvenido a AdoPets',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),

                            // Subtítulo
                            const Text(
                              'Encuentra tu compañero perfecto',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Mensaje de error
                            if (authProvider.errorMessage != null) ...[
                              ErrorAlert(
                                message: authProvider.errorMessage!,
                                onDismiss: () => authProvider.clearError(),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Botón de Google Sign In
                            CustomButton(
                              text: 'Continuar con Google',
                              onPressed: _handleGoogleSignIn,
                              isLoading: _isLoading,
                              icon: Icons.g_mobiledata,
                              backgroundColor: Colors.white,
                              textColor: AppTheme.textPrimary,
                            ),
                            const SizedBox(height: 16),

                            // Divider
                            const Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'o',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Botón para email/password (futuro)
                            OutlinedButton(
                              onPressed: () {
                                // TODO: Navegar a pantalla de email/password
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Próximamente disponible'),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                              ),
                              child: const Text('Iniciar sesión con email'),
                            ),
                            const SizedBox(height: 24),

                            // Términos y condiciones
                            Text.rich(
                              TextSpan(
                                text: 'Al continuar, aceptas nuestros ',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () {
                                        // TODO: Mostrar términos y condiciones
                                      },
                                      child: const Text(
                                        'Términos y Condiciones',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.primaryColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: ' y '),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () {
                                        // TODO: Mostrar política de privacidad
                                      },
                                      child: const Text(
                                        'Política de Privacidad',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.primaryColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
