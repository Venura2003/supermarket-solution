import 'package:flutter/material.dart';
import 'screens/product_list_screen.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Products',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B5E20),
                ),
          ),
          const SizedBox(height: 24),
          Expanded(child: ProductListScreen()),
        ],
      ),
    );
  }
}
