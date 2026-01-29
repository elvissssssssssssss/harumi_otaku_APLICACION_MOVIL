import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

  // ✅ Register sigue devolviendo int (por ahora)
  Future<int> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
  }) async {
    final res = await _dio.post('/api/auth/register', data: {
      'email': email,
      'password': password,
      'nombre': nombre,
      'apellido': apellido,
    });

    return (res.data['id'] as num).toInt();
  }

  // ✅ Login ahora devuelve User completo
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });

    // Backend ahora devuelve: { id, email, nombre, rol, token }
    return User.fromJson(res.data);
  }
}
