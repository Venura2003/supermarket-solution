import 'dart:convert';
import 'dart:io';

import 'package:supermarket_flutter_app/core/services/api_service.dart';
import '../../../core/models/report.dart';
import '../../reports/models/profit_summary.dart';

class ReportRepository {
  Future<DailySalesReport> getDailySales({DateTime? date}) async {
    final data = await ApiService.getDailySales(date: date);
    return DailySalesReport.fromJson(data);
  }

  Future<MonthlySalesReport> getMonthlySales({int? year, int? month}) async {
    final data = await ApiService.getMonthlySales(year: year, month: month);
    return MonthlySalesReport.fromJson(data);
  }

  Future<ProfitSummary> getProfitSummary({String? period, DateTime? startDate, DateTime? endDate}) async {
    final Map<String, String> params = {};
    if (period != null) params['period'] = period;
    if (startDate != null) params['startDate'] = startDate.toIso8601String();
    if (endDate != null) params['endDate'] = endDate.toIso8601String();

    final res = await ApiService.get('/reports/profit-summary', params: params);
    if (res.statusCode == 200) {
      return ProfitSummary.fromJson(jsonDecode(res.body));
    }
    throw HttpException('Failed to fetch profit summary: ${res.statusCode}');
  }

  Future<List<TopProduct>> getTopProducts({int limit = 10}) async {
    // Endpoint expected: /reports/top-products?limit=10
    final res = await ApiService.get('/reports/top-products', params: {'limit': limit.toString()});
    if (res.statusCode == 200) {
      final body = res.body;
      final decoded = body.isNotEmpty ? jsonDecode(body) as List<dynamic> : <dynamic>[];
      return decoded.map((e) => TopProduct.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Failed to fetch top products: ${res.statusCode}');
  }
}