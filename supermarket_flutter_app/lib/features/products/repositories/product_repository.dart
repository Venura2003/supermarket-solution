import 'package:supermarket_flutter_app/core/services/api_service.dart';
import '../../../core/models/product.dart';

class ProductRepository {
  Future<List<Product>> getProducts() async {
    print('[ProductRepository] GET /products');

    final response = await ApiService.get('/products');

    print('[ProductRepository] Status: ${response.statusCode}');
    print('[ProductRepository] Response: ${response.body}');

    ApiService.handleError(response);

    final decoded = ApiService.safeDecode(response);

    if (decoded == null) return [];

    List list;

    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map && decoded['data'] != null) {
      list = decoded['data'];
    } else {
      return [];
    }

    return list.map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> getProduct(int id) async {
    print('[ProductRepository] GET /products/$id');

    final response = await ApiService.get('/products/$id');

    ApiService.handleError(response);

    final decoded = ApiService.safeDecode(response);

    if (decoded == null) {
      throw Exception('Product not found');
    }

    return Product.fromJson(decoded);
  }

  Future<Product?> createProduct(Product product) async {
    print('[ProductRepository] POST /products');
    print('[ProductRepository] Payload: ${product.toJson()}');

    final response = await ApiService.post('/products', product.toJson());

    print('[ProductRepository] Status: ${response.statusCode}');
    print('[ProductRepository] Response: ${response.body}');

    ApiService.handleError(response);

    final decoded = ApiService.safeDecode(response);

    if (decoded == null) return null;

    try {
      return Product.fromJson(decoded);
    } catch (e) {
      print('[ProductRepository] Parse error: $e');
      return null;
    }
  }

  Future<Product> updateProduct(Product product) async {
    print('[ProductRepository] PUT /products/${product.id}');
    print('[ProductRepository] Payload: ${product.toJson()}');

    final response =
        await ApiService.put('/products/${product.id}', product.toJson());

    print('[ProductRepository] Status: ${response.statusCode}');
    print('[ProductRepository] Response: ${response.body}');

    if (response.statusCode == 204) return product;

    ApiService.handleError(response);

    final decoded = ApiService.safeDecode(response);

    if (decoded == null) {
      throw Exception('Update failed');
    }

    return Product.fromJson(decoded);
  }

  Future<void> deleteProduct(int id) async {
    print('[ProductRepository] DELETE /products/$id');

    final response = await ApiService.delete('/products/$id');

    print('[ProductRepository] Status: ${response.statusCode}');
    print('[ProductRepository] Response: ${response.body}');

    ApiService.handleError(response);
  }
}