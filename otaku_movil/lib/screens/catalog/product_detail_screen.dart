import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/producto.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/catalog_service.dart';
import '../../utils/url_utils.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final Future<Producto> _future;

  @override
  void initState() {
    super.initState();
    _future = CatalogService().getProductoById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    final cartP = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFDEBED),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Producto>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final p = snap.data!;
          final imgUrl = FileUrlHelper.getImageUrl(p.fotoUrl);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                const Text(
                  'Detalle del platillo',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      imgUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        height: 200,
                        child: Center(
                          child: Icon(Icons.image_not_supported_outlined, size: 40),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    p.nombre,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'S/.${p.precio.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Descripción',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  p.descripcion,
                  style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: cartP.loading
                        ? null
                        : () async {
                            final sm = ScaffoldMessenger.of(context);
                            final auth = context.read<AuthProvider>();

                            if (!auth.isAuthenticated || auth.userId == null) {
                              sm.showSnackBar(
                                const SnackBar(content: Text('Inicia sesión para agregar al carrito')),
                              );
                              Navigator.pushNamed(context, AppRoutes.login);
                              return;
                            }

                            await context.read<CartProvider>().add(
                                  usuarioId: auth.userId!,
                                  productoId: p.id,
                                  cantidad: 1,
                                );

                            final err = context.read<CartProvider>().error;
                            if (err != null) {
                              sm.showSnackBar(SnackBar(content: Text('Error: $err')));
                              return;
                            }

                            sm.showSnackBar(
                              SnackBar(content: Text('Agregado al carrito: ${p.nombre}')),
                            );

                            // Opcional: ir al tab carrito
                             Navigator.pushNamed(context, AppRoutes.home, arguments: {'tab': 1});
                          },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.purple, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      cartP.loading ? 'AGREGANDO...' : 'AGREGAR',
                      style: const TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
