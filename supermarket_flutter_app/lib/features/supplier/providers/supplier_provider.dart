import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../repositories/supplier_repository.dart';

class SupplierProvider extends ChangeNotifier {
  final SupplierRepository _repository = SupplierRepository();
  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _error;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSuppliers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _suppliers = await _repository.getSuppliers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSupplier(
    String name,
    String? contactNo,
    String? address,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final supplier = await _repository.addSupplier(name, contactNo, address);
      _suppliers.add(supplier);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
