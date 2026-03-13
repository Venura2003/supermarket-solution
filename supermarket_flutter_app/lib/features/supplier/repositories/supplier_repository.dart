import 'dart:convert';
import 'package:supermarket_flutter_app/features/supplier/models/supplier.dart';
import 'package:supermarket_flutter_app/core/services/api_service.dart';

class SupplierRepository {
  Future<List<Supplier>> getSuppliers() async {
    final response = await ApiService.get('/Suppliers');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Supplier.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load suppliers: ${response.statusCode}');
    }
  }

  Future<Supplier> addSupplier(
    String name,
    String? contactNo,
    String? address,
  ) async {
    final response = await ApiService.post('/Suppliers', {
      'name': name,
      'contactNo': contactNo,
      'address': address,
    });

    if (response.statusCode == 201) {
      return Supplier.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add supplier: ${response.statusCode}');
    }
  }
}
