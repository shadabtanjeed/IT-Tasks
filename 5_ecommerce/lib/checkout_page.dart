import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  bool _isProcessing = false;
  final double _deliveryCharge = 100.0;

  static const _accent = Color(0xFF134686);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final cart = Provider.of<CartProvider>(context, listen: false);
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final username =
          user.userMetadata?['username'] ?? user.email ?? 'Unknown';

      // Insert each cart item as a separate order record
      for (final item in cart.items) {
        await Supabase.instance.client.from('order_history').insert({
          'username': username,
          'product_id': item.id,
          'quantity': item.quantity,
          'unit_price': item.price.toString(),
          'total_price': item.totalPrice.toString(),
          'delivery_charge': _deliveryCharge.toString(),
          'delivery_address': _addressController.text,
          'phone': _phoneController.text,
          'city': _cityController.text,
          'postal_code': _postalCodeController.text,
          'customer_name': _nameController.text,
          'payment_method': 'COD',
          'status': 'pending',
        });
      }

      // Clear the cart
      await cart.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Return to home page
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), backgroundColor: _accent),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          final subtotal = cart.totalPrice;
          final total = subtotal + _deliveryCharge;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Method Section
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: _accent.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                      color: _accent.withOpacity(0.05),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.money, color: _accent),
                        const SizedBox(width: 12),
                        const Text(
                          'Cash on Delivery (COD)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '+ BDT ${_deliveryCharge.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Delivery Address Section
                  const Text(
                    'Delivery Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Phone is required' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Street Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.home),
                    ),
                    maxLines: 2,
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Address is required' : null,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.location_city),
                          ),
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'City is required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _postalCodeController,
                          decoration: InputDecoration(
                            labelText: 'Postal Code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.markunread_mailbox),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => v?.isEmpty ?? true
                              ? 'Postal code is required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Order Summary
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal:',
                              style: TextStyle(fontSize: 15),
                            ),
                            Text(
                              'BDT ${subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Delivery Charge:',
                              style: TextStyle(fontSize: 15),
                            ),
                            Text(
                              'BDT ${_deliveryCharge.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'BDT ${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Place Order Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Place Order',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
