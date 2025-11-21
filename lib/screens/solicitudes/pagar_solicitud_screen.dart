import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/solicitud_cita.dart';
import '../../models/pago.dart';
import '../../services/pago_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_theme.dart';
import 'paypal_webview_screen.dart';

/// Pantalla para pagar el anticipo (50%) de una solicitud de cita
class PagarSolicitudScreen extends StatefulWidget {
  final SolicitudCita solicitud;

  const PagarSolicitudScreen({super.key, required this.solicitud});

  @override
  State<PagarSolicitudScreen> createState() => _PagarSolicitudScreenState();
}

class _PagarSolicitudScreenState extends State<PagarSolicitudScreen> {
  final PagoService _pagoService = PagoService();
  bool _isLoading = false;
  String? _errorMessage;

  /// Cálculo del anticipo (50%)
  double get _montoAnticipo => widget.solicitud.montoAnticipo;
  double get _montoTotal => widget.solicitud.costoEstimado;
  double get _saldoPendiente => _montoTotal - _montoAnticipo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagar Anticipo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEstadoCard(),
            const SizedBox(height: 16),
            _buildInfoSolicitudCard(),
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

  Widget _buildEstadoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.pending_actions, color: Colors.orange.shade700, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solicitud ${widget.solicitud.numeroSolicitud}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Estado: ${widget.solicitud.estadoNombre}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSolicitudCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de la Solicitud',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Mascota',
              '${widget.solicitud.nombreMascota} (${widget.solicitud.especieMascota})',
            ),
            const Divider(height: 20),
            _buildInfoRow('Servicio', widget.solicitud.descripcionServicio),
            const Divider(height: 20),
            _buildInfoRow('Motivo', widget.solicitud.motivoConsulta),
            const Divider(height: 20),
            _buildInfoRow(
              'Duración estimada',
              '${widget.solicitud.duracionEstimadaMin} minutos',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenPagoCard() {
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
            _buildPagoRow(
              'Costo Total del Servicio',
              '\$${_montoTotal.toStringAsFixed(2)}',
            ),
            const Divider(height: 20),
            _buildPagoRow(
              'Anticipo a Pagar Ahora (50%)',
              '\$${_montoAnticipo.toStringAsFixed(2)}',
              esDestacado: true,
            ),
            const Divider(height: 20),
            _buildPagoRow(
              'Saldo Pendiente',
              '\$${_saldoPendiente.toStringAsFixed(2)}',
              esSubtexto: true,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'El saldo restante se pagará después de que el personal confirme tu cita',
                      style: TextStyle(
                        color: Colors.blue.shade700,
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
                  'Proceso de Pago',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPasoInstruccion('1', 'Presiona "Pagar Anticipo con PayPal"'),
            const SizedBox(height: 8),
            _buildPasoInstruccion(
              '2',
              'Serás redirigido a PayPal para completar el pago',
            ),
            const SizedBox(height: 8),
            _buildPasoInstruccion(
              '3',
              'Inicia sesión en PayPal y confirma el pago del anticipo',
            ),
            const SizedBox(height: 8),
            _buildPasoInstruccion(
              '4',
              'Después del pago, el personal revisará y confirmará tu cita',
            ),
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
                : const Icon(Icons.payment),
            label: Text(
              _isLoading ? 'Procesando...' : 'Pagar Anticipo con PayPal',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF0070BA), // Color de PayPal
              foregroundColor: Colors.white,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
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
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: esDestacado ? 16 : 14,
              fontWeight: esDestacado ? FontWeight.w600 : FontWeight.normal,
              color: esSubtexto ? Colors.grey[600] : Colors.black87,
            ),
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
    final usuario = Provider.of<AuthProvider>(context, listen: false).usuario;

    if (usuario == null) {
      setState(() {
        _errorMessage = 'Usuario no autenticado';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('\n🔷 === INICIANDO PAGO DE SOLICITUD ===');
      print('📋 Solicitud ID: ${widget.solicitud.id}');
      print('👤 Usuario ID: ${usuario.id}');
      print('💰 Monto anticipo: \$${_montoAnticipo.toStringAsFixed(2)}');
      print('💵 Monto total: \$${_montoTotal.toStringAsFixed(2)}');

      // ✅ Crear orden de PayPal para SOLICITUD (no cita)
      final request = CrearOrdenPayPalRequest(
        solicitudCitaId: widget.solicitud.id,
        usuarioId: usuario.id,
        monto: _montoAnticipo,
        conceptoPago:
            'Anticipo 50% - ${widget.solicitud.descripcionServicio} para ${widget.solicitud.nombreMascota}',
        esAnticipo: true,
        montoTotal: _montoTotal,
        returnUrl: 'adopets://payment/success',
        cancelUrl: 'adopets://payment/cancel',
      );

      print('📤 Request JSON:');
      print(request.toJson());

      final response = await _pagoService.crearOrdenPayPal(request);

      print('📥 Response recibida:');
      print('   success: ${response.success}');
      print('   message: ${response.message}');
      print('   data: ${response.data}');

      if (response.success && response.data != null) {
        final orderResponse = response.data!;

        print('✅ Orden creada exitosamente:');
        print('   Order ID: ${orderResponse.orderId}');
        print('   Approval URL: ${orderResponse.approvalUrl}');
        print('   Status: ${orderResponse.status}');

        // Abrir PayPal en WebView
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PayPalWebViewScreen(
                approvalUrl: orderResponse.approvalUrl,
                orderId: orderResponse.orderId,
                solicitudId: widget.solicitud.id,
                monto: _montoAnticipo,
              ),
            ),
          ).then((resultado) {
            if (resultado != null && resultado == true) {
              // Pago exitoso, regresar a la pantalla anterior
              Navigator.pop(context, true);
            }
          });
        }
      } else {
        print('❌ Error en la respuesta: ${response.message}');
        if (response.errors.isNotEmpty) {
          print('   Errores: ${response.errors}');
        }

        // Mensaje de error más descriptivo
        String errorMsg = response.message;

        if (errorMsg.contains('Respuesta vacía')) {
          errorMsg = '''
❌ Error de Conexión con el Backend

Posibles causas:
1. El backend no está corriendo
2. La URL del backend es incorrecta
3. El backend no tiene configurado el endpoint de PayPal
4. Problemas de red o CORS
5. ⚠️ CREDENCIALES DE PAYPAL no configuradas en el backend

Verifica en el BACKEND:
✓ Backend corriendo en la URL configurada
✓ Endpoint existe: POST /api/v1/Pagos/paypal/create-order
✓ Credenciales PayPal en appsettings.json:
  {
    "PayPal": {
      "Mode": "sandbox",
      "ClientId": "TU_CLIENT_ID",
      "ClientSecret": "TU_CLIENT_SECRET"
    }
  }
✓ Logs del backend para más detalles

🔑 Obtener credenciales:
1. Ve a https://developer.paypal.com/
2. Sección "Apps & Credentials"
3. Modo "Sandbox" activado
4. Crea una App o usa una existente
5. Copia Client ID y Secret
          ''';
        }

        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPCIÓN al iniciar pago: $e');
      print('   Stack trace: $stackTrace');

      setState(() {
        _errorMessage = 'Error al iniciar el pago: $e';
        _isLoading = false;
      });
    }
  }
}
