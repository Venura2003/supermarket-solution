

import 'dart:async'; // Add this import for TimeoutException
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supermarket_flutter_app/core/constants/app_constants.dart';

class ApiService {
  static const _tokenKey = 'jwt_token';

  /// Returns a user-friendly error message for network errors
  static String formatNetworkError(Object error) {
    if (error is SocketException) {
      return 'Cannot connect to the server. Please check your network connection or ensure the backend API is running.';
    }
    if (error is HttpException) {
      return error.message;
    }
    return 'An unexpected error occurred.';
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Map<String, String> _defaultHeaders(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static Future<http.Response> get(String endpoint, {Map<String, String>? params}) async {
    final token = await getToken();
      if (kDebugMode) print('[ApiService] Token before GET $endpoint: $token');
        if (token == null || token.isEmpty) {
          if (kDebugMode) print('[ApiService] No token found. Forcing re-login.');
        throw Exception('Not authenticated. Please log in again.');
      }
      var uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      if (params != null) uri = uri.replace(queryParameters: params);
      final headers = _defaultHeaders(token);
      if (kDebugMode) print('[ApiService] GET $uri');
      if (kDebugMode) print('[ApiService] Headers: $headers');
      final response = await http.get(uri, headers: headers);
      if (kDebugMode) print('[ApiService] Response status: ${response.statusCode}');
      if (kDebugMode) print('[ApiService] Response body: ${response.body}');
    return response;
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    // Ensure URL is constructed correctly, handle slashes if needed
    final baseUrl = AppConstants.apiBaseUrl.endsWith('/') 
        ? AppConstants.apiBaseUrl.substring(0, AppConstants.apiBaseUrl.length - 1) 
        : AppConstants.apiBaseUrl;
    final finalEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    
    final url = '$baseUrl$finalEndpoint';
    final headers = _defaultHeaders(token);
    final jsonBody = jsonEncode(body);
    
    if (kDebugMode) print('[ApiService] POST $url');
    // Using http.post directly
    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonBody)
          .timeout(const Duration(seconds: 90)); // Increased timeout for Render cold start
      return response;
    } on TimeoutException catch (_) {
      throw const SocketException('Connection timed out. The server might be waking up (Render free tier). Please try again in a minute.');
    }
  }

