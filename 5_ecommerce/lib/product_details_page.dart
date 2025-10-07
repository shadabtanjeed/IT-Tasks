import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final _supabase = Supabase.instance.client;
  final Color _accent = const Color(0xFF134686);
  Map<String, dynamic>? _product;
  bool _loading = true;
  String? _error;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _supabase
          .from('products')
          .select()
          .eq('product_id', widget.productId)
          .maybeSingle();
      if (res == null) {
        setState(() {
          _error = 'Product not found.';
          _loading = false;
        });
        return;
      }
      setState(() {
        _product = res;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: _accent,
        automaticallyImplyLeading: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _buildDetails(),
    );
  }

  Widget _buildDetails() {
    final p = _product!;
    final List<dynamic> imageLinks = p['image_links'] is String
        ? (p['image_links'] as String).split(',')
        : (p['image_links'] ?? []);
    final String imageUrl =
        imageLinks.isNotEmpty &&
            imageLinks[0] != null &&
            imageLinks[0].toString().isNotEmpty
        ? imageLinks[0].toString()
        : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 18),
          // Title
          Text(
            p['title'] ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF134686),
            ),
          ),
          const SizedBox(height: 8),
          // Category
          if ((p['category_1'] ?? '').toString().isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                p['category_1'],
                style: const TextStyle(fontSize: 13, color: Color(0xFF134686)),
              ),
            ),
          const SizedBox(height: 12),
          // Rating, Price
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber[700], size: 20),
              const SizedBox(width: 4),
              Text(
                (p['product_rating'] ?? 'N/A').toString(),
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(width: 18),
              Text(
                p['mrp'] != null ? 'BDT ${p['mrp']}' : 'BDT -',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF134686),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Description
          if ((p['description'] ?? '').toString().isNotEmpty) ...[
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(p['description'], style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 14),
          ],
          // Highlights
          if ((p['highlights'] ?? '').toString().isNotEmpty) ...[
            const Text(
              'Highlights',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(p['highlights'], style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 14),
          ],
          // Seller
          if ((p['seller_name'] ?? '').toString().isNotEmpty) ...[
            const Text('Seller', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(p['seller_name'], style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 12),
                if ((p['seller_rating'] ?? '').toString().isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[700], size: 16),
                      const SizedBox(width: 3),
                      Text(
                        p['seller_rating'].toString(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          // Quantity selector
          Row(
            children: [
              const Text(
                'Quantity:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
                splashRadius: 18,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: _accent.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('$_quantity', style: const TextStyle(fontSize: 15)),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => _quantity++),
                splashRadius: 18,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Add to Cart button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final cart = Provider.of<CartProvider>(context, listen: false);
                final imageLinks = p['image_links'] is String
                    ? (p['image_links'] as String).split(',')
                    : (p['image_links'] ?? []);
                final imageUrl =
                    imageLinks.isNotEmpty &&
                        imageLinks[0] != null &&
                        imageLinks[0].toString().isNotEmpty
                    ? imageLinks[0].toString()
                    : '';

                cart.addToCart(
                  CartItem(
                    id: widget.productId,
                    title: p['title'] ?? 'Unknown',
                    imageUrl: imageUrl,
                    price: double.tryParse(p['mrp']?.toString() ?? '0') ?? 0.0,
                    quantity: _quantity,
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to cart!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
