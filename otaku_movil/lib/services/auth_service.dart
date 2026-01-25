// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/auth_models.dart';

class AuthService {
  static const String baseUrl = 'https://pusher-backend-elvis.onrender.com/api/Auth'; // Ajustado
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Headers comunes
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers con token
  Future<Map<String, String>> get _authHeaders async {
    final token = await getToken();
    return {..._headers, if (token != null) 'Authorization': 'Bearer $token'};
  }

  // Login
  // Login corregido
  // Login actualizado para coincidir con tu API
Future<AuthResponse> login(LoginRequest request) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return AuthResponse(
        token: '',
        user: User.empty(),
        message: data['message'] ?? 'Error en la autenticación',
      );
    }

    final authResponse = AuthResponse.fromJson(data);

    // ✅ Guardar token y usuario en SharedPreferences
    await _saveAuthData(authResponse.token, authResponse.user);

    return authResponse;
  } catch (e) {
    return AuthResponse(
      token: '',
      user: User.empty(),
      message: 'Error de conexión: ${e.toString()}',
    );
  }
}


  // Register
  // Register actualizado
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        return AuthResponse(
          token: '',
          user: User.empty(),
          message: data['message'] ?? 'Error en el registro',
        );
      }

      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse(
        token: '',
        user: User.empty(),
        message: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  // Obtener perfil
  Future<User?> getProfile() async {
    try {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Actualizar perfil
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final headers = await _authHeaders;
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: headers,
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Cambiar contraseña
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final headers = await _authHeaders;
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: headers,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Verificar si está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Obtener token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Obtener usuario guardado
  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Guardar datos de autenticación
 Future<void> _saveAuthData(String token, User user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_tokenKey, token);
  await prefs.setString(_userKey, jsonEncode(user.toJson()));

  // ✅ También guarda user_id explícitamente si lo necesitas directo
  if (user.id != null) {
    await prefs.setInt('user_id', user.id!);
  }
}

}
