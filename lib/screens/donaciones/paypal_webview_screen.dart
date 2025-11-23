import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Pantalla WebView para procesar pagos de PayPal dentro de la app
class PayPalWebViewScreen extends StatefulWidget {
  final String approvalUrl;
  final String returnUrl;
  final String cancelUrl;

  const PayPalWebViewScreen({
    super.key,
    required this.approvalUrl,
    required this.returnUrl,
    required this.cancelUrl,
  });

  @override
  State<PayPalWebViewScreen> createState() => _PayPalWebViewScreenState();
}

class _PayPalWebViewScreenState extends State<PayPalWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // Extraer el orderId original del approvalUrl
    final originalOrderId = _extractOrderIdFromUrl(widget.approvalUrl);
    print('OrderId original del approvalUrl: $originalOrderId');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            print('🌐 Navegando a: $url');
            _checkForRedirect(url, originalOrderId);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            print('Página cargada: $url');
          },
          onWebResourceError: (error) {
            print('Error en WebView: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  void _checkForRedirect(String url, String? fallbackOrderId) {
    // Verificar si es la URL de retorno (éxito)
    if (url.contains(widget.returnUrl) || url.contains('success')) {
      print('Pago aprobado, extrayendo orderId...');

      // Intentar extraer de la URL actual
      String? orderId = _extractOrderIdFromUrl(url);

      // Si no se encuentra, usar el fallback del approvalUrl original
      if (orderId == null || orderId.isEmpty || orderId == 'success') {
        orderId = fallbackOrderId;
        print('Usando orderId del approvalUrl original: $orderId');
      }

      if (orderId != null && orderId.isNotEmpty) {
        print('OrderId final a enviar: $orderId');
        // Cerrar WebView y regresar el orderId para capturar el pago
        Navigator.of(context).pop({'success': true, 'orderId': orderId});
      } else {
        Navigator.of(
          context,
        ).pop({'success': false, 'error': 'No se pudo obtener orderId'});
      }
    } else if (url.contains(widget.cancelUrl) || url.contains('cancel')) {
      print('Pago cancelado por el usuario');
      Navigator.of(context).pop({'success': false, 'cancelled': true});
    }
  }

  String? _extractOrderIdFromUrl(String url) {
    try {
      print('🔍 Extrayendo orderId de: $url');
      final uri = Uri.parse(url);

      String? orderId = uri.queryParameters['token'];

      if (orderId != null && orderId.isNotEmpty && orderId != 'success') {
        print('✅ OrderId extraído del parámetro token: $orderId');
        return orderId;
      }

      if (uri.queryParameters.containsKey('PayerID')) {
        orderId = uri.queryParameters['token'];
        if (orderId != null && orderId.isNotEmpty) {
          print('OrderId extraído (con PayerID): $orderId');
          return orderId;
        }
      }

      if (url.contains('checkoutnow') && orderId != null) {
        print('OrderId extraído de checkoutnow: $orderId');
        return orderId;
      }

      print('No se pudo extraer orderId de la URL');
      return null;
    } catch (e) {
      print('Error al extraer orderId: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago con PayPal'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Confirmar cancelación
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('¿Cancelar pago?'),
                content: const Text(
                  '¿Estás seguro de que deseas cancelar la donación?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar diálogo
                      Navigator.of(
                        context,
                      ).pop({'success': false, 'cancelled': true});
                    },
                    child: const Text('Sí, cancelar'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
