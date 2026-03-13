import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders_provider.dart';
import '../models/order.dart';
import '../widgets/refund_items_dialog.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<OrdersProvider>(builder: (context, prov, _) {
            final filteredOrders = prov.orders.where((o) => 
               o.code.toLowerCase().contains(_searchQuery.toLowerCase()) || 
               (o.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
            ).toList();

            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Orders', style: Theme.of(context).textTheme.headlineMedium),
                Row(children: [
                  ElevatedButton.icon(onPressed: () => prov.fetchOrders(force: true), icon: const Icon(Icons.refresh), label: const Text('Refresh')),
                ])
              ]),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search Orders',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  hintText: 'Search by Order ID or Employee Name',
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: prov.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : prov.error != null
                        ? Center(child: Text('Error: ${prov.error}', style: const TextStyle(color: Colors.red)))
                        : filteredOrders.isEmpty
                            ? const Center(child: Text('No orders found'))
                            : ListView.separated(
                                itemCount: filteredOrders.length,
                                separatorBuilder: (_, __) => const Divider(height: 8),
                                itemBuilder: (context, i) {
                                  final o = filteredOrders[i];
                                  Future<void> _onCancel() async {
                                final ok = await showDialog<bool>(context: context, builder: (ctx) {
                                  return AlertDialog(
                                    title: const Text('Cancel Order'),
                                    content: Text('Cancel order ${o.code}? This will restock items.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
                                      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Yes')),
                                    ],
                                  );
                                });
                                if (ok == true) await prov.cancelOrder(o.id);
                              }

                              return _OrderCard(order: o, onView: () => _viewOrder(context, prov, o), onCancel: _onCancel);
                            },
                          ),
              )
            ]);
          }),
        ),
      );
  }

  void _viewOrder(BuildContext context, OrdersProvider prov, Order order) async {
    final details = await prov.getOrderDetails(order.id);
    if (details == null) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load order details')));
      return;
    }
    if (!context.mounted) return;
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: Text('Order ${details.code}'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Status: ${details.status}'),
              Text('Payment: ${details.paymentMethod}'),
              Text('Customer: ${details.customerName ?? "-"}'),
              Text('Date: ${details.formattedDate}'),
              const SizedBox(height: 12),
              const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ...details.items.map((it) => ListTile(title: Text(it.name), subtitle: Text('Qty: ${it.quantity} • Unit: LKR ${it.unitPrice.toStringAsFixed(2)}'), trailing: Text('LKR ${it.total.toStringAsFixed(2)}'))).toList(),
              const SizedBox(height: 8),
              Text('Total: LKR ${details.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (details.status == 'Refunded') 
                 Padding(padding: const EdgeInsets.only(top: 8), child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(8)),
                    child: const Text('ORDER REFUNDED', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                 )),
            ]),
          ),
        ),
        actions: [
          if (details.status == 'Completed')
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                 final items = await showDialog(
                   context: ctx,
                   builder: (context) => RefundItemsDialog(order: details),
                 );
                 if (items != null && items is List && items.isNotEmpty) {
                    // ignore: use_build_context_synchronously
                    _handleRefundItems(context, ctx, prov, details.id, items as List<Map<String, dynamic>>);
                 }
              },
              child: const Text('Refund Items'),
            ),
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
        ],
      );
    });
  }

  void _handleRefundItems(BuildContext parentContext, BuildContext dialogContext, OrdersProvider prov, int orderId, List<Map<String, dynamic>> items) async {
      Navigator.pop(dialogContext); // Close details dialog
      
      final success = await prov.refundOrderItems(orderId, items);
      
      if (parentContext.mounted) {
        if (success) {
          ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('Items refunded successfully')));
        } else {
          ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(content: Text('Refund failed: ${prov.error}')));
        }
      }
  }

  void _handleRefund(BuildContext parentContext, BuildContext dialogContext, OrdersProvider prov, int orderId) async {
    final confirm = await showDialog<bool>(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Refund'),
        content: const Text('Are you sure you want to refund this order?\nThis will restore stock and mark the order as Refunded.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Refund'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (dialogContext.mounted) Navigator.pop(dialogContext); // Close details dialog

      final success = await prov.refundOrder(orderId);
      if (parentContext.mounted && success) {
        ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('Order refunded successfully')));
      } else if (parentContext.mounted) {
        ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(content: Text('Refund failed: ${prov.error}')));
      }
    }
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onView;
  final VoidCallback onCancel;

  const _OrderCard({required this.order, required this.onView, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(order.code, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text('${order.formattedDate} • ${order.paymentMethod} • ${order.customerName ?? "-"}'),
              const SizedBox(height: 6),
              Text(
                'Items: ${order.items.fold(0, (sum, item) => sum + item.quantity)} • Total: LKR ${order.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              if (order.status == 'Refunded')
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(4)),
                    child: const Text('REFUNDED', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))
                  ),
                ),
            ]),
          ),
          Row(children: [IconButton(onPressed: onView, icon: const Icon(Icons.visibility)), IconButton(onPressed: onCancel, icon: const Icon(Icons.cancel, color: Colors.redAccent))])
        ]),
      ),
    );
  }
}
