  // ====================================
  // lib/main.dart - VERSIÓN ACTUALIZADA
  // ====================================
  // lib/main.dart
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'providers/cart_provider.dart';
  import 'providers/auth_provider.dart';
  import 'routes/app_routes.dart';
  import 'providers/producto_provider.dart';
  import 'providers/shipping_provider.dart'; // Nuevo import
  import 'providers/seguimiento_provider.dart'; // Nuevo import para TrackingProvider




  // lib/main.dart
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    final authProvider = AuthProvider();
    await authProvider.autoLogin(); // Cargar sesión existente
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider), // AuthProvider
          ChangeNotifierProvider(create: (_) => CartProvider()), // Otros providers
          ChangeNotifierProvider(create: (_) => ProductoProvider()), // ProductoProvider
          ChangeNotifierProvider(create: (_) => ShippingProvider()), // Nuevo provider
           ChangeNotifierProvider(create: (_) => TrackingProvider()), // TrackingProvider agregado
        ],
        child: const MyApp(),
      ),
    );
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Mi Tienda',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.home,
        routes: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
      );
    }
  }