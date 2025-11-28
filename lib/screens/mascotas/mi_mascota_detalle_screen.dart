import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../models/mascota.dart';
import '../../models/actualizar_mascota_request.dart';
import '../../providers/mascota_provider.dart';

class MiMascotaDetalleScreen extends StatefulWidget {
  final String mascotaId;

  const MiMascotaDetalleScreen({super.key, required this.mascotaId});

  @override
  State<MiMascotaDetalleScreen> createState() => _MiMascotaDetalleScreenState();
}

class _MiMascotaDetalleScreenState extends State<MiMascotaDetalleScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;
  Mascota? _mascota;

  // Controladores de formulario - Solo campos soportados por la API
  final _nombreController = TextEditingController();
  final _especieController = TextEditingController();
  final _razaController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _personalidadController = TextEditingController();
  final _estadoSaludController = TextEditingController();
  final _notasController = TextEditingController();

  int _sexoSeleccionado = 1;

  @override
  void initState() {
    super.initState();
    _cargarMascota();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _especieController.dispose();
    _razaController.dispose();
    _fechaNacimientoController.dispose();
    _personalidadController.dispose();
    _estadoSaludController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _cargarMascota() async {
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<MascotaProvider>(context, listen: false);
      final response = await provider.obtenerMiMascota(widget.mascotaId);

      if (response.success && response.data != null) {
        setState(() {
          _mascota = response.data!;
          _llenarFormulario();
        });
      } else {
        _mostrarError(response.message ?? 'Error al cargar la mascota');
      }
    } catch (e) {
      _mostrarError('Error inesperado: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _llenarFormulario() {
    if (_mascota == null) return;

    _nombreController.text = _mascota!.nombre;
    _especieController.text = _mascota!.especie;
    _razaController.text = _mascota!.raza ?? '';
    _fechaNacimientoController.text =
        _mascota!.fechaNacimiento?.toIso8601String() ?? '';
    _personalidadController.text = _mascota!.personalidad ?? '';
    _estadoSaludController.text = _mascota!.estadoSalud ?? '';
    _notasController.text = _mascota!.notas ?? '';

    _sexoSeleccionado = _mascota!.sexo ?? 1;
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = ActualizarMascotaRequest(
        nombre: _nombreController.text.trim().isNotEmpty
            ? _nombreController.text.trim()
            : null,
        especie: _especieController.text.trim().isNotEmpty
            ? _especieController.text.trim()
            : null,
        raza: _razaController.text.trim().isNotEmpty
            ? _razaController.text.trim()
            : null,
        fechaNacimiento: _fechaNacimientoController.text.trim().isNotEmpty
            ? _fechaNacimientoController.text.trim()
            : null,
        sexo: _sexoSeleccionado,
        personalidad: _personalidadController.text.trim().isNotEmpty
            ? _personalidadController.text.trim()
            : null,
        estadoSalud: _estadoSaludController.text.trim().isNotEmpty
            ? _estadoSaludController.text.trim()
            : null,
        notas: _notasController.text.trim().isNotEmpty
            ? _notasController.text.trim()
            : null,
      );

      final provider = Provider.of<MascotaProvider>(context, listen: false);
      final response = await provider.actualizarMiMascota(
        widget.mascotaId,
        request,
      );

      if (response.success) {
        setState(() {
          _isEditing = false;
          if (response.data != null) {
            _mascota = response.data!;
          }
        });
        _mostrarMensaje('Mascota actualizada exitosamente', isError: false);

        // Recargar lista de mascotas
        provider.cargarMisMascotas();
      } else {
        _mostrarError(response.message ?? 'Error al actualizar la mascota');
      }
    } catch (e) {
      _mostrarError('Error inesperado: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    _mostrarMensaje(mensaje, isError: true);
  }

  void _mostrarMensaje(String mensaje, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_mascota?.nombre ?? 'Mi Mascota'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing && _mascota != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _isEditing = false);
                _llenarFormulario(); // Restaurar valores originales
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mascota == null
          ? const Center(
              child: Text('No se pudo cargar la información de la mascota'),
            )
          : _buildContent(),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              onPressed: _isLoading ? null : _guardarCambios,
              backgroundColor: AppTheme.primaryColor,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.save, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información básica
            _buildSeccionTitulo('Información Básica'),
            _buildCampoTexto('Nombre', _nombreController, required: true),
            _buildCampoTexto('Especie', _especieController, required: true),
            _buildCampoTexto('Raza', _razaController),

            // Fecha de nacimiento
            const SizedBox(height: 20),
            _buildSeccionTitulo('Fecha de Nacimiento'),
            _buildCampoTexto('Fecha (ISO Format)', _fechaNacimientoController),

            // Sexo
            const SizedBox(height: 20),
            _buildSelectorSexo(),

            // Personalidad y salud
            const SizedBox(height: 20),
            _buildSeccionTitulo('Personalidad y Salud'),
            _buildCampoTexto(
              'Personalidad',
              _personalidadController,
              maxLines: 3,
            ),
            _buildCampoTexto(
              'Estado de Salud',
              _estadoSaludController,
              maxLines: 2,
            ),
            _buildCampoTexto('Notas', _notasController, maxLines: 3),

            const SizedBox(height: 100), // Espacio para el FAB
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildCampoTexto(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: !_isEditing,
          fillColor: !_isEditing ? Colors.grey[100] : null,
        ),
        validator: required && _isEditing
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es requerido';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildSelectorSexo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sexo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<int>(
                  title: const Text('Macho'),
                  value: 1,
                  groupValue: _sexoSeleccionado,
                  onChanged: _isEditing
                      ? (value) => setState(() => _sexoSeleccionado = value!)
                      : null,
                ),
              ),
              Expanded(
                child: RadioListTile<int>(
                  title: const Text('Hembra'),
                  value: 2,
                  groupValue: _sexoSeleccionado,
                  onChanged: _isEditing
                      ? (value) => setState(() => _sexoSeleccionado = value!)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
