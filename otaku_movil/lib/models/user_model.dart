class User {
  final int id;
  final String email;
  final String nombre;
  final String rol;
  final String token;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      rol: json['rol'] as String,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'rol': rol,
      'token': token,
    };
  }

  bool get isAdmin => rol == 'ADMIN';
  bool get isCliente => rol == 'CLIENTE';
}
