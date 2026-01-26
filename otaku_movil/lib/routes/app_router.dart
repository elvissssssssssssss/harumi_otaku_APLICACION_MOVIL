import 'package:flutter/material.dart';

import '../screens/auth/welcome_screen.dart';
import '../screens/auth/splash_screen.dart';
import 'app_routes.dart';
import '../screens/auth/login_screen.dart'; // <-- crea este archivo
// Importa tu CatalogoScreen real cuando lo tengas en su carpeta:
// import '../screens/catalog/catalogo_screen.dart';
import '../screens/auth/register_screen.dart';


class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

case AppRoutes.login:
  return MaterialPageRoute(
    builder: (_) => const LoginScreen(),
    settings: settings,
  );  
  case AppRoutes.register:
  return MaterialPageRoute(
    builder: (_) => const RegisterScreen(),
    settings: settings,
  );      
      case AppRoutes.welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );

      case AppRoutes.catalogo:
        // reemplaza esto por tu CatalogoScreen real
        return MaterialPageRoute(
          builder: (_) => const _CatalogoPlaceholder(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const _NotFoundScreen(),
          settings: settings,
        );
    }
  }
}

class _CatalogoPlaceholder extends StatelessWidget {
  const _CatalogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('CATÁLOGO (placeholder)')),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Ruta no encontrada')),
    );
  }
  
}
