import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/pago_service.dart';
import '../../services/storage_service.dart';
import '../../models/pago.dart';

class PayPalWebViewScreen extends StatefulWidget {
  final String approvalUrl;
  final String orderId;
  final String solicitudId;
  final double monto;

  const PayPalWebViewScreen({
    super.key,
    required this.approvalUrl,
    required this.orderId,
    required this.solicitudId,
    required this.monto,
  });

  @override
  State<PayPalWebViewScreen> createState() => _PayPalWebViewScreenState();
}

class _PayPalWebViewScreenState extends State<PayPalWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            print('🔍 Solicitud de navegación: $url');

            // Prevenir navegación a esquemas personalizados
            if (url.startsWith('adopets://') ||
                url.contains('/payment-success') ||
                url.contains('success=true') ||
                url.contains('/payment-cancel') ||
                url.contains('cancelled=true')) {
              _checkUrlForReturn(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('📄 Página iniciada: $url');
          },
          onPageFinished: (String url) {
            print('✅ Página cargada: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ Error WebView: ${error.description}');
            setState(() {
              _isLoading = false;
              _errorMessage = 'Error al cargar PayPal: ${error.description}';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  void _checkUrlForReturn(String url) {
    print('🔍 Verificando URL: $url');

    // Detectar si el usuario completó el pago (success)
    if (url.contains('adopets://payment/success')) {
      print('✅ Pago completado, capturando...');
      _capturarPago();
      return;
    }

    // Detectar si el usuario canceló el pago
    if (url.contains('adopets://payment/cancel')) {
      print('❌ Pago cancelado por el usuario');
      _mostrarCancelacion();
      return;
    }

    // También detectar URLs del backend si las está usando
    if (url.contains('/payment-success') || url.contains('success=true')) {
      print('✅ Pago completado (backend URL), capturando...');
      _capturarPago();
      return;
    }

    if (url.contains('/payment-cancel') || url.contains('cancelled=true')) {
      print('❌ Pago cancelado (backend URL)');
      _mostrarCancelacion();
      return;
    }
  }

  Future<void> _capturarPago() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _isLoading = true;
    });

    try {
      final storageService = StorageService();
      final token = await storageService.getAccessToken();

      if (token == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }

      print('🔄 Capturando pago para Order ID: ${widget.orderId}');

      final pagoService = PagoService();
      final request = CapturarPagoPayPalRequest(orderId: widget.orderId);
      final response = await pagoService.capturarPagoPayPal(request);

      print('📦 Respuesta de captura:');
      print('   success: ${response.success}');
      print('   message: ${response.message}');
      print('   data: ${response.data}');
      print('   errors: ${response.errors}');

      if (response.success && response.data != null) {
        if (mounted) {
          // Mostrar diálogo de éxito
          await _mostrarDialogoExito();

          // Regresar con resultado exitoso
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e, stackTrace) {
      print('❌ Error al capturar pago: $e');
      print('   Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isLoading = false;
          _errorMessage = 'Error al procesar el pago: $e';
        });

        _mostrarDialogoError('Error al procesar el pago: $e');
      }
    }
  }

  Future<void> _mostrarDialogoExito() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text('¡Pago Exitoso!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tu anticipo ha sido procesado correctamente.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Monto pagado: \$${widget.monto.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tu solicitud está pendiente de confirmación por el personal.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarCancelacion() {
    if (!mounted || _isProcessing) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cancel, color: Colors.orange, size: 32),
              SizedBox(width: 12),
              Text('Pago Cancelado'),
            ],
          ),
          content: const Text(
            'Has cancelado el proceso de pago. Puedes intentarlo nuevamente cuando lo desees.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
                Navigator.of(context).pop(false); // Cerrar WebView
              },
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoError(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 32),
              SizedBox(width: 12),
              Text('Error'),
            ],
          ),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
                Navigator.of(context).pop(false); // Cerrar WebView
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago con PayPal'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isProcessing
              ? null
              : () {
                  // Confirmar cancelación
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('¿Cancelar pago?'),
                        content: const Text(
                          '¿Estás seguro de que deseas cancelar el proceso de pago?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Cerrar diálogo
                              Navigator.of(
                                context,
                              ).pop(false); // Cerrar WebView
                            },
                            child: const Text('Sí, cancelar'),
                          ),
                        ],
                      );
                    },
                  );
                },
        ),
      ),
      body: Stack(
        children: [
          // WebView
          WebViewWidget(controller: _controller),

          // Indicador de carga
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando PayPal...', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

          // Indicador de procesamiento
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  margin: EdgeInsets.all(32),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Procesando pago...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Por favor espera un momento',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Mensaje de error
          if (_errorMessage != null && !_isProcessing)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.red[100],
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
