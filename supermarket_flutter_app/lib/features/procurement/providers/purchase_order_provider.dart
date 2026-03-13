import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../models/purchase_order.dart';

class PurchaseOrderProvider with ChangeNotifier {
  final AuthProvider? _authProvider;
  List<PurchaseOrder> _purchaseOrders = [];
  bool _isLoading = false;
  String? _error;

  PurchaseOrderProvider(this._authProvider);

  List<PurchaseOrder> get purchaseOrders => _purchaseOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get _token => _authProvider?.token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<void> fetchPurchaseOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/purchaseorders'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _purchaseOrders = data.map((item) => PurchaseOrder.fromJson(item)).toList();
      } else {
        _error = 'Failed to load purchase orders: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPurchaseOrder(Map<String, dynamic> poData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/purchaseorders'),
        headers: _headers,
        body: json.encode(poData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPurchaseOrders();
        return true;
      } else {
        _error = 'Failed to create purchase order: ${response.body}';
        return false;
      }
    } catch (e) {
      _error = 'Error creating purchase order: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> receiveOrder(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/purchaseorders/$id/receive'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        await fetchPurchaseOrders();
        return true;
      } else {
        _error = 'Failed to receive order: ${response.body}';
        return false;
      }
    } catch (e) {
      _error = 'Error receiving order: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
