import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../routes/app_routes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _loadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedOnce) return;
    _loadedOnce = true;

    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated && auth.userId != null) {
      Future.microtask(() => context.read<CartProvider>().refresh(usuarioId: auth.userId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated || auth.userId == null) {
      return const _NeedLoginView();
    }

    return Consumer<CartProvider>(
      builder: (context, cartP, _) {
        final cart = cartP.cart;

        return Scaffold(
          backgroundColor: const Color(0xFFF7EEF2),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('Carrito', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                      ),
                      IconButton(
                        onPressed: cartP.loading ? null : () => cartP.refresh(usuarioId: auth.userId!),
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),

                if (cartP.loading) const LinearProgressIndicator(minHeight: 2),

                if (cartP.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Error: ${cartP.error}', style: const TextStyle(color: Colors.red)),
                  ),

                Expanded(
                  child: (cart == null || cart.items.isEmpty)
                      ? const Center(child: Text('Tu carrito está vacío'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          itemCount: cart.items.length,
                          itemBuilder: (context, i) {
                            final item = cart.items[i];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 6),
                                        Text('S/.${item.precioUnitario.toStringAsFixed(2)} c/u'),
                                        const SizedBox(height: 6),
                                        Text('Subtotal: S/.${item.subtotal.toStringAsFixed(2)}',
                                            style: const TextStyle(fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: cartP.loading
                                            ? null
                                            : () async {
                                                final newQty = item.cantidad - 1;
                                                if (newQty <= 0) {
                                                  await context.read<CartProvider>().remove(
                                                        usuarioId: auth.userId!,
                                                        itemId: item.itemId,
                                                      );
                                                  return;
                                                }
                                                await context.read<CartProvider>().setCantidad(
                                                      usuarioId: auth.userId!,
                                                      itemId: item.itemId,
                                                      cantidad: newQty,
                                                    );
                                              },
                                        icon: const Icon(Icons.remove_circle_outline),
                                      ),
                                      Text('${item.cantidad}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                      IconButton(
                                        onPressed: cartP.loading
                                            ? null
                                            : () async {
                                                final newQty = item.cantidad + 1;
                                                await context.read<CartProvider>().setCantidad(
                                                      usuarioId: auth.userId!,
                                                      itemId: item.itemId,
                                                      cantidad: newQty,
                                                    );
                                              },
                                        icon: const Icon(Icons.add_circle_outline),
                                      ),
                                      IconButton(
                                        onPressed: cartP.loading
                                            ? null
                                            : () => context.read<CartProvider>().remove(
                                                  usuarioId: auth.userId!,
                                                  itemId: item.itemId,
                                                ),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                if (cart != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(child: Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                            Text('S/.${cart.total.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
  width: double.infinity,
  height: 52,
  child: ElevatedButton(
    onPressed: (cart.items.isEmpty || cartP.loading)
        ? null
        : () {
            Navigator.pushNamed(context, AppRoutes.checkout);
          },
    child: const Text('Continuar a pago'),
  ),
),

                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NeedLoginView extends StatelessWidget {
  const _NeedLoginView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Inicia sesión para ver tu carrito'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              child: const Text('Ir a login'),
            ),
          ],
        ),
      ),
    );
  }
}
