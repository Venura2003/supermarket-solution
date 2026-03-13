import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/models/expense.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/finance_transaction.dart';

class FinanceProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<FinanceTransaction> _transactions = [];
  List<String> _categories = ['Utility', 'Rent', 'Salary', 'Maintenance', 'Marketing', 'Other'];
  
  bool _isLoading = false;
  String? _error;

  // Financial Summary
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _netProfit = 0.0;

  List<Expense> get expenses => _expenses;
  List<FinanceTransaction> get transactions => _transactions;
  List<String> get categories => _categories;
  
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;
  double get netProfit => _netProfit;

  bool get isLoading => _isLoading;
  String? get error => _error;

  final AuthProvider? _authProvider;

  FinanceProvider(this._authProvider);

  /// Main method to load financial overview (Income & Expenses)
  Future<void> fetchOverview({DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = _authProvider?.token;
      if (token == null) throw Exception("Not authenticated");

      // 1. Fetch Expenses (Operational)
      await _fetchExpensesInternal(startDate, endDate, token);
      
      // 2. Fetch Sales (Income) - Filter client-side if API doesn't support date range yet
      final salesResponse = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/sales'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      // 3. Fetch GRNs (Inventory Costs)
      final grnResponse = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/grn'),
        headers: {'Authorization': 'Bearer $token'},
      );

      List<FinanceTransaction> allTransactions = [];

      // Process Expenses
      for (var expense in _expenses) {
        allTransactions.add(FinanceTransaction(
          id: 'EXP-${expense.id}',
          date: expense.date,
          description: expense.description,
          amount: expense.amount,
          type: TransactionType.expense,
          category: expense.category,
        ));
      }

      // Process Sales (Mock date filtering if API returns all)
      if (salesResponse.statusCode == 200) {
        final salesData = json.decode(salesResponse.body);
        if (salesData['success'] == true && salesData['data'] != null) {
          final List<dynamic> salesList = salesData['data'];
          for (var s in salesList) {
            final date = DateTime.tryParse(s['date'] ?? s['createdAt'] ?? '') ?? DateTime.now();
            // Filter
            if (startDate != null && date.isBefore(startDate)) continue;
            if (endDate != null && date.isAfter(endDate.add(const Duration(days: 1)))) continue;

            allTransactions.add(FinanceTransaction(
              id: 'SALE-${s['id']}',
              date: date,
              description: 'Sale #${s['orderNo'] ?? s['id']}', 
              amount: (s['totalAmount'] as num).toDouble(),
              type: TransactionType.income,
              category: 'Sales',
            ));
          }
        }
      }

      // Process GRNs
      if (grnResponse.statusCode == 200) {
        final List<dynamic> grnList = json.decode(grnResponse.body);
        for (var g in grnList) {
          final date = DateTime.tryParse(g['receivedDate'] ?? '') ?? DateTime.now();
          // Filter
          if (startDate != null && date.isBefore(startDate)) continue;
          if (endDate != null && date.isAfter(endDate.add(const Duration(days: 1)))) continue;

          allTransactions.add(FinanceTransaction(
            id: 'GRN-${g['id']}',
            date: date,
            description: 'Inventory Purchase (GRN #${g['id']})',
            amount: (g['totalAmount'] as num).toDouble(),
            type: TransactionType.expense, 
            category: 'Purchase',
          ));
        }
      }

      // Sort by Date (Desc)
      allTransactions.sort((a, b) => b.date.compareTo(a.date));
      _transactions = allTransactions;

      // Calculate Totals
      _totalIncome = _transactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
          
      _totalExpenses = _transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      _netProfit = _totalIncome - _totalExpenses;

    } catch (e) {
      _error = "Failed to load financial data: $e";
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Internal helper to reuse expense logic
  Future<void> _fetchExpensesInternal(DateTime? startDate, DateTime? endDate, String token) async {
      String queryString = "?";
      if (startDate != null) queryString += "startDate=${startDate.toIso8601String()}&";
      if (endDate != null) queryString += "endDate=${endDate.toIso8601String()}&";

      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/expenses$queryString'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _expenses = data.map((json) => Expense.fromJson(json)).toList();
      }
  }

  // Keep existing method for backward compatibility if used elsewhere
  Future<void> fetchExpenses({DateTime? startDate, DateTime? endDate, String? category}) async {
    return fetchOverview(startDate: startDate, endDate: endDate);
  }


  Future<void> addExpense(String description, double amount, String category, DateTime date) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = _authProvider?.token;
      if (token == null) throw Exception("Not authenticated");

      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/expenses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'description': description,
          'amount': amount,
          'category': category,
          'date': date.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final newExpense = Expense.fromJson(json.decode(response.body));
        _expenses.insert(0, newExpense);
      } else {
        throw Exception("Failed to add expense");
      }
    } catch (e) {
      _error = "Error adding expense: $e";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      final token = _authProvider?.token;
      if (token == null) throw Exception("Not authenticated");

      final response = await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/expenses/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        _expenses.removeWhere((e) => e.id == id);
        notifyListeners();
      } else {
        throw Exception("Failed to delete expense");
      }
    } catch (e) {
      rethrow;
    }
  }
}
