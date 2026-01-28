class PagoYape {
  final int id;        // pagoId
  final int ordenId;
  final String metodo;
  final double monto;
  final String estado;
  final String yapeQrPayload;

  const PagoYape({
    required this.id,
    required this.ordenId,
    required this.metodo,
    required this.monto,
    required this.estado,
    required this.yapeQrPayload,
  });

  factory PagoYape.fromJson(Map<String, dynamic> json) {
    return PagoYape(
      id: (json['id'] as num).toInt(),
      ordenId: (json['ordenId'] as num).toInt(),
      metodo: (json['metodo'] ?? '').toString(),
      monto: (json['monto'] as num).toDouble(),
      estado: (json['estado'] ?? '').toString(),
      yapeQrPayload: (json['yapeQrPayload'] ?? '').toString(),
    );
  }
}
