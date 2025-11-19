import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/mascota.dart';
import '../../models/solicitud_cita.dart';
import '../../services/mascota_service.dart';
import '../../services/solicitud_cita_service.dart';
import '../../providers/auth_provider.dart';
import 'pagar_solicitud_screen.dart';

/// Pantalla para solicitar cita veterinaria
/// Según documentación: 03-SolicitudesCitasDigitales-API.md
class SolicitudCitaScreen extends StatefulWidget {
  const SolicitudCitaScreen({super.key});

  @override
  State<SolicitudCitaScreen> createState() => _SolicitudCitaScreenState();
}

class _SolicitudCitaScreenState extends State<SolicitudCitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mascotaService = MascotaService();
  final _solicitudService = SolicitudCitaService();

  // Estados de carga
  bool _isLoadingMascotas = true;
  bool _isLoadingServicios = true;
  bool _isCreatingSolicitud = false;

  // Listas
  List<Mascota> _mascotas = [];
  List<Servicio> _servicios = [];

  // Selecciones
  Mascota? _mascotaSeleccionada;
  Servicio? _servicioSeleccionado;
  DateTime _fechaSeleccionada = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _horaSeleccionada = const TimeOfDay(hour: 10, minute: 0);

  // Campos del formulario según documentación API
  String _motivo = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await Future.wait([_cargarMascotas(), _cargarServicios()]);
  }

  Future<void> _cargarMascotas() async {
    setState(() => _isLoadingMascotas = true);

    try {
      final response = await _mascotaService.obtenerMisMascotas();
      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            _mascotas = response.data!;
            if (_mascotas.isNotEmpty) {
              _mascotaSeleccionada = _mascotas.first;
            }
          }
          _isLoadingMascotas = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMascotas = false);
      }
    }
  }

  Future<void> _cargarServicios() async {
    setState(() => _isLoadingServicios = true);

    try {
      final response = await _solicitudService.obtenerServicios();
      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            _servicios = response.data!;
            if (_servicios.isNotEmpty) {
              _servicioSeleccionado = _servicios.first;
            }
          }
          _isLoadingServicios = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingServicios = false);
      }
    }
  }

  Future<void> _crearSolicitud() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final usuario = Provider.of<AuthProvider>(context, listen: false).usuario;

    // ✅ 1. Validar que el usuario esté autenticado
    if (usuario == null || usuario.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error: Usuario no autenticado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ 2. Validar que la mascota esté seleccionada
    if (_mascotaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Selecciona una mascota'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ 3. Validar que el servicio esté seleccionado
    if (_servicioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Selecciona un servicio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ 4. Validar que el motivo no esté vacío
    if (_motivo.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Debes proporcionar un motivo de consulta'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Solicitud'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mascota: ${_mascotaSeleccionada!.nombre}'),
            Text('Especie: ${_mascotaSeleccionada!.especie}'),
            if (_mascotaSeleccionada!.raza != null)
              Text('Raza: ${_mascotaSeleccionada!.raza}'),
            const SizedBox(height: 8),
            Text('Servicio: ${_servicioSeleccionado!.descripcion}'),
            Text(
              'Costo estimado: \$${_servicioSeleccionado!.precioSugerido.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha: ${DateFormat('dd/MM/yyyy').format(_fechaSeleccionada)}',
            ),
            Text('Hora: ${_horaSeleccionada.format(context)}'),
            Text(
              'Duración estimada: ${_servicioSeleccionado!.duracionMinDefault} min',
            ),
            const SizedBox(height: 8),
            Text('Motivo: $_motivo'),
            const SizedBox(height: 16),
            const Text(
              'Tu solicitud será revisada por el personal. '
              'Te contactaremos pronto para confirmar tu cita.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isCreatingSolicitud = true);

    try {
      // ✅ 5. Crear fecha/hora combinada en UTC (formato ISO 8601 con Z)
      final fechaHora = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day,
        _horaSeleccionada.hour,
        _horaSeleccionada.minute,
      );

      // Convertir a UTC y formato ISO 8601 estándar
      final fechaHoraISO = fechaHora.toUtc().toIso8601String();

      // ✅ 6. Validar que todos los datos de mascota estén completos
      if (_mascotaSeleccionada!.nombre.isEmpty) {
        throw Exception('Nombre de mascota no puede estar vacío');
      }
      if (_mascotaSeleccionada!.especie.isEmpty) {
        throw Exception('Especie de mascota no puede estar vacía');
      }

      // ✅ 7. Validar que todos los datos de servicio estén completos
      if (_servicioSeleccionado!.descripcion.isEmpty) {
        throw Exception('Descripción del servicio no puede estar vacía');
      }
      if (_servicioSeleccionado!.duracionMinDefault <= 0) {
        throw Exception('Duración del servicio debe ser mayor a 0');
      }
      if (_servicioSeleccionado!.precioSugerido < 0) {
        throw Exception('Precio del servicio no puede ser negativo');
      }

      print('\n🔷 === CREANDO SOLICITUD DE CITA ===');
      print('📋 Datos del usuario:');
      print('   ID: ${usuario.id}');
      print('   Nombre: ${usuario.nombre}');
      print('   Email: ${usuario.email}');
      print('\n📋 Datos de la mascota:');
      print('   ID: ${_mascotaSeleccionada!.id}');
      print('   Nombre: ${_mascotaSeleccionada!.nombre}');
      print('   Especie: ${_mascotaSeleccionada!.especie}');
      print('   Raza: ${_mascotaSeleccionada!.raza ?? "N/A"}');
      print('\n📋 Datos del servicio:');
      print('   ID: ${_servicioSeleccionado!.id}');
      print('   Descripción: ${_servicioSeleccionado!.descripcion}');
      print('   Duración: ${_servicioSeleccionado!.duracionMinDefault} min');
      print('   Costo: \$${_servicioSeleccionado!.precioSugerido}');
      print('\n📋 Datos de la cita:');
      print('   Fecha/Hora solicitada: $fechaHoraISO');
      print('   Motivo: $_motivo');

      // ✅ 8. Crear request con TODOS los campos requeridos
      final request = CrearSolicitudCitaRequest(
        solicitanteId: usuario.id,
        mascotaId: _mascotaSeleccionada!.id,
        nombreMascota: _mascotaSeleccionada!.nombre,
        especieMascota: _mascotaSeleccionada!.especie,
        razaMascota: _mascotaSeleccionada!.raza,
        servicioId: _servicioSeleccionado!.id,
        descripcionServicio: _servicioSeleccionado!.descripcion,
        motivoConsulta: _motivo.trim(),
        fechaHoraSolicitada: fechaHoraISO,
        duracionEstimadaMin: _servicioSeleccionado!.duracionMinDefault,
        costoEstimado: _servicioSeleccionado!.precioSugerido,
      );

      print('\n📤 Request JSON a enviar:');
      print(request.toJson());

      final response = await _solicitudService.crearSolicitud(request);

      if (!mounted) return;

      setState(() => _isCreatingSolicitud = false);

      if (response.success && response.data != null) {
        final solicitudCreada = response.data!;

        print('✅ Solicitud creada exitosamente:');
        print('   ID: ${solicitudCreada.id}');
        print('   Número: ${solicitudCreada.numeroSolicitud}');
        print('   Estado: ${solicitudCreada.estadoNombre}');
        print('   Costo estimado: \$${solicitudCreada.costoEstimado}');
        print('   Monto anticipo: \$${solicitudCreada.montoAnticipo}');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ¡Solicitud creada! Procede al pago del anticipo'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // ✅ Redirigir automáticamente a la pantalla de pago
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PagarSolicitudScreen(solicitud: solicitudCreada),
          ),
        );
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isCreatingSolicitud = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al crear solicitud: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('es', 'ES'),
      helpText: 'Selecciona fecha de la cita',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  Future<void> _selectHora() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
      helpText: 'Selecciona hora de la cita',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _horaSeleccionada) {
      // Validar horario laboral (8 AM - 6 PM)
      if (picked.hour < 8 || picked.hour >= 18) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Horario debe estar entre 8:00 AM y 6:00 PM'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _horaSeleccionada = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Cita'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingMascotas || _isLoadingServicios
          ? const Center(child: CircularProgressIndicator())
          : _mascotas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes mascotas registradas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/registrar-mascota');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar Mascota'),
                  ),
                ],
              ),
            )
          : _servicios.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.orange),
                  SizedBox(height: 16),
                  Text(
                    'No hay servicios disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seleccionar mascota
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '1. Selecciona tu mascota',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<Mascota>(
                              value: _mascotaSeleccionada,
                              decoration: const InputDecoration(
                                labelText: 'Mascota *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.pets),
                              ),
                              items: _mascotas.map((mascota) {
                                return DropdownMenuItem(
                                  value: mascota,
                                  child: Text(
                                    '${mascota.nombre} (${mascota.especie})',
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _mascotaSeleccionada = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Selecciona una mascota';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Seleccionar servicio
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '2. Tipo de servicio',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<Servicio>(
                              value: _servicioSeleccionado,
                              decoration: const InputDecoration(
                                labelText: 'Servicio *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.medical_services),
                              ),
                              items: _servicios.map((servicio) {
                                return DropdownMenuItem(
                                  value: servicio,
                                  child: Text(servicio.descripcion),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _servicioSeleccionado = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Selecciona un servicio';
                                }
                                return null;
                              },
                            ),
                            if (_servicioSeleccionado != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Duración: ${_servicioSeleccionado!.duracionMinDefault} min',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.attach_money,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Precio estimado: \$${_servicioSeleccionado!.precioSugerido.toStringAsFixed(2)}',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fecha y hora
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '3. Fecha y hora preferida',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _selectFecha,
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_fechaSeleccionada),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _selectHora,
                                    icon: const Icon(Icons.access_time),
                                    label: Text(
                                      _horaSeleccionada.format(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Horario laboral: 8:00 AM - 6:00 PM',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Motivo de la consulta
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '4. Motivo de la consulta',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Motivo de consulta *',
                                hintText:
                                    'Ej: Revisión general, vacunación, esterilización programada',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.edit),
                              ),
                              maxLines: 3,
                              maxLength: 500,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El motivo es requerido';
                                }
                                if (value.trim().length < 10) {
                                  return 'El motivo debe tener al menos 10 caracteres';
                                }
                                return null;
                              },
                              onSaved: (value) => _motivo = value!,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón de enviar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isCreatingSolicitud
                            ? null
                            : _crearSolicitud,
                        icon: _isCreatingSolicitud
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          _isCreatingSolicitud
                              ? 'Enviando...'
                              : 'Enviar Solicitud',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nota informativa
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Proceso de solicitud:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '1. Tu solicitud será revisada por el personal\n'
                                  '2. Te contactaremos para confirmar disponibilidad\n'
                                  '3. Una vez confirmada, se creará tu cita oficial\n'
                                  '4. Recibirás los detalles de pago',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
