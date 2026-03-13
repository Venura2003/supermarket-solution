import 'package:supermarket_flutter_app/core/services/api_service.dart';
import '../../../core/models/employee.dart';

class EmployeeRepository {
  Future<List<Employee>> getEmployees() async {
    print('[EmployeeRepository] GET /employees');
    final response = await ApiService.get('/employees');
    print('[EmployeeRepository] Status: ${response.statusCode}');
    print('[EmployeeRepository] Response: ${response.body}');
    final data = ApiService.safeDecode(response);
    if (data == null) return [];
    try {
      // Support both direct list and wrapped { data: [...] }
      final list = data is List ? data : (data['data'] ?? []);
      return List<Employee>.from(list.map((json) => Employee.fromJson(json)));
    } catch (e) {
      print('JSON Decode Error: $e');
      print('Response Body: ${response.body}');
      return [];
    }
  }

  Future<Employee?> getEmployee(int id) async {
    print('[EmployeeRepository] GET /employees/$id');
    final response = await ApiService.get('/employees/$id');
    print('[EmployeeRepository] Status: ${response.statusCode}');
    print('[EmployeeRepository] Response: ${response.body}');
    final data = ApiService.safeDecode(response);
    if (data == null) return null;
    try {
      return Employee.fromJson(data is Map ? data : (data['data'] ?? {}));
    } catch (e) {
      print('JSON Decode Error: $e');
      print('Response Body: ${response.body}');
      return null;
    }
  }

  Future<Employee?> createEmployee(Employee employee) async {
    final payload = employee.toJson();
    // UserId is optional now
    print('[EmployeeRepository] POST /employees');
    print('[EmployeeRepository] Payload: $payload');
    final response = await ApiService.post('/employees', payload);
    print('[EmployeeRepository] Status: ${response.statusCode}');
    print('[EmployeeRepository] Response: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Backend Error: ${response.body}');
      throw Exception('Failed: ${response.body}');
    }
    final data = ApiService.safeDecode(response);
    if (data == null) return null;
    try {
      return Employee.fromJson(data is Map ? data : (data['data'] ?? {}));
    } catch (e) {
      print('JSON Decode Error: $e');
      print('Response Body: ${response.body}');
      return null;
    }
  }

  Future<Employee?> updateEmployee(Employee employee) async {
    final payload = employee.toJson();
    print('[EmployeeRepository] PUT /employees/${employee.id}');
    print('[EmployeeRepository] Payload: $payload');
    final response = await ApiService.put('/employees/${employee.id}', payload);
    print('[EmployeeRepository] Status: ${response.statusCode}');
    print('[EmployeeRepository] Response: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
      print('Backend Error: ${response.body}');
      throw Exception('Failed: ${response.body}');
    }
    final data = ApiService.safeDecode(response);
    if (data == null) return null;
    try {
      return Employee.fromJson(data is Map ? data : (data['data'] ?? {}));
    } catch (e) {
      print('JSON Decode Error: $e');
      print('Response Body: ${response.body}');
      return null;
    }
  }

  Future<void> deleteEmployee(int id) async {
    print('[EmployeeRepository] DELETE /employees/$id');
    final response = await ApiService.delete('/employees/$id');
    print('[EmployeeRepository] Status: ${response.statusCode}');
    print('[EmployeeRepository] Response: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
      print('Backend Error: ${response.body}');
      throw Exception('Failed: ${response.body}');
    }
  }
}