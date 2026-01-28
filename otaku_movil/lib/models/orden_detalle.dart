import 'orden_item.dart';

class OrdenDetalle {
  final int id;
  final int usuarioId;
  final DateTime? pickupAt;
  final num totalAmount;

  final String estadoCodigo;
  final String estadoNombre;
  final DateTime createdAt;

  final int? pagoId;
  final String? pagoEstado;
  final String? voucherImagenUrl;
  final String? nroOperacion;
  final DateTime? paidAt;

  final List<OrdenItem> items;

  OrdenDetalle({
    required this.id,
    required this.usuarioId,
    required this.pickupAt,
    required this.totalAmount,
    required this.estadoCodigo,
    required this.estadoNombre,
    required this.createdAt,
    required this.pagoId,
    required this.pagoEstado,
    required this.voucherImagenUrl,
    required this.nroOperacion,
    required this.paidAt,
    required this.items,
  });

  factory OrdenDetalle.fromJson(Map<String, dynamic> json) => OrdenDetalle(
    id: json['id'],
    usuarioId: json['usuarioId'],
    pickupAt: json['pickupAt'] == null ? null : DateTime.parse(json['pickupAt']),
    totalAmount: json['totalAmount'],
    estadoCodigo: json['estadoCodigo'],
    estadoNombre: json['estadoNombre'],
    createdAt: DateTime.parse(json['createdAt']),
    pagoId: json['pagoId'],
    pagoEstado: json['pagoEstado'],
    voucherImagenUrl: json['voucherImagenUrl'],
    nroOperacion: json['nroOperacion'],
    paidAt: json['paidAt'] == null ? null : DateTime.parse(json['paidAt']),
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => OrdenItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
