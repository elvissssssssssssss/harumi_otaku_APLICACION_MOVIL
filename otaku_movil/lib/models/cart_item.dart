class CartItem {
  final int itemId;
  final int productoId;
  final String nombre;
  final double precioUnitario;
  final int cantidad;
  final double subtotal;

  const CartItem({
    required this.itemId,
    required this.productoId,
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
    required this.subtotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: (json['itemId'] as num).toInt(),
      productoId: (json['productoId'] as num).toInt(),
      nombre: (json['nombre'] ?? '').toString(),
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      cantidad: (json['cantidad'] as num).toInt(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}
