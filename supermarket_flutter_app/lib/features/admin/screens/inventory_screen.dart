import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../products/providers/product_provider.dart';
import '../../../core/models/product.dart' as prod;

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

enum _Filter { all, low, out }

class _InventoryScreenState extends State<InventoryScreen> {
  _Filter _filter = _Filter.all;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<ProductProvider>();
      prov.fetchProducts(force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final mainContent = ChangeNotifierProvider<ProductProvider>.value(
          value: context.read<ProductProvider>(),
          child: Consumer<ProductProvider>(builder: (context, prov, _) {
            final list = prov.products;
            final total = prov.totalCount;
            final outCount = list.where((p) => p.stock == 0).length;
            final lowCount = list.where((p) => p.stock <= p.lowStockThreshold && p.stock > 0).length;

            List<prod.Product> filtered;
            switch (_filter) {
              case _Filter.low:
                filtered = list.where((p) => p.stock <= p.lowStockThreshold && p.stock > 0).toList();
                break;
              case _Filter.out:
                filtered = list.where((p) => p.stock == 0).toList();
                break;
              default:
                filtered = list;
            }

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Inventory', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 12),

                  // Summary
                  Row(children: [
                    _SummaryCard(label: 'Total products', value: total.toString(), color: Colors.blue),
                const SizedBox(width: 12),
                _SummaryCard(label: 'Low stock', value: lowCount.toString(), color: Colors.orange),
                const SizedBox(width: 12),
                _SummaryCard(label: 'Out of stock', value: outCount.toString(), color: Colors.redAccent),
              ]),

              const SizedBox(height: 12),

              // Search + filters
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search products by name'),
                    onSubmitted: (v) async {
                      if (v.isEmpty) {
                        await prov.fetchProducts(force: true);
                      } else {
                        await prov.searchProducts(v);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ToggleButtons(
                  isSelected: [_filter == _Filter.all, _filter == _Filter.low, _filter == _Filter.out],
                  onPressed: (i) => setState(() => _filter = _Filter.values[i]),
                  children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('All')), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Low Stock')), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Out of Stock'))],
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(onPressed: () => prov.fetchProducts(force: true), icon: const Icon(Icons.refresh), label: const Text('Refresh'))
              ]),

              const SizedBox(height: 12),

              Expanded(
                child: prov.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : LayoutBuilder(builder: (context, constraints) {
                        final cross = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1);
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cross, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 4),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final p = filtered[i];
                            final reorder = p.lowStockThreshold;
                            final stock = p.stock;
                            double pct = reorder > 0 ? (stock / reorder) * 100.0 : 100.0;
                            if (pct.isInfinite || pct.isNaN) pct = 100.0;
                            if (pct > 100) pct = 100;

                            Color barColor = Colors.green;
                            if (stock == 0) barColor = Colors.redAccent;
                            else if (stock <= reorder) barColor = Colors.orange;

                            final low = (stock <= reorder);
                            final out = (stock == 0);

                            return Opacity(
                              opacity: out ? 0.5 : 1.0,
                              child: Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                  child: Row(children: [
                                    Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                        Text(p.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 6),
                                        Row(children: [
                                          Expanded(
                                            child: LinearProgressIndicator(
                                              value: pct / 100.0,
                                              color: barColor,
                                              backgroundColor: Colors.grey.shade200,
                                              minHeight: 10,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                            Text('Stock: ${p.stock}', style: TextStyle(fontWeight: FontWeight.bold, color: barColor)),
                                            const SizedBox(height: 4),
                                            if (out)
                                              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.redAccent.shade100, borderRadius: BorderRadius.circular(8)), child: const Text('Out of Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
                                            else if (low)
                                              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)), child: const Text('Low Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
                                          ])
                                        ])
                                      ]),
                                    ),
                                  ]),
                                ),
                              ),
                            );
                          },
                        );
                      }),
              ),
            ]),
          ),
            );
          }),
        );
        if (isMobile) {
          return SingleChildScrollView(child: mainContent);
        } else {
          return mainContent;
        }
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(children: [
            CircleAvatar(backgroundColor: color, child: Text(value, style: const TextStyle(color: Colors.white))),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
          ]),
        ),
      ),
    );
  }
}
