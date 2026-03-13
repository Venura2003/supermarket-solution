import 'dart:io';

import 'package:flutter/foundation.dart' as fnd;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:path_provider/path_provider.dart';

import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../../../core/models/product.dart';
import '../../../core/models/category.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();
  int? _selectedCategoryId;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _barcodeController.text = widget.product!.barcode ?? '';
      _priceController.text = widget.product!.price.toString();
      _costPriceController.text = widget.product!.costPrice.toString(); // Added
      _stockController.text = widget.product!.stock.toString();
      _lowStockThresholdController.text = widget.product!.lowStockThreshold.toString();
      _selectedCategoryId = widget.product!.categoryId;
      _imagePath = widget.product!.imageUrl;
    }
    // ensure categories are loaded for the dropdown
    Future.microtask(() => context.read<CategoryProvider>().fetchCategories());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _lowStockThresholdController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final barcode = _barcodeController.text.isEmpty ? null : _barcodeController.text;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final costPrice = double.tryParse(_costPriceController.text) ?? 0.0; // Added
    final stock = int.tryParse(_stockController.text) ?? 0;
    final lowStockThreshold = int.tryParse(_lowStockThresholdController.text) ?? 5;

    final product = Product(
      id: widget.product?.id,
      name: name,
      categoryId: _selectedCategoryId,
      barcode: barcode,
      imageUrl: _imagePath,
      price: price,
      costPrice: costPrice, // Added
      stock: stock,
      lowStockThreshold: lowStockThreshold,
    );

    final provider = context.read<ProductProvider>();
    if (widget.product == null) {
      await provider.addProduct(product);
    } else {
      await provider.updateProduct(product);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/product_images');
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    final filename = path_pkg.basename(picked.path);
    final destPath = '${imagesDir.path}/$filename';
    try {
      await File(picked.path).copy(destPath);
      setState(() {
        _imagePath = destPath;
      });
    } catch (e) {
      if (fnd.kDebugMode) print('Image copy failed: $e');
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final newCat = Category(name: name, description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim());
              final provider = context.read<CategoryProvider>();
              await provider.addCategory(newCat);
              await provider.fetchCategories();
              Navigator.of(ctx).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        title: Text(isEditing ? 'Edit Product' : 'Add Product', style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(
            child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          // Image preview
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _imagePath != null && File(_imagePath!).existsSync()
                                    ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                                    : Center(child: Icon(Icons.photo_library, size: 48, color: Colors.grey[500])),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Title + category chips
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    labelText: 'Product name *',
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  ),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                  validator: (value) => value!.isEmpty ? 'Enter name' : null,
                                ),
                                const SizedBox(height: 10),
                                Consumer<CategoryProvider>(builder: (ctx, catProv, _) {
                                  final cat = catProv.categories.firstWhere((c) => c.id == _selectedCategoryId, orElse: () => Category(id: null, name: 'None'));
                                  return Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      ActionChip(
                                        label: Text(cat.name),
                                        onPressed: () async {
                                          // open category selector
                                          final v = await showDialog<int?>(context: context, builder: (dctx) => SimpleDialog(
                                            title: const Text('Select Category'),
                                            children: [
                                              SimpleDialogOption(onPressed: () => Navigator.of(dctx).pop(null), child: const Text('None')),
                                              ...catProv.categories.map((c) => SimpleDialogOption(onPressed: () => Navigator.of(dctx).pop(c.id), child: Text(c.name))).toList(),
                                            ],
                                          ));
                                          if (v != null || v == null) setState(() => _selectedCategoryId = v);
                                        },
                                      ),
                                      OutlinedButton.icon(onPressed: _showAddCategoryDialog, icon: const Icon(Icons.add), label: const Text('New category')),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Two-column responsive form
                      LayoutBuilder(builder: (ctx, cons) {
                        final twoCol = cons.maxWidth > 600;
                        return twoCol
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _leftColumn()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _rightColumn()),
                                ],
                              )
                            : Column(children: [_leftColumn(), const SizedBox(height: 12), _rightColumn()]);
                      }),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _saveProduct,
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: Text(isEditing ? 'Update product' : 'Add product'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Left column of the form
  Widget _leftColumn() {
    return Column(
      children: [
        TextFormField(
          controller: _barcodeController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(labelText: 'Barcode (optional)', filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _priceController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(labelText: 'Price *', filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isEmpty) return 'Enter price';
            if (double.tryParse(value) == null) return 'Enter valid price';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _costPriceController, // Added
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(labelText: 'Cost Price (Optional)', filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isNotEmpty && double.tryParse(value) == null) return 'Enter valid cost';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _stockController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(labelText: 'Stock *', filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isEmpty) return 'Enter stock';
            if (int.tryParse(value) == null) return 'Enter valid stock';
            return null;
          },
        ),
      ],
    );
  }

  // Right column of the form
  Widget _rightColumn() {
    return Column(
      children: [
        TextFormField(
          controller: _lowStockThresholdController,
          decoration: InputDecoration(labelText: 'Low Stock Threshold', filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isEmpty) return 'Enter threshold';
            if (int.tryParse(value) == null) return 'Enter valid threshold';
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose Image'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
      ],
    );
  }
}