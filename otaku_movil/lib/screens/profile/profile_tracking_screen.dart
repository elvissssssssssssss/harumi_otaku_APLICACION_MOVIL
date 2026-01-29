import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../services/api_client.dart';
import '../../models/orden_resumen.dart';
import '../../models/orden_detalle.dart';

class ProfileTrackingScreen extends StatefulWidget {
  const ProfileTrackingScreen({super.key});

  @override
  State<ProfileTrackingScreen> createState() => _ProfileTrackingScreenState();
}

class _ProfileTrackingScreenState extends State<ProfileTrackingScreen> {
  final _orderService = OrderService();
  final _ordenIdCtrl = TextEditingController();

  String _fmtDt(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
  }

  String _toAbsoluteUrl(String? path) {
    final raw = (path ?? '').trim();
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

    final base = ApiClient.dio.options.baseUrl.replaceAll(RegExp(r'/$'), '');
    final cleaned = raw.replaceAll('\\', '/');
    return cleaned.startsWith('/') ? '$base$cleaned' : '$base/$cleaned';
  }

  @override
  void dispose() {
    _ordenIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _showDetalle({
    required int usuarioId,
    required int ordenId,
  }) async {
    final OrdenDetalle detalle = await _orderService.getOrdenDetalle(
      usuarioId: usuarioId,
      ordenId: ordenId,
    );

    if (!mounted) return;

    final voucherUrl = _toAbsoluteUrl(detalle.voucherImagenUrl);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Pedido #${detalle.id}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('Recojo: ${_fmtDt(detalle.pickupAt)}'),
              const SizedBox(height: 8),
              Text('Estado: ${detalle.estadoNombre} (${detalle.estadoCodigo})'),
              const SizedBox(height: 8),
              Text('Pago: ${detalle.pagoEstado ?? "SIN_PAGO"}'),
              Text('Nro operación: ${detalle.nroOperacion ?? "-"}'),
              Text('Pagado: ${_fmtDt(detalle.paidAt)}'),
              const SizedBox(height: 12),
              if (voucherUrl.isNotEmpty) ...[
                const Text('Voucher:'),
                const SizedBox(height: 8),
                Image.network(
                  voucherUrl,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Text('No se pudo cargar voucher.'),
                ),
                const SizedBox(height: 12),
              ],
              const Text('Items:'),
              const SizedBox(height: 8),
              ...detalle.items.map(
                (it) => Text('${it.cantidad} x ${it.nombre} = ${it.subtotal}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _buscarPorId(int usuarioId) {
    final id = int.tryParse(_ordenIdCtrl.text.trim());
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un ID válido.')),
      );
      return;
    }
    _showDetalle(usuarioId: usuarioId, ordenId: id);
  }

  @override
  Widget build(BuildContext context) {
    final usuarioId = context.watch<AuthProvider>().userId;

    if (usuarioId == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mis compras')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ordenIdCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por ID de pedido',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _buscarPorId(usuarioId),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _buscarPorId(usuarioId),
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<OrdenResumen>>(
              future: _orderService.getMisOrdenes(usuarioId: usuarioId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }

                final ordenes = snap.data ?? [];
                if (ordenes.isEmpty) {
                  return const Center(child: Text('Aún no tienes pedidos.'));
                }

                return ListView.separated(
                  itemCount: ordenes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final o = ordenes[i];

                    final estadoTxt = (o.estadoNombre?.trim().isNotEmpty ?? false)
                        ? o.estadoNombre!
                        : 'Estado #${o.estadoActualId}';

                    final pagoTxt = (o.pagoEstado?.trim().isNotEmpty ?? false)
                        ? o.pagoEstado!
                        : '-';

                    return ListTile(
                      title: Text('Pedido #${o.id} • $estadoTxt'),
                      subtitle: Text(
                        'Recojo: ${_fmtDt(o.pickupAt)} • Total: ${o.totalAmount} • Pago: $pagoTxt',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showDetalle(usuarioId: usuarioId, ordenId: o.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
