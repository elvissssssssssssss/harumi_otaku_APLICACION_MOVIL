// lib/providers/auth_provider.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as user_model;
import '../models/auth_models.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  int? get userId => _user?.id;

  user_model.User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  user_model.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;

  // Método login unificado
  Future<bool> login({String? email, String? password, String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      if (token != null) {
        _token = token;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await loadUserProfile();
        notifyListeners();
        return true;
      } else if (email != null && password != null) {
        final request = LoginRequest(email: email, password: password);
        final response = await _authService.login(request);
        
        if (response.isSuccess) {
  _token = response.token;
  _user = response.user;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', _token!);

  // ✅ GUARDA user_id en SharedPreferences
  if (_user?.id != null) {
    await prefs.setInt('user_id', _user!.id);
     print('🧾 Usuario autenticado con ID: ${_user!.id}'); // ← Aquí
  }

  notifyListeners();
  return true;
}

        _setError(response.message ?? 'Login failed');
        return false;
      }
      throw ArgumentError('Must provide either token or email/password');
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // AutoLogin corregido
  Future<void> autoLogin() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null) {
        await login(token: token); // No necesitamos retornar el bool aquí
      }
    } catch (e) {
      _setError('Error during auto login');
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required DateTime fechaNacimiento,
    required bool receiveNewsletters,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        fechaNacimiento: fechaNacimiento,
      );
      final response = await _authService.register(request);

      if (response.isSuccess) {
        return await login(token: response.token);
      }
      _setError(response.message ?? 'Registration failed');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Resto de métodos permanecen igual...
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _user = null;
    _token = null;
    _clearError();
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      final success = await _authService.updateProfile(data);
      if (success) await loadUserProfile();
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserProfile() async {
    try {
      final user = await _authService.getProfile();
      if (user != null) {
        _user = user;
        notifyListeners();
      }
    } catch (e) {
      _setError('Error loading profile');
    }
  }
  Future<int?> _getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final userData = prefs.getString('user_data');
  if (userData != null) {
    final userJson = jsonDecode(userData);
    return userJson['id'];
  }
  return null;
}




  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}