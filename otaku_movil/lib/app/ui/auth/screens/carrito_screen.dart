import 'package:flutter/material.dart';
import 'package:otaku_movil/app/domain/services/cart_service.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('', style: TextStyle(color: Colors.black)),
      ),
      body: AnimatedBuilder(
        animation: CartService(),
        builder: (context, child) {
          final cartItems = CartService().items;
          final total = CartService().total;

          return Column(
            children: [
              // Catálogo, carrito, pago header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHeaderItem(
                      Icons.inventory_2_outlined,
                      'Catálogo',
                      true,
                    ),
                    _buildHeaderItem(
                      Icons.shopping_cart_outlined,
                      'carrito',
                      true,
                    ),
                    _buildHeaderItem(Icons.payment_outlined, 'pago', false),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Lista de productos en el carrito
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lista de productos
                      Expanded(
                        child: cartItems.isEmpty
                            ? const Center(child: Text('El carrito está vacío'))
                            : ListView.builder(
                                itemCount: cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = cartItems[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${item['nombre']} x${item['quantity']}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '\$${(item['precio'] * item['quantity']).toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                CartService().removeItem(
                                                  item['nombre'],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Total
                      const Divider(),
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
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Opciones de pago
              _buildPaymentOption(
                'Yape',
                Colors.purple,
                Icons.payment,
                () => _selectPaymentMethod('Yape'),
              ),
              _buildPaymentOption(
                'Pin',
                Colors.cyan,
                Icons.credit_card,
                () => _selectPaymentMethod('Pin'),
              ),
              _buildPaymentOption(
                'Recojo en tienda',
                Colors.grey[800]!,
                Icons.store,
                () => _selectPaymentMethod('Recojo en tienda'),
              ),

              // Botón para agregar más productos
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Acción para agregar más productos
                    Navigator.pop(context); // Regresa al catálogo
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Agregar más productos',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderItem(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Icon(icon, color: isActive ? Colors.black : Colors.grey),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    String title,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _selectPaymentMethod(String method) {
    // Implementar la lógica para seleccionar el método de pago
    if (method == 'Recojo en tienda') {
      Navigator.pushNamed(context, 'recojo');
    } else if (method == 'Yape') {
      Navigator.pushNamed(context, 'yape');
    } else {
      Navigator.pushNamed(context, 'pago');
    }
  }
}
