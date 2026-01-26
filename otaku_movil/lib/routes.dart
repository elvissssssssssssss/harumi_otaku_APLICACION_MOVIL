import 'package:flutter/material.dart';
import 'package:otaku_movil/app/ui/auth/screens/carrito_screen.dart';
import 'package:otaku_movil/app/ui/auth/screens/catalogo_screen.dart';
import 'package:otaku_movil/app/ui/auth/screens/detalle_platillo_screen.dart';
import 'package:otaku_movil/app/ui/auth/screens/login_screen.dart';
import 'package:otaku_movil/app/ui/auth/screens/pago_screen.dart';
import 'package:otaku_movil/app/ui/auth/screens/recojo_screen.dart';
import 'package:otaku_movil/app/ui/auth/screens/recuperacion_screen.dart';
import 'package:otaku_movil/app/ui/auth/screens/sesion_screen.dart';
import 'package:otaku_movil/app/ui/auth/screens/yape_screen.dart';
import 'package:otaku_movil/app/ui/auth/screens/yape_confirmacion_screen.dart';
import 'package:otaku_movil/app/ui/splash/screens/splash_scream.dart';

Map<String, Widget Function(BuildContext _)> routes = {
  "splash": (_) => SplashScream(),
  "login": (_) => LoginScreen(),
  "sesion": (_) => SesionScreen(),
  "recuperacion": (_) => RecuperacionScreen(),
  "catalogo": (_) => CatalogoScreen(),
  "carrito": (_) => CarritoScreen(),
  "pago": (_) => PagoScreen(),
  "recojo": (_) => RecojoScreen(),
  "yape": (_) => YapeScreen(),
  "yape_confirmacion": (_) => YapeConfirmacionScreen(),
};
