import 'package:flutter/material.dart';
import '../../../core/models/product.dart';
import '../../../core/models/notification.dart';
import '../../../core/models/report.dart';
import '../../../features/products/repositories/product_repository.dart';
import '../../../features/products/repositories/notification_repository.dart';
import '../../../features/products/repositories/report_repository.dart';

class DashboardProvider with ChangeNotifier {
  final ProductRepository _productRepository = ProductRepository();
  final NotificationRepository _notificationRepository = NotificationRepository();
  final ReportRepository _reportRepository = ReportRepository();

  DailySalesReport? _dailyReport;
  MonthlySalesReport? _monthlyReport;
  List<Product> _lowStockProducts = [];
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  DailySalesReport? get dailyReport => _dailyReport;
  MonthlySalesReport? get monthlyReport => _monthlyReport;
  List<Product> get lowStockProducts => _lowStockProducts;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalOrders => _dailyReport?.totalOrders ?? 0;
  double get totalRevenue => _dailyReport?.totalSalesAmount ?? 0.0;
  double get monthlyRevenue => _monthlyReport?.totalSalesAmount ?? 0.0;
  int get lowStockCount => _lowStockProducts.length;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _reportRepository.getDailySales(),
        _reportRepository.getMonthlySales(),
        _productRepository.getProducts(),
        _notificationRepository.getNotifications(),
      ]);

      _dailyReport = results[0] as DailySalesReport;
      _monthlyReport = results[1] as MonthlySalesReport;
      final products = results[2] as List<Product>;
      _notifications = results[3] as List<NotificationModel>;

      // Filter low stock products
      _lowStockProducts = products.where((p) => p.stock <= p.lowStockThreshold).toList();

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async => await loadDashboardData();
}