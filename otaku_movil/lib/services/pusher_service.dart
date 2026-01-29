import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'notification_service.dart';
import 'dart:convert';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsFlutter? _pusher;
  String? _currentUserId;
  bool _isInitialized = false;

  final NotificationService _notificationService = NotificationService();

  // 🔥 GETTERS PARA USAR EN AuthProvider
  bool get isInitialized => _isInitialized;
  String? get currentUserId => _currentUserId;

  Future<void> init(String userId) async {
    debugPrint('🔵 [PUSHER] === INICIANDO PUSHER ===');
    debugPrint('🔵 [PUSHER] Usuario ID: $userId');
    debugPrint('🔵 [PUSHER] Ya inicializado: $_isInitialized');
    debugPrint('🔵 [PUSHER] Usuario actual: $_currentUserId');
    
    if (_isInitialized && _currentUserId == userId) {
      debugPrint('✅ Pusher ya inicializado para usuario $userId');
      return;
    }

    try {
      _pusher = PusherChannelsFlutter.getInstance();
      _currentUserId = userId;

      debugPrint('🔵 [PUSHER] Configurando...');
      debugPrint('🔵 [PUSHER] API Key: 058be5b82a25fa9d45d6');
      debugPrint('🔵 [PUSHER] Cluster: mt1');

      await _pusher!.init(
        apiKey: '058be5b82a25fa9d45d6',
        cluster: 'mt1',
        onConnectionStateChange: _onConnectionStateChange,
        onError: _onError,
        onSubscriptionSucceeded: _onSubscriptionSucceeded,
        onEvent: _onEvent,
        onSubscriptionError: _onSubscriptionError,
        onDecryptionFailure: _onDecryptionFailure,
      );

      final channelName = 'user-$userId';
      debugPrint('🔵 [PUSHER] Suscribiéndose al canal: $channelName');
      
      await _pusher!.subscribe(channelName: channelName);

      debugPrint('🔵 [PUSHER] Conectando...');
      await _pusher!.connect();

      _isInitialized = true;
      debugPrint('🚀 [PUSHER] === PUSHER INICIALIZADO EXITOSAMENTE ===');
    } catch (e) {
      debugPrint('❌ [PUSHER] Error al inicializar: $e');
      debugPrint('❌ [PUSHER] Stack trace: ${StackTrace.current}');
    }
  }

  void _onConnectionStateChange(String currentState, String previousState) {
    debugPrint('🔄 Pusher conexión: $previousState → $currentState');
  }

  void _onError(String message, int? code, dynamic e) {
    debugPrint('⚠️ Pusher error: $message (código: $code)');
  }

  void _onSubscriptionSucceeded(String channelName, dynamic data) {
    debugPrint('✅ Suscripción exitosa al canal: $channelName');
  }

  void _onSubscriptionError(String message, dynamic e) {
    debugPrint('❌ Error de suscripción: $message');
  }

  void _onDecryptionFailure(String event, String reason) {
    debugPrint('❌ Fallo de descifrado: $event - $reason');
  }

  void _onEvent(PusherEvent event) {
    debugPrint('📩 ========================================');
    debugPrint('📩 [PUSHER] EVENTO RECIBIDO');
    debugPrint('📩 Canal: ${event.channelName}');
    debugPrint('📩 Evento: ${event.eventName}');
    debugPrint('📩 Datos RAW: ${event.data}');
    debugPrint('📩 ========================================');

    try {
      switch (event.eventName) {
        case 'orden-estado-cambiado':
          debugPrint('🔵 [HANDLER] Procesando orden-estado-cambiado');
          _handleOrdenEstadoCambiado(event.data);
          break;
        case 'pago-actualizado':
          debugPrint('🔵 [HANDLER] Procesando pago-actualizado');
          _handlePagoActualizado(event.data);
          break;
        case 'orden-lista-recoger':
          debugPrint('🔵 [HANDLER] Procesando orden-lista-recoger');
          _handleOrdenListaRecoger(event.data);
          break;
        case 'orden-cancelada':
          debugPrint('🔵 [HANDLER] Procesando orden-cancelada');
          _handleOrdenCancelada(event.data);
          break;
        case 'orden-creada':
          debugPrint('🔵 [HANDLER] Procesando orden-creada');
          _handleOrdenCreada(event.data);
          break;
        default:
          debugPrint('⚠️ [HANDLER] Evento no manejado: ${event.eventName}');
      }
    } catch (e) {
      debugPrint('❌ [HANDLER] Error al procesar evento: $e');
      debugPrint('❌ [HANDLER] Stack trace: ${StackTrace.current}');
    }
  }

  void _handleOrdenEstadoCambiado(String data) {
    final json = _parseJson(data);
    _notificationService.showNotification(
      id: json['ordenId'] ?? 0,
      title: '🔔 Estado de pedido actualizado',
      body: json['mensaje'] ?? 'Tu pedido cambió de estado',
      payload: 'orden:${json['ordenId']}',
    );
  }

  void _handlePagoActualizado(String data) {
    final json = _parseJson(data);
    _notificationService.showNotification(
      id: json['pagoId'] ?? 0,
      title: json['nuevoEstado'] == 'CONFIRMADO' ? '✅ Pago confirmado' : '❌ Pago rechazado',
      body: json['mensaje'] ?? 'Actualización de pago',
      payload: 'orden:${json['ordenId']}',
    );
  }

  void _handleOrdenListaRecoger(String data) {
    final json = _parseJson(data);
    _notificationService.showNotification(
      id: json['ordenId'] ?? 0,
      title: '🎉 ¡Tu pedido está listo!',
      body: json['mensaje'] ?? 'Ya puedes recoger tu pedido',
      payload: 'orden:${json['ordenId']}',
    );
  }

  void _handleOrdenCancelada(String data) {
    final json = _parseJson(data);
    _notificationService.showNotification(
      id: json['ordenId'] ?? 0,
      title: '❌ Pedido cancelado',
      body: json['mensaje'] ?? 'Tu pedido ha sido cancelado',
      payload: 'orden:${json['ordenId']}',
    );
  }

  void _handleOrdenCreada(String data) {
    final json = _parseJson(data);
    _notificationService.showNotification(
      id: json['ordenId'] ?? 0,
      title: '✅ Orden creada',
      body: json['mensaje'] ?? 'Tu orden fue creada exitosamente',
      payload: 'orden:${json['ordenId']}',
    );
  }

  Map<String, dynamic> _parseJson(String data) {
    try {
      return jsonDecode(data);
    } catch (e) {
      debugPrint('❌ Error al parsear JSON: $e');
      return {};
    }
  }

  Future<void> disconnect() async {
    if (_pusher != null) {
      try {
        if (_currentUserId != null) {
          await _pusher!.unsubscribe(channelName: 'user-$_currentUserId');
        }
        await _pusher!.disconnect();
        _isInitialized = false;
        _currentUserId = null;
        debugPrint('🔌 Pusher desconectado');
      } catch (e) {
        debugPrint('❌ Error al desconectar Pusher: $e');
      }
    }
  }
}
