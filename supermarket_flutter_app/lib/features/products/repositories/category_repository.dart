import 'package:supermarket_flutter_app/core/services/api_service.dart';
import '../../../core/models/category.dart';

class CategoryRepository {
  Future<List<Category>> getCategories() async {
    print('[CategoryRepository] GET /categories');
    final response = await ApiService.get('/categories');
    print('[CategoryRepository] Status: ${response.statusCode}');
    print('[CategoryRepository] Response: ${response.body}');
    final data = ApiService.safeDecode(response);
    if (data == null) return [];
    try {
      // Support both direct list and wrapped { data: [...] }
      final list = data is List ? data : (data['data'] ?? []);
      return List<Category>.from(list.map((json) => Category.fromJson(json)));
    } catch (e) {
      print('JSON Decode Error: $e');
      print('Response Body: ${response.body}');
      return [];
    }
  }

  Future<Category?> getCategory(int id) async {
    print('[CategoryRepository] GET /categories/$id');
    final response = await ApiService.get('/categories/$id');
    print('[CategoryRepository] Status: ${response.statusCode}');
    print('[CategoryRepository] Response: ${response.body}');
    final data = ApiService.safeDecode(response);
    if (data == null) return null;
    try {
      return Category.fromJson(data is Map ? data : (data['data'] ?? {}));
    } catch (e) {
      print('JSON Decode Error: $e');
      print('Response Body: ${response.body}');
      return null;
    }
  }

  Future<Category?> createCategory(Category category) async {
    final payload = category.toJson();
    print('[CategoryRepository] POST /categories');
    print('[CategoryRepository] Payload: $payload');
    final response = await ApiService.post('/categories', payload);
    print('[CategoryRepository] Status: ${response.statusCode}');
    print('[CategoryRepository] Response: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Backend Error: ${response.body}');
      throw Exception('Failed: ${response.body}');
    }
    final data = ApiService.safeDecode(response);
    if (data == null) return null;
    try {
      return Category.fromJson(data is Map ? data : (data['data'] ?? {}));
    } catch (e) {
      print('JSON Decode Error: $e');
      print('Response Body: ${response.body}');
      return null;
    }
  }

  Future<Category?> updateCategory(Category category) async {
    final payload = category.toJson();
    print('[CategoryRepository] PUT /categories/${category.id}');
    print('[CategoryRepository] Payload: $payload');
    final response = await ApiService.put('/categories/${category.id}', payload);
    print('[CategoryRepository] Status: ${response.statusCode}');
    print('[CategoryRepository] Response: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
      print('Backend Error: ${response.body}');
      throw Exception('Failed: ${response.body}');
    }
    final data = ApiService.safeDecode(response);
    if (data == null) return null;
    try {
      return Category.fromJson(data is Map ? data : (data['data'] ?? {}));
    } catch (e) {
      print('JSON Decode Error: $e');
      print('Response Body: ${response.body}');
      return null;
    }
  }

  Future<void> deleteCategory(int id) async {
    print('[CategoryRepository] DELETE /categories/$id');
    final response = await ApiService.delete('/categories/$id');
    print('[CategoryRepository] Status: ${response.statusCode}');
    print('[CategoryRepository] Response: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
      print('Backend Error: ${response.body}');
      throw Exception('Failed: ${response.body}');
    }
  }
}