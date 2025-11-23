import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/donacion_provider.dart';
import '../../providers/auth_provider.dart';
import 'paypal_webview_screen.dart';

/// Pantalla principal para realizar donaciones
class DonacionScreen extends StatefulWidget {
  const DonacionScreen({super.key});

  @override
  State<DonacionScreen> createState() => _DonacionScreenState();
}

class _DonacionScreenState extends State<DonacionScreen> {
  // Montos predefinidos
  final List<double> _montosPredefinidos = [50.0, 100.0, 250.0, 500.0, 1000.0];

  double? _montoSeleccionado;
  final TextEditingController _montoPersonalizadoController =
      TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
  bool _esAnonima = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _montoPersonalizadoController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hacer una Donación'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/donaciones/historial');
            },
            tooltip: 'Ver historial',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildMontosPredefinidos(),
            const SizedBox(height: 20),
            _buildMontoPersonalizado(),
            const SizedBox(height: 20),
            _buildMensajeField(),
            const SizedBox(height: 16),
            _buildOpcionAnonima(),
            const SizedBox(height: 32),
            _buildBotonDonar(),
            const SizedBox(height: 24),
            _buildEstadisticas(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
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
        ),
        child: Column(
          children: [
            Icon(Icons.favorite, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              '¡Ayuda a las mascotas!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu donación nos ayuda a rescatar, cuidar y encontrar hogares para mascotas en situación de calle',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.white, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMontosPredefinidos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona un monto',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _montosPredefinidos.map((monto) {
            final esSeleccionado = _montoSeleccionado == monto;
            return ChoiceChip(
              label: Text(
                '\$${monto.toStringAsFixed(0)} MXN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: esSeleccionado ? Colors.white : Colors.black87,
                ),
              ),
              selected: esSeleccionado,
              selectedColor: AppTheme.primaryColor,
              backgroundColor: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onSelected: (selected) {
                setState(() {
                  _montoSeleccionado = selected ? monto : null;
                  _montoPersonalizadoController.clear();
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMontoPersonalizado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'O ingresa un monto personalizado',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _montoPersonalizadoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Monto en MXN',
            prefixText: '\$ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
            suffixIcon: _montoPersonalizadoController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _montoPersonalizadoController.clear();
                        _montoSeleccionado = null;
                      });
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {
              _montoSeleccionado = double.tryParse(value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildMensajeField() {
    return TextField(
      controller: _mensajeController,
      maxLines: 3,
      maxLength: 200,
      decoration: InputDecoration(
        labelText: 'Mensaje (opcional)',
        hintText: '¿Quieres dejar un mensaje de apoyo?',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
        counterText: '${_mensajeController.text.length}/200',
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildOpcionAnonima() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: const Text(
          'Donación anónima',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          'Tu nombre no aparecerá en el listado público',
          style: TextStyle(fontSize: 13),
        ),
        value: _esAnonima,
        onChanged: (value) {
          setState(() => _esAnonima = value);
        },
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildBotonDonar() {
    final tieneMonto = _montoSeleccionado != null && _montoSeleccionado! > 0;

    return Consumer<DonacionProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.isCreatingOrder || _isProcessing;

        return ElevatedButton(
          onPressed: tieneMonto && !isLoading ? _procesarDonacion : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: AppTheme.primaryColor,
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: isLoading ? 0 : 4,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.volunteer_activism, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      tieneMonto
                          ? 'Donar \$${_montoSeleccionado!.toStringAsFixed(2)} MXN'
                          : 'Selecciona un monto',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEstadisticas() {
    return Consumer<DonacionProvider>(
      builder: (context, provider, _) {
        final stats = provider.estadisticas;
        if (stats == null) return const SizedBox.shrink();

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Impacto de la comunidad',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '${stats['totalDonaciones'] ?? 0}',
                        'Donaciones',
                        Icons.favorite,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '\$${(stats['montoTotal'] ?? 0).toStringAsFixed(0)}',
                        'Recaudado',
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String valor,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Future<void> _procesarDonacion() async {
    if (_montoSeleccionado == null || _montoSeleccionado! <= 0) {
      _mostrarError('Por favor, selecciona un monto válido');
      return;
    }

    setState(() => _isProcessing = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final donacionProvider = Provider.of<DonacionProvider>(
      context,
      listen: false,
    );

    final usuarioId = authProvider.usuario?.id;

    try {
      // Paso 1: Crear orden de PayPal
      print('🔄 Paso 1: Creando orden de PayPal...');
      final orderResponse = await donacionProvider.crearOrdenPayPal(
        monto: _montoSeleccionado!,
        usuarioId: usuarioId,
        moneda: 'MXN',
        concepto: 'Donación para AdoPets',
        mensaje: _mensajeController.text.trim().isEmpty
            ? null
            : _mensajeController.text.trim(),
        anonima: _esAnonima,
        returnUrl: 'adopets://donacion/success',
        cancelUrl: 'adopets://donacion/cancel',
      );

      if (orderResponse != null) {
        print('Orden creada: ${orderResponse.orderId}');
        print('ApprovalUrl: ${orderResponse.approvalUrl}');

        // Paso 2: Abrir WebView para aprobar el pago
        if (mounted) {
          final result = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
              builder: (context) => PayPalWebViewScreen(
                approvalUrl: orderResponse.approvalUrl,
                returnUrl: 'adopets://donacion/success',
                cancelUrl: 'adopets://donacion/cancel',
              ),
            ),
          );

          // Paso 3: Verificar resultado del WebView
          if (result != null && result['success'] == true) {
            final orderId = result['orderId'] as String?;

            if (orderId != null) {
              print('Pago aprobado, orderId: $orderId');

              // Paso 4: Capturar el pago automáticamente
              await _capturarPago(orderId);
            } else {
              _mostrarError('No se pudo obtener el orderId');
            }
          } else if (result != null && result['cancelled'] == true) {
            _mostrarInfo('Donación cancelada');
          } else {
            _mostrarError('Error al procesar el pago');
          }
        }
      } else {
        _mostrarError(donacionProvider.errorMessage ?? 'Error al crear orden');
      }
    } catch (e) {
      _mostrarError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _capturarPago(String orderId) async {
    // Mostrar loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      print('🔄 Paso 4: Capturando pago...');

      final donacionProvider = Provider.of<DonacionProvider>(
        context,
        listen: false,
      );

      final donacion = await donacionProvider.capturarPagoPayPal(orderId);

      if (mounted) {
        Navigator.pop(context); // Cerrar loading

        if (donacion != null) {
          print('Pago capturado exitosamente');
          _mostrarExito(donacion.monto);

          // Limpiar formulario
          setState(() {
            _montoSeleccionado = null;
            _montoPersonalizadoController.clear();
            _mensajeController.clear();
            _esAnonima = false;
          });

          // Paso 5: Recargar donaciones públicas (opcional)
          await donacionProvider.cargarDonacionesPublicas(limit: 10);
        } else {
          _mostrarError(
            donacionProvider.errorMessage ?? 'Error al capturar el pago',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar loading
        _mostrarError('Error al capturar pago: ${e.toString()}');
      }
    }
  }

  void _mostrarExito(double monto) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 36),
            const SizedBox(width: 12),
            const Text('¡Gracias!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tu donación de \$${monto.toStringAsFixed(2)} MXN ha sido procesada exitosamente.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tu apoyo hace la diferencia en la vida de muchas mascotas.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Refrescar donaciones
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              Provider.of<DonacionProvider>(
                context,
                listen: false,
              ).refrescarDonaciones(authProvider.usuario!.id);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _mostrarInfo(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
