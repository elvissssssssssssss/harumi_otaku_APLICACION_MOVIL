import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otaku_movil/core/styles/colors.dart';
import 'package:otaku_movil/core/styles/texts.dart';

class SesionScreen extends StatefulWidget {
  const SesionScreen({super.key});

  @override
  State<SesionScreen> createState() => _SesionScreenState();
}

class _SesionScreenState extends State<SesionScreen> {
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
          Text("Registro", style: Apptexts.h1),
          TextFormField(
            style: const TextStyle(fontSize: 20),
            decoration: const InputDecoration(
              hintText: "Nombre",
              prefixIcon: const Icon(Icons.person_outline),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
          ),
          TextFormField(
            style: const TextStyle(fontSize: 20),
            decoration: const InputDecoration(
              hintText: "Email",
              prefixIcon: const Icon(Icons.email_outlined),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
          ),
          TextFormField(
            style: const TextStyle(fontSize: 20),
            decoration: const InputDecoration(
              hintText: "Contraseña",
              prefixIcon: const Icon(Icons.lock_outline),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
          ),
          TextFormField(
            style: const TextStyle(fontSize: 20),
            decoration: const InputDecoration(
              hintText: "Repetir contraseña",
              prefixIcon: const Icon(Icons.lock_outline),

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
          ),
          Stack(
            children: [
              Container(height: 260, color: Color(0xFFe69c9b)),
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
            ],
          ),

          Expanded(
            child: Container(
              color: Color(0xFFfbdce6),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "catalogo");
                        },
                        child: SizedBox(
                          width: 90,
                          child: Text("Ingresar", textAlign: TextAlign.center),
                        ),
                      ),
                    ],
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
