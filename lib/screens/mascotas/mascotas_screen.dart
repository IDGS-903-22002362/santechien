import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/mascota_provider.dart';
import '../../models/mascota.dart';

/// Pantalla de Mascotas disponibles para adopción
class MascotasScreen extends StatefulWidget {
  const MascotasScreen({super.key});

  @override
  State<MascotasScreen> createState() => _MascotasScreenState();
}

class _MascotasScreenState extends State<MascotasScreen> {
  bool _soloDisponibles = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MascotaProvider>().cargarMascotasDisponibles(
        soloDisponibles: _soloDisponibles,
      );
    });
  }

  void _toggleFiltro(bool soloDisponibles) {
    setState(() {
      _soloDisponibles = soloDisponibles;
    });

    // Recargar la lista con el nuevo filtro
    context.read<MascotaProvider>().cargarMascotasDisponibles(
      soloDisponibles: _soloDisponibles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mascotas en Adopción'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Filtrar mascotas',
            onSelected: (value) {
              if (value == 'todas') {
                _toggleFiltro(false);
              } else {
                _toggleFiltro(true);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'disponibles',
                child: Row(
                  children: [
                    Checkbox(value: _soloDisponibles, onChanged: null),
                    const SizedBox(width: 8),
                    const Text('Solo disponibles'),
                  ],
                ),
              ),
              const PopupMenuItem(value: 'todas', child: Text('Todas')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Consumer<MascotaProvider>(
        builder: (context, mascotaProvider, _) {
          if (mascotaProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (mascotaProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${mascotaProvider.errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      mascotaProvider.cargarMascotasDisponibles(
                        soloDisponibles: _soloDisponibles,
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final mascotas = mascotaProvider.mascotasDisponibles;

          if (mascotas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 80,
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay mascotas para mostrar',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _soloDisponibles
                        ? 'Intenta mostrar todas las mascotas'
                        : 'No se encontraron mascotas',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mascotas.length,
            itemBuilder: (context, index) {
              final mascota = mascotas[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: _MascotaCard(mascota: mascota),
              );
            },
          );
        },
      ),
    );
  }
}

class _MascotaCard extends StatelessWidget {
  final Mascota mascota;

  const _MascotaCard({Key? key, required this.mascota}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MascotaProvider>();
    final fotoUrl = provider.obtenerFotoPrincipal(mascota);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // **SOLUCIÓN 1: Eliminación de altura fija (height: 140)**
      // Permite que el contenido determine la altura de la tarjeta y elimina el overflow.
      child: Container(
        // height: 140, // <--- ELIMINADO: Altura fija que causaba el overflow
        child: IntrinsicHeight(
          // Permite que los elementos Row compartan la altura máxima de su contenido.
          child: Row(
            crossAxisAlignment: CrossAxisAlignment
                .stretch, // Asegura que la columna se estire a la altura de la imagen
            children: [
              // Foto a la izquierda
              Container(
                width: 120,
                height: 120,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: fotoUrl.isNotEmpty && fotoUrl.startsWith('http')
                      ? Image.network(
                          fotoUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey[200],
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.pets, size: 32, color: Colors.grey),
                                SizedBox(height: 4),
                                Text(
                                  'Sin imagen',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pets, size: 32, color: Colors.grey),
                              SizedBox(height: 4),
                              Text(
                                'Sin foto',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              // Información a la derecha
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Información superior
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mascota.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mascota.especie,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (mascota.raza != null && mascota.raza!.isNotEmpty)
                            Text(
                              mascota.raza!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (mascota.edadEnAnios != null)
                            Text(
                              '${mascota.edadEnAnios} ${mascota.edadEnAnios == 1 ? 'año' : 'años'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),

                      // Botón en la parte inferior
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _mostrarDetallesMascota(context, mascota);
                          },
                          // **SOLUCIÓN 2: Botón Azul**
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.blue, // <--- CAMBIO DE COLOR A AZUL
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Ver detalles',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetallesMascota(BuildContext context, Mascota mascota) {
    final provider = context.read<MascotaProvider>();
    final fotoUrl = provider.obtenerFotoPrincipal(mascota);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header con botón cerrar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    'Detalles de la mascota',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto principal
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                      ),
                      child: fotoUrl.isNotEmpty && fotoUrl.startsWith('http')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                fotoUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (c, e, s) => Center(
                                  child: Icon(
                                    Icons.pets,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.pets,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // Información principal
                    Text(
                      mascota.nombre,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Detalles en tarjetas
                    _buildInfoCard('Especie', mascota.especie),
                    if (mascota.raza != null && mascota.raza!.isNotEmpty)
                      _buildInfoCard('Raza', mascota.raza!),
                    if (mascota.edadEnAnios != null)
                      _buildInfoCard(
                        'Edad',
                        '${mascota.edadEnAnios} ${mascota.edadEnAnios == 1 ? 'año' : 'años'}',
                      ),

                    const SizedBox(height: 20),

                    // Botón de acción
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cerrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String titulo, String valor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
