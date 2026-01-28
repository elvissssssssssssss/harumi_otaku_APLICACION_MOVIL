import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';

import '../catalog/catalog_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';
import '../payment/yape_voucher_screen.dart';

class HomeShell extends StatefulWidget {
  final int initialTab;
  const HomeShell({super.key, this.initialTab = 0});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = context.watch<AuthProvider>().isAuthenticated;
    final cartProv = context.watch<CartProvider>();

    final hasItems = (cartProv.cart?.items ?? const []).isNotEmpty;

    final tabs = <Widget>[
      const CatalogScreen(),
      const CartScreen(),
      if (hasItems) const YapeVoucherScreen(),
      isAuth ? const ProfileScreen() : const _NeedLoginView(),
    ];

    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Catálogo'),
      const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Carrito'),
      if (hasItems) const BottomNavigationBarItem(icon: Icon(Icons.credit_card_outlined), label: 'Pago'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
    ];

    final maxIndex = tabs.length - 1;
    if (_index > maxIndex) _index = maxIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFF7EEF2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () => setState(() => _index = tabs.length - 1),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }
}

class _NeedLoginView extends StatelessWidget {
  const _NeedLoginView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Inicia sesión para ver tu perfil'));
  }
}
