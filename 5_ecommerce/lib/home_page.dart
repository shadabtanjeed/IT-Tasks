import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'home_carousel_slider.dart' as carousel;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  final _supabase = Supabase.instance.client;
  final Color _accent = const Color(0xFF134686);

  List<Product> _products = [];
  bool _loading = false;
  String? _error;

  @override
  bool get wantKeepAlive => true; // preserve state when switching tabs

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts({bool forceReload = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Call select() without generics or .execute() because client version may vary.
      final dynamic raw = await _supabase.from('products').select();

      List<Map<String, dynamic>> data = [];

      // Handle several possible shapes returned by different supabase client versions
      if (raw is List) {
        data = raw
            .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
            .toList();
      } else if (raw is Map && raw['data'] != null) {
        final d = raw['data'];
        if (d is List) {
          data = d
              .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
              .toList();
        }
      } else if (raw is Map && raw.containsKey('error')) {
        // Some clients return a map with error key on failure
        throw Exception(raw['error'].toString());
      } else {
        // Fallback: try casting to list of maps
        try {
          data = List<Map<String, dynamic>>.from(raw as List);
        } catch (e) {
          throw Exception(
            'Unexpected response shape from Supabase: ${raw.runtimeType}',
          );
        }
      }

      final all = data.map((e) => Product.fromMap(e)).toList();

      // If fewer than 10, show all; otherwise choose 10 random unique items.
      final rnd = Random();
      List<Product> chosen;
      if (all.length <= 10) {
        chosen = all;
      } else {
        final indices = <int>{};
        while (indices.length < 10) {
          indices.add(rnd.nextInt(all.length));
        }
        chosen = indices.map((i) => all[i]).toList();
      }

      setState(() {
        _products = chosen;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadProducts(forceReload: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;
    final crossAxisCount = size.width > 600 ? 4 : 2;
    final spacing = 12.0;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: _accent,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Carousel at the top
              if (_products.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                    child: carousel.HomeCarouselSlider(
                      products: _products
                          .map(
                            (p) => carousel.Product(
                              productId: p.productId,
                              title: p.title,
                              category1: p.category1,
                              productRating: p.productRating,
                              mrp: p.mrp,
                              imageLinks: p.imageLinks,
                            ),
                          )
                          .toList(),
                      accentColor: _accent,
                    ),
                  ),
                ),

              // Products grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                sliver: _buildBody(crossAxisCount, spacing),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(int crossAxisCount, double spacing) {
    if (_loading && _products.isEmpty) {
      return SliverFillRemaining(
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _products.isEmpty) {
      return SliverFillRemaining(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: _accent, size: 48),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Failed to load products:\n$_error',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return SliverFillRemaining(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, color: _accent, size: 48),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('No products found', textAlign: TextAlign.center),
            ),
          ],
        ),
      );
    }

    // Use slightly higher aspect ratio to prevent overflow
    const childAspectRatio = 0.72;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final p = _products[index];
        return ProductCard(product: p);
      }, childCount: _products.length),
    );
  }
}

class Product {
  final String productId;
  final String title;
  final String? category1;
  final String? productRating;
  final String? mrp;
  final List<String> imageLinks;

  Product({
    required this.productId,
    required this.title,
    this.category1,
    this.productRating,
    this.mrp,
    required this.imageLinks,
  });

  factory Product.fromMap(Map<String, dynamic> m) {
    final id = (m['product_id'] ?? '') as String;
    final title = (m['title'] ?? '') as String;
    final category1 = (m['category_1'] ?? '') as String?;
    final productRating = (m['product_rating'] ?? '') as String?;
    final mrp = (m['mrp'] ?? '') as String?;

    // image_links may be stored as JSON string or comma-separated values.
    final raw = m['image_links'];
    List<String> images = [];
    if (raw is String) {
      final s = raw.trim();
      if (s.startsWith('[') && s.endsWith(']')) {
        try {
          final parsed = jsonDecode(s) as List<dynamic>;
          images = parsed
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList();
        } catch (_) {
          images = s
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } else {
        images = s
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } else if (raw is List) {
      images = raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }

    return Product(
      productId: id,
      title: title,
      category1: category1,
      productRating: productRating,
      mrp: mrp,
      imageLinks: images,
    );
  }
}

/// Product card widget
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF134686);

    final imageUrl = product.imageLinks.isNotEmpty
        ? product.imageLinks.first
        : null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to product details page with productId as parameter using go_router
          // ignore: use_build_context_synchronously
          GoRouter.of(context).go('/product/${product.productId}');
        },
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area - use Expanded
            Expanded(
              flex: 55,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: Container(
                  color: Colors.grey[100],
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.broken_image)),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        )
                      : const Center(child: Icon(Icons.image, size: 40)),
                ),
              ),
            ),

            // Content area - use Expanded
            Expanded(
              flex: 45,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // category
                    if (product.category1 != null &&
                        product.category1!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category1!,
                          style: const TextStyle(fontSize: 11, color: accent),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 6),

                    // title - limit to 2 lines
                    Expanded(
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // rating and price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  product.productRating?.isNotEmpty == true
                                      ? product.productRating!
                                      : 'N/A',
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            product.mrp?.isNotEmpty == true
                                ? 'BDT ${product.mrp}'
                                : 'BDT -',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
