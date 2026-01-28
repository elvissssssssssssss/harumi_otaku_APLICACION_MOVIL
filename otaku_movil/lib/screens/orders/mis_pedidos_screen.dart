import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/order_service.dart';
import '../../models/orden_resumen.dart';

class MisPedidosScreen extends StatefulWidget {
  const MisPedidosScreen({super.key});

  @override
  State<MisPedidosScreen> createState() => _MisPedidosScreenState();
}

class _MisPedidosScreenState extends State<MisPedidosScreen> {
  final _ordenIdCtrl = TextEditingController();

  String _fmtDt(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
  }

  @override
  void dispose() {
    _ordenIdCtrl.dispose();
    super.dispose();
  }

  void _buscarPorId() {
    final id = int.tryParse(_ordenIdCtrl.text.trim());
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un ID válido.')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.pedidoDetalle,
      arguments: id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuarioId = context.watch<AuthProvider>().userId;

    if (usuarioId == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión para ver tus pedidos.')),
      );
    }

    final service = OrderService();

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
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _buscarPorId,
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<OrdenResumen>>(
              future: service.getMisOrdenes(usuarioId: usuarioId),
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
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.pedidoDetalle,
                          arguments: o.id,
                        );
                      },
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
