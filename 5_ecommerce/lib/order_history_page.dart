import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final _supabase = Supabase.instance.client;
  static const _accent = Color(0xFF134686);

  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final username =
          user.userMetadata?['username'] ?? user.email ?? 'Unknown';

      // Fetch orders for current user
      final ordersData = await _supabase
          .from('order_history')
          .select()
          .eq('username', username)
          .order('created_at', ascending: false);

      // Fetch product details for each order
      final ordersWithProducts = <Map<String, dynamic>>[];

      for (final order in ordersData) {
        final productData = await _supabase
            .from('products')
            .select()
            .eq('product_id', order['product_id'])
            .maybeSingle();

        ordersWithProducts.add({...order, 'product': productData});
      }

      setState(() {
        _orders = ordersWithProducts;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _getImageUrl(Map<String, dynamic>? product) {
    if (product == null) return '';

    final imageLinks = product['image_links'];
    if (imageLinks is String && imageLinks.isNotEmpty) {
      final links = imageLinks.split(',');
      if (links.isNotEmpty) return links[0].trim();
    } else if (imageLinks is List && imageLinks.isNotEmpty) {
      return imageLinks[0].toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: _accent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error: $_error'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _fetchOrders,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Color(0xFF134686),
                  ),
                  SizedBox(height: 12),
                  Text('No orders yet', style: TextStyle(fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final product = order['product'];
                final imageUrl = _getImageUrl(product);
                final unitPrice =
                    double.tryParse(order['unit_price']?.toString() ?? '0') ??
                    0.0;
                final totalPrice =
                    double.tryParse(order['total_price']?.toString() ?? '0') ??
                    0.0;
                final quantity = order['quantity'] ?? 1;
                final orderId = order['order_id']?.toString() ?? 'N/A';
                final status =
                    order['status']?.toString().toUpperCase() ?? 'PENDING';
                final createdAt = order['created_at'] != null
                    ? DateTime.parse(order['created_at']).toLocal()
                    : null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #$orderId',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: status == 'PENDING'
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: status == 'PENDING'
                                      ? Colors.orange[800]
                                      : Colors.green[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (createdAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${createdAt.day}/${createdAt.month}/${createdAt.year} at ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        const Divider(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Container(
                                        width: 64,
                                        height: 64,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 64,
                                      height: 64,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product?['title'] ?? 'Product',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Quantity: $quantity',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Unit Price: BDT ${unitPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Total: BDT ${totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
