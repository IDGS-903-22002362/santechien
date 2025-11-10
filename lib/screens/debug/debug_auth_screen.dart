import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../../services/mascota_service.dart';
import '../../models/solicitud_cita.dart';
import '../../config/app_theme.dart';

/// Pantalla de debug para verificar autenticación
/// SOLO PARA DESARROLLO - Eliminar en producción
class DebugAuthScreen extends StatefulWidget {
  const DebugAuthScreen({super.key});

  @override
  State<DebugAuthScreen> createState() => _DebugAuthScreenState();
}

class _DebugAuthScreenState extends State<DebugAuthScreen> {
  final _storageService = StorageService();
  final _authService = AuthService();

  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _usuario;
  bool _hasSession = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() => _isLoading = true);

    try {
      _accessToken = await _storageService.getAccessToken();
      _refreshToken = await _storageService.getRefreshToken();
      final usuario = await _storageService.getUsuario();
      _usuario = usuario?.toJson();
      _hasSession = await _storageService.hasActiveSession();
    } catch (e) {
      print('Error cargando info de debug: $e');
    }

    setState(() => _isLoading = false);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copiado al portapapeles')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Debug Autenticación'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Estado de sesión
                _buildCard(
                  title: '📊 Estado de Sesión',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Tiene sesión activa',
                        _hasSession ? '✅ SÍ' : '❌ NO',
                        _hasSession ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Access Token',
                        _accessToken != null ? '✅ Presente' : '❌ Ausente',
                        _accessToken != null ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Refresh Token',
                        _refreshToken != null ? '✅ Presente' : '❌ Ausente',
                        _refreshToken != null ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Usuario',
                        _usuario != null ? '✅ Cargado' : '❌ No cargado',
                        _usuario != null ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Access Token
                if (_accessToken != null)
                  _buildCard(
                    title: '🔑 Access Token',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Primeros 50 caracteres:',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          _accessToken!.length > 50
                              ? '${_accessToken!.substring(0, 50)}...'
                              : _accessToken!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Longitud: ${_accessToken!.length} caracteres',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _copyToClipboard(_accessToken!),
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copiar token completo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Refresh Token
                if (_refreshToken != null)
                  _buildCard(
                    title: '🔄 Refresh Token',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Primeros 50 caracteres:',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          _refreshToken!.length > 50
                              ? '${_refreshToken!.substring(0, 50)}...'
                              : _refreshToken!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Longitud: ${_refreshToken!.length} caracteres',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Usuario
                if (_usuario != null)
                  _buildCard(
                    title: '👤 Usuario',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'ID',
                          _usuario!['id']?.toString() ?? 'N/A',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Nombre', _usuario!['nombre'] ?? 'N/A'),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Apellidos',
                          '${_usuario!['apellidoPaterno'] ?? ''} ${_usuario!['apellidoMaterno'] ?? ''}',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Email', _usuario!['email'] ?? 'N/A'),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Teléfono',
                          _usuario!['telefono'] ?? 'N/A',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Roles',
                          (_usuario!['roles'] as List?)?.join(', ') ?? 'N/A',
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Acciones
                _buildCard(
                  title: '⚙️ Acciones',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          final response = await _authService.getMe();
                          setState(() => _isLoading = false);

                          if (!mounted) return;

                          if (response.success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '✅ Token válido - Usuario obtenido',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _loadDebugInfo();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('❌ ${response.message}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.verified_user),
                        label: const Text('Verificar token con GET /auth/me'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          print('\n🧪 === INICIANDO PRUEBA DE POST ===');
                          print(
                            'Este botón enviará una petición POST simulada',
                          );
                          print(
                            'para verificar que el header Authorization se envía',
                          );

                          setState(() => _isLoading = true);

                          final mascotaService = MascotaService();

                          try {
                            print(
                              '📤 Intentando enviar POST a /MisMascotas...',
                            );

                            // Crear request de prueba - esto generará error de validación
                            // pero veremos los headers en los logs
                            final testRequest = RegistrarMascotaRequest(
                              nombre: 'TEST_DEBUG',
                              especie: 'Perro',
                              raza: 'Test',
                              sexo: 1, // 1 = Macho
                              notas: 'Prueba de headers - verificar logs',
                            );

                            final response = await mascotaService
                                .registrarMascota(testRequest);

                            setState(() => _isLoading = false);

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  response.success
                                      ? '✅ POST exitoso (revisa logs)'
                                      : '⚠️ Status: ${response.message}\nRevisa TODOS los logs de Flutter arriba ⬆️',
                                ),
                                backgroundColor: response.success
                                    ? Colors.green
                                    : Colors.orange,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          } catch (e) {
                            setState(() => _isLoading = false);
                            print('❌ Error en prueba: $e');

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('❌ Error: $e\nRevisa los logs'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }

                          print('🧪 === FIN PRUEBA DE POST ===\n');
                        },
                        icon: const Icon(Icons.bug_report),
                        label: const Text(
                          '🧪 Probar POST /MisMascotas (DEBUG)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          await _storageService.clearAll();
                          await _loadDebugInfo();
                          setState(() => _isLoading = false);

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🗑️ Storage limpiado'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Limpiar storage'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Advertencia
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Esta pantalla es solo para desarrollo. Eliminar en producción.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: valueColor != null ? FontWeight.bold : null,
            ),
          ),
        ),
      ],
    );
  }
}
