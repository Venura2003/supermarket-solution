import 'package:flutter/material.dart';
import '../models/order.dart';

class RefundItemsDialog extends StatefulWidget {
  final Order order;
  const RefundItemsDialog({super.key, required this.order});

  @override
  State<RefundItemsDialog> createState() => _RefundItemsDialogState();
}

class _RefundItemsDialogState extends State<RefundItemsDialog> {
  final Map<int, int> _quantities = {};
  final Set<int> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    // Initialize with 0
    for (var item in widget.order.items) {
      _quantities[item.id] = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final refundableItems = widget.order.items.where((i) => (i.quantity - i.refundedQuantity) > 0).toList();

    return AlertDialog(
      title: Text('Refund Items - Order ${widget.order.code}'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: refundableItems.isEmpty 
          ? const Center(child: Text('No items available for refund.'))
          : ListView.builder(
              itemCount: refundableItems.length,
              itemBuilder: (context, index) {
                final item = refundableItems[index];
                final maxQty = item.quantity - item.refundedQuantity;
                final currentQty = _quantities[item.id] ?? 0;
                final isSelected = _selectedItems.contains(item.id);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedItems.add(item.id);
                        if (currentQty == 0) _quantities[item.id] = 1;
                      } else {
                        _selectedItems.remove(item.id);
                        _quantities[item.id] = 0;
                      }
                    });
                  },
                  title: Text(item.name),
                  subtitle: isSelected 
                    ? Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: currentQty > 1 ? () => setState(() => _quantities[item.id] = currentQty - 1) : null,
                          ),
                          Text('$currentQty / $maxQty'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: currentQty < maxQty ? () => setState(() => _quantities[item.id] = currentQty + 1) : null,
                          ),
                          const Spacer(),
                          Text('Ref: LKR ${(item.unitPrice * currentQty).toStringAsFixed(2)}')
                        ],
                      )
                    : Text('Qty: ${item.quantity} (Refunded: ${item.refundedQuantity}) • Max Refund: $maxQty'),
                );
              },
            ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _selectedItems.isEmpty ? null : () {
            // Build result list
            final results = <Map<String, dynamic>>[];
            for (var id in _selectedItems) {
               results.add({
                 'orderItemId': id,
                 'quantity': _quantities[id]
               });
            }
            Navigator.pop(context, results);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('Process Refund'),
        )
      ],
    );
  }
}
