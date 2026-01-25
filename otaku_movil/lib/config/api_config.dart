import '../utils/category_mapper.dart';

// lib/config/api_config.dart
class ApiConfig {
  static const baseUrl = 'https://pusher-backend-elvis.onrender.com'; // NO uses localhost ni 192.168.x.x

  static const String apiPath = '/api';

  static const String productosUrl = '$baseUrl$apiPath/Productos';

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


