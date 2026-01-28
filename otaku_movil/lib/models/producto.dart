class Producto {
  final int id;
  final int categoriaId;
  final String nombre;
  final String descripcion;
  final String fotoUrl;
  final double precio;
  final bool activo;

  const Producto({
    required this.id,
    required this.categoriaId,
    required this.nombre,
    required this.descripcion,
    required this.fotoUrl,
    required this.precio,
    required this.activo,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: (json['id'] as num).toInt(),
      categoriaId: (json['categoriaId'] as num).toInt(),
      nombre: (json['nombre'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      fotoUrl: (json['fotoUrl'] ?? '').toString(),
      precio: (json['precio'] as num).toDouble(),
      activo: (json['activo'] as bool?) ?? true,
    );
  }
}
