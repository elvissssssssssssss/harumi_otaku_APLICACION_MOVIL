import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/health_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _warmUpAndGo();
  }

  Future<void> _warmUpAndGo() async {
    try {
      // Warm-up (no importa si falla, solo es para despertar)
      await HealthService().ping();
    } catch (_) {}

    // Un pequeño delay opcional para que se vea el splash
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
