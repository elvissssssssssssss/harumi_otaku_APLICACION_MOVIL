// lib/config/api_config.dart

class ApiConfig {
  // ✅ Backend principal de otaku_movil
  static const String baseUrl = 'https://harumi-otaku-backend-net.onrender.com';
  static const String apiPath = '/api';

  // Ejemplo de endpoint (ajusta si quieres)
  static const String productosUrl = '$baseUrl$apiPath/productos';

  // ✅ CONFIGURACIÓN DE PUSHER (otaku_movil)
  static const String pusherKey = 'f4e6b23dca02881c8df9';
  static const String pusherCluster = 'us2';

  // Endpoint de auth para canales privados en tu backend .NET
  // Debes crear POST /api/pusher/auth en el backend
  static const String pusherAuthEndpoint = '$baseUrl$apiPath/pusher/auth';

  // ✅ Helper para imágenes (si lo necesitas)
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'http://via.placeholder.com/300x300/e0e0e0/9e9e9e?text=Sin+Imagen';
    }

    final cleanedPath = imagePath
        .replaceFirst(RegExp(r'^wwwroot[\\/]+'), '')
        .replaceAll('\\', '/');

    return '$baseUrl/$cleanedPath'.replaceAll(' ', '%20');
  }

  static const Duration timeoutDuration = Duration(seconds: 30);

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
