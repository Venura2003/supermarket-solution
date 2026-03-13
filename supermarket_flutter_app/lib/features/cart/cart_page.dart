import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _barcodeCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScan() {
    final text = _barcodeCtrl.text.trim();
    if (text.isEmpty) return;

    int qty = 1;
    String code = text;

    // Check for "qty * barcode" pattern
    if (text.contains('*')) {
      final parts = text.split('*');
      if (parts.length == 2) {
        final parsedQty = int.tryParse(parts[0]);
        if (parsedQty != null && parsedQty > 0) {
          qty = parsedQty;
          code = parts[1].trim();
        }
      }
    }
    
    context.read<CartProvider>().addItemByBarcode(code, quantity: qty).then((_) {
      _barcodeCtrl.clear();
      _focusNode.requestFocus();
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      _barcodeCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _barcodeCtrl.text.length);
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cart = context.watch<CartProvider>();
          final isNarrow = constraints.maxWidth < 800;

          final scannerInput = Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _barcodeCtrl,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Scan Barcode / Enter Item Code',
                    prefixIcon: Icon(Icons.qr_code_scanner),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _onScan(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _onScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                ),
                child: const Text('Add'),
              ),
            ],
          );

          final summaryCard = Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Summary', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _SummaryRow(label: 'Subtotal', value: cart.subTotal),
                  _SummaryRow(label: 'Tax (12%)', value: cart.tax),
                  _SummaryRow(label: 'Discount', value: cart.discount),
                  const Divider(),
                  _SummaryRow(label: 'Total', value: cart.total, isBold: true),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: cart.items.isEmpty ? null : () => Navigator.pushNamed(context, '/checkout'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), padding: const EdgeInsets.all(16)),
                    child: const Text('Checkout', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cart (POS)',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B5E20),
                      ),
                ),
                const SizedBox(height: 16),
                scannerInput,
                const SizedBox(height: 16),
                Expanded(
                  child: cart.items.isEmpty 
                    ? const Center(child: Text('Cart is empty'))
                    : ListView.separated(
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, idx) {
                          final item = cart.items[idx];
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                    InkWell(
                                      onTap: () => cart.removeItem(item.productId),
                                      child: const Icon(Icons.close, color: Colors.red, size: 18),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () { if (item.quantity > 1) cart.updateQuantity(item.productId, item.quantity - 1); },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300), 
                                          borderRadius: BorderRadius.circular(4)
                                        ),
                                        child: const Icon(Icons.remove, size: 16),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    InkWell(
                                      onTap: () => cart.updateQuantity(item.productId, item.quantity + 1),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300), 
                                          borderRadius: BorderRadius.circular(4)
                                        ),
                                        child: const Icon(Icons.add, size: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('x ${item.unitPrice.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    const Spacer(),
                                    Text((item.unitPrice * item.quantity).toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ),
                const SizedBox(height: 12),
                summaryCard,
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cart (POS)',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1B5E20),
                            ),
                      ),
                      const SizedBox(height: 16),
                      scannerInput,
                      const SizedBox(height: 16),
                      Expanded(
                        child: cart.items.isEmpty
                            ? const Center(child: Text('Scan items to start sale'))
                            : ListView.separated(
                                itemCount: cart.items.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, idx) {
                                  final item = cart.items[idx];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green.shade50,
                                      child: const Icon(Icons.shopping_cart, color: Colors.green),
                                    ),
                                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('Unit Price: LKR ${item.unitPrice.toStringAsFixed(2)}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove),
                                            onPressed: () {
                                               if (item.quantity > 1) cart.updateQuantity(item.productId, item.quantity - 1);
                                            },
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey.shade300),
                                              borderRadius: BorderRadius.circular(4)
                                            ),
                                            child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () => cart.updateQuantity(item.productId, item.quantity + 1),
                                          ),
                                          const SizedBox(width: 16),
                                          Text('LKR ${(item.lineTotal).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => cart.removeItem(item.productId),
                                          ),
                                        ],
                                      ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                       const SizedBox(height: 60),
                       summaryCard
                    ],
                  )
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;

  const _SummaryRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
          Text('LKR ${value.toStringAsFixed(2)}', style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
        ],
      ),
    );
  }
}
