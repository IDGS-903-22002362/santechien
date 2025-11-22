import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cita_provider.dart';
import 'providers/mascota_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/citas/citas_screen.dart';
import 'screens/mascotas/mascotas_screen.dart';
import 'screens/mascotas/mis_mascotas_screen.dart';
import 'screens/mascotas/registrar_mascota_screen.dart';
import 'screens/solicitudes/solicitud_cita_screen.dart';
import 'screens/solicitudes/mis_solicitudes_screen.dart';
import 'screens/debug/debug_auth_screen.dart';
import 'utils/ui_logger.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar Storage Service
  await StorageService().init();

  runApp(const AdoPetsApp());
}

class AdoPetsApp extends StatelessWidget {
  const AdoPetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CitaProvider()),
        ChangeNotifierProvider(create: (_) => MascotaProvider()),
      ],
      child: MaterialApp(
        title: 'AdoPets',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),

        // Localizaciones para español
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // Español
          Locale('en', 'US'), // Inglés
        ],
        locale: const Locale('es', 'ES'),

        // Rutas
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/citas': (context) => const CitasScreen(),
          '/mascotas': (context) => const MascotasScreen(),
          '/mis-mascotas': (context) => const MisMascotasScreen(),
          '/registrar-mascota': (context) => const RegistrarMascotaScreen(),
          '/solicitar-cita': (context) => const SolicitudCitaScreen(),
          '/mis-solicitudes': (context) => const MisSolicitudesScreen(),
          '/debug-auth': (context) =>
              const DebugAuthScreen(), // Solo desarrollo
          '/ui-logs': (context) =>
              const UILogViewerScreen(), // Ver logs en la UI
        },
      ),
    );
  }
}
