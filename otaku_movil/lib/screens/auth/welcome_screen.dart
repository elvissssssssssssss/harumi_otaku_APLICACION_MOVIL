import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE91E63),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/logoblanco.png',
              height: 200,
            ),
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google login pendiente')),
                    );  
                  },
                  child: const Text('Continuar con el Gmail'),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Ir como invitado
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.catalogo,
                      (route) => false,
                    );
                  },
                  child: const Text('Invitado'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
