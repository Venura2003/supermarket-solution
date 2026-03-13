import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supermarket_flutter_app/core/models/product_models.dart' as core_models;
import 'package:supermarket_flutter_app/core/repositories/product_repository.dart' as core_repo;
import 'package:supermarket_flutter_app/core/data/product_dao.dart';
import '../../../core/models/product.dart' as legacy_models;
import '../repositories/product_repository.dart' as remote_repo;

class ProductProvider with ChangeNotifier {
  final core_repo.ProductRepository _productRepository = core_repo.ProductRepository();
  final remote_repo.ProductRepository _remoteRepository = remote_repo.ProductRepository();
  List<legacy_models.Product> _products = [];
  List<legacy_models.Product>? _injectedProducts;
  bool _isSearchResults = false;
  bool _isLoading = false;
  String? _errorMessage;

  List<legacy_models.Product> get products => _products;
  List<legacy_models.Product>? get injectedProducts => _injectedProducts;
  /// Total products shown to the user; prefer injected set when present
  int get totalCount => (_injectedProducts != null && _injectedProducts!.isNotEmpty) ? _injectedProducts!.length : _products.length;
  /// Number of products considered low-stock (prefers injected set when present)
  int get lowStockCount {
    final list = (_injectedProducts != null && _injectedProducts!.isNotEmpty) ? _injectedProducts! : _products;
    return list.where((p) => p.stock <= p.lowStockThreshold).length;
  }
  bool get isSearchResults => _isSearchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage;
  bool get isDemo => _productRepository.usedDemo;

  Future<void> loadProducts() async => await fetchProducts(force: true);

