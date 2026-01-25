// services/cart_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';

class CartService {
  final String baseUrl = 'https://pusher-backend-elvis.onrender.com/api/cart';

  Future<bool> addToCart(CartItem item, int userId) async {
    final url = Uri.parse(baseUrl);
    
    final body = {
      'userId': userId,
      'productId': item.id,
      'talla': item.talla,
      'quantity': item.cantidad,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

  
    return response.statusCode == 200 || response.statusCode == 201;
  }
  // lib/services/cart_service.dart

Future<bool> clearCart(int userId) async {
  final url = Uri.parse('https://pusher-backend-elvis.onrender.com/api/Cart/clear/$userId');

  final response = await http.delete(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': '*/*',
    },
  );

  print("DELETE STATUS: ${response.statusCode}");
  print("DELETE RESPONSE: ${response.body}");

  return response.statusCode == 200;
}

Future<bool> updateCartItemQuantity(int cartItemId, int quantity) async {


 final response = await http.put(
  Uri.parse('$baseUrl/$cartItemId'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'quantity': quantity}),
);


  return response.statusCode == 200;
}
Future<List<CartItem>> getCartItems(int userId) async {
  final url = Uri.parse('https://pusher-backend-elvis.onrender.com/api/Cart/$userId');

  final response = await http.get(
    url,
    headers: {'Accept': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final itemsJson = data['items'] as List;

    return itemsJson.map((json) => CartItem.fromJson(json)).toList();
  } else {
    throw Exception('Error al obtener carrito: ${response.body}');
  }
}






}
