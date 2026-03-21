import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../../shared/statistic_card.dart';
import '../../shared/modern_search_bar.dart';
import '../../shared/modern_data_table.dart';
import 'add_edit_product_screen.dart';
import '../providers/category_provider.dart';
import '../../../core/models/category.dart';

class ProductListScreen extends StatefulWidget {
  final bool isReadOnly;
  final int? filterCategoryId;
  final String? filterCategoryName;

  const ProductListScreen({
    super.key, 
    this.isReadOnly = false,
    this.filterCategoryId,
    this.filterCategoryName,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      // If provider already has products (e.g., pushed from POS search), don't overwrite them.
      if (provider.products.isEmpty) {
        provider.loadProducts();
      }
      // ensure categories loaded for dropdowns and display
      Future.microtask(() => context.read<CategoryProvider>().fetchCategories());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    // If an external injected set exists (e.g., from POS search), prefer
    // showing that set so the user can edit those items immediately.
    final injected = productProvider.injectedProducts;
    final base = (injected != null && injected.isNotEmpty) ? injected : productProvider.products;
    
    // Apply category filter if needed
    final categoryFiltered = widget.filterCategoryId != null 
        ? base.where((p) => p.categoryId == widget.filterCategoryId).toList()
        : base;

    final products = categoryFiltered.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    final categoryProvider = Provider.of<CategoryProvider>(context);

    if (productProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 4),
      );
    }