  /// Uses core repository which persists fetched products locally and
  /// falls back to local DB when network fails.
  Future<void> fetchProducts({bool force = false}) async {
    if (kDebugMode) print('[ProductProvider] fetchProducts called (force=$force)');
    _isLoading = true;
    notifyListeners();
    try {
      // FORCE backend fetch by default so page is always fresh.
      // The core repo handles persistence (upsert) automatically.
      final data = await _productRepository.fetchProducts();
      
      // If we got fewer products than expected (e.g. cached/offline set is small),
      // we might want to try a direct API call if we suspect the core repo
      // returned a stale local cache. But core repo's fetchProducts() *does* try API first.
      
      // Convert core models to legacy Product for UI compatibility
      _products = data.map((core) => _toLegacy(core)).toList();
      
      // Sort products by name for better UX
      _products.sort((a, b) => a.name.compareTo(b.name));

      // normal fetch does not clear injected sets; injected results are stored separately
      // BUT if we are explicitly loading products (e.g. on page load), we should probably
      // respect that this is the "source of truth".
      
      _errorMessage = null;
      if (kDebugMode) print('[ProductProvider] fetched ${data.length} products');
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) print('[ProductProvider] Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Perform a search (POS/backend-aware). When [q] is empty this falls
  /// back to a normal fetch. Search results are marked so UI can treat them
  /// as externally-provided result sets (no automatic overwrite).
  Future<void> searchProducts(String q) async {
    if (q.isEmpty) return await fetchProducts(force: true);
    if (kDebugMode) print('[ProductProvider] searchProducts called: $q');
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _productRepository.fetchProducts(q: q);
      // store search results as injected set instead of overwriting main list
      _injectedProducts = data.map((core) => _toLegacy(core)).toList();
      _isSearchResults = true;
      _errorMessage = null;
      if (kDebugMode) print('[ProductProvider] search returned ${data.length} items (injected)');
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) print('[ProductProvider] Search error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Replace current products with externally-provided list (e.g., search results)
  void setProducts(List<legacy_models.Product> products) {
    if (kDebugMode) print('[ProductProvider] setProducts called: incoming=${products.length}');
    // keep main _products intact; store injected list separately so UI
    // (Products page) can choose to always display the full catalog.
    _injectedProducts = products;
    _errorMessage = null;
    // Do not flip `_isSearchResults` here — injected results are stored
    // for optional use but the Products page should continue to show the
    // main product catalog by default.
    _isLoading = false;
    notifyListeners();
  }

  /// Clear any externally-injected product sets.
  void clearInjectedProducts() {
    _injectedProducts = null;
    _isSearchResults = false;
    notifyListeners();
  }

  legacy_models.Product _toLegacy(core_models.Product core) {
    // Map fields conservatively; legacy Product expects numeric id and simpler fields
    int? id;
    try {
      id = int.tryParse(core.id);
    } catch (_) {
      id = null;
    }

    final categoryId = core.categories.isNotEmpty ? int.tryParse(core.categories.first.id) : null;
    final barcode = core.skus.isNotEmpty ? core.skus.first.barcode : null;
    final imageUrl = core.images.isNotEmpty ? core.images.first.url : null;

    return legacy_models.Product(
      id: id,
      name: core.name,
      categoryId: categoryId,
      barcode: barcode,
      imageUrl: imageUrl,
      price: core.skus.isNotEmpty ? core.skus.first.price : 0.0,
      costPrice: core.skus.isNotEmpty ? core.skus.first.costPrice : 0.0,
      stock: core.skus.isNotEmpty ? core.skus.first.stock : 0,
      lowStockThreshold: 5,
      createdAt: null,
    );
  }

  Future<void> addProduct(legacy_models.Product product) async {
    if (kDebugMode) print('[ProductProvider] addProduct called');
    try {
      // try remote create, but always persist locally so UI shows the new item
      dynamic createdRemote;
      try {
        createdRemote = await _remoteRepository.createProduct(product);
      } catch (e) {
        if (kDebugMode) print('[ProductProvider] remote create failed: $e');
      }

      // persist locally
      final dao = ProductDao();
      final core = _toCore(product);
      await dao.upsertProduct(core);

      // If an injected set is active, update it in-place so the UI reflects
      // the change immediately.
      if (_injectedProducts != null) {
        _injectedProducts = List<legacy_models.Product>.from(_injectedProducts!);
        _injectedProducts!.add(product);
      }
      
      // Update main list optimistically so other screens (like POS) see it immediately
      _products.add(product);
      notifyListeners();
      
      // refresh main products in background to get canonical state from server
      await fetchProducts(force: true);
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) print('[ProductProvider] Error: $_errorMessage');
      notifyListeners();
    }
  }

  /// Force sync from backend and refresh provider state
  Future<int> syncProducts() async {
    if (kDebugMode) print('[ProductProvider] syncProducts called');
    try {
      final count = await _productRepository.syncWithBackend();
      await fetchProducts(force: true);
      return count;
    } catch (e) {
      if (kDebugMode) print('[ProductProvider] sync error: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(legacy_models.Product product) async {
    if (kDebugMode) print('[ProductProvider] updateProduct called');
    try {
      try {
        await _remoteRepository.updateProduct(product);
      } catch (e) {
        if (kDebugMode) print('[ProductProvider] remote update failed: $e');
      }
      final dao = ProductDao();
      final core = _toCore(product);
      await dao.upsertProduct(core);
      
      // If viewing an injected set, update it in-place and notify UI.
      if (_injectedProducts != null) {
        final idx = _injectedProducts!.indexWhere((p) => p.id == product.id);
        if (idx >= 0) {
          _injectedProducts = List<legacy_models.Product>.from(_injectedProducts!);
          _injectedProducts![idx] = product;
        }
      }
      
      // Update main list optimistically/directly
      final mainIdx = _products.indexWhere((p) => p.id == product.id);
      if (mainIdx >= 0) {
        _products[mainIdx] = product;
      }
      
      notifyListeners();
      await fetchProducts(force: true);
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) print('[ProductProvider] Error: $_errorMessage');
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    if (kDebugMode) print('[ProductProvider] deleteProduct called');
    try {
      try {
        await _remoteRepository.deleteProduct(id);
      } catch (e) {
        // If it's a server error (e.g., 400 constraint violation, 500 error), rethrow so UI knows
        // and we don't delete locally (which would cause sync issues).
        // Only proceed with local delete if it's a network/connectivity error.
        final str = e.toString().toLowerCase();
        if (str.contains('socketexception') || str.contains('clientexception') || str.contains('connection refused')) {
          if (kDebugMode) print('[ProductProvider] Network error during delete, proceeding offline: $e');
        } else {
          if (kDebugMode) print('[ProductProvider] Server error during delete, aborting: $e');
          rethrow;
        }
      }
      
      final dao = ProductDao();
      // DAO uses string IDs; delete using the numeric id as string
      try {
        await dao.deleteProduct(id.toString());
      } catch (e) {
        // If local delete fails but remote succeeded, we might be in inconsistent state, 
        // but syncing should fix it.
         if (kDebugMode) print('[ProductProvider] Local delete warning: $e');
      }

      // If viewing injected results, remove the item locally so the UI updates
      if (_injectedProducts != null) {
        _injectedProducts = List<legacy_models.Product>.from(_injectedProducts!);
        _injectedProducts!.removeWhere((p) => p.id == id);
      }
      
      // Update main list locally immediately
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      
      // Then sync in background
      await fetchProducts(force: true);
    } catch (e) {
      if (kDebugMode) print('[ProductProvider] Delete failed: $e');
      // Do not set global _errorMessage here as it would replace the product list UI with an error card.
      // Instead, we rethrow so the UI can show a SnackBar or specific alert.
      rethrow;
    }
  }

  core_models.Product _toCore(legacy_models.Product p) {
    final id = p.id != null ? p.id.toString() : 'local-${DateTime.now().millisecondsSinceEpoch}';
    return core_models.Product(
      id: id,
      name: p.name,
      description: null,
      categories: p.categoryId != null ? [core_models.Category(id: p.categoryId.toString(), name: '')] : [],
      images: p.imageUrl != null && p.imageUrl!.isNotEmpty ? [core_models.ProductImage(url: p.imageUrl!)] : [],
      attributes: [],
      skus: [core_models.SKU(sku: id, attributes: {}, price: p.price, costPrice: p.costPrice, stock: p.stock, barcode: p.barcode ?? '')],
    );
  }
}
