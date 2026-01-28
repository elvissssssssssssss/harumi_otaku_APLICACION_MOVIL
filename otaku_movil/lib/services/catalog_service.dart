import 'package:dio/dio.dart';
import '../models/categoria.dart';
import '../models/producto.dart';
import 'api_client.dart';

class CatalogService {
  final Dio _dio = ApiClient.dio;

  Future<List<Categoria>> getCategorias() async {
    final res = await _dio.get('/api/categorias');
    final list = (res.data as List).cast<dynamic>();
    return list.map((e) => Categoria.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Producto>> getProductos({int? categoriaId, bool? activo}) async {
    final res = await _dio.get(
      '/api/productos',
      queryParameters: {
        if (categoriaId != null) 'categoriaId': categoriaId,
        if (activo != null) 'activo': activo,
      },
    );

    final list = (res.data as List).cast<dynamic>();
    return list.map((e) => Producto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Producto> getProductoById(int id) async {
    final res = await _dio.get('/api/productos/$id');
    return Producto.fromJson(res.data as Map<String, dynamic>);
  }
}
