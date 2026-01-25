// lib/providers/producto_provider.dart
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../config/api_config.dart';
import '../utils/category_mapper.dart';
import 'dart:core'; // Para Uri.parse (opcional, ya que 'dart:core' se importa por defecto).

import 'dart:convert';


class ProductoProvider with ChangeNotifier {
  final ProductoService _productoService = ProductoService();
  
  List<Producto> _productos = [];
  List<Producto> _productosFiltrados = [];
  bool _isLoading = false;
  String? _error;
  
  String _generoActual = 'mujer';
  String _tipoActual = 'novedad';
  String _busquedaActual = '';
 
  // Getters
  List<Producto> get productos => _productos;
  List<Producto> get productosFiltrados => _productosFiltrados;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get generoActual => _generoActual;
  String get tipoActual => _tipoActual;
  String get busquedaActual => _busquedaActual;

  // Setters
  set generoActual(String genero) {
    _generoActual = genero;
    _aplicarFiltros();
    notifyListeners();
  }

  set tipoActual(String tipo) {
    _tipoActual = tipo;
    _aplicarFiltros();
    notifyListeners();
  }

  set busquedaActual(String busqueda) {
    _busquedaActual = busqueda;
    _aplicarFiltros();
    notifyListeners();
  }

  // Cargar todos los productos
  Future<void> cargarProductos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _productos = await _productoService.getAllProductos();
      _aplicarFiltros();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar productos por categoría específica
  Future<void> cargarProductosPorCategoria(String categoria) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _productos = await _productoService.getProductosByCategoria(categoria);
      _productosFiltrados = _productos;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar productos por género y tipo
Future<List<Producto>> getProductosByGeneroYTipo(String genero, String tipo) async {
  final categoria = CategoryMapper.getBackendCategory(genero, tipo);
  final url = Uri.parse('${ApiConfig.productosUrl}/categoria/$categoria');


  final response = await http.get(url, headers: ApiConfig.defaultHeaders);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List;
    return data.map((json) => Producto.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar productos: ${response.reasonPhrase}');
  }
}



  // Buscar productos
  Future<void> buscarProductos(String termino) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _productos = await _productoService.searchProductos(termino);
      _productosFiltrados = _productos;
      _busquedaActual = termino;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> filtrarProductosAvanzado({
  required String genero,
  required String tipo,
  String? marca,
  String? talla,
  String? color,
  double? precioMin,
  double? precioMax,
}) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final productos = await _productoService.getProductosByGeneroYTipo(genero, tipo);

    _productos = productos;

    _productosFiltrados = productos.where((producto) {
      final cumpleMarca = marca == null || marca == 'Todas' || producto.marca?.toLowerCase() == marca.toLowerCase();
      final cumpleTalla = talla == null || talla == 'Todas' || producto.tallas.contains(talla);
      final cumpleColor = color == null || color == 'todas' || producto.colores.any((c) => c.toLowerCase() == color.toLowerCase());
      final cumplePrecio = (precioMin == null || producto.precio >= precioMin) &&
                           (precioMax == null || producto.precio <= precioMax);
      return cumpleMarca && cumpleTalla && cumpleColor && cumplePrecio;
    }).toList();
  } catch (e) {
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  // Obtener producto por ID
  Future<Producto?> obtenerProductoPorId(int id) async {
    try {
      return await _productoService.getProductoById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  

  // Aplicar filtros locales
  void _aplicarFiltros() {
    _productosFiltrados = _productos.where((producto) {
      bool cumpleGenero = _generoActual.isEmpty || 
          producto.genero?.toLowerCase() == _generoActual.toLowerCase();
      
      bool cumpleTipo = true;
      if (_tipoActual.isNotEmpty) {
        if (_tipoActual == 'novedad') {
          cumpleTipo = producto.categoria.toLowerCase().contains('novedad');
        } else {
          cumpleTipo = producto.categoria.toLowerCase().contains(_tipoActual.toLowerCase());
        }
      }

      bool cumpleBusqueda = _busquedaActual.isEmpty ||
          producto.nombre.toLowerCase().contains(_busquedaActual.toLowerCase()) ||
          producto.descripcion.toLowerCase().contains(_busquedaActual.toLowerCase());

      return cumpleGenero && cumpleTipo && cumpleBusqueda;
    }).toList();
  }

  // Cambiar filtros y recargar
  void cambiarFiltros(String genero, String tipo) {
    
    _generoActual = genero;
    _tipoActual = tipo;
    _aplicarFiltros();
  }

  // Limpiar filtros
  void limpiarFiltros() {
    _generoActual = '';
    _tipoActual = '';
    _busquedaActual = '';
    _aplicarFiltros();
    notifyListeners();
  }

  // Limpiar error
  void limpiarError() {
    _error = null;
    notifyListeners();
  }
  Set<String> get tallasDisponibles {
  return _productos.expand((p) => p.tallas).toSet();
}
void setProductosFiltrados(List<Producto> productos) {
  _productosFiltrados = productos;
  notifyListeners();
}


Set<String> get coloresDisponibles {
  return _productos.expand((p) => p.colores).toSet();
}


  // Refrescar datos
  Future<void> refrescar() async {
    await cargarProductos();
  }
}