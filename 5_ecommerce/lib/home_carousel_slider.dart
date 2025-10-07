import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';

class HomeCarouselSlider extends StatelessWidget {
  final List<Product> products;
  final Color accentColor;

  const HomeCarouselSlider({
    super.key,
    required this.products,
    this.accentColor = const Color(0xFF134686),
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    // Take up to 5 random products for carousel
    final carouselProducts = products.length <= 5
        ? products
        : products.sublist(0, 5);

    return CarouselSlider(
      options: CarouselOptions(
        height: 240,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 2),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: false,
      ),
      items: carouselProducts.map((product) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Product Image
                    Positioned.fill(
                      child: product.imageLinks.isNotEmpty
                          ? Image.network(
                              product.imageLinks.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                    ),
                    // Gradient Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Category badge
                            if (product.category1 != null &&
                                product.category1!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  product.category1!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            // Product title
                            Text(
                              product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Rating and Price
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      product.productRating?.isNotEmpty == true
                                          ? product.productRating!
                                          : 'N/A',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  product.mrp?.isNotEmpty == true
                                      ? 'BDT ${product.mrp}'
                                      : 'BDT -',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
          },
        );
      }).toList(),
    );
  }
}

// Product model - reuse from home_page.dart
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
