import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../reports/screens/pdf_preview_screen.dart'; // Import PdfPreviewScreen
import '../../../core/services/pdf_report_service.dart';
import '../../../features/products/providers/report_provider.dart';
import '../../dashboard/widgets/sales_analytics_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  final PdfReportService _pdfService = PdfReportService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReports();
      // also load top products
      context.read<ReportProvider>().loadTopProducts();
    });
  }

  void _loadReports() {
    final provider = context.read<ReportProvider>();
    provider.loadDailyReport(date: _selectedDate);
    provider.loadMonthlyReport(year: _selectedYear, month: _selectedMonth);
    
    // Load profit summary for the selected month to show on screen
    final startOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
    final endOfMonth = DateTime(_selectedYear, _selectedMonth + 1, 0);
    provider.loadProfitSummary(
      startDate: startOfMonth,
      endDate: endOfMonth,
      period: 'Monthly'
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
         _selectedDate = picked;
         _selectedYear = picked.year;
         _selectedMonth = picked.month;
      });
      _loadReports();
    }
  }

  Future<void> _handleExport() async {
    final provider = context.read<ReportProvider>();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export Report', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.today),
              title: Text('Daily Report (${DateFormat('MMM dd').format(_selectedDate)})'),
              subtitle: const Text('Includes sales, expenses, and profit for the selected day.'),
              onTap: () async {
                Navigator.pop(ctx);
                await _generatePdfReport(
                  title: 'Daily Financial Report',
                  period: DateFormat('MMMM dd, yyyy').format(_selectedDate),
                  startDate: _selectedDate,
                  endDate: _selectedDate,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text('Monthly Report (${DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth))})'),
              subtitle: const Text('Includes full month financial summary.'),
              onTap: () async {
                Navigator.pop(ctx);
                final start = DateTime(_selectedYear, _selectedMonth, 1);
                final end = DateTime(_selectedYear, _selectedMonth + 1, 0);
                 await _generatePdfReport(
                  title: 'Monthly Financial Report',
                  period: DateFormat('MMMM yyyy').format(start),
                  startDate: start,
                  endDate: end,
                );
              },
            ),
             ListTile(
              leading: const Icon(Icons.calendar_view_week),
              title: Text('Annual Report ($_selectedYear)'),
              subtitle: const Text('Includes full year financial summary.'),
              onTap: () async {
                Navigator.pop(ctx);
                final start = DateTime(_selectedYear, 1, 1);
                final end = DateTime(_selectedYear, 12, 31);
                 await _generatePdfReport(
                  title: 'Annual Financial Report',
                  period: 'Year $_selectedYear',
                  startDate: start,
                  endDate: end,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePdfReport({
    required String title,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final provider = context.read<ReportProvider>();
      
      // Fetch data specifically for the report
      final profitData = await provider.fetchProfitSummaryForExport(
        startDate: startDate,
        endDate: endDate,
        period: 'Custom'
      );
      
      // Use existing top products or fetch new ones?
      // For now, use existing state or fetch 10 items
      // We will just use the current top products list for context, 
      // or we could fetch top products strictly for that period if the API supported it.
      // Assuming existing top products are "overall" or based on recent activity.
      final topProducts = provider.topProducts;

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      final pdfBytes = await _pdfService.generateProfitReport(
        title: title,
        reportDate: startDate,
        periodDetails: period,
        profitData: profitData,
        topProducts: topProducts,
      );

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PdfPreviewScreen(
            title: title,
            pdfBytes: pdfBytes,
            fileName: '${title.replaceAll(" ", "_")}_$period.pdf',
          ),
        ),
      );

    } catch (e) {
      Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating report: $e')));
      }
    }
  }

  void _selectMonthYear(int year, int month) {
    setState(() {
      _selectedYear = year;
      _selectedMonth = month;
    });
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);
    // Build simpler, less nested UI to avoid parser issues and overflows
    final kpiCards = Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildKpiCard(context, DateFormat('MMM dd').format(_selectedDate), reportProvider.dailyReport != null ? 'LKR ${NumberFormat('#,##0.00').format(reportProvider.dailyReport!.totalSalesAmount)}' : '-', 'Orders: ${reportProvider.dailyReport?.totalOrders ?? '-'}'),
        _buildKpiCard(context, DateFormat('MMM yyyy').format(DateTime(_selectedYear, _selectedMonth)), reportProvider.monthlyReport != null ? 'LKR ${NumberFormat('#,##0.00').format(reportProvider.monthlyReport!.totalSalesAmount)}' : '-', 'Orders: ${reportProvider.monthlyReport?.totalOrders ?? '-'}'),
        // Profit Card
        _buildKpiCard(
          context, 
          'Net Profit (${DateFormat('MMM').format(DateTime(_selectedYear, _selectedMonth))})', 
          reportProvider.profitSummary != null ? 'LKR ${NumberFormat('#,##0.00').format(reportProvider.profitSummary!.netProfit)}' : '-',
          reportProvider.profitSummary != null ? (reportProvider.profitSummary!.netProfit >= 0 ? 'Profitable' : 'Loss') : '',
          color: reportProvider.profitSummary != null && reportProvider.profitSummary!.netProfit < 0 ? Colors.red.shade50 : null
        ),
        _buildKpiCard(context, 'Top Product', reportProvider.topProducts.isNotEmpty ? reportProvider.topProducts.first.name : '-', ''),
      ],
    );

    final chartCard = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Sales (last 30 days)', style: Theme.of(context).textTheme.titleLarge),
            TextButton.icon(onPressed: () => _selectDate(context), icon: const Icon(Icons.calendar_today), label: Text(DateFormat('MMM dd, yyyy').format(_selectedDate))),
          ]),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SalesAnalyticsChart(
                dailySalesOverride: reportProvider.dailyReport?.totalSalesAmount,
                monthlySalesOverride: reportProvider.monthlyReport?.totalSalesAmount,
                isLoadingOverride: reportProvider.isLoading,
                dailyLabel: DateFormat('MMM dd').format(_selectedDate),
                monthlyLabel: DateFormat('MMM yyyy').format(DateTime(_selectedYear, _selectedMonth)),
              ),
            ),
          ),
        ]),
      ),
    );

    final topSellingCard = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Top Selling', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (reportProvider.isLoading) const Center(child: CircularProgressIndicator())
          else if (reportProvider.topProducts.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reportProvider.topProducts.length > 8 ? 8 : reportProvider.topProducts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = reportProvider.topProducts[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('Sold: ${p.quantitySold} • LKR ${p.revenue.toStringAsFixed(2)}'),
                );
              },
            )
          else
            const Text('No top products data'),
        ]),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reports', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          kpiCards,
          const SizedBox(height: 18),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 2, child: chartCard),
            const SizedBox(width: 16),
            Expanded(child: topSellingCard),
          ]),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: _handleExport,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('View Report'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ReportItem extends StatelessWidget {
  final String label;
  final String value;

  const _ReportItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildKpiCard(BuildContext context, String title, String value, String subtitle, {Color? color}) {
  return SizedBox(
    width: 360,
    child: Card(
      elevation: 2,
      color: color, // Uses optional color for highlighting profit/loss
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: subtitle == 'Loss' ? Colors.red : null,
              fontWeight: FontWeight.w500
            )),
          ]
        ]),
      ),
    ),
  );
}