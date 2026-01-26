import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Mi cuenta')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _menuItem(context, 'Mis datos'),
            _menuItem(context, 'Direcciones de envío'),
            _menuItem(context, 'Mis compras', onTap: () {
              Navigator.pushNamed(context, AppRoutes.profileTracking);
            }),
            _menuItem(context, 'Ayuda'),
            const Spacer(),
            _menuItem(
              context,
              'Cerrar sesión',
              isDanger: true,
              onTap: () => _showLogoutDialog(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    String title, {
    VoidCallback? onTap,
    bool isDanger = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDanger ? Colors.red : Colors.black,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _logout(context);
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>(); // equivalente a listen:false [web:166]
    await auth.logout();

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}
