// lib/models/producto.dart

import '../config/api_config.dart';

class Producto {
  final int id;
  final String nombre;
  final String codigo;
  final String descripcion;
  final double precio;


  final String categoria;
  final String? marca;
  final String? imagen;
  
  final List<String> colores;
  final List<String> tallas;
  final String? genero;
  final bool activo;
  final int stock; // ✅ Asegúrate de incluirlo aquí
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  Producto({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.descripcion,
    required this.precio,
   
    required this.categoria,
    this.marca,
    this.imagen,
    required this.colores,
    required this.tallas,
    this.genero,
    required this.activo,
    required this.stock, // ✅ Incluido en el constructor
    required this.fechaCreacion,
    this.fechaActualizacion,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    final tallaStr = data['talla']?.toString() ?? '';
    final List<String> tallas = tallaStr.isNotEmpty
        ? tallaStr.split(',').map((t) => t.trim()).toList()
        : [];

    final colorStr = data['color']?.toString() ?? '';
    final List<String> colores = colorStr.isNotEmpty
        ? colorStr.split(',').map((c) => c.trim()).toList()
        : [];

    return Producto(
      id: data['id'] ?? 0,
      nombre: data['nombre'] ?? '',
      codigo: data['code'] ?? '',
      descripcion: data['description'] ?? '',
      precio: (data['precio'] ?? 0.0).toDouble(),


      categoria: data['categoria'] ?? '',
      marca: data['marca'],
      imagen: data['imagen'],
      colores: colores,
      tallas: tallas,
      stock: data['stock'] ?? 0, // ✅ Incluido aquí
      genero: _determinarGenero(data['categoria']),
      activo: true,
      fechaCreacion: DateTime.parse(
          data['createdAt'] ?? DateTime.now().toIso8601String()),
      fechaActualizacion: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : null,
    );
  }

  static String? _determinarGenero(String? categoria) {
    if (categoria == null) return null;
    if (categoria.toLowerCase().contains('hombre')) return 'hombre';
    if (categoria.toLowerCase().contains('mujer')) return 'mujer';
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'descripcion': descripcion,
      'precio': precio,
      
      'categoria': categoria,
      'marca': marca,
      'imagen': imagen,
      'colores': colores.join(','), // ✅ Convertir a string si tu API lo requiere
      'talla': tallas.join(','),     // ✅ Igual aquí
      'stock': stock,                // ✅ Esto es lo correcto
      'genero': genero,
      'activo': activo,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  String getImageUrl() {
    return ApiConfig.getImageUrl(imagen);
  }
}
