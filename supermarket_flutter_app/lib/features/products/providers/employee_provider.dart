import 'package:flutter/material.dart';
import '../../../core/models/employee.dart';
import '../repositories/employee_repository.dart';

class EmployeeProvider with ChangeNotifier {
  final EmployeeRepository _employeeRepository = EmployeeRepository();
  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchEmployees() async {
    print('[EmployeeProvider] fetchEmployees called');
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _employeeRepository.getEmployees();
      print('[EmployeeProvider] API result count: ${data.length}');
      _employees = data;
      print('[EmployeeProvider] provider list count: ${_employees.length}');
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[EmployeeProvider] Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('[EmployeeProvider] fetchEmployees notifyListeners, isLoading: $_isLoading');
    }
  }

  Future<void> addEmployee(Employee employee) async {
    print('[EmployeeProvider] addEmployee called');
    try {
      await _employeeRepository.createEmployee(employee);
      await fetchEmployees();
    } catch (e) {
      _errorMessage = e.toString();
      print('[EmployeeProvider] Error: $_errorMessage');
      notifyListeners();
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    print('[EmployeeProvider] updateEmployee called');
    try {
      await _employeeRepository.updateEmployee(employee);
      await fetchEmployees();
    } catch (e) {
      _errorMessage = e.toString();
      print('[EmployeeProvider] Error: $_errorMessage');
      notifyListeners();
    }
  }

  Future<void> deleteEmployee(int id) async {
    print('[EmployeeProvider] deleteEmployee called');
    try {
      await _employeeRepository.deleteEmployee(id);
      await fetchEmployees();
    } catch (e) {
      _errorMessage = e.toString();
      print('[EmployeeProvider] Error: $_errorMessage');
      notifyListeners();
    }
  }
}