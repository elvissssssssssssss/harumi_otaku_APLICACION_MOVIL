import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../services/api_client.dart';
import '../../models/orden_detalle.dart';
import '../../models/orden_estado_historial.dart';

class _DetalleData {
  final OrdenDetalle orden;
  final List<OrdenEstadoHistorial> historial;
  _DetalleData(this.orden, this.historial);
}

class PedidoDetalleScreen extends StatelessWidget {
  final int ordenId;
  const PedidoDetalleScreen({super.key, required this.ordenId});

  static const _primaryPink = Color(0xFFFF69B4);
  static const _accentPink = Color(0xFFFFB6D9);
  static const _darkGray = Color(0xFF2D2D2D);
  static const _lightGray = Color(0xFFF5F5F5);

  String _fmtDt(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
  }

  Future<_DetalleData> _load({
    required OrderService service,
    required int usuarioId,
  }) async {
    final orden = await service.getOrdenDetalle(ordenId: ordenId, usuarioId: usuarioId);

    List<OrdenEstadoHistorial> hist = [];
    try {
      hist = await service.getHistorialEstados(ordenId: ordenId, usuarioId: usuarioId);
    } catch (e) {
      print('Historial falló para orden $ordenId: $e');
      hist = [];
    }

    return _DetalleData(orden, hist);
  }

  String _toAbsoluteUrl(String? path) {
    final raw = (path ?? '').trim();
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

    final base = ApiClient.dio.options.baseUrl.replaceAll(RegExp(r'/$'), '');
    final cleaned = raw.replaceAll('\\', '/');
    return cleaned.startsWith('/') ? '$base$cleaned' : '$base/$cleaned';
  }

  Color _getPagoColor(String? estado) {
    switch (estado) {
      case 'CONFIRMADO':
        return Colors.green;
      case 'EN_REVISION':
        return Colors.orange;
      case 'RECHAZADO':
        return Colors.red;
      case 'PENDIENTE':
        return Colors.grey;
      default:
        return _darkGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioId = context.watch<AuthProvider>().userId;

    if (usuarioId == null) {
      return Scaffold(
        backgroundColor: _lightGray,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 64, color: _accentPink),
              const SizedBox(height: 16),
              const Text('Debes iniciar sesión.'),
            ],
          ),
        ),
      );
    }

    final service = OrderService();

    return Scaffold(
      backgroundColor: _lightGray,
      appBar: AppBar(
        title: Text('Pedido #$ordenId', style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: _primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<_DetalleData>(
        future: _load(service: service, usuarioId: usuarioId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primaryPink),
              ),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 64, color: _accentPink),
                  const SizedBox(height: 16),
                  Text(
                    'No se pudo cargar el pedido',
                    style: TextStyle(fontSize: 16, color: _darkGray, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          final data = snap.data!;
          final o = data.orden;

          final estadoNombre = o.estadoNombre ?? 'SIN_ESTADO';
          final estadoCodigo = o.estadoCodigo ?? '-';
          final voucherUrl = _toAbsoluteUrl(o.voucherImagenUrl);
          final pagoColor = _getPagoColor(o.pagoEstado);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryPink.withOpacity(0.1), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long, color: _primaryPink, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Estado del Pedido',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _darkGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: _primaryPink.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 12, color: _primaryPink),
                            const SizedBox(width: 8),
                            Text(
                              '$estadoNombre ($estadoCodigo)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _primaryPink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.schedule, 'Recojo', _fmtDt(o.pickupAt)),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.monetization_on, 'Total', 'S/. ${o.totalAmount}'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.calendar_today, 'Creado', _fmtDt(o.createdAt)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.payment, color: pagoColor, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Información de Pago',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _darkGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.check_circle_outline, 'Estado', o.pagoEstado ?? "SIN_PAGO"),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.tag, 'Nro operación', o.nroOperacion ?? "-"),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.event_available, 'Pagado', _fmtDt(o.paidAt)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (voucherUrl.isNotEmpty)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.image, color: _primaryPink, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Voucher de Pago',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _darkGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Image.network(
                        voucherUrl,
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 240,
                          color: _lightGray,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.broken_image, size: 48, color: _accentPink),
                                const SizedBox(height: 8),
                                Text(
                                  'No se pudo cargar la imagen',
                                  style: TextStyle(color: _darkGray.withOpacity(0.6)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.restaurant_menu, color: _primaryPink, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Items del Pedido',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _darkGray,
                      ),
                    ),
                  ],
                ),
              ),

              ...o.items.map(
                (it) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _accentPink.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.fastfood, color: _primaryPink),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  it.nombre,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _darkGray,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cant: ${it.cantidad} × S/. ${it.precioUnitario}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _darkGray.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'S/. ${it.subtotal}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _primaryPink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.timeline, color: _primaryPink, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Historial de Estados',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _darkGray,
                      ),
                    ),
                  ],
                ),
              ),

              if (data.historial.isEmpty)
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Sin historial disponible',
                        style: TextStyle(color: _darkGray.withOpacity(0.6)),
                      ),
                    ),
                  ),
                )
              else
                ...data.historial.asMap().entries.map(
                  (entry) {
                    final idx = entry.key;
                    final h = entry.value;
                    final isLast = idx == data.historial.length - 1;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 40,
                            child: Column(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _primaryPink,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                                ),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: _accentPink,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16, left: 8),
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${h.estadoNombre} (${h.estadoCodigo})',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: _darkGray,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time, size: 14, color: _darkGray.withOpacity(0.6)),
                                          const SizedBox(width: 4),
                                          Text(
                                            _fmtDt(h.fechaCambio),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: _darkGray.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (h.comentario != null && h.comentario!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          h.comentario!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            color: _darkGray.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _darkGray.withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: _darkGray.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _darkGray,
            ),
          ),
        ),
      ],
    );
  }
}
