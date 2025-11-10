import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/cita.dart';
import '../../models/pago.dart';
import '../../services/pago_service.dart';
import '../../config/app_theme.dart';

/// Pantalla para realizar el pago de una cita con PayPal
class PagarCitaScreen extends StatefulWidget {
  final Cita cita;

  const PagarCitaScreen({super.key, required this.cita});

  @override
  State<PagarCitaScreen> createState() => _PagarCitaScreenState();
}

class _PagarCitaScreenState extends State<PagarCitaScreen> {
  final PagoService _pagoService = PagoService();
  bool _isLoading = false;
  String? _errorMessage;

  double get _montoAPagar {
    return widget.cita.calculoAnticipo ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Cita')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildResumenPagoCard(),
            const SizedBox(height: 24),
            _buildInstrucciones(),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildError(),
            ],
            const SizedBox(height: 24),
            _buildBotonPagar(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
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
            const SizedBox(height: 12),
            _buildInfoRow('Mascota', widget.cita.mascotaNombre ?? 'N/A'),
            const Divider(height: 20),
            _buildInfoRow('Tipo', widget.cita.tipoConsulta),
            const Divider(height: 20),
            _buildInfoRow(
              'Veterinario',
              widget.cita.veterinarioNombre ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenPagoCard() {
    final costoTotal = widget.cita.costoTotal ?? 0.0;
    final anticipo = _montoAPagar;
    final saldoPendiente = costoTotal - anticipo;

    return Card(
      color: AppTheme.primaryLight.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Resumen de Pago',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPagoRow('Costo Total', '\$${costoTotal.toStringAsFixed(2)}'),
            const Divider(height: 20),
            _buildPagoRow(
              'Anticipo (50%)',
              '\$${anticipo.toStringAsFixed(2)}',
              esDestacado: true,
            ),
            const Divider(height: 20),
            _buildPagoRow(
              'Saldo Pendiente',
              '\$${saldoPendiente.toStringAsFixed(2)}',
              esSubtexto: true,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'El saldo restante se pagará al finalizar el servicio',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
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

  Widget _buildInstrucciones() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '¿Cómo funciona?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPasoInstruccion('1', 'Presiona "Pagar con PayPal"'),
            const SizedBox(height: 8),
            _buildPasoInstruccion(
              '2',
              'Serás redirigido a PayPal para completar el pago',
            ),
            const SizedBox(height: 8),
            _buildPasoInstruccion(
              '3',
              'Inicia sesión en PayPal y confirma el pago',
            ),
            const SizedBox(height: 8),
            _buildPasoInstruccion('4', 'Recibirás una confirmación de tu cita'),
          ],
        ),
      ),
    );
  }

  Widget _buildPasoInstruccion(String numero, String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              numero,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(texto, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonPagar() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _iniciarPagoPayPal,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Image.asset(
                    'assets/paypal_logo.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.payment);
                    },
                  ),
            label: Text(_isLoading ? 'Procesando...' : 'Pagar con PayPal'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF0070BA), // Color de PayPal
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Pago seguro mediante PayPal',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPagoRow(
    String label,
    String value, {
    bool esDestacado = false,
    bool esSubtexto = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: esDestacado ? 16 : 14,
            fontWeight: esDestacado ? FontWeight.w600 : FontWeight.normal,
            color: esSubtexto ? Colors.grey[600] : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: esDestacado ? 18 : 14,
            fontWeight: esDestacado ? FontWeight.bold : FontWeight.w500,
            color: esDestacado ? AppTheme.primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _iniciarPagoPayPal() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Crear orden de PayPal
      final request = CrearOrdenPayPalRequest(
        citaId: widget.cita.id,
        monto: _montoAPagar,
        tipoPago: TipoPago.anticipo,
        conceptoPago:
            'Anticipo 50% - ${widget.cita.tipoConsulta} - ${widget.cita.mascotaNombre}',
        descripcionDetallada:
            'Pago anticipado del 50% para ${widget.cita.tipoConsulta} programado para la mascota ${widget.cita.mascotaNombre}',
      );

      final response = await _pagoService.crearOrdenPayPal(request);

      if (response.success && response.data != null) {
        final orderResponse = response.data!;

        // Abrir PayPal en el navegador
        final uri = Uri.parse(orderResponse.approvalUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);

          // Mostrar diálogo de espera
          if (mounted) {
            _mostrarDialogoEspera(orderResponse.orderId);
          }
        } else {
          throw Exception('No se pudo abrir PayPal');
        }
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al iniciar el pago: $e';
        _isLoading = false;
      });
    }
  }

  void _mostrarDialogoEspera(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Completa el pago en PayPal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Completa el pago en la ventana de PayPal que se acaba de abrir.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Una vez completado el pago, presiona "He completado el pago"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isLoading = false);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _verificarPago(orderId);
            },
            child: const Text('He completado el pago'),
          ),
        ],
      ),
    );
  }

  Future<void> _verificarPago(String orderId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Capturar el pago
      final request = CapturarPagoPayPalRequest(orderId: orderId);
      final response = await _pagoService.capturarPagoPayPal(request);

      if (mounted) {
        Navigator.pop(context); // Cerrar loading

        if (response.success && response.data != null) {
          _mostrarExito();
        } else {
          setState(() {
            _errorMessage = response.message;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar loading
        setState(() {
          _errorMessage = 'Error al verificar el pago: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _mostrarExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 32),
            const SizedBox(width: 12),
            const Text('¡Pago Exitoso!'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu pago ha sido procesado correctamente.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Tu cita ha sido confirmada. Recibirás un recordatorio antes de la fecha programada.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Volver a la pantalla anterior
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
