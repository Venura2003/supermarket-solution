import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supermarket_flutter_app/core/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class CartItem {
  final int productId;
  final String name;
  int quantity;
  double unitPrice;

  CartItem({required this.productId, required this.name, this.quantity = 1, required this.unitPrice});

  double get lineTotal => quantity * unitPrice;
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  double taxRate = 0.12; // example 12%
  double discount = 0.0;

  List<CartItem> get items => List.unmodifiable(_items);

  double get subTotal => _items.fold(0.0, (s, i) => s + i.lineTotal);
  double get tax => subTotal * taxRate;
  double get total => subTotal + tax - discount;

  Future<void> addItem(CartItem item) async {
    try {
      // Defensive server-side stock check before adding
      final res = await ApiService.get('/products/${item.productId}');
      if (res.statusCode == 200) {
        final json = ApiService.safeDecode(res) as Map<String, dynamic>?;
        final serverStock = json != null && json['stock'] != null ? (json['stock'] as num).toInt() : null;
        if (serverStock != null && serverStock <= 0) {
          throw Exception('Out of stock');
        }
      }
    } catch (e) {
      // If the check failed due to network/auth issues, log in debug and allow add.
      if (kDebugMode) print('[CartProvider] Stock check failed or product unavailable: $e');
    }

    final existing = _items.firstWhere((i) => i.productId == item.productId, orElse: () => CartItem(productId: -1, name: '', unitPrice: 0));
    if (existing.productId != -1) {
      existing.quantity += item.quantity;
    } else {
      _items.add(item);
    }
    notifyListeners();
    // Persist to server so backend cart stays in sync with client UI
    try {
      await ApiService.addToCart({
        'ProductId': item.productId,
        'Quantity': item.quantity,
      });
    } catch (e) {
      if (kDebugMode) print('[CartProvider] Failed to persist cart item to server: $e');
    }
  }

  Future<void> addItemByBarcode(String barcode, {int quantity = 1}) async {
    try {
      final res = await ApiService.get('/products/barcode/$barcode');
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final id = json['id'] as int;
        final name = json['name'] as String;
        final price = (json['price'] as num).toDouble();
        
        // Stock check could be redundant as addItem checks it, 
        // but addItem implementation uses product endpoint check by ID.
        // The endpoint /products/barcode returns product details so we can trust it.
        
        await addItem(CartItem(productId: id, name: name, unitPrice: price, quantity: quantity));
      } else {
        throw Exception('Product not found');
      }
    } catch (e) {
      if (kDebugMode) print('[CartProvider] addItemByBarcode failed: $e');
      rethrow;
    }
  }

  void removeItem(int productId) {
    _items.removeWhere((i) => i.productId == productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    final item = _items.firstWhere((i) => i.productId == productId, orElse: () => CartItem(productId: -1, name: '', unitPrice: 0));
    if (item.productId != -1) {
      item.quantity = quantity;
      notifyListeners();
    }
  }

  Future<void> persistToServer(int employeeId) async {
    final payload = {
      'employeeId': employeeId,
      'items': _items.map((i) => {'productId': i.productId, 'quantity': i.quantity, 'unitPrice': i.unitPrice}).toList()
    };
    await ApiService.post('/cart/sync', payload);
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
