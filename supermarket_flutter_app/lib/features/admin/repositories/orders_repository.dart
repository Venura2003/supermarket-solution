import 'dart:convert';
import 'dart:io';

import 'package:supermarket_flutter_app/core/services/api_service.dart';
import '../models/order.dart';

class OrdersRepository {
  Future<List<Order>> fetchOrders({DateTime? startDate, DateTime? endDate, String? status, String? paymentMethod, int pageNumber = 1, int pageSize = 50}) async {
    final params = <String, String>{'pageNumber': pageNumber.toString(), 'pageSize': pageSize.toString()};
    if (startDate != null) params['startDate'] = startDate.toIso8601String();
    if (endDate != null) params['endDate'] = endDate.toIso8601String();
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (paymentMethod != null && paymentMethod.isNotEmpty) params['paymentMethod'] = paymentMethod;

    final res = await ApiService.get('/orders', params: params);
    if (res.statusCode == 200) {
      final body = res.body;
      final decoded = body.isNotEmpty ? jsonDecode(body) as List<dynamic> : <dynamic>[];
      return decoded.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Failed to fetch orders: ${res.statusCode}');
  }

  Future<Order?> getOrder(int id) async {
    final res = await ApiService.get('/orders/$id');
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      return Order.fromJson(decoded);
    }
    if (res.statusCode == 404) return null;
    throw HttpException('Failed to get order: ${res.statusCode}');
  }

  Future<void> cancelOrder(int id) async {
    final res = await ApiService.delete('/orders/$id');
    if (res.statusCode != 200 && res.statusCode != 204) throw HttpException('Failed to cancel order: ${res.statusCode}');
  }

  Future<void> refundOrder(int id) async {
    final res = await ApiService.post('/orders/$id/refund', {});
    if (res.statusCode != 200) throw HttpException('Failed to refund order: ${res.statusCode}');
  }

  Future<void> refundOrderItems(int id, List<Map<String, dynamic>> items) async {
    final res = await ApiService.post('/orders/$id/refund-items', {'items': items});
    if (res.statusCode != 200) throw HttpException('Failed to refund items: ${res.statusCode}');
  }
}
