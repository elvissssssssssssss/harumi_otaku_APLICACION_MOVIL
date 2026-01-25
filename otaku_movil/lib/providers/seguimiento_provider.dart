// lib/providers/seguimiento_provider.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/seguimiento.dart';
import '../services/seguimiento_service.dart';

class TrackingProvider extends ChangeNotifier {
  final EnvioTrackingService _service = EnvioTrackingService();

  // Estado de los datos
  List<SeguimientoEnvio> _seguimientos = [];
  List<DocumentoEnvio> _documentos = [];
  List<EstadoEnvio> _estados = [];
  int? _ventaSeleccionada;

  // Estado de carga
  bool _isLoading = false;
  bool _isConfirmingDelivery = false;
  bool _isUploadingDocument = false;

  // Mensajes
  String _message = '';
  bool _isError = false;

  // Getters
  List<SeguimientoEnvio> get seguimientos => _seguimientos;
  List<DocumentoEnvio> get documentos => _documentos;
  List<EstadoEnvio> get estados => _estados;
  int? get ventaSeleccionada => _ventaSeleccionada;
  
  bool get isLoading => _isLoading;
  bool get isConfirmingDelivery => _isConfirmingDelivery;
  bool get isUploadingDocument => _isUploadingDocument;
  
  String get message => _message;
  bool get isError => _isError;

  /// Buscar envío por ID
  Future<void> buscarEnvio(int ventaId) async {
    _isLoading = true;
    _ventaSeleccionada = ventaId;
    _clearMessage();
    notifyListeners();

    try {
      // Cargar seguimientos y documentos en paralelo
      await Future.wait([
        _cargarSeguimientos(ventaId),
        _cargarDocumentos(ventaId),
      ]);

      _showMessage('Información del envío cargada correctamente', isError: false);
    } catch (e) {
      _showMessage('Error al buscar el envío: ${e.toString()}', isError: true);
      _seguimientos.clear();
      _documentos.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar seguimientos
  Future<void> _cargarSeguimientos(int ventaId) async {
    try {
      final seguimientos = await _service.getSeguimiento(ventaId);
      // Ordenar por fecha de cambio
      _seguimientos = seguimientos..sort((a, b) {
        final fechaA = DateTime.tryParse(a.fechaCambio ?? '') ?? DateTime.now();
        final fechaB = DateTime.tryParse(b.fechaCambio ?? '') ?? DateTime.now();
        return fechaA.compareTo(fechaB);
      });
    } catch (e) {
      debugPrint('Error al cargar seguimientos: $e');
      _seguimientos.clear();
      rethrow;
    }
  }

  /// Cargar documentos
  Future<void> _cargarDocumentos(int ventaId) async {
    try {
      final documentos = await _service.getDocumentos(ventaId);
      // Ordenar por fecha de subida (más reciente primero)
      _documentos = documentos..sort((a, b) {
        final fechaA = DateTime.tryParse(a.fechaSubida ?? '') ?? DateTime.now();
        final fechaB = DateTime.tryParse(b.fechaSubida ?? '') ?? DateTime.now();
        return fechaB.compareTo(fechaA);
      });
    } catch (e) {
      debugPrint('Error al cargar documentos: $e');
      _documentos.clear();
      rethrow;
    }
  }

  /// Confirmar entrega del envío
  Future<void> confirmarEntrega() async {
    if (_ventaSeleccionada == null) return;

    _isConfirmingDelivery = true;
    _clearMessage();
    notifyListeners();

    try {
      await _service.confirmarEntrega(_ventaSeleccionada!);
      _showMessage('Entrega confirmada correctamente', isError: false);
      
      // Recargar seguimientos para obtener el estado actualizado
      await _cargarSeguimientos(_ventaSeleccionada!);
    } catch (e) {
      _showMessage('Error al confirmar la entrega: ${e.toString()}', isError: true);
    } finally {
      _isConfirmingDelivery = false;
      notifyListeners();
    }
  }

  /// Subir documento
  Future<void> uploadDocumento({
    required String tipoDocumento,
    required File archivo,
  }) async {
    if (_ventaSeleccionada == null) return;

    _isUploadingDocument = true;
    _clearMessage();
    notifyListeners();

    try {
      await _service.uploadDocumento(
        ventaId: _ventaSeleccionada!,
        tipoDocumento: tipoDocumento,
        archivo: archivo,
      );
      
      _showMessage('Documento subido correctamente', isError: false);
      
      // Recargar documentos para mostrar el nuevo documento
      await _cargarDocumentos(_ventaSeleccionada!);
    } catch (e) {
      _showMessage('Error al subir documento: ${e.toString()}', isError: true);
    } finally {
      _isUploadingDocument = false;
      notifyListeners();
    }
  }

  /// Cargar estados disponibles
  Future<void> loadEstados() async {
    try {
      _estados = await _service.getEstados();
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar estados: $e');
      _showMessage('Error al cargar estados: ${e.toString()}', isError: true);
    }
  }

  /// Verificar si se puede confirmar entrega
  bool puedeConfirmarEntrega() {
    if (_seguimientos.isEmpty) return false;
    
    final ultimoSeguimiento = _seguimientos.last;
    
    // Puede confirmar si el último estado es "Listo para Recojo" (id: 4) o "En Camino" (id: 3)
    // y no está confirmado por el cliente
    return (ultimoSeguimiento.estadoId == 3 || ultimoSeguimiento.estadoId == 4) && 
           (ultimoSeguimiento.confirmadoPorCliente != true);
  }

  /// Obtener progreso del envío
  double getProgreso() {
    return _service.getProgresoEnvio(_seguimientos);
  }

  /// Obtener color del último estado
  String getColorEstadoActual() {
    if (_seguimientos.isEmpty) return '#6c757d';
    return _service.getColorEstado(_seguimientos.last.estadoId);
  }

  /// Obtener información del estado actual
  EstadoEnvioInfo? getEstadoActualInfo() {
    if (_seguimientos.isEmpty) return null;
    return EstadosEnvio.getEstado(_seguimientos.last.estadoId);
  }

  /// Obtener label del tipo de documento
  String getTipoDocumentoLabel(String tipo) {
    return TiposDocumento.getLabel(tipo);
  }

  /// Formatear fecha
  String formatearFecha(String? fecha) {
    return _service.formatearFecha(fecha);
  }

  /// Obtener URL del documento
  String getDocumentoUrl(String rutaArchivo) {
    return _service.getDocumentoUrl(rutaArchivo);
  }

  /// Validar archivo antes de subir
  Map<String, dynamic> validarArchivo(File archivo) {
    return _service.validarArchivo(archivo);
  }

  /// Limpiar datos del envío actual
  void clearEnvio() {
    _ventaSeleccionada = null;
    _seguimientos.clear();
    _documentos.clear();
    _clearMessage();
    notifyListeners();
  }

  /// Mostrar mensaje
  void _showMessage(String message, {required bool isError}) {
    _message = message;
    _isError = isError;
    notifyListeners();
    
    // Limpiar mensaje después de 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      if (_message == message) {
        _clearMessage();
        notifyListeners();
      }
    });
  }

  /// Limpiar mensaje
  void _clearMessage() {
    _message = '';
    _isError = false;
  }

  /// Limpiar mensaje manualmente
  void clearMessage() {
    _clearMessage();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  } }