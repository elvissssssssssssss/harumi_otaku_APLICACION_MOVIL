class OrdenEstadoHistorial {
  final int? estadoId;
  final String estadoCodigo;
  final String estadoNombre;
  final DateTime createdAt;

  OrdenEstadoHistorial({
    required this.estadoId,
    required this.estadoCodigo,
    required this.estadoNombre,
    required this.createdAt,
  });

  factory OrdenEstadoHistorial.fromJson(Map<String, dynamic> json) {
    return OrdenEstadoHistorial(
      estadoId: json['estadoId'],
      estadoCodigo: json['estadoCodigo'] ?? '',
      estadoNombre: json['estadoNombre'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
