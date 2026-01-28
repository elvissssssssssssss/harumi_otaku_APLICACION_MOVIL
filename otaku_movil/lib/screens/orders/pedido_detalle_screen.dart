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

  String _fmtDt(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
  }

  Future<_DetalleData> _load({
    required OrderService service,
    required int usuarioId,
  }) async {
    final orden = await service.getOrdenDetalle(ordenId: ordenId, usuarioId: usuarioId);
    final hist = await service.getHistorialEstados(ordenId: ordenId, usuarioId: usuarioId);
    return _DetalleData(orden, hist);
  }

  String _toAbsoluteUrl(String? path) {
    final raw = (path ?? '').trim();
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

    final base = ApiClient.dio.options.baseUrl.replaceAll(RegExp(r'/$'), '');
    final cleaned = raw.replaceAll('\\', '/');
    return cleaned.startsWith('/')
        ? '$base$cleaned'
        : '$base/$cleaned';
  }

  @override
  Widget build(BuildContext context) {
    final usuarioId = context.watch<AuthProvider>().userId;

    if (usuarioId == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión.')),
      );
    }

    final service = OrderService();

    return Scaffold(
      appBar: AppBar(title: Text('Pedido #$ordenId')),
      body: FutureBuilder<_DetalleData>(
        future: _load(service: service, usuarioId: usuarioId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final data = snap.data!;
          final o = data.orden;

          final voucherUrl = _toAbsoluteUrl(o.voucherImagenUrl);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: Text('Estado: ${o.estadoNombre} (${o.estadoCodigo})'),
                  subtitle: Text(
                    'Recojo: ${_fmtDt(o.pickupAt)}\n'
                    'Total: ${o.totalAmount} • Creado: ${_fmtDt(o.createdAt)}',
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Card(
                child: ListTile(
                  title: Text('Pago: ${o.pagoEstado ?? "SIN_PAGO"}'),
                  subtitle: Text(
                    'Nro operación: ${o.nroOperacion ?? "-"}\n'
                    'Pagado: ${_fmtDt(o.paidAt)}',
                  ),
                ),
              ),
              const SizedBox(height: 8),

              if (voucherUrl.isNotEmpty)
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Voucher'),
                      ),
                      Image.network(
                        voucherUrl,
                        height: 240,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('No se pudo cargar la imagen del voucher.'),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),
              const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...o.items.map(
                (it) => Card(
                  child: ListTile(
                    title: Text(it.nombre),
                    subtitle: Text('Cant: ${it.cantidad} • P.U.: ${it.precioUnitario}'),
                    trailing: Text('${it.subtotal}'),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Text('Historial de estados',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (data.historial.isEmpty)
                const Text('Sin historial.')
              else
                ...data.historial.map(
                  (h) => ListTile(
                    leading: const Icon(Icons.timeline),
                    title: Text('${h.estadoNombre} (${h.estadoCodigo})'),
                    subtitle: Text(_fmtDt(h.createdAt)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
