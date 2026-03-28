
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supermarket_flutter_app/features/products/providers/product_provider.dart';
import 'package:supermarket_flutter_app/core/widgets/loading_widget.dart';
import 'package:supermarket_flutter_app/core/widgets/custom_button.dart';
import 'package:supermarket_flutter_app/core/widgets/empty_state.dart';
import 'package:supermarket_flutter_app/features/products/screens/add_edit_product_screen.dart';
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

  const ProductListScreen({Key? key, this.isReadOnly = false, this.filterCategoryId, this.filterCategoryName}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool _isRetrying = false;

  Future<void> _retryLoad(BuildContext context) async {
    setState(() => _isRetrying = true);
    try {
         await Provider.of<ProductProvider>(context, listen: false).fetchProducts(force: true);
    } finally {
      setState(() => _isRetrying = false);
    }
  }

  void _showActionError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _addProduct(BuildContext context) async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AddEditProductScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
    if (result == true) {
         await Provider.of<ProductProvider>(context, listen: false).fetchProducts(force: true);
    }
  }

  Future<void> _editProduct(BuildContext context, product) async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AddEditProductScreen(product: product),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
    if (result == true) {
         await Provider.of<ProductProvider>(context, listen: false).fetchProducts(force: true);
    }
  }

  Future<void> _deleteProduct(BuildContext context, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      try {
         await Provider.of<ProductProvider>(context, listen: false).deleteProduct(id);
      } catch (e) {
        _showActionError(context, 'Delete failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading == true || _isRetrying) {
          return const LoadingWidget();
        }
        if (provider.errorMessage != null && provider.errorMessage?.isNotEmpty == true) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Failed to load products',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                CustomButton(
                  label: _isRetrying ? 'Retrying...' : 'Retry',
                  onPressed: _isRetrying ? null : () => _retryLoad(context),
                  icon: Icons.refresh,
                ),
              ],
            ),
          );
        }

        final products = provider.products;
        return Scaffold(
          floatingActionButton: widget.isReadOnly
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _addProduct(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                ),
          body: products.isEmpty
              ? EmptyState(
                  message: 'No products found',
                  icon: Icons.inventory_2_outlined,
                  iconSize: 64,
                  spacing: 16,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final p = products[i];
                    final isMobile = MediaQuery.of(context).size.width < 500;
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      p.imageUrl != null && p.imageUrl!.isNotEmpty
                                          ? CircleAvatar(radius: 28, backgroundImage: NetworkImage(p.imageUrl!))
                                          : const CircleAvatar(radius: 28, child: Icon(Icons.inventory_2_outlined)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          p.name,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('LKR ${p.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text('Stock: ${p.stock}', style: const TextStyle(fontSize: 13)),
                                      ),
                                      const Spacer(),
                                      if (!widget.isReadOnly) ...[
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                          onPressed: () => _editProduct(context, p),
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                          onPressed: () => _deleteProduct(context, p.id!),
                                          tooltip: 'Delete',
                                        ),
                                      ]
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  p.imageUrl != null && p.imageUrl!.isNotEmpty
                                      ? CircleAvatar(radius: 32, backgroundImage: NetworkImage(p.imageUrl!))
                                      : const CircleAvatar(radius: 32, child: Icon(Icons.inventory_2_outlined)),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text('LKR ${p.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('Stock: ${p.stock}', style: const TextStyle(fontSize: 15)),
                                  ),
                                  if (!widget.isReadOnly) ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editProduct(context, p),
                                      tooltip: 'Edit',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteProduct(context, p.id!),
                                      tooltip: 'Delete',
                                    ),
                                  ]
                                ],
                              ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
