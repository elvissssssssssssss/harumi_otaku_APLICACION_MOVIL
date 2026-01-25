// lib/services/envio_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/envio.dart';

class EnvioService {
  final String baseUrl = 'https://pusher-backend-elvis.onrender.com/api/TblEnvios';

  Future<bool> enviarDatos(Envio envio) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(envio.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Error del servidor: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al conectar con la API: $e');
      return false;
    }
  }
}
