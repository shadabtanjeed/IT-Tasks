import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    // Clear cart from shared preferences
    await Provider.of<CartProvider>(context, listen: false).clearCart();
    // Sign out from Supabase
    await Supabase.instance.client.auth.signOut();
    // navigate to login route after sign out
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFF134686),
                child: Text(
                  (user?.userMetadata?['username'] ?? user?.email ?? 'U')
                      .toString()
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user?.userMetadata?['username'] ?? user?.email ?? 'User',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF134686),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.email),
                title: Text(user?.email ?? 'No email'),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(
                  Icons.shopping_bag,
                  color: Color(0xFF134686),
                ),
                title: const Text('Order History'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/order-history'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF134686),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Logout'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
