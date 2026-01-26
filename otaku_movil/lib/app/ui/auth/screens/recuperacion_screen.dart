import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:otaku_movil/core/styles/colors.dart';
//import 'package:otaku_movil/core/styles/texts.dart';

class RecuperacionScreen extends StatefulWidget {
  const RecuperacionScreen({super.key});

  @override
  State<RecuperacionScreen> createState() => _RecuperarContrasenaPageState();
}

class _RecuperarContrasenaPageState extends State<RecuperacionScreen> {
  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verifyPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Image.asset(
                'assets/img/secundario1.png', // <- reemplaza con tu imagen
                height: 100,
              ),
              const SizedBox(height: 10),
              const Text(
                "RECUPERACION DE\nCONTRASEÑA",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 25),

              // Campo: Nueva contraseña
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword1,
                  decoration: InputDecoration(
                    labelText: "NUEVA CONTRASEÑA:",
                    hintText: "ingresar nueva contraseña",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword1
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword1 = !_obscurePassword1;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Campo: Verificar contraseña
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _verifyPasswordController,
                  obscureText: _obscurePassword2,
                  decoration: InputDecoration(
                    labelText: "VERIFICAR CONTRASEÑA:",
                    hintText: "verificar nueva contraseña",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword2
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword2 = !_obscurePassword2;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botón guardar contraseña
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFf06292), // rosa
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
                onPressed: () {
                  // Lógica para guardar contraseña
                },
                child: const Text(
                  "guardar contraseña",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),

              const SizedBox(height: 30),

              // Imagen inferior (personajes)
              //Image.asset(
              //'assets/img/personajes.pn', // <- reemplaza con tu imagen
              // height: 120,
              //),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
