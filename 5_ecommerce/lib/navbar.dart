import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Navbar extends StatelessWidget {
  final Widget child;
  final String location;
  const Navbar({super.key, required this.child, required this.location});

  int _locationToIndex(String location) {
    if (location.startsWith('/top-stories')) return 1;
    if (location.startsWith('/best-stories')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    const routes = ['/top-stories', '/best-stories'];
    final destination = routes[index];
    if (location != destination) {
      context.go(destination);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _locationToIndex(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fiber_new), label: 'New'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Top'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Best'),
        ],
      ),
    );
  }
}
