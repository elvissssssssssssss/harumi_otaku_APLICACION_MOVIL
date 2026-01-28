import 'package:dio/dio.dart';
import '../models/cart.dart';
import 'api_client.dart';

class CartService {
  final Dio _dio = ApiClient.dio;

  Future<Cart> getActual({required int usuarioId}) async {
    final res = await _dio.get(
      '/api/carrito/actual',
      queryParameters: {'usuarioId': usuarioId},
    );
    return Cart.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Cart> addItem({
    required int usuarioId,
    required int productoId,
    int cantidad = 1,
  }) async {
    final res = await _dio.post(
      '/api/carrito/items',
      queryParameters: {'usuarioId': usuarioId},
      data: {'productoId': productoId, 'cantidad': cantidad},
    );
    return Cart.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Cart> updateItemCantidad({
    required int usuarioId,
    required int itemId,
    required int cantidad,
  }) async {
    final res = await _dio.patch(
      '/api/carrito/items/$itemId',
      queryParameters: {'usuarioId': usuarioId},
      data: {'cantidad': cantidad},
    );
    return Cart.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Cart> deleteItem({
    required int usuarioId,
    required int itemId,
  }) async {
    final res = await _dio.delete(
      '/api/carrito/items/$itemId',
      queryParameters: {'usuarioId': usuarioId},
    );
    return Cart.fromJson(res.data as Map<String, dynamic>);
  }
}
