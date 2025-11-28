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
  final Map<String, String> _filtros = {};

  // Opciones para los filtros
  final List<String> _especies = ['Perro', 'Gato', 'Conejo', 'Ave', 'Otro'];
  final List<String> _sexos = ['Macho', 'Hembra'];
  final List<String> _edades = List.generate(15, (index) => '${index + 1}');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MascotaProvider>().cargarMascotasDisponibles(
        soloDisponibles: _soloDisponibles,
      );
    });
  }

  void _aplicarFiltros() {
    context.read<MascotaProvider>().cargarMascotasDisponibles(
      soloDisponibles: true, // SIEMPRE solo disponibles
      filtros: _filtros,
    );
  }

  void _limpiarFiltros() {
    setState(() {
      _filtros.clear();
    });
    _aplicarFiltros();
  }

  void _mostrarFiltros(BuildContext context) {
    String? especieSeleccionada = _filtros['especie'];
    String? sexoSeleccionado = _filtros['sexo'];
    String? edadSeleccionada = _filtros['edad'];
    String? razaTexto = _filtros['raza'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Filtrar Mascotas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filtro de especie
            const Text(
              'Especie',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _especies.map((especie) {
                final bool seleccionada = especieSeleccionada == especie;
                return FilterChip(
                  label: Text(especie),
                  selected: seleccionada,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _filtros['especie'] = especie;
                      } else {
                        _filtros.remove('especie');
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Filtro de sexo
            const Text(
              'Sexo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _sexos.map((sexo) {
                final bool seleccionado = sexoSeleccionado == sexo;
                return FilterChip(
                  label: Text(sexo),
                  selected: seleccionado,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _filtros['sexo'] = sexo;
                      } else {
                        _filtros.remove('sexo');
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Filtro de edad (números del 1 al 15)
            const Text(
              'Edad (años)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                itemCount: _edades.length,
                itemBuilder: (context, index) {
                  final edad = _edades[index];
                  final bool seleccionada = edadSeleccionada == edad;
                  return FilterChip(
                    label: Text('$edad año${edad != '1' ? 's' : ''}'),
                    selected: seleccionada,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _filtros['edad'] = edad;
                        } else {
                          _filtros.remove('edad');
                        }
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Filtro de raza (texto libre)
            const Text(
              'Raza (opcional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Ej: Labrador, Siames, etc.',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    _filtros['raza'] = value;
                  } else {
                    _filtros.remove('raza');
                  }
                });
              },
              controller: TextEditingController(text: razaTexto),
            ),

            const SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _limpiarFiltros,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: const Text('Limpiar Filtros'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _aplicarFiltros();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Aplicar Filtros'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltrosActivos() {
    if (_filtros.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Filtros activos
          ..._filtros.entries.map((entry) {
            String valorMostrado = entry.value;
            if (entry.key == 'edad') {
              valorMostrado =
                  '$valorMostrado año${entry.value != '1' ? 's' : ''}';
            }
            return Chip(
              label: Text('${entry.key}: $valorMostrado'),
              onDeleted: () {
                setState(() {
                  _filtros.remove(entry.key);
                });
                _aplicarFiltros();
              },
            );
          }).toList(),

          // Botón para limpiar todos
          ActionChip(
            label: const Text('Limpiar todo'),
            onPressed: _limpiarFiltros,
            backgroundColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mascotas en Adopción'),
        actions: [
          // Botón de filtros avanzados
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _mostrarFiltros(context),
            tooltip: 'Filtros avanzados',
          ),
        ],
      ),
      body: Column(
        children: [
          // Mostrar filtros activos
          _buildFiltrosActivos(),

          // Lista de mascotas
          Expanded(
            child: Consumer<MascotaProvider>(
              builder: (context, mascotaProvider, _) {
                if (mascotaProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (mascotaProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${mascotaProvider.errorMessage}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _aplicarFiltros,
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
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _filtros.isNotEmpty
                              ? 'Intenta cambiar los filtros'
                              : 'No se encontraron mascotas disponibles',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_filtros.isNotEmpty)
                          TextButton(
                            onPressed: _limpiarFiltros,
                            child: const Text('Limpiar filtros'),
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
          ),
        ],
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
      child: Container(
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      ? Image.network(fotoUrl, fit: BoxFit.cover)
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _mostrarDetallesMascota(context, mascota);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
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
    final fotos = mascota.fotos ?? [];
    final fotoPrincipal = provider.obtenerFotoPrincipal(mascota);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
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
              const SizedBox(height: 16),

              // Foto principal o carrusel
              if (fotos.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: fotos.length,
                    itemBuilder: (context, index) {
                      final foto = fotos[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          foto.storageKey,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                )
              else if (fotoPrincipal.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    fotoPrincipal,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              const SizedBox(height: 16),

              Text(
                mascota.nombre,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  _obtenerEstadoTexto(mascota.estatus),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: _obtenerEstadoColor(mascota.estatus),
              ),
              const SizedBox(height: 16),

              // Info básica
              Column(
                children: [
                  _buildInfoItem('Especie', mascota.especie, Icons.pets),
                  _buildInfoItem(
                    'Raza',
                    mascota.raza ?? 'No especificada',
                    Icons.emoji_nature,
                  ),
                  _buildInfoItem(
                    'Edad',
                    '${mascota.edadEnAnios ?? '?'} años',
                    Icons.cake,
                  ),
                  _buildInfoItem(
                    'Sexo',
                    _obtenerSexoTexto(mascota.sexo),
                    Icons.female,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Secciones
              if (mascota.personalidad != null)
                _buildSeccion(
                  'Personalidad',
                  Icons.psychology,
                  mascota.personalidad!,
                ),
              if (mascota.estadoSalud != null)
                _buildSeccion(
                  'Estado de salud',
                  Icons.medical_services,
                  mascota.estadoSalud!,
                ),
              if (mascota.requisitoAdopcion != null)
                _buildSeccion(
                  'Requisitos de adopción',
                  Icons.checklist,
                  mascota.requisitoAdopcion!,
                ),
              if (mascota.origen != null)
                _buildSeccion('Origen', Icons.place, mascota.origen!),
              if (mascota.notas != null)
                _buildSeccion('Notas adicionales', Icons.note, mascota.notas!),

              const SizedBox(height: 16),

              // Botones
              if (mascota.estatus == 1) // Disponible
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/solicitud-adopcion',
                        arguments: mascota.id,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Solicitar adopción',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cerrar', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String titulo, String valor, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
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
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 14,
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

  Widget _buildSeccion(String titulo, IconData icon, String contenido) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(contenido, style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  String _obtenerSexoTexto(int? sexo) {
    if (sexo == null) return 'No especificado';
    switch (sexo) {
      case 1:
        return 'Macho';
      case 2:
        return 'Hembra';
      default:
        return 'No especificado';
    }
  }

  String _obtenerEstadoTexto(int estatus) {
    switch (estatus) {
      case 1:
        return 'Disponible';
      case 2:
        return 'En proceso';
      case 3:
        return 'Adoptado';
      case 4:
        return 'No disponible';
      default:
        return 'Desconocido';
    }
  }

  Color _obtenerEstadoColor(int estatus) {
    switch (estatus) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
