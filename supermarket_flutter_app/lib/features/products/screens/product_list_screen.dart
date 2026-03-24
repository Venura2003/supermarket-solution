import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supermarket_flutter_app/features/products/providers/product_provider.dart';
// Removed unused imports
// Removed unused imports
// import 'dart:io';
// import 'dart:math' as math;
// import '../../shared/statistic_card.dart';
// import '../../shared/modern_search_bar.dart';
// import '../../shared/modern_data_table.dart';
// import '../providers/category_provider.dart';
// import '../../../core/models/category.dart';

class ProductListScreen extends StatefulWidget {
  final bool isReadOnly;
  final int? filterCategoryId;
  final String? filterCategoryName;

  const ProductListScreen({
    Key? key,
    this.isReadOnly = false,
    this.filterCategoryId,
    this.filterCategoryName,
  }) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        // Filter products by category if filterCategoryId is provided
        final products = (widget.filterCategoryId != null)
            ? provider.products.where((p) => p.categoryId == widget.filterCategoryId).toList()
            : provider.products;

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage != null) {
          return Center(child: Text('Error: \\${provider.errorMessage}'));
        }
        if (products.isEmpty) {
          return const Center(child: Text('No products found for this category.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              leading: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? CircleAvatar(backgroundImage: NetworkImage(product.imageUrl!))
                  : const CircleAvatar(child: Icon(Icons.shopping_bag)),
              title: Text(product.name),
              subtitle: Text('Rs. \\${product.price.toStringAsFixed(2)}'),
              // Add more product details as needed
            );
          },
        );
      },
    );
  }
}
