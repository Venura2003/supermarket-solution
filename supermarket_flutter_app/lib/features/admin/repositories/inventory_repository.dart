import 'dart:convert';
import 'dart:io';

import 'package:supermarket_flutter_app/core/services/api_service.dart';
import '../models/inventory_item.dart';

class InventoryRepository {
  Future<List<InventoryItem>> fetchItems({String? q}) async {
    final params = <String, String>{};
    if (q != null && q.isNotEmpty) params['q'] = q;
    final res = await ApiService.get('/inventory/items', params: params);
    if (res.statusCode == 200) {
      final body = res.body;
      final decoded = body.isNotEmpty ? jsonDecode(body) as List<dynamic> : <dynamic>[];
      return decoded.map((e) => InventoryItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Failed to fetch inventory items: ${res.statusCode}');
  }

  Future<void> updateStock(int id, int newQty) async {
    final res = await ApiService.put('/inventory/items/$id/stock', {'stock': newQty});
    if (res.statusCode != 200 && res.statusCode != 204) throw HttpException('Failed to update stock: ${res.statusCode}');
  }

  Future<InventoryItem> createItem({required String sku, required String name, required int stock, required int reorderLevel}) async {
    final payload = {'sku': sku, 'name': name, 'stock': stock, 'reorderLevel': reorderLevel};
    final res = await ApiService.post('/inventory/items', payload);
    if (res.statusCode == 201 || res.statusCode == 200) {
      final body = res.body;
      final decoded = body.isNotEmpty ? jsonDecode(body) as Map<String, dynamic> : <String, dynamic>{};
      return InventoryItem.fromJson(decoded);
    }
    throw HttpException('Failed to create inventory item: ${res.statusCode}');
  }

  Future<void> deleteItem(int id) async {
    final res = await ApiService.delete('/inventory/items/$id');
    if (res.statusCode != 200 && res.statusCode != 204) throw HttpException('Failed to delete inventory item: ${res.statusCode}');
  }
}
