import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  AuthProvider(this._service);

  int? _userId;
  int? get userId => _userId;
  bool get isAuthenticated => _userId != null;

  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
  }) async {
    _userId = await _service.register(
      email: email,
      password: password,
      nombre: nombre,
      apellido: apellido,
    );
    notifyListeners(); // actualiza UI escuchando provider [web:222]
    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _userId = await _service.login(email: email, password: password);
    notifyListeners(); // actualiza UI escuchando provider [web:222]
    return true;
  }

  Future<void> logout() async {
    _userId = null;
    notifyListeners(); // actualiza UI escuchando provider [web:222]
  }
}
