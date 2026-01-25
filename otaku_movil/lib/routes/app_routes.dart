// lib/routes/app_routes.dart - VERSIÓN CON MEJORAS OPCIONALES
import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/categoria/categoria_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/favoritos/favoritos_screen.dart';
import '../screens/producto/producto_detalle_screen.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/payment/payment_methods_screen.dart';
import '../screens/perfil/seguimiento/profile_seguimiento_screen.dart';
import '../screens/busqueda/search_screen.dart';


class AppRoutes {
  // Constantes para las rutas (evita errores de tipeo)
  static const String home = '/';
  static const String homeAlternative = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String categoria = '/categoria';
  static const String carrito = '/carrito';
  static const String favoritos = '/favoritos';
  static const String productoDetalle = '/producto-detalle';
  static const payment = '/payment';
  static const paymentMethods = '/metodos-pago';
  static const String profileTracking = '/profile/seguimiento';
  static const String search = '/search'; 
  


  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeScreen(),
      homeAlternative: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      profile: (context) => const ProfileScreen(),
      categoria: (context) => const CategoriaScreen(),
      carrito: (context) => const CartScreen(),
      favoritos: (context) => const FavoritosScreen(),
      
      payment: (_) => const PaymentScreen(),
      paymentMethods: (context) => const PaymentMethodsScreen(),
      profileTracking: (context) => const ProfileTrackingScreen(),
      search: (context) => const SearchScreen(),
      // Agrega más rutas según necesites
    };
  }

  // Método para navegar (opcional)
  static void navigateTo(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  // Método para navegar y reemplazar (opcional)
  static void navigateAndReplace(BuildContext context, String route) {
    Navigator.pushReplacementNamed(context, route);
  }
}