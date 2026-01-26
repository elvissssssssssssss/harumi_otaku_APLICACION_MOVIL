import 'package:flutter/material.dart';
//import 'package:otaku_movil/core/styles/colors.dart';
import 'package:otaku_movil/app/ui/auth/screens/detalle_platillo_screen.dart';
import 'package:otaku_movil/app/domain/services/auth_service.dart';
import 'package:otaku_movil/app/domain/services/cart_service.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  // Mapa de productos por categoría
  final Map<String, List<Map<String, dynamic>>> _allProducts = {
    'RAMEN': [
      {
        'nombre': 'Ramen de cerdo',
        'precio': 15.00,
        'imagen': 'assets/img/ramen/ramendecerdo.png',
      },
      {
        'nombre': 'Ramen de pollo',
        'precio': 15.00,
        'imagen': 'assets/img/ramen/shin.png',
      },
      {
        'nombre': 'Ramen de Ramion',
        'precio': 8.00,
        'imagen': 'assets/img/ramen/neoguri.png',
      },
      {
        'nombre': 'Bibimpap',
        'precio': 13.00,
        'imagen': 'assets/img/ramen/chapagetti.png',
      },
      {
        'nombre': 'Ramen Naruto',
        'precio': 25.00,
        'imagen': 'assets/img/ramen/chapagetti.png',
      },
      {
        'nombre': 'Ramen Goku',
        'precio': 30.00,
        'imagen': 'assets/img/ramen/chapagetti.png',
      },
    ],
    'MOCHIS': [
      {
        'nombre': 'Mochi de Fresa',
        'precio': 5.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
      {
        'nombre': 'Mochi de Té Verde',
        'precio': 6.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
      {
        'nombre': 'Mochi de Mango',
        'precio': 5.50,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
    ],
    'ESPECIALIDADES': [
      {
        'nombre': 'Kibimpap',
        'precio': 15.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
      {
        'nombre': 'Pollo Frito Coreano',
        'precio': 20.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
      {
        'nombre': 'Muslito Luffy',
        'precio': 20.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
      {
        'nombre': 'Tooboki',
        'precio': 20.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
      {
        'nombre': 'Tonkatsu',
        'precio': 20.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
    ],
    // Puedes agregar más categorías aquí
    'BEBIDAS': [
      {
        'nombre': 'Bebidas alcohólicas',
        'imagen': 'assets/img/logo.png', // Placeholder
        'isSubcategory': true,
        'precio': 0.0,
        'products': [
          {
            'nombre': 'Soju Original',
            'precio': 12.00,
            'imagen': 'assets/img/logo.png',
          },
          {
            'nombre': 'Sake Premium',
            'precio': 25.00,
            'imagen': 'assets/img/logo.png',
          },
          {
            'nombre': 'Cerveza Asahi',
            'precio': 8.00,
            'imagen': 'assets/img/logo.png',
          },
        ],
      },
      {
        'nombre': 'Bebidas tradicionales',
        'imagen': 'assets/img/logo.png', // Placeholder
        'isSubcategory': true,
        'precio': 0.0,
        'products': [
          {
            'nombre': 'Té Matcha Ceremonial',
            'precio': 15.00,
            'imagen': 'assets/img/logo.png',
          },
          {
            'nombre': 'Té Oolong',
            'precio': 6.00,
            'imagen': 'assets/img/logo.png',
          },
        ],
      },
      {
        'nombre': 'Bebidas modernas',
        'imagen': 'assets/img/logo.png', // Placeholder
        'isSubcategory': true,
        'precio': 0.0,
        'products': [
          {
            'nombre': 'BubleTea Fresa',
            'precio': 10.00,
            'imagen': 'assets/img/logo.png',
          },
          {
            'nombre': 'BubleTea Arándano',
            'precio': 10.00,
            'imagen': 'assets/img/logo.png',
          },
          {
            'nombre': 'BubleTea Café',
            'precio': 10.00,
            'imagen': 'assets/img/logo.png',
          },
          {
            'nombre': 'Milk Tea Taro',
            'precio': 11.00,
            'imagen': 'assets/img/logo.png',
          },
        ],
      },
      {
        'nombre': 'Refrescos',
        'imagen': 'assets/img/logo.png', // Placeholder
        'isSubcategory': true,
        'precio': 0.0,
        'products': [
          {
            'nombre': 'Ramune Fresa',
            'precio': 5.00,
            'imagen': 'assets/img/logo.png',
          },
          {'nombre': 'Calpis', 'precio': 4.50, 'imagen': 'assets/img/logo.png'},
          {
            'nombre': 'Coca Cola',
            'precio': 3.00,
            'imagen': 'assets/img/logo.png',
          },
        ],
      },
    ],
    'HELADOS': [
      {
        'nombre': 'Helado de Matcha',
        'precio': 5.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
      {
        'nombre': 'Helado de Vainilla',
        'precio': 4.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
    ],
    'CORN DOGS': [
      {
        'nombre': 'Corn dogs de Pollo',
        'precio': 15.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
      {
        'nombre': 'Corn dogs de Chancho',
        'precio': 15.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
      {
        'nombre': 'Corn dogs Clásico',
        'precio': 15.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
      {
        'nombre': 'Corn dogs de Ramen',
        'precio': 15.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
      {
        'nombre': 'Corn dogs de Papas',
        'precio': 15.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
    ],
    'COMBOS': [
      {
        'nombre': 'Corn Dog Takis Fuego + Bebida',
        'precio': 10.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
      {
        'nombre': 'Corn Dog Shettos Picante + Bebida',
        'precio': 10.00,
        'imagen': 'assets/img/logo.png', // Placeholder
      },
    ],
  };

  String _categoriaSeleccionada = 'RAMEN';

  List<Map<String, dynamic>>? _subProductos;
  String? _tituloSubCategoria;

  List<Map<String, dynamic>> get _productos =>
      _subProductos ?? (_allProducts[_categoriaSeleccionada] ?? []);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEE8F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_subProductos != null) {
              setState(() {
                _subProductos = null;
                _tituloSubCategoria = null;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: _tituloSubCategoria != null
            ? Text(
                _tituloSubCategoria!,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de navegación superior
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.category_outlined, 'Catálogo', true),
                _buildNavItem(Icons.shopping_cart_outlined, 'carrito', false),
                _buildNavItem(Icons.payment_outlined, 'pago', false),
              ],
            ),
          ),

          // Dropdown para seleccionar categoría
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<String>(
                value: _categoriaSeleccionada,
                isExpanded: true,
                underline: Container(),
                icon: const Icon(Icons.arrow_drop_down),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                items:
                    <String>[
                      'RAMEN',
                      'BEBIDAS',
                      'HELADOS',
                      'COMBOS',
                      'CORN DOGS',
                      'MOCHIS',
                      'ESPECIALIDADES',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _categoriaSeleccionada = newValue;
                    });
                  }
                },
              ),
            ),
          ),

          // Etiqueta "DEMO" en la esquina
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: const Text(
                'DEMO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Lista de productos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _productos.length,
              itemBuilder: (context, index) {
                final producto = _productos[index];

                // Layout para subcategorías (como BEBIDAS)
                if (producto['isSubcategory'] == true) {
                  return GestureDetector(
                    onTap: () {
                      if (producto['products'] != null) {
                        setState(() {
                          _subProductos = producto['products'];
                          _tituloSubCategoria = producto['nombre'];
                        });
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          // Imagen
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(producto['imagen']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Información (Nombre y "ver mas")
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  producto['nombre'],
                                  style: const TextStyle(fontSize: 18),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'ver mas',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Flecha
                          const Icon(
                            Icons.play_arrow,
                            size: 24,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  );
                }

                // Layout normal para productos
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      // Imagen del producto
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(producto['imagen']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Información del producto
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto['nombre'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'S/.${producto['precio'].toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botón de agregar
                      ElevatedButton(
                        onPressed: () async {
                          // Verificar si el usuario está autenticado
                          final authService = AuthService();
                          if (await authService.checkLoginAndRedirect(
                            context,
                          )) {
                            // Agregar al carrito
                            CartService().addItem(producto);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${producto['nombre']} agregado al carrito',
                                ),
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'VER CARRITO',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    Navigator.pushNamed(context, 'carrito');
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          side: const BorderSide(
                            color: Colors.purple,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('AGREGAR'),
                      ),
                      // Flecha para ver detalles
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          // Navegar a la pantalla de detalle del platillo
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetallePlatilloScreen(producto: producto),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (label == 'carrito') {
          Navigator.pushNamed(context, 'carrito');
        } else if (label == 'pago') {
          // Navigator.pushNamed(context, 'pago');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.black : Colors.grey, size: 24),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
