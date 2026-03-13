import 'package:flutter/material.dart';
import '../../../core/models/report.dart';
import '../../reports/models/profit_summary.dart';
import '../repositories/report_repository.dart';

class ReportProvider with ChangeNotifier {
  final ReportRepository _reportRepository = ReportRepository();
  DailySalesReport? _dailyReport;
  MonthlySalesReport? _monthlyReport;
  ProfitSummary? _profitSummary;
  List<TopProduct> _topProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  DailySalesReport? get dailyReport => _dailyReport;
  MonthlySalesReport? get monthlyReport => _monthlyReport;
  ProfitSummary? get profitSummary => _profitSummary;
  List<TopProduct> get topProducts => _topProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDailyReport({DateTime? date}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dailyReport = await _reportRepository.getDailySales(date: date);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMonthlyReport({int? year, int? month}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _monthlyReport = await _reportRepository.getMonthlySales(year: year, month: month);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfitSummary({String? period, DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profitSummary = await _reportRepository.getProfitSummary(period: period, startDate: startDate, endDate: endDate);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to fetch data without updating state (for exports)
  Future<ProfitSummary> fetchProfitSummaryForExport({String? period, DateTime? startDate, DateTime? endDate}) {
    return _reportRepository.getProfitSummary(period: period, startDate: startDate, endDate: endDate);
  }

  Future<void> loadTopProducts({int limit = 10}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _topProducts = await _reportRepository.getTopProducts(limit: limit);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}