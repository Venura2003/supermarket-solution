import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/models/product.dart';
import '../../products/providers/product_provider.dart';
import '../../supplier/providers/supplier_provider.dart';
import '../../grn/providers/grn_provider.dart';

class GoodsReceivedScreen extends StatefulWidget {
  const GoodsReceivedScreen({super.key});

  @override
  State<GoodsReceivedScreen> createState() => _GoodsReceivedScreenState();
}

class _GoodsReceivedScreenState extends State<GoodsReceivedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // New GRN State
  int? _selectedSupplierId;
  final List<Map<String, dynamic>> _newGrnItems = [];
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierProvider>().fetchSuppliers();
      context.read<GrnProvider>().fetchGrns();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddSupplierDialog() {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Supplier Name *'),
            ),
            TextField(
              controller: contactController,
              decoration: const InputDecoration(labelText: 'Contact No'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await context.read<SupplierProvider>().addSupplier(
                  nameController.text,
                  contactController.text.isEmpty
                      ? null
                      : contactController.text,
                  addressController.text.isEmpty
                      ? null
                      : addressController.text,
                );
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final productProvider = context.read<ProductProvider>();
    // Ensure all products are available for searching
    final allProducts = productProvider.products;

    Product? selectedProduct;
    int quantity = 1;
    double unitCost = 0.0;
    double? newSellingPrice;
    
    // Controller for unit cost to update when product is selected
    final TextEditingController costController = TextEditingController(text: '0.00');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Product to GRN'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product Selector Button
                  InkWell(
                    onTap: () async {
                      final Product? result = await _showProductSearchSheet(context, allProducts);
                      if (result != null) {
                        setState(() {
                          selectedProduct = result;
                          // If we had a cost history, we could pre-fill it here
                          // costController.text = result.cost.toString(); 
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: selectedProduct != null ? Theme.of(context).primaryColor : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedProduct != null 
                                ? '${selectedProduct!.name} \nStock: ${selectedProduct!.stock}' 
                                : 'Select Product...',
                              style: TextStyle(
                                color: selectedProduct != null ? Colors.black : Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (selectedProduct != null)
                            const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
                  if (selectedProduct != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Barcode: ${selectedProduct?.barcode ?? "N/A"}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],

                  const SizedBox(height: 20),
                  
                  TextFormField(
                    initialValue: '1',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shopping_bag_outlined),
                    ),
                    onChanged: (val) => quantity = int.tryParse(val) ?? 1,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: costController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Unit Cost',
                      border: OutlineInputBorder(),
                      prefixText: 'LKR ',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    onChanged: (val) => unitCost = double.tryParse(val) ?? 0.0,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'New Selling Price (Optional)',
                      border: OutlineInputBorder(),
                      prefixText: 'LKR ',
                      prefixIcon: Icon(Icons.price_change_outlined),
                      helperText: 'Leave empty to keep current price',
                    ),
                    onChanged: (val) => newSellingPrice = double.tryParse(val),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedProduct != null &&
                      quantity > 0 &&
                      unitCost >= 0 &&
                      selectedProduct!.id != null) {
                    this.setState(() {
                      // Check if already added
                      final existingIndex = _newGrnItems.indexWhere(
                        (item) =>
                            item['productId'] == selectedProduct!.id!,
                      );
                      if (existingIndex >= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item already in list')),
                        );
                        return;
                      }

                      _newGrnItems.add({
                        'productId': selectedProduct!.id!,
                        'productName': selectedProduct!.name,
                        'quantity': quantity,
                        'unitCost': unitCost,
                        'newSellingPrice': newSellingPrice,
                        'totalCost': quantity * unitCost,
                      });
                    });
                    Navigator.pop(ctx);
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a product and enter valid details')),
                     );
                  }
                },
                child: const Text('Add Item'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Product?> _showProductSearchSheet(BuildContext context, List<Product> allProducts) async {
    return await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local search state inside the sheet
                String query = '';
                List<Product> filteredProducts = allProducts; // Initial list

                // We need to manage the text editing controller to avoid losing focus
                // or state reset issues, but for a simple dialog, the builder is fine.
                // However, `StatefulBuilder` logic for filtering needs to be self-contained.
                
                // Note: The variable 'filteredProducts' needs to be updated inside setState.
                // But declaring it inside builder resets it on rebuild. 
                // We should rely on a StatefulWidget if complex, but here we can just
                // compute it or use a variable captured in the closure if we are careful.
                // Actually, `StatefulBuilder` rebuilds `builder` when `setState` is called.
                // So variables declared inside `builder` are re-initialized.
                // We must move variables outside or use a stateful widget.
                
                // Let's use a nested StatefulWidget for the sheet content to be safe.
                return _ProductSearchSheetContent(allProducts: allProducts);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _submitGrn() async {
    if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a supplier')));
      return;
    }
    if (_newGrnItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add at least one item')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await context.read<GrnProvider>().createGrn(
        supplierId: _selectedSupplierId!,
        items: _newGrnItems,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GRN Created Successfully')),
        );
        setState(() {
          _newGrnItems.clear();
          _notesController.clear();
          _selectedSupplierId = null;
        });
        _tabController.animateTo(1); // Switch to history tab
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goods Received Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'New GRN', icon: Icon(Icons.add_shopping_cart)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildNewGrnTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildNewGrnTab() {
    final supplierProvider = context.watch<SupplierProvider>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Supplier Selection Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedSupplierId,
                  decoration: const InputDecoration(
                    labelText: 'Supplier',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  items: supplierProvider.suppliers
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSupplierId = val),
                  hint: const Text('Select Supplier'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _showAddSupplierDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('New Supplier'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Items Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GRN Items (${_newGrnItems.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: _showAddItemDialog,
                icon: const Icon(Icons.add_box),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Items List
          Expanded(
            child: _newGrnItems.isEmpty
                ? Center(
                    child: Text(
                      'No items added yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: _newGrnItems.length,
                    itemBuilder: (context, index) {
                      final item = _newGrnItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(
                            item['productName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Qty: ${item['quantity']}  ×  Cost: LKR ${item['unitCost']}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'LKR ${item['totalCost']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => setState(
                                  () => _newGrnItems.removeAt(index),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 16),

          // Total & Notes
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'LKR ${_newGrnItems.fold<double>(0, (sum, item) => sum + (item['totalCost'] as double)).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes / Remarks',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitGrn,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'SUBMIT GRN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final grnProvider = context.watch<GrnProvider>();

    if (grnProvider.isLoading && grnProvider.grns.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (grnProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${grnProvider.error}'),
            ElevatedButton(
              onPressed: () => context.read<GrnProvider>().fetchGrns(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (grnProvider.grns.isEmpty) {
      return const Center(child: Text('No GRN history found'));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<GrnProvider>().fetchGrns(),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: grnProvider.grns.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final grn = grnProvider.grns[index];
          final date =
              DateTime.tryParse(grn['receivedDate'] ?? '') ?? DateTime.now();

          return Card(
            elevation: 2,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long, color: Colors.blue),
              ),
              title: Text(
                '${grn['supplierName']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'GRN #${grn['id']} • ${DateFormat('yyyy-MM-dd HH:mm').format(date.toLocal())}',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'LKR ${grn['totalAmount']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '${grn['itemsCount']} Items',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              onTap: () {
                // Future enhancement: Show detailed view
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Detail view coming soon')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProductSearchSheetContent extends StatefulWidget {
  final List<Product> allProducts;
  const _ProductSearchSheetContent({super.key, required this.allProducts});

  @override
  State<_ProductSearchSheetContent> createState() =>
      _ProductSearchSheetContentState();
}

class _ProductSearchSheetContentState
    extends State<_ProductSearchSheetContent> {
  late List<Product> _filteredProducts;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.allProducts;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterProducts(_searchController.text);
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredProducts = widget.allProducts);
      return;
    }

    final lower = query.toLowerCase();
    setState(() {
      _filteredProducts = widget.allProducts.where((p) {
        final name = p.name.toLowerCase();
        final barcode = p.barcode?.toLowerCase() ?? '';
        return name.contains(lower) || barcode.contains(lower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search Product (Name or Barcode)',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                          : null,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _filteredProducts.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            image:
                                product.imageUrl != null
                                    ? DecorationImage(
                                      image: NetworkImage(product.imageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                          ),
                          child:
                              product.imageUrl == null
                                  ? const Icon(
                                    Icons.inventory_2,
                                    color: Colors.grey,
                                  )
                                  : null,
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.barcode != null)
                              Text(
                                'Barcode: ${product.barcode}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            Text(
                              'Current Stock: ${product.stock}',
                              style: TextStyle(
                                color:
                                    product.stock < 10
                                        ? Colors.red
                                        : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          'LKR ${product.price}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () => Navigator.pop(context, product),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}