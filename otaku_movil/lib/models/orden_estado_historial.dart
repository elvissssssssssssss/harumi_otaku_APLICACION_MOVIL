class OrdenEstadoHistorial {
  final int id;
  final int ordenId;
  final int estadoId;
  final String estadoCodigo;
  final String estadoNombre;
  final int cambiadoPorUsuarioId;
  final String? comentario;      // <- puede ser null
  final DateTime fechaCambio;

  OrdenEstadoHistorial({
    required this.id,
    required this.ordenId,
    required this.estadoId,
    required this.estadoCodigo,
    required this.estadoNombre,
    required this.cambiadoPorUsuarioId,
    required this.comentario,
    required this.fechaCambio,
  });

  factory OrdenEstadoHistorial.fromJson(Map<String, dynamic> json) {
    return OrdenEstadoHistorial(
      id: json['id'] as int,
      ordenId: json['ordenId'] as int,
      estadoId: json['estadoId'] as int,
      estadoCodigo: json['estadoCodigo'] as String,
      estadoNombre: json['estadoNombre'] as String,
      cambiadoPorUsuarioId: json['cambiadoPorUsuarioId'] as int,
      comentario: json['comentario'] as String?,            // aquí
      fechaCambio: DateTime.parse(json['fechaCambio'] as String),
    );
  }
}
