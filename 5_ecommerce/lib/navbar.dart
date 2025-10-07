import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavShell extends StatefulWidget {
  final Widget child;
  const AppNavShell({super.key, required this.child});

  @override
  State<AppNavShell> createState() => _AppNavShellState();
}

class _AppNavShellState extends State<AppNavShell> {
  int _currentIndex = 0;

  static const _accent = Color(0xFF134686);

  final List<String> _titles = const ['Home', 'Cart', 'Categories', 'Profile'];
  final List<String> _routes = const [
    '/home',
    '/cart',
    '/categories',
    '/profile',
  ];

  void _onTap(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
      context.go(_routes[index]);
    }
  }

  // Determine current index based on location
  int _calculateCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/cart')) return 1;
    if (location.startsWith('/categories')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0; // home or product details
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateCurrentIndex(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[currentIndex]),
        backgroundColor: _accent,
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: _accent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: _onTap,
      ),
    );
  }
}
