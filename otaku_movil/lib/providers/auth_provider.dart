import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/pusher_notification_service.dart';
import '../models/user_model.dart';  // ✅ IMPORTAR

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  final PusherNotificationService _pusherService = PusherNotificationService();
  
  AuthProvider(this._service) {
    restoreSession();
  }

  // ✅ NUEVA variable para guardar el usuario completo
  User? _currentUser;

  // ✅ Getters de compatibilidad (mantienen código existente funcionando)
  int? get userId => _currentUser?.id;
  String? get token => _currentUser?.token;
  bool get isAuthenticated => _currentUser != null;
  User? get currentUser => _currentUser;  // ✅ Nuevo getter

  // 🔥 RESTAURAR SESIÓN
  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');

      if (userJson != null && userJson.isNotEmpty) {
        final userData = User.fromJson(jsonDecode(userJson));
        _currentUser = userData;
        debugPrint('✅ Sesión restaurada: ${_currentUser!.nombre} (${_currentUser!.rol})');

        await _pusherService.initialize(_currentUser!.id, _currentUser!.token);
        notifyListeners();
      } else {
        debugPrint('ℹ️ No hay sesión guardada');
      }
    } catch (e) {
      debugPrint('❌ Error al restaurar sesión: $e');
      await _clearSession();
    }
  }

  // 🔥 GUARDAR SESIÓN - ✅ AHORA RECIBE User, NO int
  Future<void> _saveSession(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardar usuario completo como JSON
      await prefs.setString('user_data', jsonEncode(user.toJson()));
      
      // Mantener compatibilidad con código antiguo
      await prefs.setInt('user_id', user.id);
      await prefs.setString('token', user.token);
      
      debugPrint('💾 Sesión guardada: ${user.nombre} (${user.rol})');
    } catch (e) {
      debugPrint('❌ Error al guardar sesión: $e');
    }
  }

  // 🔥 ELIMINAR SESIÓN
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await prefs.remove('user_id');
      await prefs.remove('token');
      debugPrint('🗑️ Sesión eliminada');
    } catch (e) {
      debugPrint('❌ Error al limpiar sesión: $e');
    }
  }

  // ✅ REGISTER
  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
  }) async {
    try {
      final resultUserId = await _service.register(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
      );

      if (resultUserId > 0) {
        // Hacer login automático después del registro
        return await login(email: email, password: password);
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error en register: $e');
      return false;
    }
  }

  // ✅ LOGIN - CORREGIDO
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _service.login(
        email: email,
        password: password,
      );

      // Guardar usuario completo
      _currentUser = user;
      
      // Guardar sesión con el objeto User
      await _saveSession(user);
      
      // Inicializar Pusher
      await _pusherService.initialize(user.id, user.token);
      debugPrint('✅ Login exitoso: ${user.nombre} (${user.rol})');
      debugPrint('🚀 Pusher inicializado para usuario ${user.id}');

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error en login: $e');
      return false;
    }
  }

  // ✅ LOGOUT
  Future<void> logout() async {
    await _pusherService.disconnect();
    await _clearSession();
    _currentUser = null;
    debugPrint('🔌 Pusher desconectado y sesión cerrada');
    notifyListeners();
  }
}
