import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _service;
  CartProvider(this._service);

  bool loading = false;
  String? error;
  Cart? cart;

  Future<void> refresh({required int usuarioId}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      cart = await _service.getActual(usuarioId: usuarioId);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> add({
    required int usuarioId,
    required int productoId,
    int cantidad = 1,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      cart = await _service.addItem(
        usuarioId: usuarioId,
        productoId: productoId,
        cantidad: cantidad,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> setCantidad({
    required int usuarioId,
    required int itemId,
    required int cantidad,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      cart = await _service.updateItemCantidad(
        usuarioId: usuarioId,
        itemId: itemId,
        cantidad: cantidad,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> remove({
    required int usuarioId,
    required int itemId,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      cart = await _service.deleteItem(usuarioId: usuarioId, itemId: itemId);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
