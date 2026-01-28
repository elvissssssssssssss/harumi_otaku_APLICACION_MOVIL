import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/cart_provider.dart';

import '../services/auth_service.dart';
import '../services/catalog_service.dart';
import '../services/cart_service.dart';

import '../routes/app_routes.dart';
import '../routes/app_router.dart';
import '../providers/checkout_provider.dart';
import '../services/order_service.dart';
import '../services/payment_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => CatalogProvider(CatalogService())),
        ChangeNotifierProvider(create: (_) => CartProvider(CartService())),
        ChangeNotifierProvider(create: (_) => CheckoutProvider(OrderService(), PaymentService())),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
