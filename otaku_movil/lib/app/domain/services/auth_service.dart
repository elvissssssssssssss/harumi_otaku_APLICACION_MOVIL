import 'package:flutter/material.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }
  
  AuthService._internal();
  
  bool _isLoggedIn = false;
  
  bool get isLoggedIn => _isLoggedIn;
  
  void login() {
    _isLoggedIn = true;
  }
  
  void logout() {
    _isLoggedIn = false;
  }
  
  Future<bool> checkLoginAndRedirect(BuildContext context) async {
    if (!_isLoggedIn) {
      // Redirigir al usuario a la pantalla de inicio de sesión
      await Navigator.pushNamed(context, 'login');
      return false;
    }
    return true;
  }
}