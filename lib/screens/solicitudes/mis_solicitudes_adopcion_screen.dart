import 'package:adopets_app/models/solicitud_adopcion_response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adopets_app/providers/adopcion_provider.dart';
import 'package:intl/intl.dart';

class MisSolicitudesAdopcionScreen extends StatefulWidget {
  const MisSolicitudesAdopcionScreen({super.key});

  @override
  _MisSolicitudesAdopcionScreenState createState() =>
      _MisSolicitudesAdopcionScreenState();
}

class _MisSolicitudesAdopcionScreenState
    extends State<MisSolicitudesAdopcionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<AdopcionProvider>(
        context,
        listen: false,
      ).cargarMisSolicitudes(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdopcionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Solicitudes de Adopción"),
        // QUITÉ el fondo azul
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: provider.loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Cargando solicitudes...",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : provider.misSolicitudes.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                await provider.cargarMisSolicitudes();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.misSolicitudes.length,
                itemBuilder: (_, index) {
                  final solicitud = provider.misSolicitudes[index];
                  return _SolicitudCard(solicitud: solicitud);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          const Text(
            "No tienes solicitudes",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Cuando solicites adoptar una mascota,\naparecerán aquí tus solicitudes.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.pets),
            label: const Text("Explorar Mascotas"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  final SolicitudAdopcionResponse solicitud;

  const _SolicitudCard({required this.solicitud});

  // Métodos para convertir valores numéricos a texto
  String _getEstadoTexto(int estado) {
    switch (estado) {
      case 1:
        return 'Pendiente';
      case 2:
        return 'En revisión';
      case 3:
        return 'Aprobada';
      case 4:
        return 'Rechazada';
      default:
        return 'Desconocido';
    }
  }

  Color _getEstadoColor(int estado) {
    switch (estado) {
      case 1: // Pendiente
        return Colors.orange;
      case 2: // En revisión
        return Colors.blue;
      case 3: // Aprobada
        return Colors.green;
      case 4: // Rechazada
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotos = solicitud.fotos;
    final fechaSolicitud = solicitud.fechaSolicitud.toLocal();
    final fechaFormateada = DateFormat('dd/MM/yyyy').format(fechaSolicitud);
    final estadoTexto = _getEstadoTexto(solicitud.estado);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SolicitudDetalleScreen(solicitud: solicitud),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 150,
          // AÑADÍ márgenes internos
          margin: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Foto a la izquierda - AÑADÍ márgenes
              Container(
                width: 140,
                margin: const EdgeInsets.all(8), // Márgenes para la foto
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Bordes redondeados
                  color: Colors.grey.shade100,
                ),
                child: fotos.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Bordes redondeados
                        child: Image.network(
                          fotos
                              .firstWhere(
                                (foto) => foto.esPrincipal,
                                orElse: () => fotos.first,
                              )
                              .storageKey,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.pets,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
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
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.pets,
                          size: 40,
                          color: Colors.grey.shade400,
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  solicitud.mascotaNombre,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Chip(
                                label: Text(
                                  estadoTexto,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: _getEstadoColor(
                                  solicitud.estado,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                fechaFormateada,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Solicitante: ${solicitud.usuarioNombre}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // Botón ver detalles
                      Container(
                        width: double.infinity,
                        height: 28,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SolicitudDetalleScreen(
                                  solicitud: solicitud,
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue.shade700,
                            side: BorderSide(color: Colors.blue.shade700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          child: const Text(
                            "Ver Detalles",
                            style: TextStyle(
                              fontSize: 11,
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
}

/// Pantalla de detalles de solicitud - COMPLETA con motivo de rechazo
class SolicitudDetalleScreen extends StatelessWidget {
  final SolicitudAdopcionResponse solicitud;

  const SolicitudDetalleScreen({super.key, required this.solicitud});

  // Métodos de conversión
  String _getEstadoTexto(int estado) {
    switch (estado) {
      case 1:
        return 'Pendiente';
      case 2:
        return 'En revisión';
      case 3:
        return 'Aprobada';
      case 4:
        return 'Rechazada';
      default:
        return 'Desconocido';
    }
  }

  String _getViviendaTexto(int vivienda) {
    switch (vivienda) {
      case 1:
        return 'Casa';
      case 2:
        return 'Departamento';
      case 3:
        return 'Otro';
      default:
        return 'No especificado';
    }
  }

  String _getHorasDisponibilidadTexto(int horas) {
    switch (horas) {
      case 1:
        return 'Menos de 2 horas';
      case 2:
        return '2-4 horas';
      case 3:
        return '4-6 horas';
      case 4:
        return 'Más de 6 horas';
      default:
        return 'No especificado';
    }
  }

  Color _getEstadoColor(int estado) {
    switch (estado) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(int estado) {
    switch (estado) {
      case 1:
        return Icons.pending;
      case 2:
        return Icons.hourglass_empty;
      case 3:
        return Icons.check_circle;
      case 4:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Widget _buildInfoSection(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'No especificado',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: value.isNotEmpty ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanSection(String title, bool value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(
                    value ? 'Sí' : 'No',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: value ? Colors.green : Colors.red,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.isNotEmpty ? value : 'No especificado',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fotos = solicitud.fotos;
    final fechaSolicitud = solicitud.fechaSolicitud.toLocal();
    final fechaFormateada = DateFormat(
      "dd 'de' MMMM 'de' yyyy 'a las' HH:mm",
    ).format(fechaSolicitud);
    final estadoTexto = _getEstadoTexto(solicitud.estado);

    return Scaffold(
      appBar: AppBar(
        title: Text("Solicitud de ${solicitud.mascotaNombre}"),
        // QUITÉ el fondo azul
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrusel de fotos
            if (fotos.isNotEmpty)
              Container(
                height: 250,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: PageView.builder(
                    itemCount: fotos.length,
                    itemBuilder: (_, index) {
                      final fotoUrl = fotos[index].storageKey;
                      return Image.network(
                        fotoUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.pets,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                height: 150,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade100,
                ),
                child: Center(
                  child: Icon(
                    Icons.pets,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),

            // Estado de la solicitud
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: _getEstadoColor(solicitud.estado).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getEstadoColor(solicitud.estado).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getEstadoIcon(solicitud.estado),
                    color: _getEstadoColor(solicitud.estado),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado de la solicitud',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          estadoTexto,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getEstadoColor(solicitud.estado),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // CORRECCIÓN: Solo mostrar motivo de rechazo si no es null
            if (solicitud.motivoRechazo != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade700, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Motivo de rechazo',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            solicitud.motivoRechazo!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Información de la mascota
            const Text(
              "Información de la Mascota",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            _buildInfoSection(
              "Nombre de la mascota",
              solicitud.mascotaNombre,
              Icons.pets,
            ),

            // Información personal
            const SizedBox(height: 24),
            const Text(
              "Información Personal",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            _buildInfoSection(
              "Nombre del solicitante",
              solicitud.usuarioNombre,
              Icons.person,
            ),

            _buildInfoSection(
              "Tipo de vivienda",
              _getViviendaTexto(solicitud.vivienda),
              Icons.home,
            ),

            _buildInfoSection(
              "Dirección",
              solicitud.direccion,
              Icons.location_on,
            ),

            // Situación familiar
            const SizedBox(height: 24),
            const Text(
              "Situación Familiar",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            _buildInfoSection(
              "Número de niños",
              solicitud.numNinios.toString(),
              Icons.child_care,
            ),

            _buildBooleanSection(
              "¿Tiene otras mascotas?",
              solicitud.otrasMascotas,
              Icons.pets,
            ),

            // Información adicional
            const SizedBox(height: 24),
            const Text(
              "Información Adicional",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            _buildInfoSection(
              "Horas de disponibilidad",
              _getHorasDisponibilidadTexto(solicitud.horasDisponibilidad),
              Icons.access_time,
            ),

            _buildInfoSection(
              "Ingresos mensuales",
              "\$${solicitud.ingresosMensuales}",
              Icons.attach_money,
            ),

            // Motivo de adopción
            _buildTextSection(
              "Motivo de adopción",
              solicitud.motivoAdopcion,
              Icons.emoji_objects,
            ),

            // Fecha de solicitud
            _buildInfoSection(
              "Fecha de solicitud",
              fechaFormateada,
              Icons.calendar_today,
            ),

            // QUITÉ la sección del ID de solicitud
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
