import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

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

  Future<int> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });

    return (res.data['userId'] as num).toInt();
  }
}