  /// Safely decode JSON only if status is 200/201 and body is not empty
  static dynamic safeDecode(http.Response response) {
    if (kDebugMode) print('[ApiService] statusCode: ${response.statusCode}');
    if (kDebugMode) print('[ApiService] response.body: ${response.body}');
    if (response.statusCode == 401) {
      throw const HttpException('Session expired. Please log in again.');
    } else if ((response.statusCode == 200 || response.statusCode == 201) && response.body.isNotEmpty) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[ApiService] JSON decode error: $e');
          debugPrint('[ApiService] Failing body: ${response.body}');
        }
        throw FormatException('Invalid JSON: ${response.body}\nError: $e');
      }
    } else if (response.statusCode == 400 && response.body.isNotEmpty) {
      // Validation error JSON
      try {
        return jsonDecode(response.body);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[ApiService] JSON decode error (400): $e');
          debugPrint('[ApiService] Failing body: ${response.body}');
        }
        throw FormatException('Invalid error JSON: ${response.body}\nError: $e');
      }
    } else if (response.statusCode == 204 || response.body.isEmpty) {
      return null;
    } else {
      throw HttpException('Request failed: ${response.statusCode} ${response.body}');
    }
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    final response = await http.put(Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
      headers: _defaultHeaders(token), body: jsonEncode(data));
    return response;
  }

  static Future<http.Response> delete(String endpoint) async {
    final token = await getToken();
    final response = await http.delete(Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
      headers: _defaultHeaders(token));
    return response;
  }

  // Higher-level helpers
  static Future<List<dynamic>> fetchProducts({String? q, String? barcode, int? categoryId}) async {
    final params = <String, String>{};
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (barcode != null && barcode.isNotEmpty) params['barcode'] = barcode;
    if (categoryId != null) params['categoryId'] = categoryId.toString();
    final res = await get('/products', params: params);
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw HttpException('Failed to fetch products: ${res.statusCode}');
  }

  static Future<dynamic> fetchProductByBarcode(String barcode) async {
    final res = await get('/products/barcode/$barcode');
    if (res.statusCode == 200) return jsonDecode(res.body);
    if (res.statusCode == 404) return null;
    throw HttpException('Failed barcode lookup: ${res.statusCode}');
  }

  static Future<dynamic> getCart() async {
    final res = await get('/cart');
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw HttpException('Failed to get cart: ${res.statusCode}');
  }

  static Future<void> addToCart(Map<String, dynamic> item) async {
    final res = await post('/cart/add', item);
    if (res.statusCode != 200 && res.statusCode != 204) throw HttpException('Add to cart failed: ${res.statusCode}');
  }

  static Future<void> removeFromCart(Map<String, dynamic> item) async {
    final res = await post('/cart/remove', item);
    if (res.statusCode != 200 && res.statusCode != 204) throw HttpException('Remove from cart failed: ${res.statusCode}');
  }

  static Future<http.Response> checkout(Map<String, dynamic> payload) async {
    final token = await getToken();
    return await http.post(Uri.parse('${AppConstants.apiBaseUrl}/sales/checkout'),
        headers: _defaultHeaders(token), body: jsonEncode(payload));
  }

  // Download receipt PDF bytes and save to temp file, returning local path
  static Future<String> downloadReceipt(String urlPath, String filename) async {
    final token = await getToken();
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$urlPath');
    final res = await http.get(uri, headers: _defaultHeaders(token));
    if (res.statusCode == 200) {
      final bytes = res.bodyBytes;
      final dir = Directory.systemTemp;
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      return file.path;
    }
    throw HttpException('Failed to download receipt: ${res.statusCode}');
  }

  // Reports
  static Future<Map<String, dynamic>> getDailySales({DateTime? date}) async {
    final params = <String, String>{};
    if (date != null) params['date'] = date.toIso8601String().split('T')[0];
    final res = await get('/reports/daily-sales', params: params);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw HttpException('Failed to get daily sales: ${res.statusCode}');
  }

  static Future<Map<String, dynamic>> getMonthlySales({int? year, int? month}) async {
    final params = <String, String>{};
    if (year != null) params['year'] = year.toString();
    if (month != null) params['month'] = month.toString();
    final res = await get('/reports/monthly-sales', params: params);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw HttpException('Failed to get monthly sales: ${res.statusCode}');
  }

  // Categories
  static Future<List<dynamic>> getCategories() async {
    final res = await get('/categories');
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw HttpException('Failed to get categories: ${res.statusCode}');
  }

  static Future<dynamic> createCategory(Map<String, dynamic> data) async {
    final res = await post('/categories', data);
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw HttpException('Failed to create category: ${res.statusCode}');
  }

  static Future<dynamic> updateCategory(int id, Map<String, dynamic> data) async {
    final res = await put('/categories/$id', data);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw HttpException('Failed to update category: ${res.statusCode}');
  }

  static Future<void> deleteCategory(int id) async {
    final res = await delete('/categories/$id');
    if (res.statusCode != 204 && res.statusCode != 200) throw HttpException('Failed to delete category: ${res.statusCode}');
  }

  // Employees
  static Future<List<dynamic>> getEmployees() async {
    final res = await get('/employees');
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw HttpException('Failed to get employees: ${res.statusCode}');
  }

  static Future<dynamic> createEmployee(Map<String, dynamic> data) async {
    final res = await post('/employees', data);
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw HttpException('Failed to create employee: ${res.statusCode}');
  }

  static Future<dynamic> updateEmployee(int id, Map<String, dynamic> data) async {
    final res = await put('/employees/$id', data);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw HttpException('Failed to update employee: ${res.statusCode}');
  }

  static Future<void> deleteEmployee(int id) async {
    final res = await delete('/employees/$id');
    if (res.statusCode != 204 && res.statusCode != 200) throw HttpException('Failed to delete employee: ${res.statusCode}');
  }

  // Notifications
  static Future<List<dynamic>> getNotifications() async {
    final res = await get('/notifications');
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw HttpException('Failed to get notifications: ${res.statusCode}');
  }

  static Future<void> markNotificationAsRead(int id) async {
    final res = await put('/notifications/$id/read', {});
    if (res.statusCode != 200 && res.statusCode != 204) throw HttpException('Failed to mark notification as read: ${res.statusCode}');
  }

  // Error handling
  static void handleError(http.Response response) {
    if (response.statusCode >= 400) {
      dynamic errorBody;
      try {
        errorBody = jsonDecode(response.body);
      } catch (_) {
        errorBody = response.body;
      }
      String message;
      if (errorBody is Map) {
        message = (errorBody['message']?.toString())
            ?? (errorBody['error']?.toString())
            ?? errorBody.toString();
      } else {
        message = errorBody.toString();
      }
      throw HttpException('$message (${response.statusCode})');
    }
  }
}
