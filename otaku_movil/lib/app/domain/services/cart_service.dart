import 'package:flutter/foundation.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  void addItem(Map<String, dynamic> product) {
    // Check if item already exists to increment quantity
    final index = _items.indexWhere((item) => item['nombre'] == product['nombre']);
    
    if (index >= 0) {
      _items[index]['quantity'] = (_items[index]['quantity'] ?? 1) + 1;
    } else {
      _items.add({
        ...product,
        'quantity': 1,
      });
    }
    notifyListeners();
  }

  void removeItem(String productName) {
    _items.removeWhere((item) => item['nombre'] == productName);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get total {
    return _items.fold(0, (sum, item) {
      final price = (item['precio'] as num).toDouble();
      final quantity = (item['quantity'] as num).toInt();
      return sum + (price * quantity);
    });
  }
}
