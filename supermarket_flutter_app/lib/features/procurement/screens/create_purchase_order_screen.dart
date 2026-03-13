import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../products/providers/product_provider.dart';
import '../../supplier/providers/supplier_provider.dart';
import '../providers/purchase_order_provider.dart';
import '../../../core/models/product.dart';
import '../../supplier/models/supplier.dart'; // Corrected import path

class CreatePurchaseOrderScreen extends StatefulWidget {
  const CreatePurchaseOrderScreen({super.key});

  @override
  State<CreatePurchaseOrderScreen> createState() => _CreatePurchaseOrderScreenState();
}

class _CreatePurchaseOrderScreenState extends State<CreatePurchaseOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  Supplier? _selectedSupplier;
  DateTime _expectedDate = DateTime.now().add(const Duration(days: 7));
  final List<Map<String, dynamic>> _items = [];

  Product? _selectedProduct;
  final TextEditingController _quantityCtrl = TextEditingController();
  final TextEditingController _costCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<SupplierProvider>().fetchSuppliers();
    });
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a product')));
      return;
    }
    
    final qty = int.tryParse(_quantityCtrl.text) ?? 0;
    final cost = double.tryParse(_costCtrl.text) ?? 0.0;

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quantity must be greater than 0')));
      return;
    }
    
    if (cost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cost must be greater than 0')));
      return;
    }

    setState(() {
      _items.add({
        'productId': _selectedProduct!.id,
        'productName': _selectedProduct!.name,
        'quantity': qty,
        'unitCost': cost,
        'totalCost': qty * cost,
      });
      // Reset fields
      _selectedProduct = null;
      _quantityCtrl.clear();
      _costCtrl.clear();
    });
  }

  void _submit() async {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a supplier')));
      return;
    }
    
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one item')));
      return;
    }

    final poData = {
      'supplierId': _selectedSupplier!.id,
      'expectedDeliveryDate': _expectedDate.toIso8601String(),
      'items': _items.map((e) => {
        'productId': e['productId'],
        'quantity': e['quantity'],
        'unitCost': e['unitCost']
      }).toList(),
    };

    try {
      final success = await context.read<PurchaseOrderProvider>().createPurchaseOrder(poData);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase Order Created Successfully!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  double get _calculateTotal {
    return _items.fold(0.0, (sum, item) => sum + (item['totalCost'] as double));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('New Purchase Order', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSupplierSection(),
            const SizedBox(height: 20),
            _buildProductEntrySection(),
            const SizedBox(height: 24),
            _buildItemsListSection(),
            const SizedBox(height: 24),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Supplier Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 16),
            Consumer<SupplierProvider>(
              builder: (context, provider, _) {
                return DropdownButtonFormField<Supplier>(
                   value: _selectedSupplier,
                   decoration: InputDecoration(
                     labelText: 'Select Supplier',
                     prefixIcon: const Icon(Icons.store),
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                   ),
                   items: provider.suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                   onChanged: (val) => setState(() => _selectedSupplier = val),
                 );
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context, 
                  initialDate: _expectedDate, 
                  firstDate: DateTime.now(), 
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(primary: Color(0xFF1B5E20)),
                      ),
                      child: child!,
                    );
                  }
                );
                if (picked != null) setState(() => _expectedDate = picked);
              },
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Expected Delivery Date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(DateFormat('yyyy-MM-dd').format(_expectedDate)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductEntrySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Products', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 16),
            Consumer<ProductProvider>(
              builder: (context, provider, _) {
                return DropdownButtonFormField<Product>(
                  value: _selectedProduct,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Select Product',
                    prefixIcon: const Icon(Icons.inventory_2),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: provider.products.map((p) => DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedProduct = val;
                      // Auto-fill cost if available (assuming costPrice is in Product model)
                      // _costCtrl.text = val?.costPrice.toString() ?? ''; 
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _costCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Unit Cost (LKR)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add Item to Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order Items (${_items.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            if (_items.isNotEmpty)
              TextButton.icon(
                onPressed: () => setState(() => _items.clear()),
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_items.isEmpty)
           Container(
             width: double.infinity,
             padding: const EdgeInsets.all(32),
             decoration: BoxDecoration(
               color: Colors.grey[100],
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: Colors.grey[300]!)
             ),
             child: Column(
               children: [
                 Icon(Icons.assignment_add, size: 48, color: Colors.grey[400]),
                 const SizedBox(height: 12),
                 Text('No items added yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
               ],
             ),
           )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[50],
                    child: Text('${index + 1}', style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)),
                  ),
                  title: Text(item['productName'], style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${item['quantity']} Units  ×  LKR ${item['unitCost']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'LKR ${item['totalCost'].toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => setState(() => _items.removeAt(index)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))
        ]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Estimated Cost', style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text(
                'LKR ${_calculateTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: const Text('SUBMIT PURCHASE ORDER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
    );
  }
}
