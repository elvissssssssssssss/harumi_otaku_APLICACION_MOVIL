// lib/utils/category_mapper.dart
// lib/utils/category_mapper.dart
class CategoryMapper {
  // Mapeo completo de categorías frontend -> backend
  static const Map<String, Map<String, String>> categoryMapping = {
    'hombre': {
      'novedades': 'hombre_novedades', // Cambiado de 'novedad' a 'novedades'
      'uniformes_deportivas': 'hombre_uniformes_deportivas',
      'ropa_corporativa': 'hombre_ropa_corporativa',
      'ntx_prom': 'hombre_ntx_prom',
    },
    'mujer': {
      'novedades': 'mujer_novedades',
      'ropa_corporativa': 'mujer_ropa_corporativa',
      'ntx_prom': 'mujer_ntx_prom',
    },
  };

  // Nombres amigables para mostrar en la UI
  static const Map<String, String> displayNames = {
    'hombre_novedades': 'Novedades Hombre',
    'hombre_uniformes_deportivas': 'Uniformes Deportivas Hombre',
    'hombre_ropa_corporativa': 'Ropa Corporativa Hombre',
    'hombre_ntx_prom': 'NTX Prom Hombre',
    'mujer_novedades': 'Novedades Mujer',
    'mujer_ropa_corporativa': 'Ropa Corporativa Mujer',
    'mujer_ntx_prom': 'NTX Prom Mujer',
  };

  // Obtener categoría del backend
  static String getBackendCategory(String genero, String tipo) {
    return categoryMapping[genero]?[tipo] ?? '${genero}_novedades';
  }

  // Obtener nombre para mostrar en UI
  static String getDisplayName(String backendCategory) {
    return displayNames[backendCategory] ?? backendCategory;
  }

  // Obtener todas las categorías organizadas para la UI
  static List<Map<String, dynamic>> getCategoriesForUI() {
    return [
      // Hombre
      ...categoryMapping['hombre']!.entries.map((e) => {
            'genero': 'hombre',
            'tipo': e.key,
            'displayName': getDisplayName(e.value),
            'backendCategory': e.value,
          }),
      // Mujer
      ...categoryMapping['mujer']!.entries.map((e) => {
            'genero': 'mujer',
            'tipo': e.key,
            'displayName': getDisplayName(e.value),
            'backendCategory': e.value,
          }),
    ];
  }
}
