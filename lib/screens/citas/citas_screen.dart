import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cita_provider.dart';
import '../../models/cita.dart';
import '../../widgets/cita_card.dart';
import '../../config/app_theme.dart';
import 'cita_detalle_screen.dart';
import 'nueva_cita_screen.dart';
import 'pagar_cita_screen.dart';

/// Pantalla principal de citas
class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    final citaProvider = context.read<CitaProvider>();
    await citaProvider.cargarMisCitas();
    await citaProvider.cargarMisMascotas();
    setState(() => _isLoading = false);
  }

  Future<void> _refrescar() async {
    final citaProvider = context.read<CitaProvider>();
    await citaProvider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Próximas'),
            Tab(text: 'Pasadas'),
            Tab(text: 'Canceladas'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<CitaProvider>(
              builder: (context, citaProvider, child) {
                if (citaProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (citaProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          citaProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _cargarDatos,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refrescar,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCitasList(citaProvider.citasProgramadas),
                      _buildCitasList(citaProvider.citasPasadas),
                      _buildCitasList(citaProvider.citasCanceladas),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarANuevaCita,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cita'),
      ),
    );
  }

  Widget _buildCitasList(List<Cita> citas) {
    if (citas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No hay citas',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Programa una nueva cita para tu mascota',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: citas.length,
      itemBuilder: (context, index) {
        final cita = citas[index];
        return CitaCard(
          cita: cita,
          onTap: () => _navegarADetalle(cita),
          onPagar: cita.requiereAnticipo ? () => _navegarAPagar(cita) : null,
          onCancelar: cita.puedeCancelarse
              ? () => _mostrarDialogoCancelar(cita)
              : null,
        );
      },
    );
  }

  void _navegarANuevaCita() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const NuevaCitaScreen()))
        .then((_) => _refrescar());
  }

  void _navegarADetalle(Cita cita) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CitaDetalleScreen(citaId: cita.id),
      ),
    );
  }

  void _navegarAPagar(Cita cita) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => PagarCitaScreen(cita: cita)),
        )
        .then((_) => _refrescar());
  }

  void _mostrarDialogoCancelar(Cita cita) {
    final motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que deseas cancelar esta cita?',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo de cancelación',
                hintText: 'Ingresa el motivo',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver'),
          ),
          ElevatedButton(
            onPressed: () async {
              final motivo = motivoController.text.trim();
              if (motivo.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debes ingresar un motivo de cancelación'),
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _cancelarCita(cita, motivo);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancelar Cita'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelarCita(Cita cita, String motivo) async {
    final citaProvider = context.read<CitaProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final exito = await citaProvider.cancelarCita(
      citaId: cita.id,
      motivo: motivo,
    );

    if (mounted) {
      Navigator.pop(context); // Cerrar loading

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita cancelada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              citaProvider.errorMessage ?? 'Error al cancelar la cita',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
