class OrdenResumen {
  final int id;
  final int usuarioId;

  final DateTime? pickupAt;
  final num totalAmount;

  final int estadoActualId;
  final String? estadoCodigo;
  final String? estadoNombre;
  final DateTime createdAt;

  final int itemsCount;
  final int itemsCantidadTotal;
  final num itemsSubtotalTotal;

  final int? pagoId;
  final String? pagoEstado;
  final String? voucherImagenUrl;
  final String? nroOperacion;
  final DateTime? paidAt;

  OrdenResumen({
    required this.id,
    required this.usuarioId,
    required this.pickupAt,
    required this.totalAmount,
    required this.estadoActualId,
    required this.estadoCodigo,
    required this.estadoNombre,
    required this.createdAt,
    required this.itemsCount,
    required this.itemsCantidadTotal,
    required this.itemsSubtotalTotal,
    required this.pagoId,
    required this.pagoEstado,
    required this.voucherImagenUrl,
    required this.nroOperacion,
    required this.paidAt,
  });

  factory OrdenResumen.fromJson(Map<String, dynamic> json) => OrdenResumen(
        id: json['id'],
        usuarioId: json['usuarioId'],
        pickupAt: json['pickupAt'] == null ? null : DateTime.parse(json['pickupAt']),
        totalAmount: json['totalAmount'],
        estadoActualId: json['estadoActualId'],
        estadoCodigo: json['estadoCodigo'],
        estadoNombre: json['estadoNombre'],
        createdAt: DateTime.parse(json['createdAt']),
        itemsCount: json['itemsCount'] ?? 0,
        itemsCantidadTotal: json['itemsCantidadTotal'] ?? 0,
        itemsSubtotalTotal: json['itemsSubtotalTotal'] ?? 0,
        pagoId: json['pagoId'],
        pagoEstado: json['pagoEstado'],
        voucherImagenUrl: json['voucherImagenUrl'],
        nroOperacion: json['nroOperacion'],
        paidAt: json['paidAt'] == null ? null : DateTime.parse(json['paidAt']),
      );
}
