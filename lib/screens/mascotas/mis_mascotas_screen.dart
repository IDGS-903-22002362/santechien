import 'package:flutter/material.dart';
import '../../models/mascota.dart';
import '../../services/mascota_service.dart';
import 'registrar_mascota_screen.dart';

class MisMascotasScreen extends StatefulWidget {
  const MisMascotasScreen({super.key});

  @override
  State<MisMascotasScreen> createState() => _MisMascotasScreenState();
}

class _MisMascotasScreenState extends State<MisMascotasScreen> {
  final _mascotaService = MascotaService();
  List<Mascota> _mascotas = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarMascotas();
  }

  Future<void> _cargarMascotas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _mascotaService.obtenerMisMascotas();

      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            _mascotas = response.data!;
          } else {
            _errorMessage = response.message;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navegarARegistrarMascota() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const RegistrarMascotaScreen()),
    );

    if (resultado == true) {
      _cargarMascotas(); // Recargar lista
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mascotas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarMascotas,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarARegistrarMascota,
        icon: const Icon(Icons.add),
        label: const Text('Registrar Mascota'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _cargarMascotas,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_mascotas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No tienes mascotas registradas',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Registra tu primera mascota para poder solicitar citas veterinarias',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navegarARegistrarMascota,
              icon: const Icon(Icons.add),
              label: const Text('Registrar Mascota'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarMascotas,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mascotas.length,
        itemBuilder: (context, index) {
          final mascota = _mascotas[index];
          return _MascotaCard(mascota: mascota);
        },
      ),
    );
  }
}

class _MascotaCard extends StatelessWidget {
  final Mascota mascota;

  const _MascotaCard({required this.mascota});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navegar a detalle de mascota
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: _getColorPorEspecie(mascota.especie),
                child: Text(
                  mascota.nombre[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      mascota.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Especie y raza
                    Text(
                      _buildEspecieRaza(),
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),

                    // Edad
                    if (mascota.edadEnAnios != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            mascota.descripcionEdad,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Sexo
                    if (mascota.sexo != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            mascota.sexo == 'Macho' ? Icons.male : Icons.female,
                            size: 16,
                            color: mascota.sexo == 'Macho'
                                ? Colors.blue
                                : Colors.pink,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mascota.sexo!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Icono de flecha
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _buildEspecieRaza() {
    if (mascota.raza != null && mascota.raza!.isNotEmpty) {
      return '${mascota.especie} - ${mascota.raza}';
    }
    return mascota.especie;
  }

  Color _getColorPorEspecie(String especie) {
    switch (especie.toLowerCase()) {
      case 'perro':
        return Colors.brown;
      case 'gato':
        return Colors.orange;
      case 'ave':
        return Colors.blue;
      case 'roedor':
        return Colors.grey;
      case 'reptil':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }
}
