
class Employee {
  final int? id;
  final int? userId;
  final String name;
  final String email;
  final String phone;
  final String position;
  final double salary;
  final DateTime hireDate;
  final String role;
  final bool isActive;
  final String? username;

  Employee({
    this.id,
    this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.position,
    required this.salary,
    required this.hireDate,
    String? role,
    this.isActive = true,
    this.username,
  }) : role = role ?? position;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      position: json['position'] ?? 'Employee',
      salary: _parseDouble(json['salary']),
      hireDate: json['hireDate'] != null ? DateTime.parse(json['hireDate']) : DateTime.now(),
      role: json['role'] ?? json['position'] ?? 'Employee',
      isActive: json['isActive'] ?? true,
      username: json['username'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'position': role,
      'salary': salary,
      'hireDate': hireDate.toIso8601String(),
      'role': role,
      'isActive': isActive,
      'username': username,
    };
  }
}