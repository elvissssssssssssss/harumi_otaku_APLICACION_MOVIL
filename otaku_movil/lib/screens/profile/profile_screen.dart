// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bar_menu.dart';
import '/routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Verificación de autenticación
    if (!authProvider.isAuthenticated) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppBarMenu(),
      body: _buildProfileContent(context), // Pasar el contexto aquí
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'mi cuenta',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Column(
              children: [
                _buildMenuItem('mis datos', context),
                _buildMenuItem('direcciones de envío', context),
                _buildMenuItem('mis compras', context),
                _buildMenuItem('puntua esta app', context),
                _buildMenuItem('recomienda esta app', context),
                _buildMenuItem('ayuda', context),
                _buildMenuItem('cerrar sesión', context, isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, BuildContext context, {bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.grey[300]! : Colors.transparent,
            width: isLast ? 1.0 : 0,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () => _handleMenuItemTap(title, context),
      ),
    );
  }

  void _handleMenuItemTap(String title, BuildContext context) {
  switch (title) {
    case 'cerrar sesión':
      _showLogoutDialog(context);
      break;
    case 'mis compras':
      Navigator.pushNamed(context, AppRoutes.profileTracking);
      break;
      // Agrega más casos según necesites
      default:
        // Acción por defecto o nada
        break;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(fontSize: 18),
          ),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    // Redirige al login y limpia el stack de navegación
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
    
    // Mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Has cerrado sesión correctamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}