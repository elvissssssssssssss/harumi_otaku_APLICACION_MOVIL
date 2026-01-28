// lib/utils/url_utils.dart

import '../config/constants.dart'; // ApiConfig.baseUrl

class FileUrlHelper {
  static String get baseUrl => ApiConfig.baseUrl;

  /// Convierte rutas tipo:
  /// - "8c836e9e4de442868d0849f6a7a3bee4.jpg"
  /// - "/uploads/productos/8c836e9e4de442868d0849f6a7a3bee4.jpg"
  /// - "wwwroot\\uploads\\productos\\archivo.jpg"
  /// en una URL absoluta: "https://.../uploads/productos/archivo.jpg"
  static String getImageUrl(String rutaArchivo) {
    rutaArchivo = rutaArchivo.trim();
    if (rutaArchivo.isEmpty) return '';

    // Si ya es URL completa, devolver tal cual
    if (rutaArchivo.startsWith('http://') || rutaArchivo.startsWith('https://')) {
      return rutaArchivo;
    }

    // Normalizar rutas locales (similar a tu código anterior)
    String cleanedPath = rutaArchivo
        .replaceAll(RegExp(r'^wwwroot[\\\/]+'), '') // quita 'wwwroot/'
        .replaceAll(RegExp(r'^[\\\/]+'), '')        // quita barras iniciales
        .replaceAll('\\', '/');                    // backslash -> slash

    // Si solo viene el nombre del archivo, le añadimos carpeta por defecto
    if (!cleanedPath.contains('/')) {
      cleanedPath = 'uploads/productos/$cleanedPath';
    }

    // Evitar doble slash entre baseUrl y path
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

    return '$base/$cleanedPath';
  }
}
