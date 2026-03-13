import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../products/providers/report_provider.dart';
import 'models/profit_summary.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedPeriod = 'Monthly'; // 'Daily', 'Monthly', 'Yearly'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final provider = context.read<ReportProvider>();
    provider.loadProfitSummary(period: _selectedPeriod);
    provider.loadTopProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Financial & Sales Reports',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B5E20),
                    ),
              ),
              DropdownButton<String>(
                value: _selectedPeriod,
                items: const [
                  DropdownMenuItem(value: 'Daily', child: Text('Today')),
                  DropdownMenuItem(value: 'Monthly', child: Text('This Month')),
                  DropdownMenuItem(value: 'Yearly', child: Text('This Year')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedPeriod = val);
                    _loadData();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Consumer<ReportProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) return const Center(child: CircularProgressIndicator());
              if (provider.errorMessage != null) return Text('Error: ${provider.errorMessage}', style: const TextStyle(color: Colors.red));

              final summary = provider.profitSummary;
              
              return Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (summary != null) _buildSummaryCards(summary),
                      const SizedBox(height: 32),
                      const Text('Top Selling Products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      if (provider.topProducts.isEmpty)
                        const Text('No sales data available.')
                      else
                        Card(
                          elevation: 2,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Product')),
                              DataColumn(label: Text('Sold Qty'), numeric: true),
                              DataColumn(label: Text('Revenue'), numeric: true),
                            ],
                            rows: provider.topProducts.map((p) {
                              return DataRow(cells: [
                                DataCell(Text(p.name)),
                                DataCell(Text(p.quantitySold.toString())),
                                DataCell(Text('LKR ${p.revenue.toStringAsFixed(2)}')),
                              ]);
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ProfitSummary summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = width > 1100 ? 4 : (width > 600 ? 2 : 1);
        double childAspectRatio = width > 1100 ? 1.5 : (width > 600 ? 1.8 : 2.5);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _SummaryCard(title: 'Total Sales', value: summary.totalSales, color: Colors.blue, icon: Icons.shopping_bag),
            _SummaryCard(title: 'Product Cost', value: summary.totalProductCost, color: Colors.orange, icon: Icons.inventory_2),
            _SummaryCard(title: 'Expenses', value: summary.totalExpenses, color: Colors.red, icon: Icons.money_off),
            _SummaryCard(title: 'Net Profit', value: summary.netProfit, color: Colors.green, icon: Icons.monetization_on, isBold: true),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  final IconData icon;
  final bool isBold;

  const _SummaryCard({required this.title, required this.value, required this.color, required this.icon, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'LKR ${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: isBold ? color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