    if (productProvider.error != null) {
      final errorMsg = productProvider.error ?? '';
      final userFriendlyMsg = errorMsg.contains('SocketException')
          ? 'Cannot connect to the server. Please check your network connection or ensure the backend API is running.'
          : errorMsg.replaceAll(RegExp(r'Exception:|ClientException:'), '').trim();
      return Center(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
            // Support dynamic product shape (model instance or Map) by resolving fields safely.
                Text(
                  userFriendlyMsg,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => productProvider.loadProducts(),
                  child: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red.shade900,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No products available', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black54)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner when viewing externally-injected results (placed above stats)
              if (injected != null && injected.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.yellow.shade700),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Viewing injected POS results (${injected.length})', style: const TextStyle(fontWeight: FontWeight.w600))),
                      TextButton(
                        onPressed: () {
                          productProvider.clearInjectedProducts();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ),
              // Banner when viewing category filter
              if (widget.filterCategoryId != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Filtering by Category: ${widget.filterCategoryName ?? "Unknown"}', 
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
                        )
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Colors.blue),
                        onPressed: () {
                          // If pushed as a modal/fullscreen page, pop it.
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  StatisticCard(
                    title: 'Total Products',
                    value: productProvider.totalCount.toString(),
                    icon: Icons.inventory,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 24),
                  StatisticCard(
                    title: 'Low Stock',
                    value: productProvider.lowStockCount.toString(),
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddEditProductScreen(),
                        ),
                      );
                      // If injected results are active, provider already updates
                      // injected lists in-place; otherwise refresh main products.
                      if (productProvider.injectedProducts == null) {
                        await productProvider.loadProducts();
                      }
                    },
                  ),
                ],
              ),
              if (productProvider.isDemo)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Demo data — items seeded locally', style: TextStyle(color: Colors.orange)),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              ModernSearchBar(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                      // Perform backend/POS-aware search from the provider. When
                      // empty, provider will fall back to the normal product list.
                      productProvider.searchProducts(val);
                    },
                showAddButton: false,
              ),
              const SizedBox(height: 24),
              // Responsive product cards grid (more real-world / supermarket style)
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width > 1100 ? 4 : width > 800 ? 3 : width > 520 ? 2 : 1;
                  return Scrollbar(
                    controller: _verticalScrollController,
                    thumbVisibility: true,
                    child: GridView.builder(
                      controller: _verticalScrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      gridDelegate: (() {
                        // Compute a sensible childAspectRatio based on available width
                        // so cards can expand vertically when needed and avoid
                        // the Flutter overflow indicator.
                        final spacing = 16.0 * (crossAxisCount - 1);
                        final itemWidth = (width - spacing) / crossAxisCount;
                        double desiredHeight;
                        if (itemWidth < 280) {
                          desiredHeight = 300; // narrow columns -> taller cards (vertical layout)
                        } else if (itemWidth < 360) {
                          desiredHeight = 200; // medium columns
                        } else {
                          desiredHeight = 160; // wide columns -> compact horizontal cards
                        }
                        final aspect = itemWidth / desiredHeight;
                        return SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: aspect,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        );
                      })(),
                      itemCount: products.length,
                      itemBuilder: (context, idx) {
                        final product = products[idx];
                        return _ProductCard(
                          product: product,
                          categoryName: product.categoryId != null
                              ? (categoryProvider.categories.firstWhere((c) => c.id == product.categoryId, orElse: () => Category(id: null, name: 'Unknown')).name)
                              : '—',
                          onEdit: () async {
                            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEditProductScreen(product: product)));
                            if (productProvider.injectedProducts == null) await productProvider.loadProducts();
                          },
                          onDelete: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Product'),
                                content: Text('Are you sure you want to delete "${product.name}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.of(context).pop(true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
                                ],
                              ),
                            );
                            if (shouldDelete == true) {
                              try {
                                await productProvider.deleteProduct(product.id ?? 0);
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted')));
                                if (productProvider.injectedProducts == null) await productProvider.loadProducts();
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('Failed to delete: ${e.toString().replaceAll('Exception:', '')}'),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                              }
                            }
                          },
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedLoadingState extends StatelessWidget {
  const _AnimatedLoadingState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 18),
          Text('Loading products...', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _AnimatedEmptyState extends StatelessWidget {
  const _AnimatedEmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No products available', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black54)),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic product;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({required this.product, required this.categoryName, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    // Support dynamic product shape (model instance or Map) by resolving fields safely.
    String resolve(dynamic obj, String key) {
      try {
        if (obj == null) return '';
        if (obj is Map) return (obj[key] ?? '').toString();
        final v = obj?.toJson != null ? obj.toJson()[key] : null;
        if (v != null) return v.toString();
        // try property access
        final prop = obj?.toString();
        return (obj?.name ?? obj?[key] ?? '')?.toString() ?? '';
      } catch (_) {
        try {
          return (obj[key] ?? '').toString();
        } catch (_) {
          return obj?.toString() ?? '';
        }
      }
    }

    final displayName = () {
      final n1 = resolve(product, 'name');
      if (n1.isNotEmpty) return n1;
      final n2 = resolve(product, 'productName');
      if (n2.isNotEmpty) return n2;
      return resolve(product, 'title');
    }();

    final priceVal = () {
      try {
        if (product is Map) return (product['price'] ?? 0.0) as num;
        return product.price as num;
      } catch (_) {
        try {
          return double.parse(resolve(product, 'price'));
        } catch (_) {
          return 0.0;
        }
      }
    }();

    final priceText = 'LKR ${priceVal.toDouble().toStringAsFixed(2)}';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      shadowColor: Colors.black12,
      child: Padding(
    padding: const EdgeInsets.all(10),
        child: LayoutBuilder(builder: (context, constraints) {
          // If the card is narrow, use a vertical layout to avoid horizontal overflow
          if (constraints.maxWidth < 300) {
            // Make image size responsive to available height so the vertical
            // card doesn't overflow when grid cell is tight.
            final availableH = constraints.maxHeight.isFinite ? constraints.maxHeight : 180.0;
            final rawImg = availableH * 0.45;
            final imgSize = math.max(64.0, math.min(116.0, rawImg));
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: imgSize,
                    height: imgSize,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: (() {
                          String? imageUrl = product.imageUrl;
                          if (imageUrl != null && imageUrl.startsWith('/images/')) {
                            imageUrl = 'https://supermarket-api-2lx7.onrender.com$imageUrl';
                          }
                          if (imageUrl != null && imageUrl.isNotEmpty) {
                            if (imageUrl.toLowerCase().startsWith('http')) {
                              return Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 48, color: Colors.grey));
                            } else {
                              return Image.file(File(imageUrl), fit: BoxFit.cover);
                            }
                          } else {
                            return Container(color: Colors.grey[100], child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 28));
                          }
                        })(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(child: Text(displayName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis)),
                const SizedBox(height: 2),
                Flexible(child: Text(categoryName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(height: 4),
                Row(children: [Expanded(child: Text(priceText, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700))), ConstrainedBox(constraints: const BoxConstraints(maxWidth: 110), child: Chip(label: Text('Stock: ${product.stock}', overflow: TextOverflow.ellipsis), backgroundColor: product.stock <= 5 ? Colors.orange.shade50 : Colors.green.shade50, shape: const StadiumBorder()))]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, color: Colors.blue)), IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, color: Colors.red))]),
              ],
            );
          }

          // Default horizontal layout for wider cards
          return Row(
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: (() {
                      String? imageUrl = product.imageUrl;
                      if (imageUrl != null && imageUrl.startsWith('/images/')) {
                        imageUrl = 'https://supermarket-api-2lx7.onrender.com$imageUrl';
                      }
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        if (imageUrl.toLowerCase().startsWith('http')) {
                          return Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 64, color: Colors.grey));
                        } else {
                          return Image.file(File(imageUrl), fit: BoxFit.cover);
                        }
                      } else {
                        return Container(color: Colors.grey[100], child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40));
                      }
                    })(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(displayName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(categoryName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Text(priceText, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, maxLines: 1)),
                        const SizedBox(width: 8),
                        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 90), child: Chip(label: Text('Stock: ${product.stock}', overflow: TextOverflow.ellipsis), backgroundColor: product.stock <= 5 ? Colors.orange.shade50 : Colors.green.shade50)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 48,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, color: Colors.blue)),
                    IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, color: Colors.red)),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}