import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '/routes/app_routes.dart';

// Banner animado
class DiscountBannerRotativo extends StatefulWidget {
  const DiscountBannerRotativo({Key? key}) : super(key: key);

  @override
  State<DiscountBannerRotativo> createState() => _DiscountBannerRotativoState();
}

class _DiscountBannerRotativoState extends State<DiscountBannerRotativo> with SingleTickerProviderStateMixin {
  final List<String> mensajes = [
    '¡50% de descuento!',
    '¡Envío gratis!',
    'Hacemos envíos a todo el Perú',
  ];
  int _index = 0;
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 500), _nextMessage);
  }

  void _nextMessage() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    await _controller.reverse();
    setState(() {
      _index = (_index + 1) % mensajes.length;
    });
    await _controller.forward();
    _nextMessage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(0),
      ),
      child: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Text(
            mensajes[_index],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

// Badge de carrito
class CartIconBadge extends StatelessWidget {
  final VoidCallback onTap;
  final bool selected;

  const CartIconBadge({Key? key, required this.onTap, this.selected = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().items.length;
    final color = selected ? Colors.red : Colors.black87;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart_outlined, color: color, size: 28),
                const SizedBox(height: 1),
                Text(
                  'Carrito',
                  style: TextStyle(
                    color: color,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (cartCount > 0)
              Positioned(
                top: -2,
                right: -7,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent[700],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 16),
                  child: Text(
                    cartCount > 99 ? '99+' : cartCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// AppBar con acciones personalizadas y badge de carrito
class AppBarMenu extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex; // 0: search, 1: perfil, 2: favoritos, 3: carrito

  const AppBarMenu({Key? key, this.selectedIndex = -1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: preferredSize.height,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const DiscountBannerRotativo(),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Row(
                  children: [
                    _buildLogo(context),
                    const Spacer(),
                    ..._buildAppBarActions(context, authProvider),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.home),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 3) , 
        
        child: Image.asset(
          'assets/images/logo.png',
          width: 110,
          height: 60,

          fit: BoxFit.contain,
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context, AuthProvider authProvider) {
    return [
      // Búsqueda
      _AppBarIcon(
        icon: Icons.search,
        label: 'Buscar',
        selected: selectedIndex == 0,
        onTap: () => Navigator.pushNamed(context, AppRoutes.search),
      ),
      // Perfil
      _AppBarIcon(
        icon: selectedIndex == 1 ? Icons.account_circle : Icons.account_circle_outlined,
        label: 'Tú',
        selected: selectedIndex == 1,
        onTap: () => _handleProfileAction(context, authProvider),
      ),
      // Favoritos
      _AppBarIcon(
        icon: selectedIndex == 2 ? Icons.favorite : Icons.favorite_border,
        label: 'Favoritos',
        selected: selectedIndex == 2,
        onTap: () => _handleFavoritesAction(context, authProvider),
      ),
      // Carrito (badge)
      CartIconBadge(
        onTap: () => _handleCartAction(context, authProvider),
        selected: selectedIndex == 3,
      ),
    ];
  }

  void _handleProfileAction(BuildContext context, AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      Navigator.pushNamed(context, AppRoutes.profile);
    } else {
      Navigator.pushNamed(context, AppRoutes.login)
          .then((_) => authProvider.autoLogin());
    }
  }

  void _handleFavoritesAction(BuildContext context, AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      Navigator.pushNamed(context, AppRoutes.favoritos);
    } else {
      Navigator.pushNamed(context, AppRoutes.login)
          .then((_) => authProvider.autoLogin());
    }
  }

  void _handleCartAction(BuildContext context, AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      Navigator.pushNamed(context, AppRoutes.carrito);
    } else {
      Navigator.pushNamed(context, AppRoutes.login)
          .then((_) => authProvider.autoLogin());
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(98);
}

// Icono personalizado para la AppBar con texto debajo
class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AppBarIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.red : Colors.black87;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            if (label.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                    decoration: selected ? TextDecoration.underline : TextDecoration.none,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

