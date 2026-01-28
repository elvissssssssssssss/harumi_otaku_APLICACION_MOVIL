import 'package:flutter/foundation.dart';
import '../models/categoria.dart';
import '../models/producto.dart';
import '../services/catalog_service.dart';

class CatalogProvider extends ChangeNotifier {
  final CatalogService _service;
  CatalogProvider(this._service);

  bool loading = false;
  String? error;

  List<Categoria> categorias = [];
  Categoria? categoriaSeleccionada;

  List<Producto> productos = [];

  Future<void> init() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      categorias = await _service.getCategorias();

      if (categorias.isNotEmpty) {
        categoriaSeleccionada = categorias.first;
        productos = await _service.getProductos(
          categoriaId: categoriaSeleccionada!.id,
          activo: true,
        );
      } else {
        productos = [];
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> seleccionarCategoria(Categoria categoria) async {
    categoriaSeleccionada = categoria;
    loading = true;
    error = null;
    notifyListeners();

    try {
      productos = await _service.getProductos(categoriaId: categoria.id, activo: true);
    } catch (e) {
      error = e.toString();
      productos = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
