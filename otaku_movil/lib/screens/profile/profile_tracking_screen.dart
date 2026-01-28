import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../models/orden_resumen.dart';
import '../../models/orden_detalle.dart';




class ProfileTrackingScreen extends StatefulWidget {
  const ProfileTrackingScreen({super.key});

  @override
  State<ProfileTrackingScreen> createState() => _ProfileTrackingScreenState();
}

class _ProfileTrackingScreenState extends State<ProfileTrackingScreen> {
  final _orderService = OrderService();

  Future<void> _showDetalle({
    required int usuarioId,
    required int ordenId,
  }) async {
    final detalle = await _orderService.getOrdenDetalle(
      usuarioId: usuarioId,
      ordenId: ordenId,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Pedido #${detalle.id}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('Estado: ${detalle.estadoNombre} (${detalle.estadoCodigo})'),
              const SizedBox(height: 8),
              Text('Pago: ${detalle.pagoEstado ?? "SIN_PAGO"}'),
              Text('Nro operación: ${detalle.nroOperacion ?? "-"}'),
              const SizedBox(height: 12),
              const Text('Items:'),
              const SizedBox(height: 8),
              ...detalle.items.map((it) => Text('${it.cantidad} x ${it.nombre} = ${it.subtotal}')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final usuarioId = auth.userId;

    if (usuarioId == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mis compras')),
      body: FutureBuilder<List<OrdenResumen>>(
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
              return ListTile(
                title: Text('Pedido #${o.id} • ${o.estadoNombre ?? ""}'),
                subtitle: Text('Total: ${o.totalAmount ?? "-"} • Pago: ${o.pagoEstado ?? "-"}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDetalle(usuarioId: usuarioId, ordenId: o.id),
              );
            },
          );
        },
      ),
    );
  }
}
