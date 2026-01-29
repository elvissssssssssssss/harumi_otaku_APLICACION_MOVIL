// lib/services/pusher_notification_service.dart
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class PusherNotificationService {
  static final PusherNotificationService _instance = PusherNotificationService._internal();
  factory PusherNotificationService() => _instance;
  PusherNotificationService._internal();

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  
  // Callback para navegación (opcional)
  Function(String)? onNotificationTap;

  Future<void> initialize(int userId, String userToken) async {
    if (_isInitialized) {
      print('⚠️ Pusher ya inicializado');
      return;
    }

    try {
      print('🔵 Inicializando notificaciones Pusher...');
      
      await _initializeLocalNotifications();

      await _pusher.init(
        apiKey: ApiConfig.pusherKey,
        cluster: ApiConfig.pusherCluster,
        onConnectionStateChange: (currentState, previousState) {
          print('🔵 Pusher: $previousState → $currentState');
        },
        onError: (message, code, exception) {
          print('❌ Error Pusher: $message (code: $code)');
        },
        // 🔥 USANDO AUTH PARA CANALES PRIVADOS, COMO EN TEXTIL
        onAuthorizer: (channelName, socketId, options) async {
          return await _authorizePusher(channelName, socketId, userToken);
        },
      );

      await _pusher.connect();
      await _subscribeToUserChannel(userId);

      _isInitialized = true;
      print('✅ Pusher inicializado para usuario $userId');
    } catch (e) {
      print('❌ Error al inicializar Pusher: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        print('📲 Notificación clickeada: ${details.payload}');
        
        if (details.payload != null) {
          _handleNotificationTap(details.payload!);
        }
      },
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _handleNotificationTap(String payload) {
    try {
      final data = jsonDecode(payload);
      final ordenId = data['ordenId'] ?? data['venta_id'];

      print('🔔 Navegando a detalle de orden/venta: $ordenId');
      
      if (onNotificationTap != null && ordenId != null) {
        onNotificationTap!('/orden/$ordenId'); // ajusta ruta según tu app
      }
    } catch (e) {
      print('❌ Error al procesar tap: $e');
    }
  }

  Future<Map<String, String?>> _authorizePusher(
    String channelName,
    String socketId,
    String userToken,
  ) async {
    try {
      print('🔐 Autenticando canal: $channelName');
      print('🆔 Socket ID: $socketId');
      
      final response = await http.post(
        Uri.parse(ApiConfig.pusherAuthEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'socket_id': socketId,
          'channel_name': channelName,
        }),
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Autenticación exitosa');
        
        return {
          'auth': data['auth'],
        };
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error autenticación: $e');
      rethrow;
    }
  }

  Future<void> _subscribeToUserChannel(int userId) async {
    final channelName = 'private-user-$userId';
    
    await _pusher.subscribe(
      channelName: channelName,
      onEvent: (event) {
        print('🔔 Evento recibido: ${event.eventName}');
        print('📦 Datos: ${event.data}');
        
        switch (event.eventName) {
          case 'orden-estado-cambiado':
            _handleOrdenEstadoCambiado(event.data);
            break;
          case 'pago-actualizado':
            _handlePagoActualizado(event.data);
            break;
          case 'orden-lista-recoger':
            _handleOrdenListaRecoger(event.data);
            break;
          case 'orden-cancelada':
            _handleOrdenCancelada(event.data);
            break;
          case 'orden-creada':
            _handleOrdenCreada(event.data);
            break;
        }
      },
    );
    
    print('✅ Suscrito a: $channelName');
  }

  void _handleOrdenEstadoCambiado(dynamic data) {
    try {
      final json = data is String ? jsonDecode(data) : data;
      _showNotification(
        title: '🔔 Estado de pedido actualizado',
        body: json['mensaje'] ?? 'Tu pedido cambió de estado',
        payload: jsonEncode(json),
      );
    } catch (e) {
      print('❌ Error procesando orden-estado-cambiado: $e');
    }
  }

  void _handlePagoActualizado(dynamic data) {
    try {
      final json = data is String ? jsonDecode(data) : data;
      _showNotification(
        title: json['nuevoEstado'] == 'CONFIRMADO' ? '✅ Pago confirmado' : '❌ Pago actualizado',
        body: json['mensaje'] ?? 'Actualización de pago',
        payload: jsonEncode(json),
      );
    } catch (e) {
      print('❌ Error procesando pago-actualizado: $e');
    }
  }

  void _handleOrdenListaRecoger(dynamic data) {
    try {
      final json = data is String ? jsonDecode(data) : data;
      _showNotification(
        title: '🎉 ¡Tu pedido está listo!',
        body: json['mensaje'] ?? 'Ya puedes recoger tu pedido',
        payload: jsonEncode(json),
      );
    } catch (e) {
      print('❌ Error procesando orden-lista-recoger: $e');
    }
  }

  void _handleOrdenCancelada(dynamic data) {
    try {
      final json = data is String ? jsonDecode(data) : data;
      _showNotification(
        title: '❌ Pedido cancelado',
        body: json['mensaje'] ?? 'Tu pedido ha sido cancelado',
        payload: jsonEncode(json),
      );
    } catch (e) {
      print('❌ Error procesando orden-cancelada: $e');
    }
  }

  void _handleOrdenCreada(dynamic data) {
    try {
      final json = data is String ? jsonDecode(data) : data;
      _showNotification(
        title: '✅ Orden creada',
        body: json['mensaje'] ?? 'Tu orden fue creada exitosamente',
        payload: jsonEncode(json),
      );
    } catch (e) {
      print('❌ Error procesando orden-creada: $e');
    }
  }

  Future<void> _showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    print('🔔 Mostrando notificación: $title');
    
    const android = AndroidNotificationDetails(
      'ordenes_channel',
      'Notificaciones de Órdenes',
      channelDescription: 'Actualizaciones de tus pedidos',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      const NotificationDetails(android: android),
      payload: payload,
    );
    
    print('✅ Notificación mostrada');
  }

  Future<void> disconnect() async {
    await _pusher.disconnect();
    _isInitialized = false;
    print('🔴 Pusher desconectado');
  }
}
