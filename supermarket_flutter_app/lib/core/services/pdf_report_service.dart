import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/reports/models/profit_summary.dart';
import '../../core/models/report.dart';

class PdfReportService {
  final NumberFormat _currencyFormat = NumberFormat.simpleCurrency(name: 'LKR');

  Future<Uint8List> generateProfitReport({
    required String title,
    required DateTime reportDate,
    required String periodDetails, // e.g. "March 2024" or "2024-03-15"
    required ProfitSummary profitData,
    List<TopProduct>? topProducts,
    // You could also pass expense breakdown if available
  }) async {
    final pdf = pw.Document();

    // Load fonts or images if needed (optional for basic report)
    // final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(title, periodDetails),
          pw.SizedBox(height: 20),
          _buildFinancialSummary(profitData),
          pw.SizedBox(height: 20),
          if (topProducts != null && topProducts.isNotEmpty) _buildTopProductsTable(topProducts),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(String title, String period) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Supermarket Solution', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text('Report Period: $period', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildFinancialSummary(ProfitSummary data) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      padding: const pw.EdgeInsets.all(16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Financial Overview', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          _buildSummaryRow('Total Income (Sales)', data.totalSales, isPositive: true),
          _buildSummaryRow('Cost of Goods Sold (COGS)', -data.totalProductCost, isPositive: false),
          pw.Divider(color: PdfColors.grey300),
          _buildSummaryRow('Gross Profit', data.grossProfit, isBold: true),
          pw.SizedBox(height: 8),
          _buildSummaryRow('Operating Expenses', -data.totalExpenses, isPositive: false),
          pw.Divider(color: PdfColors.black, thickness: 1.5),
          _buildSummaryRow('Net Profit', data.netProfit, isBold: true, fontSize: 16, color: data.netProfit >= 0 ? PdfColors.green800 : PdfColors.red800),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryRow(String label, double amount, {bool isBold = false, bool isPositive = true, double fontSize = 12, PdfColor? color}) {
    final style = pw.TextStyle(
      fontSize: fontSize,
      fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: color ?? PdfColors.black,
    );

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(
            '${amount < 0 ? "- " : ""}${_currencyFormat.format(amount.abs())}',
            style: style,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTopProductsTable(List<TopProduct> products) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Top Performing Products', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ['Product Name', 'Qty Sold', 'Revenue'],
          data: products.map((p) => [
            p.name,
            p.quantitySold.toString(),
            _currencyFormat.format(p.revenue),
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
          cellAlignment: pw.Alignment.centerLeft,
          headerAlignment: pw.Alignment.centerLeft,
        ),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Generated on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
          ),
        ),
      ],
    );
  }
}
