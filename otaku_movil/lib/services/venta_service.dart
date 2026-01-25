// lib/services/venta_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

class VentaService {
  static const String _apiUrl = 'https://pusher-backend-elvis.onrender.com/api/Ventas';

  // 🟢 POST: Registrar venta completa (ESTRUCTURA CORRECTA PARA .NET)
  static Future<Map<String, dynamic>?> registrarVentaCompleta({
    required int userId,
    required int metodoPagoId,
    required double total,
    required List<Map<String, dynamic>> detalles,
  }) async {
    try {
      print('📤 Enviando venta completa a: $_apiUrl/completa');
      
      final payload = {
        'userId': userId,
        'metodoPagoId': metodoPagoId,
        'total': total,
        
        'detalles': detalles,
      };

      final jsonPayload = jsonEncode(payload);
      print('📦 PAYLOAD: $jsonPayload');

      final response = await http.post(
        Uri.parse('$_apiUrl/completa'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonPayload,
      ).timeout(const Duration(seconds: 30));

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Venta registrada: ID ${data['id']}');
        return data;
      } else {
        print('❌ Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('🚨 Excepción: $e');
      return null;
    }
  }

  // 🟢 GET: Obtener todas las ventas
  static Future<List<Map<String, dynamic>>?> obtenerVentas() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // 🟢 GET: Obtener venta por ID
  static Future<Map<String, dynamic>?> obtenerVentaPorId(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // 🟢 GET: Obtener ventas por usuario
  static Future<List<Map<String, dynamic>>?> obtenerVentasPorUsuario(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/usuario/$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // 🟢 POST: Crear preferencia de pago en Mercado Pago
  static Future<Map<String, dynamic>?> crearPreferenciaPago(List<Map<String, dynamic>> items) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/preferencia'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'items': items}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
