import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isAuth = context.watch<AuthProvider>().isAuthenticated;
    if (!isAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = context.watch<AuthProvider>().isAuthenticated;
    if (!isAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return widget.child;
  }
}
