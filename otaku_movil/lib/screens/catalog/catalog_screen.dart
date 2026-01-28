import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';

import '../../models/categoria.dart';
import '../../models/producto.dart';

import '../../routes/app_routes.dart';
import '../../utils/url_utils.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (context, p, _) {
        if (!p.loading && p.error == null && p.categorias.isEmpty && p.productos.isEmpty) {
          Future.microtask(() => context.read<CatalogProvider>().init());
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF7EEF2),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: DropdownButtonFormField<Categoria>(
                    value: p.categoriaSeleccionada,
                    items: p.categorias
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.nombre.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: p.loading
                        ? null
                        : (c) {
                            if (c == null) return;
                            context.read<CatalogProvider>().seleccionarCategoria(c);
                          },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),

                if (p.loading) const LinearProgressIndicator(minHeight: 2),

                if (p.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Error: ${p.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: p.productos.length,
                    itemBuilder: (context, index) {
                      final prod = p.productos[index];

                      return _ProductoItem(
                        producto: prod,
                        onAdd: () async {
                          final auth = context.read<AuthProvider>();

                          if (!auth.isAuthenticated || auth.userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Inicia sesión para agregar al carrito')),
                            );
                            Navigator.pushNamed(context, AppRoutes.login);
                            return;
                          }

                          await context.read<CartProvider>().add(
                                usuarioId: auth.userId!,
                                productoId: prod.id,
                                cantidad: 1,
                              );

                          final cartError = context.read<CartProvider>().error;
                          if (cartError != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error carrito: $cartError')),
                            );
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Agregado al carrito: ${prod.nombre}')),
                          );

                          // Opcional: ir al tab Carrito en tu HomeShell (si lo manejas por initialTab)
                          Navigator.pushNamed(context, AppRoutes.home, arguments: {'tab': 1});
                        },
                        onOpen: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.productDetail,
                            arguments: prod.id,
                          );
                        },
                      );
                    },
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

class _ProductoItem extends StatelessWidget {
  final Producto producto;
  final VoidCallback onAdd;
  final VoidCallback onOpen;

  const _ProductoItem({
    required this.producto,
    required this.onAdd,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final url = FileUrlHelper.getImageUrl(producto.fotoUrl);

    if (url.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: Center(child: Icon(Icons.image_not_supported_outlined)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(producto.nombre,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('S/.${producto.precio.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: onAdd,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF7E3FF2), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text(
                'AGREGAR',
                style: TextStyle(color: Color(0xFF7E3FF2), fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: onOpen,
              icon: const Icon(Icons.arrow_forward_ios, size: 18),
            ),
          ],
        ),
      );
    }

    final img = Image.network(
      url,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const SizedBox(
        width: 56,
        height: 56,
        child: Center(child: Icon(Icons.image_not_supported_outlined)),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          InkWell(
            onTap: onOpen,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: img,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.nombre,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('S/.${producto.precio.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onAdd,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF7E3FF2), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text(
              'AGREGAR',
              style: TextStyle(color: Color(0xFF7E3FF2), fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: onOpen,
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
          ),
        ],
      ),
    );
  }
}
