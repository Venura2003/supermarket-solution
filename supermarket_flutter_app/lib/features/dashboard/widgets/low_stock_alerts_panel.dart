import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../../core/models/product.dart';
import '../../../features/products/providers/product_provider.dart';

class LowStockAlertsPanel extends StatelessWidget {
  const LowStockAlertsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Low Stock Alerts',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (dashboardProvider.lowStockProducts.isNotEmpty)
                  Text(
                    '${dashboardProvider.lowStockProducts.length} items',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (dashboardProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (dashboardProvider.lowStockProducts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('All products are well stocked!'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dashboardProvider.lowStockProducts.length,
                itemBuilder: (context, index) {
                  final product = dashboardProvider.lowStockProducts[index];
                  return _LowStockItem(product: product);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LowStockItem extends StatelessWidget {
  final Product product;

  const _LowStockItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(
          Icons.warning,
          color: Colors.orange,
        ),
        title: Text(
          product.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Stock: ${product.stock}  •  Threshold: ${product.lowStockThreshold}',
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () => _openRestockDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Restock'),
        ),
      ),
    );
  }

  void _openRestockDialog(BuildContext context) {
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Restock ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current stock: ${product.stock}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity to add',
                hintText: 'e.g. 50',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = int.tryParse(quantityController.text);
              if (val == null || val <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid positive number')));
                return;
              }

              Navigator.of(ctx).pop(); // Close dialog immediately

              try {
                // Construct updated product - manual copyWith since method is missing
                final updated = Product(
                  id: product.id,
                  name: product.name,
                  categoryId: product.categoryId,
                  barcode: product.barcode,
                  imageUrl: product.imageUrl,
                  price: product.price,
                  stock: product.stock + val, // Add stock
                  lowStockThreshold: product.lowStockThreshold,
                  createdAt: product.createdAt,
                );

                await context.read<ProductProvider>().updateProduct(updated);
                
                // Refresh dashboard to remove from list if stock is now sufficient
                if (context.mounted) {
                  await context.read<DashboardProvider>().loadDashboardData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Stock updated for ${product.name}'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update stock: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Confirm Restock'),
          ),
        ],
      ),
    );
  }
}