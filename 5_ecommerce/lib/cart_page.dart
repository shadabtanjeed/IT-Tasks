import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No top AppBar here; the shell provides it. Keep consistent styling in body.
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.shopping_cart, size: 64, color: Color(0xFF134686)),
            SizedBox(height: 12),
            Text('Your cart is empty', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
