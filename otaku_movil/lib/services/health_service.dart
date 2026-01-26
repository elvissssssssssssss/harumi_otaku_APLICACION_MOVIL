import 'package:dio/dio.dart';
import 'api_client.dart';

class HealthService {
  final Dio _dio = ApiClient.dio;

  Future<void> ping() async {
    // Usa una ruta liviana. Si no tienes /health, puedes usar /api/auth/me o /swagger.
    await _dio.get('/api/auth/me');
  }
}
