class OrdenItem {
  final int id;
  final int productoId;
  final String nombre;
  final int cantidad;
  final num precioUnitario;
  final num subtotal;

  OrdenItem({
    required this.id,
    required this.productoId,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory OrdenItem.fromJson(Map<String, dynamic> json) => OrdenItem(
    id: json['id'],
    productoId: json['productoId'],
    nombre: json['nombre'],
    cantidad: json['cantidad'],
    precioUnitario: json['precioUnitario'],
    subtotal: json['subtotal'],
  );
}
