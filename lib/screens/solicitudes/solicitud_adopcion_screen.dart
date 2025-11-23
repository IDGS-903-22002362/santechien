import 'package:adopets_app/models/solicitud_adopcion.dart';
import 'package:adopets_app/providers/adopcion_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SolicitudAdopcionScreen extends StatefulWidget {
  const SolicitudAdopcionScreen({super.key});

  @override
  State<SolicitudAdopcionScreen> createState() =>
      _SolicitudAdopcionScreenState();
}

class _SolicitudAdopcionScreenState extends State<SolicitudAdopcionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController motivoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController ingresosController = TextEditingController();
  final TextEditingController ninosController = TextEditingController();
  final TextEditingController horasController = TextEditingController();

  // Variables del formulario
  int vivienda = 1; // 1 casa, 2 depa, etc.
  bool otrasMascotas = false;

  late String mascotaId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mascotaId = ModalRoute.of(context)!.settings.arguments as String;
  }

  @override
  Widget build(BuildContext context) {
    final solicitudProvider = context.watch<AdopcionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Solicitud de Adopción")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Estás solicitando adoptar una mascota",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Tipo de vivienda
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Tipo de vivienda",
                  border: OutlineInputBorder(),
                ),
                value: vivienda,
                items: const [
                  DropdownMenuItem(value: 1, child: Text("Casa")),
                  DropdownMenuItem(value: 2, child: Text("Departamento")),
                  DropdownMenuItem(value: 3, child: Text("Quinta")),
                  DropdownMenuItem(value: 99, child: Text("Otro")),
                ],
                onChanged: (v) => setState(() => vivienda = v!),
              ),

              const SizedBox(height: 20),

              // Número de niños
              TextFormField(
                controller: ninosController,
                decoration: const InputDecoration(
                  labelText: "Número de niños",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? "Ingresa un número" : null,
              ),

              const SizedBox(height: 20),

              // Otras mascotas
              SwitchListTile(
                title: const Text("¿Tienes otras mascotas?"),
                value: otrasMascotas,
                onChanged: (v) => setState(() => otrasMascotas = v),
              ),

              const SizedBox(height: 10),

              // Horas disponibles
              TextFormField(
                controller: horasController,
                decoration: const InputDecoration(
                  labelText: "Horas disponibles al día",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? "Ingresa un número" : null,
              ),

              const SizedBox(height: 20),

              // Dirección
              TextFormField(
                controller: direccionController,
                decoration: const InputDecoration(
                  labelText: "Dirección",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) =>
                    v == null || v.isEmpty ? "Escribe la dirección" : null,
              ),

              const SizedBox(height: 20),

              // Ingresos mensuales
              TextFormField(
                controller: ingresosController,
                decoration: const InputDecoration(
                  labelText: "Ingresos mensuales",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? "Ingresa un número" : null,
              ),

              const SizedBox(height: 20),

              // Motivo de adopción
              TextFormField(
                controller: motivoController,
                decoration: const InputDecoration(
                  labelText: "Motivo de adopción",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? "Escribe el motivo" : null,
              ),

              const SizedBox(height: 30),

              // Botón
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: solicitudProvider.loading ? null : enviarSolicitud,
                  child: solicitudProvider.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Enviar solicitud"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void enviarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AdopcionProvider>();

    final solicitud = Adopcion(
      usuarioId: "00000000-0000-0000-0000-000000000000", // TEMPORAL
      mascotaId: mascotaId,
      vivienda: vivienda,
      numNinios: int.parse(ninosController.text),
      otrasMascotas: otrasMascotas,
      horasDisponibilidad: num.parse(horasController.text),
      direccion: direccionController.text,
      ingresosMensuales: num.parse(ingresosController.text),
      motivoAdopcion: motivoController.text,
      fechaSolicitud: DateTime.now(),
      estado: 1,
    );

    await provider.enviarSolicitud(solicitud);

    if (!mounted) return;

    if (provider.solicitudEnviada) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Solicitud enviada"),
          content: const Text(
            "Tu solicitud de adopción ha sido enviada correctamente.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
                Navigator.pushReplacementNamed(
                  context,
                  '/mascotas',
                ); // Navegar a mascotas
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? "Error desconocido")),
      );
    }
  }
}
