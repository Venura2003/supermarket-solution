import 'package:flutter/material.dart';
import '../repositories/grn_repository.dart';

class GrnProvider extends ChangeNotifier {
  final GrnRepository _repository = GrnRepository();
  List<dynamic> _grns = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get grns => _grns;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchGrns() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _grns = await _repository.getGrns();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createGrn({
    required int supplierId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = {'supplierId': supplierId, 'items': items, 'notes': notes};
      await _repository.createGrn(data);
      // Refresh list
      await fetchGrns();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
