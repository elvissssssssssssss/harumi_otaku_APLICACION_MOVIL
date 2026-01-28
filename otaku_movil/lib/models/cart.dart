import 'cart_item.dart';

class Cart {
  final int carritoId;
  final int usuarioId;
  final String estado;
  final List<CartItem> items;
  final double total;

  const Cart({
    required this.carritoId,
    required this.usuarioId,
    required this.estado,
    required this.items,
    required this.total,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List? ?? []).cast<dynamic>();
    return Cart(
      carritoId: (json['carritoId'] as num).toInt(),
      usuarioId: (json['usuarioId'] as num).toInt(),
      estado: (json['estado'] ?? '').toString(),
      items: itemsJson.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList(),
      total: (json['total'] as num).toDouble(),
    );
  }
}
