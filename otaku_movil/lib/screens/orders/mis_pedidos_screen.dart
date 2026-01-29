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

  static const _primaryPink = Color(0xFFFF69B4);
  static const _accentPink = Color(0xFFFFB6D9);
  static const _darkGray = Color(0xFF2D2D2D);
  static const _lightGray = Color(0xFFF5F5F5);

  String _fmtDt(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
  }

  String _mapEstado(int estadoId, String? nombre) {
    if (nombre != null && nombre.trim().isNotEmpty) return nombre;
    switch (estadoId) {
      case 1:
        return 'Orden Creada';
      case 2:
        return 'Pendiente de pago';
      case 3:
        return 'En cocina';
      case 4:
        return 'Listo para entrega';
      case 5:
        return 'Orden finalizada';
      default:
        return 'Estado #$estadoId';
    }
  }

  Color _getEstadoColor(int estadoId) {
    switch (estadoId) {
      case 1:
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.green;
      default:
        return _darkGray;
    }
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
        SnackBar(
          content: const Text('Ingresa un ID de pedido válido'),
          backgroundColor: _primaryPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
      return Scaffold(
        backgroundColor: _lightGray,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 80, color: _accentPink),
              const SizedBox(height: 16),
              Text(
                'Debes iniciar sesión\npara ver tus pedidos',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: _darkGray),
              ),
            ],
          ),
        ),
      );
    }

    final service = OrderService();

    return Scaffold(
      backgroundColor: _lightGray,
      appBar: AppBar(
        title: const Text('Mis Compras', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: _primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: _primaryPink,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ordenIdCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Buscar por ID de pedido',
                        labelStyle: TextStyle(color: _darkGray.withOpacity(0.6)),
                        prefixIcon: Icon(Icons.search, color: _primaryPink),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: _buscarPorId,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryPink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Buscar', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: FutureBuilder<List<OrdenResumen>>(
              future: service.getMisOrdenes(usuarioId: usuarioId),
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
                          'No pudimos cargar tus pedidos',
                          style: TextStyle(fontSize: 16, color: _darkGray, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Revisa tu conexión e intenta nuevamente',
                          style: TextStyle(fontSize: 14, color: _darkGray.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  );
                }

                final ordenes = snap.data ?? [];
                if (ordenes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 80, color: _accentPink),
                        const SizedBox(height: 16),
                        Text(
                          '¡Aún no tienes pedidos!',
                          style: TextStyle(fontSize: 18, color: _darkGray, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Haz tu primera orden y disfruta\nla mejor comida otaku',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: _darkGray.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ordenes.length,
                  itemBuilder: (_, i) {
                    final o = ordenes[i];
                    final estadoTxt = _mapEstado(o.estadoActualId, o.estadoNombre);
                    final estadoColor = _getEstadoColor(o.estadoActualId);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.pedidoDetalle,
                              arguments: o.id,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Pedido #${o.id}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: _darkGray,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: estadoColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        estadoTxt,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: estadoColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.schedule, size: 16, color: _darkGray.withOpacity(0.6)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Recojo: ${_fmtDt(o.pickupAt)}',
                                      style: TextStyle(fontSize: 13, color: _darkGray.withOpacity(0.8)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.monetization_on, size: 16, color: _primaryPink),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Total: S/. ${o.totalAmount}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: _primaryPink,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(Icons.chevron_right_rounded, color: _accentPink),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
