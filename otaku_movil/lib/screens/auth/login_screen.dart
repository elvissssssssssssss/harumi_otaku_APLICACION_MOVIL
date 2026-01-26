import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EEF2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Image.asset('assets/img/secundario1.png', height: 140),
            const SizedBox(height: 10),
            const Text(
              'Bienvenido',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                hintText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                    },
                    child: const Text('Acceso'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: const Text('Registrarse'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // TODO: continuar como invitado -> catalogo
              },
              child: const Text('Continuar como invitado'),
            ),
            GestureDetector(
              onTap: () {
                // TODO: recuperar contraseña
              },
              child: const Text(
                '¿SE OLVIDÓ SU CONTRASEÑA?',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
