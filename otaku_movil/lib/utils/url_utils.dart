import '../config/constants.dart';

class FileUrlHelper {
  static String get baseUrl => ApiConfig.baseUrl;

  static String getImageUrl(String? rutaArchivo, {String? defaultFolder}) {
    final raw = (rutaArchivo ?? '').trim();
    if (raw.isEmpty) return '';

    // Si ya es URL completa, devolver tal cual
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

    // Normalizar rutas tipo "wwwroot\\uploads\\..."
    String cleaned = raw
        .replaceAll(RegExp(r'^wwwroot[\\\/]+'), '')
        .replaceAll(RegExp(r'^[\\\/]+'), '')
        .replaceAll('\\', '/');

    // Si viene solo el nombre del archivo, agrega folder por defecto (si se especifica)
    if (!cleaned.contains('/')) {
      final folder = (defaultFolder ?? 'uploads/productos').replaceAll(RegExp(r'^/+|/+$'), '');
      cleaned = '$folder/$cleaned';
    }

    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return '$base/$cleaned';
  }

  static String voucherUrl(String? ruta) =>
      getImageUrl(ruta, defaultFolder: 'uploads/vouchers');

  static String productoUrl(String? ruta) =>
      getImageUrl(ruta, defaultFolder: 'uploads/productos');
}
