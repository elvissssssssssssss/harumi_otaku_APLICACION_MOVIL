
  // ====================================
  // 5. lib/screens/cart/cart_screen.dart
  // ====================================
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../../providers/cart_provider.dart';
  import '../../models/cart_item.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../../services/cart_service.dart';





  class CartScreen extends StatelessWidget {
    const CartScreen({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('Carrito de Compras'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/favoritos');
              },
              icon: const Icon(Icons.favorite_border),
            ),
          ],
        ),
        body: Consumer<CartProvider>(
          builder: (context, cart, child) {
            if (cart.items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tu carrito está vacío',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Agrega productos para comenzar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _buildCartItem(context, item, cart);
                    },
                  ),
                ),
                _buildCartSummary(context, cart),
              ],
            );
          },
        ),
      );
    }

 Widget _buildCartItem(BuildContext context, CartItem item, CartProvider cart) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(item.imagen),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // INFO PRODUCTO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Talla: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      item.talla,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'S/${item.precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 40, 40, 41),
                  ),
                ),
              ],
            ),
          ),
          // QUANTITY Y BOTONES
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.remove, size: 18, color: Colors.black54),
                    ),
                    onTap: () {
                      if (item.cantidad > 1) {
                        cart.updateQuantity(item.id, item.talla, item.cantidad - 1);
                      }
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[100],
                    ),
                    child: Text(
                      '${item.cantidad}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.add, size: 18, color: Colors.black54),
                    ),
                    onTap: () {
                      if (item.cantidad < 1) {
                        cart.updateQuantity(item.id, item.talla, item.cantidad + 1);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Solo puedes agregar 1 unidad.'),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 95, 95, 95),
                      backgroundColor: const Color.fromARGB(255, 247, 247, 247),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      if (item.cartItemId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ID del item no disponible')),
                        );
                        return;
                      }
                      final success = await CartService().updateCartItemQuantity(
                        item.cartItemId!, item.cantidad,
                      );
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cantidad actualizada'), backgroundColor: Colors.green),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error al actualizar'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text('Actualizar'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getInt('user_id');
                      if (userId != null) {
                        await cart.clearCartFromServer(userId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Producto(s) eliminados del carrito')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usuario no identificado')),
                        );
                      }
                    },
                    child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


    Widget _buildCartSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'S/ ${cart.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
              final userId = prefs.getInt('user_id'); // ✅

        

                if (userId != null && userId > 0) {
                  Navigator.pushNamed(
                    context,
                    '/payment',
                    arguments: {
                      'total': cart.total,
                      'items': cart.items,
                    },
                  );
                } else {
                  Navigator.pushNamed(context, '/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Empezar a comprar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }}

