import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/solicitud_cita.dart';
import '../../services/mascota_service.dart';

class RegistrarMascotaScreen extends StatefulWidget {
  const RegistrarMascotaScreen({super.key});

  @override
  State<RegistrarMascotaScreen> createState() => _RegistrarMascotaScreenState();
}

class _RegistrarMascotaScreenState extends State<RegistrarMascotaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mascotaService = MascotaService();

  // Controladores
  final _nombreController = TextEditingController();
  final _razaController = TextEditingController();
  final _personalidadController = TextEditingController();
  final _estadoSaludController = TextEditingController();
  final _notasController = TextEditingController();

  // Variables
  String _especieSeleccionada = 'Perro';
  int _sexoSeleccionado = 1; // 1 = Macho, 2 = Hembra
  DateTime? _fechaNacimiento;
  bool _isLoading = false;

  final List<String> _especies = [
    'Perro',
    'Gato',
    'Ave',
    'Roedor',
    'Reptil',
    'Otro',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _razaController.dispose();
    _personalidadController.dispose();
    _estadoSaludController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _selectFechaNacimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      helpText: 'Selecciona fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  Future<void> _registrarMascota() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = RegistrarMascotaRequest(
        nombre: _nombreController.text.trim(),
        especie: _especieSeleccionada,
        raza: _razaController.text.trim().isEmpty
            ? null
            : _razaController.text.trim(),
        fechaNacimiento: _fechaNacimiento,
        sexo: _sexoSeleccionado,
        personalidad: _personalidadController.text.trim().isEmpty
            ? null
            : _personalidadController.text.trim(),
        estadoSalud: _estadoSaludController.text.trim().isEmpty
            ? null
            : _estadoSaludController.text.trim(),
        notas: _notasController.text.trim().isEmpty
            ? null
            : _notasController.text.trim(),
      );

      final response = await _mascotaService.registrarMascota(request);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Mascota registrada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true); // Retornar true para indicar éxito
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Mi Mascota')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Descripción
                  Card(
                    color: Colors.blue[50],
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Registra tu mascota para poder solicitar citas veterinarias',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nombre
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      hintText: 'Ej: Max, Luna, Rocky',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pets),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Especie
                  DropdownButtonFormField<String>(
                    value: _especieSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Especie *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _especies.map((especie) {
                      return DropdownMenuItem(
                        value: especie,
                        child: Text(especie),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _especieSeleccionada = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Raza
                  TextFormField(
                    controller: _razaController,
                    decoration: const InputDecoration(
                      labelText: 'Raza (opcional)',
                      hintText: 'Ej: Labrador, Persa, Mestizo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pets_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sexo
                  const Text('Sexo *', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<int>(
                          title: const Text('Macho'),
                          value: 1,
                          groupValue: _sexoSeleccionado,
                          onChanged: (value) {
                            setState(() {
                              _sexoSeleccionado = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<int>(
                          title: const Text('Hembra'),
                          value: 2,
                          groupValue: _sexoSeleccionado,
                          onChanged: (value) {
                            setState(() {
                              _sexoSeleccionado = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Fecha de nacimiento
                  ListTile(
                    title: const Text('Fecha de Nacimiento (opcional)'),
                    subtitle: Text(
                      _fechaNacimiento != null
                          ? DateFormat('dd/MM/yyyy').format(_fechaNacimiento!)
                          : 'No especificada',
                    ),
                    leading: const Icon(Icons.calendar_today),
                    trailing: const Icon(Icons.edit),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    onTap: _selectFechaNacimiento,
                  ),
                  const SizedBox(height: 16),

                  // Personalidad
                  TextFormField(
                    controller: _personalidadController,
                    decoration: const InputDecoration(
                      labelText: 'Personalidad (opcional)',
                      hintText: 'Ej: Juguetón, tranquilo, amigable',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.psychology),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Estado de salud
                  TextFormField(
                    controller: _estadoSaludController,
                    decoration: const InputDecoration(
                      labelText: 'Estado de Salud (opcional)',
                      hintText: 'Ej: Saludable, vacunas al día',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.favorite),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Notas adicionales
                  TextFormField(
                    controller: _notasController,
                    decoration: const InputDecoration(
                      labelText: 'Notas Adicionales (opcional)',
                      hintText: 'Información adicional relevante',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Botón de registrar
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _registrarMascota,
                    icon: const Icon(Icons.save),
                    label: const Text('Registrar Mascota'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
