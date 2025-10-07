import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simple placeholder list for categories — keep color scheme
    final categories = ['Electronics', 'Clothing', 'Home', 'Books', 'Toys'];
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: categories.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF134686),
                child: Text(
                  categories[index][0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(categories[index]),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}
