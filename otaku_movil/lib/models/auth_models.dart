
// lib/models/auth_models.dart
import 'package:textil/models/user.dart';

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class RegisterRequest {
  final String email;
  final String password;
  final String nombre;
  final String apellido;
  final DateTime fechaNacimiento;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.nombre,
    required this.apellido,
    required this.fechaNacimiento,
  });

   Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'nombre': nombre,
    'apellido': apellido,
    'fecha_nacimiento': fechaNacimiento.toIso8601String(),
  };
}

class AuthResponse {
  final String token;
  final User user;
  final String? message;

  AuthResponse({
    required this.token,
    required this.user,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user']),
      message: json['message'],
    );
  }

  bool get isSuccess => token.isNotEmpty;
}