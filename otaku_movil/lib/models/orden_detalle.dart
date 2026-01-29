import 'orden_item.dart';

class OrdenDetalle {
  final int id;
  final int usuarioId;
  final DateTime? pickupAt;
  final num totalAmount;

  final int estadoActualId;
  final String? estadoCodigo;      // puede ser null
  final String? estadoNombre;      // puede ser null
  final DateTime createdAt;

  final int? pagoId;
  final String? pagoEstado;        // puede ser null
  final String? voucherImagenUrl;  // puede ser null
  final String? nroOperacion;      // puede ser null
  final DateTime? paidAt;

  final List<OrdenItem> items;

  OrdenDetalle({
    required this.id,
    required this.usuarioId,
    required this.pickupAt,
    required this.totalAmount,
    required this.estadoActualId,
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
        id: json['id'] as int,
        usuarioId: json['usuarioId'] as int,
        pickupAt: json['pickupAt'] == null
            ? null
            : DateTime.parse(json['pickupAt'] as String),
        totalAmount: json['totalAmount'] as num,
        estadoActualId: json['estadoActualId'] as int,
        estadoCodigo: json['estadoCodigo'] as String?,
        estadoNombre: json['estadoNombre'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        pagoId: json['pagoId'] as int?,
        pagoEstado: json['pagoEstado'] as String?,
         voucherImagenUrl: json['voucherImagenUrl'] as String?, // ✅
        nroOperacion: json['nroOperacion'] as String?,
        paidAt: json['paidAt'] == null
            ? null
            : DateTime.parse(json['paidAt'] as String),
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => OrdenItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
