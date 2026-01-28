import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

import '../screens/auth/splash_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

import '../screens/home/home_shell.dart';
import '../screens/catalog/product_detail_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/payment/yape_voucher_screen.dart';
import '../screens/payment/pendiente_validacion_screen.dart';
import '../screens/orders/mis_pedidos_screen.dart';
import '../screens/orders/pedido_detalle_screen.dart';
import '../screens/profile/profile_tracking_screen.dart'; // NUEVO


class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen(), settings: settings);

      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen(), settings: settings);

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen(), settings: settings);

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen(), settings: settings);

      case AppRoutes.home:
        final args = (settings.arguments as Map?) ?? {};
        final initialTab = (args['tab'] as int?) ?? 0; // 0=catalogo,1=carrito,2=pago,3=perfil
        return MaterialPageRoute(
          builder: (_) => HomeShell(initialTab: initialTab),
          settings: settings,
        );

      case AppRoutes.productDetail:
        final productId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: productId),
          settings: settings,
        );
case AppRoutes.pendienteValidacion:
  return MaterialPageRoute(
    builder: (_) => const PendienteValidacionScreen(),
    settings: settings,
  );

 case AppRoutes.misPedidos:
        return MaterialPageRoute(
          builder: (_) => const MisPedidosScreen(),
          settings: settings,
        );

      case AppRoutes.pedidoDetalle:
        final ordenId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => PedidoDetalleScreen(ordenId: ordenId),
          settings: settings,
        );
case AppRoutes.profileTracking:
  return MaterialPageRoute(
    builder: (_) => const ProfileTrackingScreen(),
    settings: settings,
  );


      case AppRoutes.cart:
        return MaterialPageRoute(builder: (_) => const CartScreen(), settings: settings);

      case AppRoutes.checkout:
        return MaterialPageRoute(builder: (_) => const YapeVoucherScreen(), settings: settings);

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
          settings: settings,
        );
    }
  }
}
