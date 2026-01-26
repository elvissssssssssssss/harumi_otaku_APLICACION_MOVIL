import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otaku_movil/core/styles/colors.dart';

class SplashScream extends StatefulWidget {
  const SplashScream({super.key});

  @override
  State<SplashScream> createState() => _SplashScreamState();
}

class _SplashScreamState extends State<SplashScream> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(width: double.maxFinite),
            Image.asset("assets/img/logoblanco.png", width: 240),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "login");
              },
              child: SizedBox(
                width: double.maxFinite,
                child: Text(
                  "Continuar con el Gmail",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 26),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "catalogo");
              },
              child: SizedBox(
                width: double.maxFinite,
                child: Text("Invitado", textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
