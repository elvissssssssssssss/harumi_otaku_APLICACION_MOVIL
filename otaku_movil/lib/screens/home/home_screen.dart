// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '/widgets/app_bar_menu.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    return Scaffold(
      appBar: const AppBarMenu(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner Principal
            _buildHeroBanner(context, screenWidth, screenHeight),
           
            // Sección de ofertas exclusivas
            _buildOffersSection(context),
           
            // Sección de novedades
            _buildNovedadesSection(context, screenWidth),
           
            // Sección de ayuda y footer
            _buildFooterSection(),
          ],
        ),
      ),
    );
  }


  Widget _buildHeroBanner(BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      height: screenHeight * 0.6,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade100,
            Colors.white,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Imagen de fondo
          // OPCIÓN 5: Usando FittedBox para mayor control
// OPCIÓN 7: Para dispositivos responsivos
// Imagen ocupando la parte superior, dejando espacio para el contenido
Positioned(
  top: 0,
  left: 0,
  right: 0,
  height: screenHeight * 0.72, // Ajusta este porcentaje según necesites
  child: Image.asset(
    'assets/images/imagen5.jpg',
    fit: BoxFit.cover,
  ),
),
         // Overlay con gradiente
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          // Contenido del banner
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               
                const SizedBox(height: 8),
                const Text(
                  'Nueva Temporada',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '*No se aplica a artículos seleccionados ni rebajas',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/categoria');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'COMPRAR AHORA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildOffersSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        children: [
          const Text(
            '¡Aprovecha nuestras ofertas exclusivas!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber.shade400,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text(
              'Envíos gratis en compras mayores a S/150',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNovedadesSection(BuildContext context, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¡NOVEDADES!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildImprovedGridItem(context, 'assets/images/casaca3.jpg', 'CASACA MUJER', 'mujer', 'casaca'),
              _buildImprovedGridItem(context, 'assets/images/casaca1.jpg', 'NOVEDADES MUJER', 'mujer', 'novedades'),
              _buildImprovedGridItem(context, 'assets/images/casacah.jpeg', 'CASACA HOMBRE', 'hombre', 'casaca'),
              _buildImprovedGridItem(context, 'assets/images/casacaho.jpg', 'NOVEDADES HOMBRE', 'hombre', 'novedades'),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildImprovedGridItem(BuildContext context, String imagePath, String categoria, String genero, String tipo) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/categoria',
          arguments: {
            'genero': genero,
            'tipo': tipo,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Imagen de fondo
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              // Overlay con gradiente mejorado
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              // Contenido de texto
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        categoria,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Ver más',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildFooterSection() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            '¿Necesitas ayuda?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Ingresa tu consulta',
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.all(16),
                suffixIcon: Icon(Icons.send_rounded, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Redes sociales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton('Facebook', Icons.facebook),
              _buildSocialButton('Instagram', Icons.camera_alt_rounded),
              _buildSocialButton('YouTube', Icons.play_circle_outline),
              _buildSocialButton('TikTok', Icons.music_note),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          // Políticas
          _buildPolicyLink('Política de cookies'),
          _buildPolicyLink('Política de privacidad'),
          _buildPolicyLink('Condiciones de compra'),
          const SizedBox(height: 20),
          Text(
            '© 2024 NTX Store. Todos los derechos reservados.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildSocialButton(String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }


  Widget _buildPolicyLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

