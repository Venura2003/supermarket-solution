
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
      MaterialPageRoute(builder: (_) => AddEditProductScreen()),
    );
    if (result == true) {
         await Provider.of<ProductProvider>(context, listen: false).fetchProducts(force: true);
    }
  }

  Future<void> _editProduct(BuildContext context, product) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditProductScreen(product: product)),
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
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final p = products[i];
                    return ListTile(
                      leading: p.imageUrl != null && p.imageUrl!.isNotEmpty
                          ? CircleAvatar(backgroundImage: NetworkImage(p.imageUrl!))
                          : const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
                      title: Text(p.name),
                      subtitle: Text('Stock: {p.stock}  |  LKR {p.price.toStringAsFixed(2)}'),
                      trailing: widget.isReadOnly
                          ? null
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                              ],
                            ),
                      onTap: widget.isReadOnly ? null : () => _editProduct(context, p),
                    );
                  },
                ),
        );
      },
    );
  }
}
