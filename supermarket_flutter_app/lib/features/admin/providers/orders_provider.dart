import 'package:flutter/material.dart';
import '../models/order.dart';
import '../repositories/orders_repository.dart';

class OrdersProvider with ChangeNotifier {
  final OrdersRepository _repo = OrdersRepository();
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders({DateTime? startDate, DateTime? endDate, String? status, String? paymentMethod, bool force = false}) async {
    if (_orders.isNotEmpty && !force) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _repo.fetchOrders(startDate: startDate, endDate: endDate, status: status, paymentMethod: paymentMethod);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> getOrderDetails(int id) async {
    try {
      return await _repo.getOrder(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancelOrder(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repo.cancelOrder(id);
      _orders.removeWhere((o) => o.id == id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> refundOrder(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repo.refundOrder(id);
      final index = _orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        // Ideally we update the object, but for now let's just mark it as Refunded in the list if possible
        // Since fields are final, we can't update in place easily without copyWith.
        // Let's just fetch everything again to be sure.
        _orders = await _repo.fetchOrders();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> refundOrderItems(int id, List<Map<String, dynamic>> items) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repo.refundOrderItems(id, items);
      await fetchOrders(force: true); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
