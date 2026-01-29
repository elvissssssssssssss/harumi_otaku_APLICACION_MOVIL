import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 🔥 CREAR CANAL DE NOTIFICACIONES (Android)
    await createNotificationChannel();

    _initialized = true;
    debugPrint('✅ NotificationService inicializado');
  }

  // 🔥 MÉTODO PARA CREAR CANAL DE NOTIFICACIONES
  Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'orden_updates', // id
      'Actualizaciones de pedidos', // nombre
      description: 'Notificaciones de cambios en tus pedidos',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    debugPrint('✅ Canal de notificación creado: orden_updates');
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notificación tocada. Payload: ${response.payload}');

    // TODO: Navegar a la pantalla correspondiente
    if (response.payload != null) {
      final parts = response.payload!.split(':');
      if (parts.length == 2 && parts[0] == 'orden') {
        final ordenId = int.tryParse(parts[1]);
        debugPrint('📱 Navegar a orden: $ordenId');
        // navigatorKey.currentState?.pushNamed('/orden-detalle', arguments: ordenId);
      }
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'orden_updates',
      'Actualizaciones de pedidos',
      channelDescription: 'Notificaciones de cambios en tus pedidos',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );

    debugPrint('🔔 Notificación mostrada: $title');
  }

  Future<void> requestPermissions() async {
    // iOS
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    debugPrint('✅ Permisos de notificaciones solicitados');
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);  
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
