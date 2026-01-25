// lib/services/mercadopago_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import '../models/user.dart';
import '../models/envio.dart';

class MercadoPagoService {
  static const String backendUrl = 'https://pusher-backend-elvis.onrender.com/api/Ventas/preferencia';

  /// MÉTODO PRINCIPAL CON USER Y ENVÍO
  static Future<Map<String, dynamic>?> createPreference({
    required User user,
    required List<CartItem> carrito,
    Envio? envio,
  }) async {
    try {
      print('🚀 =============== MERCADOPAGO ===============');
      print('👤 Usuario: ${user.nombre}');
      print('📧 Email: ${user.email}');
      print('📦 Items: ${carrito.length}');
      
      // Construir items con precios redondeados a 2 decimales
      final items = carrito.map((item) {
        final precioRedondeado = double.parse(item.precio.toStringAsFixed(2));
        print('   📦 ${item.nombre} - Talla: ${item.talla}');
        print('      Cantidad: ${item.cantidad} | Precio: S/$precioRedondeado');
        
        return {
          'title': "${item.nombre} - Talla: ${item.talla}",
          'quantity': item.cantidad,
          'unitPrice': precioRedondeado, // IMPORTANTE: 2 decimales máximo
        };
      }).toList();

      // Calcular totales
      final subtotal = carrito.fold<double>(
        0, 
        (sum, item) => sum + (item.precio * item.cantidad)
      );
      const envioMonto = 15.65;
      final total = subtotal + envioMonto;

      print('💰 Subtotal: S/${subtotal.toStringAsFixed(2)}');
      print('🚚 Envío: S/${envioMonto.toStringAsFixed(2)}');
      print('💵 Total: S/${total.toStringAsFixed(2)}');

      // Payload completo
      final payload = {
        'items': items,
        'user': {
          'name': user.nombre,
          'email': user.email,
        },
        if (envio != null) 'shipping': {
          'address': envio.direccion,
          'region': envio.region,
          'province': envio.provincia,
          'locality': envio.localidad,
          'dni': envio.dni,
          'phone': envio.telefono,
        },
      };

      print('📤 Enviando a backend...');

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 30));

      print('📥 Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        print('✅ Preferencia creada');
        print('🔗 URL: ${data['sandboxInitPoint'] ?? data['initPoint']}');
        print('============================================');
        
        return {
          'id': data['id'] ?? data['preferenceId'],
          'init_point': data['initPoint'] ?? data['init_point'],
          'sandbox_init_point': data['sandboxInitPoint'] ?? data['sandbox_init_point'],
        };
      } else {
        print('❌ Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('🚨 ERROR: $e');
      return null;
    }
  }

  /// MÉTODO SIMPLE (TU CÓDIGO ACTUAL - FUNCIONA)
  static Future<String?> crearPreferencia(List<CartItem> carrito) async {
    try {
      print('📦 Creando preferencia simple (sin user/envío)...');
      
      final items = carrito.map((item) {
        // Redondear precio a 2 decimales para evitar errores
        final precioRedondeado = double.parse(item.precio.toStringAsFixed(2));
        
        return {
          'title': item.nombre,
          'quantity': item.cantidad,
          'unitPrice': precioRedondeado, // ✅ Ahora con 2 decimales
        };
      }).toList();

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'items': items}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Abrir sandboxInitPoint para pruebas, initPoint en producción
        return data['sandboxInitPoint'] ?? data['initPoint'];
      } else {
        print('Error backend: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}