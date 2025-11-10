import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/cita_provider.dart';
import '../../models/cita.dart';
import '../../models/mascota.dart';
import '../../models/veterinario.dart';

/// Pantalla para crear una nueva cita
class NuevaCitaScreen extends StatefulWidget {
  const NuevaCitaScreen({super.key});

  @override
  State<NuevaCitaScreen> createState() => _NuevaCitaScreenState();
}

class _NuevaCitaScreenState extends State<NuevaCitaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _motivoController = TextEditingController();
  final _notasController = TextEditingController();

  // Valores del formulario
  Mascota? _mascotaSeleccionada;
  Veterinario? _veterinarioSeleccionado;
  String? _tipoConsultaSeleccionado;
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  int _duracionMinutos = 30;
  bool _enviarRecordatorio = true;

  // Tipos de consulta disponibles
  final List<String> _tiposConsulta = [
    'Consulta General',
    'Vacunación',
    'Cirugía Menor',
    'Cirugía Mayor',
    'Esterilización',
    'Desparasitación',
    'Control de Peso',
    'Emergencia',
    'Seguimiento',
    'Estética',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _motivoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    final citaProvider = context.read<CitaProvider>();
    await citaProvider.cargarMisMascotas();
    await citaProvider.cargarVeterinarios();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Cita')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<CitaProvider>(
              builder: (context, citaProvider, child) {
                if (citaProvider.mascotas.isEmpty) {
                  return _buildSinMascotas();
                }

                return Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSeleccionMascota(citaProvider.mascotas),
                      const SizedBox(height: 16),
                      _buildSeleccionTipoConsulta(),
                      const SizedBox(height: 16),
                      _buildSeleccionVeterinario(citaProvider.veterinarios),
                      const SizedBox(height: 16),
                      _buildSeleccionFecha(),
                      const SizedBox(height: 16),
                      _buildSeleccionHora(),
                      const SizedBox(height: 16),
                      _buildSeleccionDuracion(),
                      const SizedBox(height: 16),
                      _buildCampoMotivo(),
                      const SizedBox(height: 16),
                      _buildCampoNotas(),
                      const SizedBox(height: 16),
                      _buildCheckboxRecordatorio(),
                      const SizedBox(height: 24),
                      _buildBotonCrear(citaProvider),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSinMascotas() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No tienes mascotas registradas',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Primero debes registrar una mascota',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  Widget _buildSeleccionMascota(List<Mascota> mascotas) {
    return DropdownButtonFormField<Mascota>(
      value: _mascotaSeleccionada,
      decoration: const InputDecoration(
        labelText: 'Mascota *',
        prefixIcon: Icon(Icons.pets),
      ),
      items: mascotas.map((mascota) {
        return DropdownMenuItem(
          value: mascota,
          child: Text('${mascota.nombre} (${mascota.especie})'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _mascotaSeleccionada = value);
      },
      validator: (value) {
        if (value == null) return 'Selecciona una mascota';
        return null;
      },
    );
  }

  Widget _buildSeleccionTipoConsulta() {
    return DropdownButtonFormField<String>(
      value: _tipoConsultaSeleccionado,
      decoration: const InputDecoration(
        labelText: 'Tipo de Consulta *',
        prefixIcon: Icon(Icons.medical_services),
      ),
      items: _tiposConsulta.map((tipo) {
        return DropdownMenuItem(value: tipo, child: Text(tipo));
      }).toList(),
      onChanged: (value) {
        setState(() => _tipoConsultaSeleccionado = value);
      },
      validator: (value) {
        if (value == null) return 'Selecciona un tipo de consulta';
        return null;
      },
    );
  }

  Widget _buildSeleccionVeterinario(List<Veterinario> veterinarios) {
    if (veterinarios.isEmpty) {
      return Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No hay veterinarios disponibles',
                  style: TextStyle(color: Colors.orange.shade700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DropdownButtonFormField<Veterinario>(
      value: _veterinarioSeleccionado,
      decoration: const InputDecoration(
        labelText: 'Veterinario *',
        prefixIcon: Icon(Icons.person),
      ),
      items: veterinarios.map((veterinario) {
        return DropdownMenuItem(
          value: veterinario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(veterinario.titulo),
              if (veterinario.especialidad != null)
                Text(
                  veterinario.especialidad!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _veterinarioSeleccionado = value);
      },
      validator: (value) {
        if (value == null) return 'Selecciona un veterinario';
        return null;
      },
    );
  }

  Widget _buildSeleccionFecha() {
    return InkWell(
      onTap: _seleccionarFecha,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha *',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _fechaSeleccionada != null
              ? DateFormat('dd/MM/yyyy', 'es').format(_fechaSeleccionada!)
              : 'Selecciona una fecha',
          style: TextStyle(
            color: _fechaSeleccionada != null
                ? Colors.black87
                : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSeleccionHora() {
    return InkWell(
      onTap: _seleccionarHora,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Hora *',
          prefixIcon: Icon(Icons.access_time),
        ),
        child: Text(
          _horaSeleccionada != null
              ? _horaSeleccionada!.format(context)
              : 'Selecciona una hora',
          style: TextStyle(
            color: _horaSeleccionada != null
                ? Colors.black87
                : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSeleccionDuracion() {
    return DropdownButtonFormField<int>(
      value: _duracionMinutos,
      decoration: const InputDecoration(
        labelText: 'Duración estimada',
        prefixIcon: Icon(Icons.timer),
      ),
      items: const [
        DropdownMenuItem(value: 15, child: Text('15 minutos')),
        DropdownMenuItem(value: 30, child: Text('30 minutos')),
        DropdownMenuItem(value: 45, child: Text('45 minutos')),
        DropdownMenuItem(value: 60, child: Text('1 hora')),
        DropdownMenuItem(value: 90, child: Text('1.5 horas')),
        DropdownMenuItem(value: 120, child: Text('2 horas')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _duracionMinutos = value);
        }
      },
    );
  }

  Widget _buildCampoMotivo() {
    return TextFormField(
      controller: _motivoController,
      decoration: const InputDecoration(
        labelText: 'Motivo de la consulta *',
        prefixIcon: Icon(Icons.description),
        hintText: 'Describe el motivo de la cita',
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ingresa el motivo de la consulta';
        }
        return null;
      },
    );
  }

  Widget _buildCampoNotas() {
    return TextFormField(
      controller: _notasController,
      decoration: const InputDecoration(
        labelText: 'Notas adicionales (opcional)',
        prefixIcon: Icon(Icons.note),
        hintText: 'Información adicional relevante',
      ),
      maxLines: 3,
    );
  }

  Widget _buildCheckboxRecordatorio() {
    return CheckboxListTile(
      value: _enviarRecordatorio,
      onChanged: (value) {
        setState(() => _enviarRecordatorio = value ?? true);
      },
      title: const Text('Enviar recordatorios'),
      subtitle: const Text('Recibirás notificaciones antes de la cita'),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildBotonCrear(CitaProvider citaProvider) {
    return ElevatedButton.icon(
      onPressed: citaProvider.isLoading ? null : _crearCita,
      icon: citaProvider.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.check),
      label: Text(citaProvider.isLoading ? 'Creando cita...' : 'Crear Cita'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: ahora,
      firstDate: ahora,
      lastDate: ahora.add(const Duration(days: 90)),
      locale: const Locale('es', 'ES'),
    );

    if (fecha != null) {
      setState(() => _fechaSeleccionada = fecha);
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() => _horaSeleccionada = hora);
    }
  }

  Future<void> _crearCita() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona una fecha')));
      return;
    }

    if (_horaSeleccionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona una hora')));
      return;
    }

    // Combinar fecha y hora
    final fechaHora = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      _horaSeleccionada!.hour,
      _horaSeleccionada!.minute,
    );

    // Validar que la fecha/hora sea futura
    if (fechaHora.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha y hora deben ser futuras')),
      );
      return;
    }

    final citaProvider = context.read<CitaProvider>();

    final request = CrearCitaRequest(
      mascotaId: _mascotaSeleccionada!.id,
      veterinarioId: _veterinarioSeleccionado!.id,
      fechaHora: fechaHora,
      duracionMinutos: _duracionMinutos,
      tipoConsulta: _tipoConsultaSeleccionado!,
      motivo: _motivoController.text.trim(),
      notas: _notasController.text.trim().isEmpty
          ? null
          : _notasController.text.trim(),
      enviarRecordatorio: _enviarRecordatorio,
    );

    final cita = await citaProvider.crearCita(request);

    if (mounted) {
      if (cita != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              citaProvider.errorMessage ?? 'Error al crear la cita',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
