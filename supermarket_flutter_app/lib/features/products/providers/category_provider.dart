import 'package:flutter/material.dart';
import '../../../core/models/category.dart';
import '../repositories/category_repository.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryRepository _categoryRepository = CategoryRepository();
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCategories({bool force = false}) async {
    if (!force && _categories.isNotEmpty) {
      print('[CategoryProvider] fetchCategories skipped (cached=${_categories.length})');
      return;
    }
    print('[CategoryProvider] fetchCategories start');
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _categoryRepository.getCategories();
      _categories = data;
      print('[CategoryProvider] Categories loaded: ${_categories.length}');
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[CategoryProvider] Category fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('[CategoryProvider] fetchCategories notifyListeners');
    }
  }

  Future<void> addCategory(Category category) async {
    print('[CategoryProvider] addCategory called');
    try {
        await _categoryRepository.createCategory(category);
        await fetchCategories(force: true);
    } catch (e) {
      _errorMessage = e.toString();
      print('[CategoryProvider] Error: $_errorMessage');
      notifyListeners();
    }
  }

  Future<void> updateCategory(Category category) async {
    print('[CategoryProvider] updateCategory called');
    try {
        await _categoryRepository.updateCategory(category);
        await fetchCategories(force: true);
    } catch (e) {
      _errorMessage = e.toString();
      print('[CategoryProvider] Error: $_errorMessage');
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id) async {
    print('[CategoryProvider] deleteCategory called');
    try {
        await _categoryRepository.deleteCategory(id);
        await fetchCategories(force: true);
    } catch (e) {
      _errorMessage = e.toString();
      print('[CategoryProvider] Error: $_errorMessage');
      notifyListeners();
    }
  }
}