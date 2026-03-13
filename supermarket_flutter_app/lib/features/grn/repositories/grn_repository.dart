import 'dart:convert';
import 'package:supermarket_flutter_app/core/services/api_service.dart';

class GrnRepository {
  Future<List<dynamic>> getGrns() async {
    final response = await ApiService.get('/Grn');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load GRNs');
    }
  }

  Future<Map<String, dynamic>> getGrn(int id) async {
    final response = await ApiService.get('/Grn/$id');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load GRN details');
    }
  }

  Future<void> createGrn(Map<String, dynamic> grnData) async {
    // grnData should match CreateGRNDto structure
    final response = await ApiService.post('/Grn', grnData);
    if (response.statusCode != 201) {
      throw Exception('Failed to create GRN: ${response.body}');
    }
  }
}
