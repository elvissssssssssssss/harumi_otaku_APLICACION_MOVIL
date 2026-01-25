// lib/services/envio_tracking_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/seguimiento.dart';
import '../config/api_config.dart';

class EnvioTrackingService {
  final Dio _dio = Dio(); 
  final String baseUrl = ApiConfig.baseUrl;

  EnvioTrackingService() {
    _dio.options.baseUrl = '$baseUrl/api/Envios';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Interceptor para logs en desarrollo
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => debugPrint(object.toString()),
      ));
    }

    // Interceptor para manejo de errores
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        debugPrint('Error en EnvioTrackingService: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // Obtener token del almacenamiento local (implementar según tu auth_service)
  String? _getToken() {
    // Implementar según tu sistema de autenticación
    // return AuthService.getToken();
    return null; // Por ahora
  }

  // Configurar headers con autenticación
  Map<String, dynamic> _getHeaders() {
    final token = _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Obtener estados de envío disponibles
  Future<List<EstadoEnvio>> getEstados() async {
    try {
      final response = await _dio.get(
        '/estados',
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => EstadoEnvio.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener estados: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Obtener seguimiento de un envío específico
  Future<List<SeguimientoEnvio>> getSeguimiento(int ventaId) async {
    try {
      final response = await _dio.get(
        '/seguimiento/$ventaId',
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SeguimientoEnvio.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener seguimiento: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Agregar nuevo seguimiento
  Future<ApiResponse> addSeguimiento(SeguimientoEnvio seguimiento) async {
    try {
      final response = await _dio.post(
        '/seguimiento',
        data: seguimiento.toJson(),
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.fromJson(response.data);
      } else {
        throw Exception('Error al agregar seguimiento: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Obtener documentos de un envío
  Future<List<DocumentoEnvio>> getDocumentos(int ventaId) async {
    try {
      final response = await _dio.get(
        '/documentos/$ventaId',
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => DocumentoEnvio.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener documentos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Agregar registro de documento (sin archivo físico)
  Future<ApiResponse> addDocumento(DocumentoEnvio documento) async {
    try {
      final response = await _dio.post(
        '/documentos',
        data: documento.toJson(),
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.fromJson(response.data);
      } else {
        throw Exception('Error al agregar documento: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Subir archivo de documento
  Future<ApiResponse> uploadDocumento({
    required int ventaId,
    required String tipoDocumento,
    required File archivo,
  }) async {
    try {
      // Validar archivo antes de subirlo
      final validacion = validarArchivo(archivo);
      if (!validacion['valido']) {
        throw Exception(validacion['mensaje']);
      }

      FormData formData = FormData.fromMap({
        'venta_id': ventaId.toString(),
        'tipo_documento': tipoDocumento,
        'archivo': await MultipartFile.fromFile(
          archivo.path,
          filename: archivo.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/upload-documento',
        data: formData,
        options: Options(
          headers: {
            if (_getToken() != null) 'Authorization': 'Bearer ${_getToken()}',
            // No establecer Content-Type para FormData, Dio lo hace automáticamente
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.fromJson(response.data);
      } else {
        throw Exception('Error al subir documento: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Confirmar entrega del envío
  Future<ApiResponse> confirmarEntrega(int ventaId) async {
    try {
      final response = await _dio.post(
        '/confirmar-entrega/$ventaId',
        data: {},
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(response.data);
      } else {
        throw Exception('Error al confirmar entrega: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Obtener mis seguimientos (para usuario autenticado)
  Future<List<SeguimientoEnvio>> getMisSeguimientos() async {
    try {
      final response = await _dio.get(
        '/mis-seguimientos',
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SeguimientoEnvio.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener mis seguimientos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // *** MÉTODOS AUXILIARES ***

  /// Obtener la URL completa del documento
  String getDocumentoUrl(String rutaArchivo) {
    // Remover la primera barra si existe para evitar doble barra
    final ruta = rutaArchivo.startsWith('/') ? rutaArchivo.substring(1) : rutaArchivo;
    return '${baseUrl}/$ruta';
  }

  /// Validar si un archivo es válido para subir
  Map<String, dynamic> validarArchivo(File archivo) {
    const maxSize = 5 * 1024 * 1024; // 5MB
    const tiposPermitidos = [
      'image/jpeg',
      'image/jpg', 
      'image/png',
      'application/pdf'
    ];

    // Verificar tamaño
    if (archivo.lengthSync() > maxSize) {
      return {
        'valido': false,
        'mensaje': 'El archivo es muy grande. Máximo 5MB permitido.'
      };
    }

    // Verificar extensión (aproximación básica)
    final extension = archivo.path.split('.').last.toLowerCase();
    final extensionesValidas = ['jpg', 'jpeg', 'png', 'pdf'];
    
    if (!extensionesValidas.contains(extension)) {
      return {
        'valido': false,
        'mensaje': 'Tipo de archivo no permitido. Solo JPG, PNG y PDF.'
      };
    }

    return {'valido': true};
  }

  /// Obtener el estado de progreso de un envío (porcentaje)
  double getProgresoEnvio(List<SeguimientoEnvio> seguimientos) {
    if (seguimientos.isEmpty) return 0;

    final ultimoSeguimiento = seguimientos.last;
    final estadoInfo = EstadosEnvio.getEstado(ultimoSeguimiento.estadoId);
    
    return estadoInfo?.progreso ?? 0;
  }

  /// Obtener el color del estado según el ID
  String getColorEstado(int estadoId) {
    final estadoInfo = EstadosEnvio.getEstado(estadoId);
    return estadoInfo?.color ?? '#6c757d';
  }

  /// Verificar si un estado permite agregar seguimiento
  bool puedeAgregarSeguimiento(int estadoActual, int nuevoEstado) {
    // No se puede retroceder en los estados (excepto casos especiales)
    if (nuevoEstado <= estadoActual && nuevoEstado != 3) {
      return false;
    }

    // Si ya está confirmado por cliente, no se puede cambiar
    if (estadoActual == 6) {
      return false;
    }

    return true;
  }

  /// Formatear fecha para mostrar
  String formatearFecha(String? fecha) {
    if (fecha == null) return 'No disponible';
    
    try {
      final date = DateTime.parse(fecha);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'No disponible';
    }
  }

  /// Obtener el ícono Material según el tipo de documento
  String getIconoDocumento(String tipoDocumento) {
    return TiposDocumento.getTipo(tipoDocumento)?.icono ?? 'description';
  }

  /// Manejo de errores de Dio
  Exception _handleDioError(DioException error) {
    String errorMessage = 'Ha ocurrido un error desconocido';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Tiempo de espera agotado. Verifique su conexión a internet.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Error de conexión. Verifique su conexión a internet.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            errorMessage = 'Solicitud incorrecta. Verifique los datos enviados.';
            break;
          case 401:
            errorMessage = 'No autorizado. Inicie sesión nuevamente.';
            break;
          case 403:
            errorMessage = 'No tiene permisos para realizar esta acción.';
            break;
          case 404:
            errorMessage = 'El recurso solicitado no fue encontrado.';
            break;
          case 500:
            errorMessage = 'Error interno del servidor. Intente más tarde.';
            break;
          default:
            errorMessage = 'Error del servidor: $statusCode';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Operación cancelada.';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Error de conexión. Verifique su conexión a internet.';
        break;
      default:
        errorMessage = error.message ?? 'Error desconocido';
    }

    debugPrint('Error en EnvioTrackingService: $errorMessage');
    return Exception(errorMessage);
  }
}