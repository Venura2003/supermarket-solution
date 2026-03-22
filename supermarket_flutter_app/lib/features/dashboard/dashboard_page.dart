import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'widgets/kpi_cards.dart';
import 'widgets/sales_analytics_chart.dart';
import 'widgets/low_stock_alerts_panel.dart';
import 'package:provider/provider.dart';
import '../products/screens/add_edit_product_screen.dart';
import '../../core/providers/cart_provider.dart';
import 'providers/dashboard_provider.dart';

class DashboardPage extends StatefulWidget {
  final Function(int)? onSwitchTab;
  const DashboardPage({super.key, this.onSwitchTab});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
    @override
    void initState() {
      super.initState();
      // Ensure dashboard data is loaded when the page is opened
      Future.microtask(() {
        final provider = Provider.of<DashboardProvider>(context, listen: false);
        provider.loadDashboardData();
      });
    }
  final GlobalKey _repaintKey = GlobalKey();
  bool _saving = false;

  Future<void> _captureAndSave() async {
    try {
      setState(() => _saving = true);
      final renderObject = _repaintKey.currentContext?.findRenderObject();
      if (renderObject == null) throw Exception('Render boundary not found');
      final dynamic boundary = renderObject;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to convert image');
      final bytes = byteData.buffer.asUint8List();

      final dir = Directory.current.path;
      final sep = Platform.pathSeparator;
      final outDir = Directory('$dir${sep}build');
      if (!outDir.existsSync()) outDir.createSync(recursive: true);
      final outFile = File('${outDir.path}${sep}dashboard_screenshot.png');
      await outFile.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Screenshot saved: ${outFile.path}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Screenshot failed: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
      child: SingleChildScrollView(
        child: RepaintBoundary(
          key: _repaintKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header: title + quick actions (responsive)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good day, Manager',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Dashboard',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _QuickAction(icon: Icons.add_box_outlined, label: 'Add Product', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditProductScreen()))),
                            _QuickAction(icon: Icons.inventory_2_outlined, label: 'Inventory', onTap: () {
                              if (widget.onSwitchTab != null) widget.onSwitchTab!(7);
                            }),
                            _QuickAction(icon: Icons.pie_chart_outline, label: 'Reports', onTap: () {
                              if (widget.onSwitchTab != null) widget.onSwitchTab!(4);
                            }),
                            Tooltip(
                              message: _saving ? 'Saving...' : 'Save a screenshot',
                              child: ElevatedButton.icon(
                                onPressed: _saving ? null : _captureAndSave,
                                icon: const Icon(Icons.camera_alt_outlined),
                                label: Text(_saving ? 'Saving' : 'Save'),
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good day, Manager',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Dashboard',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Quick actions
                        Row(
                          children: [
                            _QuickAction(icon: Icons.add_box_outlined, label: 'Add Product', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditProductScreen()))),
                            const SizedBox(width: 8),
                            _QuickAction(icon: Icons.inventory_2_outlined, label: 'Inventory', onTap: () {
                              if (widget.onSwitchTab != null) widget.onSwitchTab!(7);
                            }),
                            const SizedBox(width: 8),
                            _QuickAction(icon: Icons.pie_chart_outline, label: 'Reports', onTap: () {
                              if (widget.onSwitchTab != null) widget.onSwitchTab!(4);
                            }),
                            const SizedBox(width: 8),
                            Tooltip(
                              message: _saving ? 'Saving...' : 'Save a screenshot',
                              child: ElevatedButton.icon(
                                onPressed: _saving ? null : _captureAndSave,
                                icon: const Icon(Icons.camera_alt_outlined),
                                label: Text(_saving ? 'Saving' : 'Save'),
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 18),

              // Search / filter bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search product, order, or customer...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (q) {
                        if (q.isNotEmpty) {
                          Navigator.pushNamed(context, '/product-search', arguments: q);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.read<DashboardProvider>().refreshData(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Responsive layout: main + sidebar
              LayoutBuilder(builder: (context, constraints) {
                final isWide = constraints.maxWidth > 920;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SizedBox(height: 220, child: KpiCards()),
                            SizedBox(height: 28),
                            SalesAnalyticsChart(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 420,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            LowStockAlertsPanel(),
                            SizedBox(height: 20),
                            _RecentActivityPanel(),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      KpiCards(),
                      SizedBox(height: 20),
                      SalesAnalyticsChart(),
                      SizedBox(height: 20),
                      LowStockAlertsPanel(),
                      SizedBox(height: 20),
                      _RecentActivityPanel(),
                    ],
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityPanel extends StatelessWidget {
  const _RecentActivityPanel();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Activity', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                TextButton(onPressed: () => provider.refreshData(), child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 8),
            if (provider.isLoading) const Center(child: CircularProgressIndicator())
            else if (provider.notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('No recent activity', style: TextStyle(color: Colors.grey)),
              )
            else
              Column(
                children: provider.notifications.take(6).map((n) {
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(child: Icon(Icons.notifications, size: 18)),
                    title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(n.message, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(TimeOfDay.fromDateTime(n.createdAt).format(context), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

