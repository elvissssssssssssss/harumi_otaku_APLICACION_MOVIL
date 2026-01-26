import 'package:flutter/material.dart';
import 'package:otaku_movil/app/domain/services/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:otaku_movil/core/styles/colors.dart';
import 'package:otaku_movil/core/styles/texts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secundary,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Image.asset("assets/img/secundario1.png", height: 150),
          Text("Bienvenido", style: Apptexts.h1),
          Stack(
            children: [
              Container(height: 260, color: Color(0xFFfbdce6)),
              PhysicalShape(
                clipper: UpperClipPath(),
                color: Colors.black,
                elevation: 6.0,
                shadowColor: const Color.fromARGB(255, 0, 0, 0),
                child: ClipPath(
                  clipper: UpperClipPath(),
                  child: Container(
                    height: 220,
                    color: Colors.white, //Colors.white,
                  ),
                ),
              ),
              ClipPath(
                clipper: LowerClipPath(),
                child: Container(height: 260, color: Color(0xFFfbdce6)),
              ),
              const SizedBox(height: 20),
              const _FormInputs(),
            ],
          ),

          Expanded(
            child: Container(
              color: Color(0xFFfbdce6),
              child: Column(
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Autenticar al usuario
                              final authService = AuthService();
                              authService.login();
                              Navigator.pushNamedAndRemoveUntil(
                                context, 
                                "catalogo", 
                                (route) => false
                              );
                            },
                            child: SizedBox(
                              width: 90,
                              child: Text("Acceso", textAlign: TextAlign.center),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "sesion");
                            },
                            child: SizedBox(
                              width: 90,
                              child: Text(
                                "Registrarse",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          // Navegar al catálogo como invitado
                          Navigator.pushNamedAndRemoveUntil(
                            context, 
                            "catalogo", 
                            (route) => false
                          );
                        },
                        child: const Text(
                          "Continuar como invitado",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, 'recuperacion');
                    },
                    child: const Text(
                      "¿SE OLVIDÓ SU CONTRASEÑA?",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormInputs extends StatelessWidget {
  const _FormInputs();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: "Email",
              prefixIcon: const Icon(Icons.email_outlined),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          child: TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Contraseña",
              prefixIcon: const Icon(Icons.lock_outline),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class UpperClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double mx = size.width;
    double my = size.height;
    var path = Path();
    path.lineTo(0, my);
    path.lineTo(mx - 60, 60);
    //path.lineTo(mx, 0);
    path.quadraticBezierTo(mx, 36, mx, 0);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class LowerClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double mx = size.width;
    double my = size.height;
    var path = Path();
    path.lineTo(0, my);
    path.lineTo(mx, my);
    path.lineTo(mx, 60);
    path.lineTo(60, my - 56);
    path.quadraticBezierTo(0, my - 36, 0, my);
    path.lineTo(0, my);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
