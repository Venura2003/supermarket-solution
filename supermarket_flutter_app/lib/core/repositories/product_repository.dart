import 'package:supermarket_flutter_app/core/models/product_models.dart';
import 'package:supermarket_flutter_app/core/services/api_service.dart';
import 'package:supermarket_flutter_app/core/data/product_dao.dart';

/// ProductRepository handles remote fetch + local persistence (sqflite) and
/// a read-first strategy for offline support.
class ProductRepository {
  // Simple in-memory cache
  final Map<String, Product> _cacheById = {};
  final ProductDao _dao = ProductDao();
  bool _usedDemo = false;

  /// Whether the last fetch returned demo-seeded data (debug only)
  bool get usedDemo => _usedDemo;

  Future<List<Product>> fetchProducts({String? q, String? barcode, int? categoryId}) async {
    // ALWAYS try network first ("Network-First" strategy)
    // This ensures Product Page always gets the full list from server.
    // If the server is reachable, the local DB will be updated with fresh data.
    try {
      final raw = await ApiService.fetchProducts(q: q, barcode: barcode, categoryId: categoryId);
      final List<Product> products = raw.map((e) {
        final map = e as Map<String, dynamic>;
        
        // Ensure ID is a string (API might return int)
        if (map['id'] is int) map['id'] = map['id'].toString();
        
         // Handle category ID properly for core model
        if (map['categoryId'] != null) {
          map['categoryId'] = map['categoryId'].toString();
          // If flat 'categoryId' exists but 'categories' list is missing, create it
          if (map['categories'] == null || (map['categories'] as List).isEmpty) {
             map['categories'] = [{'id': map['categoryId'], 'name': 'Category'}];
          }
        }
        
        // Transform flat API structure (price, stock, barcode, imageUrl) to nested Core Model
        // Because Product.fromJson expects nested lists (skus, images)
        if (map['skus'] == null) {
          map['skus'] = [{
            'sku': map['id'], // Use product ID as SKU code
            'attributes': {},
            'price': map['price'] ?? 0.0,
            'stock': map['stock'] ?? 0,
            'barcode': map['barcode']
          }];
        }
        
        if (map['images'] == null && map['imageUrl'] != null) {
          map['images'] = [{'url': map['imageUrl']}];
        }

        Product p;
        try {
           p = Product.fromJson(map);
        } catch (e) {
           // Fallback for malformed JSON or mismatching types
           // Create a safe basic product to avoid crashing the whole list
           p = Product(
             id: map['id'].toString(), 
             name: map['name'] ?? 'Unknown',
             categories: [],
             images: [],
             attributes: [],
             skus: []
           );
        }
        
        _cacheById[p.id] = p;
        // update local DB to keep it in sync
        _dao.upsertProduct(p);
        return p;
      }).toList();
      
      // If performing a search, we return exactly what the server gave.
      // If fetching all products (q=null), we should ideally REPLACE the local cache
      // to avoid "zombie" products that were deleted on server but stay local.
      // However, for safety/speed we just upsert for now. To be perfect, we would:
      // if (q == null) await _dao.clearAndInsertAll(products);
      
      return products;
    } catch (e) {
      // On error (network), fallback to local DB ("Offline-Fallback")
      print('[ProductRepository] Network fetch failed, using local DB: $e');
      final local = await _dao.getAllProducts();
      
      if (local.isEmpty) {
        if (const bool.fromEnvironment('dart.vm.product') == false) {
          // Dev mode seed
          _usedDemo = true;
          return _seedDemoProducts();
        }
        _usedDemo = false;
        return [];
      }
      
      if (q != null && q.isNotEmpty) {
        final ql = q.toLowerCase();
        _usedDemo = false;
        return local.where((p) => p.name.toLowerCase().contains(ql)).toList();
      }
      _usedDemo = false;
      return local;
    }
  }

  Future<List<Product>> _seedDemoProducts() async {
    final now = DateTime.now();
    final p1 = Product(
      id: 'demo-1',
      name: 'Demo Rice 5kg',
      description: 'High-quality demo rice',
      categories: [],
      images: [ProductImage(url: 'https://via.placeholder.com/150')],
      attributes: [ProductAttribute(name: 'Weight', value: '5kg')],
      skus: [SKU(sku: 'DEMO-RICE-5KG', attributes: {'Weight': '5kg'}, price: 1250.0, stock: 20, barcode: '1234567890123')],
    );

    final p2 = Product(
      id: 'demo-2',
      name: 'Demo Sugar 1kg',
      description: 'Refined demo sugar',
      categories: [],
      images: [ProductImage(url: 'https://via.placeholder.com/150')],
      attributes: [ProductAttribute(name: 'Weight', value: '1kg')],
      skus: [SKU(sku: 'DEMO-SUGAR-1KG', attributes: {'Weight': '1kg'}, price: 240.0, stock: 50, barcode: '2345678901234')],
    );

    await _dao.upsertProduct(p1);
    await _dao.upsertProduct(p2);
    return [p1, p2];
  }

  Future<Product?> fetchProductById(String id) async {
    if (_cacheById.containsKey(id)) return _cacheById[id];
    try {
      final res = await ApiService.get('/products/$id');
      if (res.statusCode == 200) {
        final map = ApiService.safeDecode(res) as Map<String, dynamic>;
        final p = Product.fromJson(map);
        _cacheById[p.id] = p;
        await _dao.upsertProduct(p);
        return p;
      }
      if (res.statusCode == 404) return null;
      throw Exception('Failed to load product: ${res.statusCode}');
    } catch (e) {
      // fallback to local DB
      return await _dao.getProductById(id);
    }
  }

  Future<Product?> fetchProductByBarcode(String barcode) async {
    try {
      final raw = await ApiService.fetchProductByBarcode(barcode);
      if (raw == null) return null;
      final p = Product.fromJson(Map<String, dynamic>.from(raw as Map));
      _cacheById[p.id] = p;
      await _dao.upsertProduct(p);
      return p;
    } catch (e) {
      // fallback: search local DB by scanning SKUs/barcode
      final all = await _dao.getAllProducts();
      try {
        return all.firstWhere((p) => p.skus.any((s) => s.barcode == barcode));
      } catch (_) {
        return null;
      }
    }
  }

  // Helper: search within cached products
  List<Product> searchCache(String q) {
    final ql = q.toLowerCase();
    return _cacheById.values.where((p) => p.name.toLowerCase().contains(ql) || (p.description?.toLowerCase().contains(ql) ?? false)).toList();
  }

  /// Syncs all products currently in memory to local DB (useful after bulk fetch)
  Future<void> persistCache() async {
    for (final p in _cacheById.values) {
      await _dao.upsertProduct(p);
    }
  }

  /// Force-fetch from backend and persist to local DB. Returns number synced.
  Future<int> syncWithBackend() async {
    final raw = await ApiService.fetchProducts();
    final List<Product> products = (raw as List<dynamic>).map((e) {
      final map = e as Map<String, dynamic>;
      final p = Product.fromJson(map);
      return p;
    }).toList();
    for (final p in products) {
      await _dao.upsertProduct(p);
      _cacheById[p.id] = p;
    }
    _usedDemo = false;
    return products.length;
  }
}
