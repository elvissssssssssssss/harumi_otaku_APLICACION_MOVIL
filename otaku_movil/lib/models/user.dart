// lib/models/user.dart
class User {
  final int id;
  final String email;
  final String nombre;
  final String apellido;
  final DateTime fechaNacimiento;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.fechaNacimiento,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory User.empty() {
  return User(
    id: 0,
    email: '',
    nombre: '',
    apellido: '',
    fechaNacimiento: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
