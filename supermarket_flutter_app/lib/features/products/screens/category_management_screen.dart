import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/category.dart';
import '../../../features/products/providers/category_provider.dart';
import '../../../features/products/providers/product_provider.dart';
import 'product_list_screen.dart'; // Added by Copilot
import 'dart:math' as math;

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  Category? _editingCategory;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CategoryProvider>().fetchCategories();
      // ensure products are loaded so we can show counts per category
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showCategoryDialog([Category? category]) {
    _editingCategory = category;
    _nameController.text = category?.name ?? '';
    _descriptionController.text = category?.description ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveCategory,
            child: Text(category == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;

    final category = Category(
      id: _editingCategory?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    final provider = context.read<CategoryProvider>();
    if (_editingCategory == null) {
      provider.addCategory(category);
    } else {
      provider.updateCategory(category);
    }

    Navigator.of(context).pop();
    _clearForm();
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _editingCategory = null;
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryProvider>().deleteCategory(category.id!);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final productProvider = context.watch<ProductProvider>();

    // apply search filtering
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? categoryProvider.categories
        : categoryProvider.categories.where((c) => c.name.toLowerCase().contains(query)).toList();

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern header card
          Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle),
                  child: Icon(Icons.category, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text('Categories', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Organize your product categories and manage them quickly.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                  ]),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showCategoryDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
                )
              ]),
            ),
          ),
          const SizedBox(height: 14),

          // Elevated search bar
          Row(children: [
            Expanded(
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration.collapsed(hintText: 'Search categories...'),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () { _searchController.clear(); setState(() {}); }),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Optional filter button
            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.filter_list), label: const Text('Filter'))
          ]),

          const SizedBox(height: 18),

          if (categoryProvider.isLoading)
            // loading placeholders
            Expanded(
              child: LayoutBuilder(builder: (ctx, cons) {
                final cross = (cons.maxWidth / 260).floor().clamp(1, 4);
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cross, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.25),
                  itemCount: math.max(6, cross * 2),
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          CircleAvatar(backgroundColor: Colors.grey[300], radius: 30),
                          const SizedBox(width: 12),
                          Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            // flexible placeholders (no fixed heights that cause overflow)
                            Container(width: 140, color: Colors.grey[300]),
                            const SizedBox(height: 8),
                            Container(width: 80, color: Colors.grey[200]),
                          ]))
                        ]),
                      ),
                    );
                  },
                );
              }),
            )
          else if (filtered.isEmpty)
            Expanded(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.category, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text('No categories found', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Add a category to get started.', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(onPressed: () => _showCategoryDialog(), icon: const Icon(Icons.add), label: const Text('Add Category'))
                ]),
              ),
            )
          else
            Expanded(
              child: LayoutBuilder(builder: (ctx, cons) {
                final cross = (cons.maxWidth / 300).floor().clamp(1, 4);
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cross, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final category = filtered[index];
                    final count = productProvider.products.where((p) => p.categoryId == category.id).length;
                    final initials = (category.name.split(' ').map((s) => s.isEmpty ? '' : s[0]).take(2).join()).toUpperCase();
                    final color = Colors.primaries[(category.id ?? 0) % Colors.primaries.length];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: Text('${category.name} Products'),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                elevation: 0.5,
                              ),
                              body: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ProductListScreen(
                                  filterCategoryId: category.id,
                                  filterCategoryName: category.name,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center, 
                            children: [
                              CircleAvatar(
                                radius: 30, 
                                backgroundColor: color.shade200, 
                                child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold))
                              ),
                              const SizedBox(width: 16),
                              // Ensure title is single-line and flexible
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min, 
                                  crossAxisAlignment: CrossAxisAlignment.start, 
                                  children: [
                                    // Show full category name (wrap as needed), do not truncate
                                    Text(category.name, style: Theme.of(context).textTheme.titleMedium, softWrap: true),
                                    if (category.description != null) const SizedBox(height: 8),
                                    if (category.description != null) 
                                      Text(
                                        category.description!, 
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]), 
                                        maxLines: 2, 
                                        overflow: TextOverflow.ellipsis
                                      ),
                                  ]
                                )
                              ),
                              const SizedBox(width: 12),
                              Column(
                                mainAxisSize: MainAxisSize.min, 
                                mainAxisAlignment: MainAxisAlignment.center, 
                                children: [
                                  Chip(label: Text('$count products')), 
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min, 
                                    children: [
                                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showCategoryDialog(category)),
                                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteCategory(category)),
                                    ]
                                  )
                                ]
                              )
                            ]
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
        ],
      ),
    );
  }
}