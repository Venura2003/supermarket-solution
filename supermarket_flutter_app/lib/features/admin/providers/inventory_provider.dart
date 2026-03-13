import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../models/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryRepository _repo = InventoryRepository();
  List<InventoryItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<InventoryItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchItems({String? q, bool force = false}) async {
    if (_items.isNotEmpty && !force) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.fetchItems(q: q);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStock(int id, int newQty) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repo.updateStock(id, newQty);
      final idx = _items.indexWhere((e) => e.id == id);
      if (idx >= 0) {
        final it = _items[idx];
        _items[idx] = InventoryItem(id: it.id, sku: it.sku, name: it.name, stock: newQty, reorderLevel: it.reorderLevel);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem({required String sku, required String name, required int stock, required int reorderLevel}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newItem = await _repo.createItem(sku: sku, name: name, stock: stock, reorderLevel: reorderLevel);
      _items.insert(0, newItem);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteItem(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.deleteItem(id);
      _items.removeWhere((e) => e.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> exportCsv() async {
    final headers = ['id', 'sku', 'name', 'stock', 'reorderLevel'];
    final rows = <String>[];
    rows.add(headers.join(','));
    for (final it in _items) {
      final cols = [it.id.toString(), _escapeCsv(it.sku), _escapeCsv(it.name), it.stock.toString(), it.reorderLevel.toString()];
      rows.add(cols.join(','));
    }
    final csv = rows.join('\n');

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path.replaceAll('\\', '/')}/inventory_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);
    // try open
    try {
      await OpenFile.open(file.path);
    } catch (_) {}
    return file.path;
  }

  String _escapeCsv(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      final escaped = v.replaceAll('"', '""');
      return '"$escaped"';
    }
    return v;
  }
}
