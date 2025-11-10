// Ejemplo de integración del módulo de citas en main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'config/app_theme.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/cita_provider.dart';

// Screens
import 'screens/splash_screen.dart';
// import 'screens/home_screen.dart'; // Descomentar cuando se implemente la integración

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider de autenticación existente
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // ✅ NUEVO: Provider de citas
        ChangeNotifierProvider(create: (_) => CitaProvider()),

        // Agregar más providers según sea necesario
      ],
      child: MaterialApp(
        title: 'AdoPets',
        debugShowCheckedModeBanner: false,

        // Tema de la aplicación
        theme: AppTheme.lightTheme(),

        // ✅ IMPORTANTE: Localizaciones para español
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // Español
          Locale('en', 'US'), // Inglés
        ],
        locale: const Locale('es', 'ES'), // Locale por defecto
        // Pantalla inicial
        home: const SplashScreen(),
      ),
    );
  }
}

/* 
 * EJEMPLO DE HOME SCREEN CON INTEGRACIÓN DE CITAS
 * 
 * Agregar en tu HomeScreen existente:
 */

/*
import '../widgets/citas_quick_access.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Cargar citas al iniciar
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    final citaProvider = context.read<CitaProvider>();
    await citaProvider.cargarMisCitas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdoPets'),
      ),
      
      // Drawer con item de citas
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryDark,
                    AppTheme.primaryColor,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'AdoPets',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Menú Principal',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // ✅ Item de citas en el menú
            const CitasDrawerItem(),
            
            const Divider(),
            
            // Otros items del menú...
          ],
        ),
      ),
      
      // Body con widget de acceso rápido a citas
      body: ListView(
        children: [
          // ✅ Widget de acceso rápido a citas
          const CitasQuickAccessWidget(),
          
          // Otros widgets del home...
        ],
      ),
      
      // ✅ Botón flotante para nueva cita (opcional)
      floatingActionButton: const NuevaCitaFloatingButton(),
    );
  }
}
*/

/* 
 * NOTAS IMPORTANTES:
 * 
 * 1. Agregar dependencia de localizaciones en pubspec.yaml:
 *    flutter_localizations:
 *      sdk: flutter
 * 
 * 2. El CitaProvider debe ser inicializado antes de usarse
 * 
 * 3. Para formateo de fechas en español, las localizaciones
 *    deben estar configuradas correctamente
 * 
 * 4. Asegurar que la API base URL esté configurada en:
 *    lib/config/api_config.dart
 * 
 * 5. El usuario debe estar autenticado para usar el módulo
 *    (el token JWT se obtiene automáticamente del storage)
 */
