// lib/services/producto_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';
import '../config/api_config.dart';

import 'dart:core'; 

class ProductoService {
  
  // Obtener todos los productos
  Future<List<Producto>> getAllProductos() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.productosUrl),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Producto.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener producto por ID
 Future<Producto?> getProductoById(int id) async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.productosUrl}/$id'),
      headers: ApiConfig.defaultHeaders,
    ).timeout(ApiConfig.timeoutDuration);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final productoJson = json['data']; // ✅ tomar solo el objeto 'data'
      return Producto.fromJson(productoJson);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al cargar producto: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}


  Future<List<Producto>> getProductosByCategoria(String categoria) async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.productosUrl}/categoria/$categoria'),
      headers: ApiConfig.defaultHeaders,
    ).timeout(ApiConfig.timeoutDuration);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> productosJson = jsonData['data']; // <- Extraer del ApiResponse

      return productosJson.map((json) => Producto.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar productos por categoría: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}


  // Obtener productos por género y tipo
Future<List<Producto>> getProductosByGeneroYTipo(String genero, String tipo) async {
  final url = Uri.parse('${ApiConfig.productosUrl}/$genero/$tipo');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body);
    final List<dynamic> data = json['data']; // ✅ usar solo la lista interna
    return data.map((e) => Producto.fromJson(e)).toList();
  } else {
    throw Exception('Error al cargar productos');
  }
}



  // Buscar productos
 Future<List<Producto>> searchProductos(String searchTerm) async {
  try {
    final response = await http.get(
      Uri.parse(ApiConfig.productosUrl),
      headers: ApiConfig.defaultHeaders,
    ).timeout(ApiConfig.timeoutDuration);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> productosJson = jsonData['data'] ?? [];
      final productos = productosJson.map((json) => Producto.fromJson(json)).toList();

      return productos.where((producto) =>
        producto.nombre.toLowerCase().contains(searchTerm.toLowerCase()) ||
        (producto.categoria.toLowerCase().contains(searchTerm.toLowerCase()))
      ).toList();
    } else {
      throw Exception('Error al buscar productos: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}

}