// lib/models/envio_models.dart

class EstadoEnvio {
  final int id;
  final String nombre;
  final String descripcion;
  final String creadoEn;
  final String actualizadoEn;

  EstadoEnvio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  factory EstadoEnvio.fromJson(Map<String, dynamic> json) {
    return EstadoEnvio(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      creadoEn: json['creado_en'],
      actualizadoEn: json['actualizado_en'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'creado_en': creadoEn,
      'actualizado_en': actualizadoEn,
    };
  }
}

class SeguimientoEnvio {
  final int? id;
  final int ventaId;
  final int estadoId;
  final String ubicacionActual;
  final String observaciones;
  final String? fechaCambio;
  final bool? confirmadoPorCliente;
  final String? fechaConfirmacion;
  final String? estadoNombre;
  final String? estadoDescripcion;

  SeguimientoEnvio({
    this.id,
    required this.ventaId,
    required this.estadoId,
    required this.ubicacionActual,
    required this.observaciones,
    this.fechaCambio,
    this.confirmadoPorCliente,
    this.fechaConfirmacion,
    this.estadoNombre,
    this.estadoDescripcion,
  });

  factory SeguimientoEnvio.fromJson(Map<String, dynamic> json) {
    return SeguimientoEnvio(
      id: json['id'],
      ventaId: json['venta_id'],
      estadoId: json['estado_id'],
      ubicacionActual: json['ubicacion_actual'],
      observaciones: json['observaciones'],
      fechaCambio: json['fecha_cambio'],
      confirmadoPorCliente: json['confirmado_por_cliente'],
      fechaConfirmacion: json['fecha_confirmacion'],
      estadoNombre: json['estado_nombre'],
      estadoDescripcion: json['estado_descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venta_id': ventaId,
      'estado_id': estadoId,
      'ubicacion_actual': ubicacionActual,
      'observaciones': observaciones,
      'fecha_cambio': fechaCambio,
      'confirmado_por_cliente': confirmadoPorCliente,
      'fecha_confirmacion': fechaConfirmacion,
      'estado_nombre': estadoNombre,
      'estado_descripcion': estadoDescripcion,
    };
  }
}

class DocumentoEnvio {
  final int? id;
  final int ventaId;
  final String tipoDocumento;
  final String nombreArchivo;
  final String rutaArchivo;
  final String? fechaSubida;

  DocumentoEnvio({
    this.id,
    required this.ventaId,
    required this.tipoDocumento,
    required this.nombreArchivo,
    required this.rutaArchivo,
    this.fechaSubida,
  });

  factory DocumentoEnvio.fromJson(Map<String, dynamic> json) {
    return DocumentoEnvio(
      id: json['id'],
      ventaId: json['venta_id'],
      tipoDocumento: json['tipo_documento'],
      nombreArchivo: json['nombre_archivo'],
      rutaArchivo: json['ruta_archivo'],
      fechaSubida: json['fecha_subida'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venta_id': ventaId,
      'tipo_documento': tipoDocumento,
      'nombre_archivo': nombreArchivo,
      'ruta_archivo': rutaArchivo,
      'fecha_subida': fechaSubida,
    };
  }
}

class ApiResponse {
  final String message;
  final String? ruta;

  ApiResponse({
    required this.message,
    this.ruta,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      message: json['message'],
      ruta: json['ruta'],
    );
  }
}

// Enums y constantes
enum TipoDocumento { boleta, fotoEnvio, guiaRemision, comprobanteEntrega }

enum EstadoEnvioId { confirmado, empaquetado, enCamino, listoParaRecojo, entregado, confirmadoPorCliente }

class EstadoEnvioInfo {
  final int id;
  final String nombre;
  final String descripcion;
  final String color;
  final String icono;
  final double progreso;

  EstadoEnvioInfo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.color,
    required this.icono,
    required this.progreso,
  });
}

class TipoDocumentoInfo {
  final String label;
  final String icono;
  final List<String> extensions;

  TipoDocumentoInfo({
    required this.label,
    required this.icono,
    required this.extensions,
  });
}

// Constantes para los estados
class EstadosEnvio {
  static final Map<int, EstadoEnvioInfo> estados = {
    1: EstadoEnvioInfo(
      id: 1,
      nombre: 'Confirmado',
      descripcion: 'Pedido confirmado y en preparación',
      color: '#17a2b8',
      icono: 'check_circle',
      progreso: 16.67,
    ),
    2: EstadoEnvioInfo(
      id: 2,
      nombre: 'Empaquetado',
      descripcion: 'Productos empaquetados y listos para envío',
      color: '#6f42c1',
      icono: 'inventory_2',
      progreso: 33.33,
    ),
    3: EstadoEnvioInfo(
      id: 3,
      nombre: 'En Camino',
      descripcion: 'Pedido en tránsito hacia su destino',
      color: '#fd7e14',
      icono: 'local_shipping',
      progreso: 50,
    ),
    4: EstadoEnvioInfo(
      id: 4,
      nombre: 'Listo para Recojo',
      descripcion: 'Pedido disponible para recoger en agencia',
      color: '#20c997',
      icono: 'store',
      progreso: 66.67,
    ),
    5: EstadoEnvioInfo(
      id: 5,
      nombre: 'Entregado',
      descripcion: 'Pedido entregado al cliente',
      color: '#28a745',
      icono: 'done_all',
      progreso: 83.33,
    ),
    6: EstadoEnvioInfo(
      id: 6,
      nombre: 'Confirmado por Cliente',
      descripcion: 'Entrega verificada por el comprador',
      color: '#155724',
      icono: 'verified_user',
      progreso: 100,
    ),
  };

  static EstadoEnvioInfo? getEstado(int id) => estados[id];
}

// Tipos de documento con información adicional
class TiposDocumento {
  static final Map<String, TipoDocumentoInfo> tipos = {
    'boleta': TipoDocumentoInfo(
      label: 'Boleta',
      icono: 'receipt',
      extensions: ['.pdf'],
    ),
    'foto_envio': TipoDocumentoInfo(
      label: 'Foto del Envío',
      icono: 'photo_camera',
      extensions: ['.jpg', '.jpeg', '.png'],
    ),
    'guia_remision': TipoDocumentoInfo(
      label: 'Guía de Remisión',
      icono: 'local_shipping',
      extensions: ['.pdf'],
    ),
    'comprobante_entrega': TipoDocumentoInfo(
      label: 'Comprobante de Entrega',
      icono: 'check_circle',
      extensions: ['.pdf', '.jpg', '.jpeg', '.png'],
    ),
  };

  static TipoDocumentoInfo? getTipo(String tipo) => tipos[tipo];
  static String getLabel(String tipo) => tipos[tipo]?.label ?? tipo;
}