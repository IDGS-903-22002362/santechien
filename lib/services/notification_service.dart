import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

// Handler para mensajes en background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 Mensaje en background: ${message.messageId}');
  print('Título: ${message.notification?.title}');
  print('Cuerpo: ${message.notification?.body}');
  print('Data: ${message.data}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // Stream controller para notificaciones
  final _notificationStreamController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get notificationStream =>
      _notificationStreamController.stream;

  /// Inicializar servicio de notificaciones
  Future<void> initialize() async {
    print('🔔 Inicializando servicio de notificaciones...');

    // 1. Solicitar permisos
    await _requestPermissions();

    // 2. Configurar notificaciones locales
    await _initializeLocalNotifications();

    // 3. Configurar Firebase Messaging
    await _configureFirebaseMessaging();

    // 4. Obtener token FCM
    await _getFCMToken();

    // 5. Configurar listeners
    _setupMessageHandlers();

    print('✅ Servicio de notificaciones inicializado');
  }

  /// Solicitar permisos de notificaciones
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await Permission.notification.request();
    }

    if (Platform.isAndroid && Platform.version.compareTo('33') >= 0) {
      await Permission.notification.request();
    }

    // Firebase Messaging permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('🔔 Permisos de notificación: ${settings.authorizationStatus}');
  }

  /// Inicializar notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    // Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');

    // iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal de notificaciones para Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  /// Crear canal de notificaciones (Android)
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'citas_recordatorios', // ID (debe coincidir con backend)
      'Recordatorios de Citas', // Nombre
      description: 'Notificaciones de recordatorios de citas veterinarias',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Configurar Firebase Messaging
  Future<void> _configureFirebaseMessaging() async {
    // Configurar opciones de presentación (iOS)
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Obtener token FCM
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('🔑 FCM Token: $_fcmToken');

      // Guardar token localmente
      if (_fcmToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', _fcmToken!);
      }

      return _fcmToken;
    } catch (e) {
      print('❌ Error al obtener FCM token: $e');
      return null;
    }
  }

  /// Configurar listeners de mensajes
  void _setupMessageHandlers() {
    // 1. Mensaje recibido cuando la app está en FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📬 Mensaje recibido en foreground:');
      print('Título: ${message.notification?.title}');
      print('Cuerpo: ${message.notification?.body}');
      print('Data: ${message.data}');

      // Mostrar notificación local
      _showLocalNotification(message);

      // Emitir evento
      _notificationStreamController.add(message);
    });

    // 2. Usuario TAP en notificación (app en background o terminada)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('👆 Notificación abierta desde background:');
      print('Data: ${message.data}');

      // Emitir evento para navegación
      _notificationStreamController.add(message);
    });

    // 3. Verificar si la app se abrió desde una notificación
    _checkInitialMessage();

    // 4. Token refresh listener
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('🔄 Token FCM actualizado: $newToken');
      _fcmToken = newToken;
      // Actualizar token en el backend
      _updateTokenOnBackend(newToken);
    });
  }

  /// Verificar mensaje inicial (app abierta desde notificación)
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();

    if (initialMessage != null) {
      print('🚀 App abierta desde notificación:');
      print('Data: ${initialMessage.data}');

      // Emitir evento
      await Future.delayed(const Duration(seconds: 2));
      _notificationStreamController.add(initialMessage);
    }
  }

  /// Mostrar notificación local
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'citas_recordatorios',
          'Recordatorios de Citas',
          channelDescription:
              'Notificaciones de recordatorios de citas veterinarias',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF4CAF50),
          playSound: true,
          enableVibration: true,
          icon: '@drawable/ic_notification',
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  /// Callback para tap en notificación local
  void _onNotificationTapped(NotificationResponse response) {
    print('👆 Notificación local tapeada: ${response.payload}');
  }

  /// Actualizar token en backend
  Future<void> _updateTokenOnBackend(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);

      // TODO: Llamar al API service para actualizar en backend
      print('💾 Token guardado localmente: $token');
    } catch (e) {
      print('❌ Error al actualizar token: $e');
    }
  }

  /// Suscribirse a un topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Suscrito al topic: $topic');
    } catch (e) {
      print('❌ Error al suscribirse al topic $topic: $e');
    }
  }

  /// Desuscribirse de un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Desuscrito del topic: $topic');
    } catch (e) {
      print('❌ Error al desuscribirse del topic $topic: $e');
    }
  }

  /// Limpiar
  void dispose() {
    _notificationStreamController.close();
  }
}
