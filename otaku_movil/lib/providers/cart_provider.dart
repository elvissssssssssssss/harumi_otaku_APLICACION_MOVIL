// ====================================
// 3. lib/providers/cart_provider.dart
// ====================================
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/producto.dart';
import 'package:http/http.dart' as http;
import '../services/cart_service.dart';
import 'dart:convert';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final CartService _cartService = CartService();

  List<CartItem> get items => _items;

  double get total => _items.fold(0, (sum, item) => sum + item.precio * item.cantidad);

  int get itemCount => _items.length;

  void updateQuantity(int id, String talla, int nuevaCantidad) {
    for (var item in _items) {
      if (item.id == id && item.talla == talla) {
        item.cantidad = nuevaCantidad;
        break;
      }
    }
    notifyListeners();
  }

  void removeItem(int id, String talla) {
    _items.removeWhere((item) => item.id == id && item.talla == talla);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void addItem(CartItem nuevo) {
    final index = _items.indexWhere((item) => item.id == nuevo.id && item.talla == nuevo.talla);
    if (index >= 0) {
      _items[index].cantidad += nuevo.cantidad;
    } else {
      _items.add(nuevo);
    }
    notifyListeners();
  }
  
    Future<void> clearCartFromServer(int userId) async {
    final success = await _cartService.clearCart(userId);
    if (success) {
      _items.clear();
      notifyListeners();
    }
  }
  Future<void> fetchCartItems(int userId) async {
  try {
    final response = await http.get(
      Uri.parse('https://pusher-backend-elvis.onrender.com/api/Cart/$userId'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final itemsJson = data['items'] as List;

      _items.clear();
      _items.addAll(itemsJson.map((json) => CartItem.fromJson(json)).toList());
      notifyListeners();
    } else {
      print('Error al cargar carrito: ${response.body}');
    }
  } catch (e) {
    print('Error en fetchCartItems: $e');
  }
}

Future<void> loadCart(int userId) async {
  final response = await CartService().getCartItems(userId);
  items.clear();
  items.addAll(response);

  for (var item in _items) {
    print("🛒 item id: ${item.cartItemId} - productoId: ${item.id} - cantidad: ${item.cantidad}");
  }

  notifyListeners();
}



}