import 'package:flutter/material.dart';
import 'package:otaku_movil/app/domain/services/auth_service.dart';

class DetallePlatilloScreen extends StatelessWidget {
  final Map<String, dynamic> producto;

  const DetallePlatilloScreen({super.key, required this.producto});

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
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del platillo
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Detalle del platillo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            // Imagen del platillo
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(producto['imagen']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Nombre del platillo
            Center(
              child: Text(producto['nombre'], style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),

            // Descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Descripción',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'El ramen de cerdo, conocido como Tonkotsu Ramen, es una sopa japonesa hecha con un caldo potente y cremoso elaborado a base de huesos de cerdo cocidos por horas. Se caracteriza por su textura rica, sabor intenso y normalmente se sirve con fideos delgados, chashu (cerdo asado), huevo ajitama y vegetales.',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),

            // Ingredientes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Ingredientes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIngredienteItem('Huesos de cerdo'),
                  _buildIngredienteItem(
                    'Panceta de cerdo - chashu tierno y jugoso',
                  ),
                  _buildIngredienteItem(
                    'Fideos ramen - de trigo, delgados y firmes',
                  ),
                  _buildIngredienteItem('Agua mineral de calidad'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botón flotante de agregar al carrito
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Verificar si el usuario está autenticado
                      final authService = AuthService();
                      if (await authService.checkLoginAndRedirect(context)) {
                        // Si está autenticado, navegar al carrito
                        Navigator.pushNamed(context, 'carrito');
                      }
                      // Si no está autenticado, checkLoginAndRedirect ya redirigió a login
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      side: const BorderSide(color: Colors.purple, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'AGREGAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredienteItem(String ingrediente) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(ingrediente, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
