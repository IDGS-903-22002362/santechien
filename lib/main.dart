import 'package:adopets_app/providers/adopcion_provider.dart';
import 'package:adopets_app/screens/solicitudes/mis_solicitudes_adopcion_screen.dart';
import 'package:adopets_app/screens/solicitudes/solicitud_adopcion_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cita_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/mascota_provider.dart';
import 'providers/donacion_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/citas/citas_screen.dart';
import 'screens/mascotas/mascotas_screen.dart';
import 'screens/mascotas/mi_mascota_detalle_screen.dart';
import 'screens/mascotas/mis_mascotas_screen.dart';
import 'screens/mascotas/registrar_mascota_screen.dart';
import 'screens/solicitudes/solicitud_cita_screen.dart';
import 'screens/solicitudes/mis_solicitudes_screen.dart';
import 'screens/donaciones/donacion_screen.dart';
import 'screens/donaciones/historial_donaciones_screen.dart';
import 'screens/debug/debug_auth_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/perfil/mi_perfil_screen.dart';
import 'screens/legal/terminos_screen.dart';
import 'utils/ui_logger.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';

// Background message handler (debe estar fuera de la clase main)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('🔔 Background message: ${message.messageId}');
  print('   Título: ${message.notification?.title}');
  print('   Cuerpo: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configurar background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inicializar Storage Service
  await StorageService().init();

  // Inicializar Notification Service
  await NotificationService().initialize();

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

        ChangeNotifierProvider(create: (_) => AdopcionProvider()),
        ChangeNotifierProvider(create: (_) => DonacionProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
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
          '/solicitud-adopcion': (context) => const SolicitudAdopcionScreen(),

          '/mis-mascotas': (context) => const MisMascotasScreen(),
          '/mi-mascota-detalle': (context) {
            final mascotaId =
                ModalRoute.of(context)!.settings.arguments as String;
            return MiMascotaDetalleScreen(mascotaId: mascotaId);
          },
          '/registrar-mascota': (context) => const RegistrarMascotaScreen(),
          '/solicitar-cita': (context) => const SolicitudCitaScreen(),
          '/mis-solicitudes': (context) => const MisSolicitudesScreen(),

          '/mis-solicitudes-adopcion': (context) =>
              const MisSolicitudesAdopcionScreen(),

          '/donaciones': (context) => const DonacionScreen(),
          '/donaciones/historial': (context) =>
              const HistorialDonacionesScreen(),

          '/chat': (context) => const ChatScreen(),

          '/perfil': (context) => const MiPerfilScreen(),
          '/terminos': (context) => const TerminosScreen(),

          '/debug-auth': (context) =>
              const DebugAuthScreen(), // Solo desarrollo
          '/ui-logs': (context) =>
              const UILogViewerScreen(), // Ver logs en la UI
        },
      ),
    );
  }
}
