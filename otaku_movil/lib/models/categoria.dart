class Categoria {
  final int id;
  final String nombre;

  const Categoria({required this.id, required this.nombre});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: (json['id'] as num).toInt(),
      nombre: (json['nombre'] ?? '').toString(),
    );
  }
}
