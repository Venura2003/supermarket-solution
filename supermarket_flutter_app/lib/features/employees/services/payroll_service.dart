import 'dart:convert';
import '../../../core/services/api_service.dart';
import '../models/payroll_model.dart';
import 'package:supermarket_flutter_app/core/constants/app_constants.dart'; // Just in case, but ApiService handles logic

class PayrollApiService {
  Future<List<PayrollRecord>> getPayrollHistory() async {
    final response = await ApiService.get('/payroll/history');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PayrollRecord.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load payroll history');
    }
  }

  Future<void> createPayroll(Map<String, dynamic> payrollData) async {
    final response = await ApiService.post('/payroll', payrollData);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create payroll: ${response.body}');
    }
  }

  Future<void> createAdvance(Map<String, dynamic> advanceData) async {
    final response = await ApiService.post('/payroll/advance', advanceData);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create advance: ${response.body}');
    }
  }

  Future<List<dynamic>> getPendingAdvances(String employeeId) async {
    final response = await ApiService.get('/payroll/advances/pending/$employeeId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load pending advances');
    }
  }
}
