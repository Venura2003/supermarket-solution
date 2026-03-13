import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/auth_models.dart';
import '../../core/models/employee.dart';
import '../auth/repositories/auth_repository.dart';
import '../products/providers/employee_provider.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  final AuthRepository _authRepository = AuthRepository();
  String _searchQuery = '';
  String _selectedDepartment = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeProvider>(context, listen: false).fetchEmployees();
    });
  }

  List<Employee> _filterEmployees(List<Employee> employees) {
    return employees.where((emp) {
      final matchesSearch = emp.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            emp.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDept = _selectedDepartment == 'All' || emp.position == _selectedDepartment;
      return matchesSearch && matchesDept;
    }).toList();
  }

  void _showEmployeeView(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(employee.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Position', employee.position),
            _detailRow('Phone', employee.phone),
            _detailRow('Salary', employee.salary.toStringAsFixed(2)),
            _detailRow('Hired', employee.hireDate.toString().split(' ')[0]),
            const SizedBox(height: 10),
            // Email/Username intentionally omitted from view per request
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEmployeeDialog(BuildContext context, [Employee? employee]) {
    final isEditing = employee != null;
    final formKey = GlobalKey<FormState>();
    
    // Controllers
    final nameController = TextEditingController(text: employee?.name ?? '');
    final emailController = TextEditingController(text: employee?.email ?? '');
    final passwordController = TextEditingController();
    final phoneController = TextEditingController(text: employee?.phone ?? '');
    final positionController = TextEditingController(text: employee?.position ?? '');
    final salaryController = TextEditingController(text: employee?.salary.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Employee' : 'Add Employee'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  if (!isEditing)
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Contact Email'),
                      validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                    ),
                  // Password and User fields removed, only Employee info is managed here
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: positionController,
                    decoration: const InputDecoration(labelText: 'Position'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: salaryController,
                    decoration: const InputDecoration(labelText: 'Salary'),
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid number' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final provider = Provider.of<EmployeeProvider>(context, listen: false);
                  
                  try {
                    if (isEditing) {
                      final updated = Employee(
                        id: employee.id,
                        userId: employee.userId,
                        name: nameController.text,
                        email: employee.email,
                        phone: phoneController.text,
                        position: positionController.text,
                        salary: double.parse(salaryController.text),
                        hireDate: employee.hireDate,
                      );
                      Navigator.pop(ctx); 
                      await provider.updateEmployee(updated);
                   } else {
                      // Modified: Create Employee ONLY (No User or Login created yet)
                      // Admin must enable access in the Users Screen later.
                      
                      Navigator.pop(ctx); 
                      
                      // Create Employee Profile with null userId (optional in backend)
                      final newEmployee = Employee(
                        userId: null, 
                        name: nameController.text,
                        email: emailController.text,
                        phone: phoneController.text,
                        position: positionController.text,
                        salary: double.parse(salaryController.text),
                        hireDate: DateTime.now(),
                      );
                      await provider.addEmployee(newEmployee);
                    }
                  } catch (e) {
                     if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Employee?'),
        content: Text('Are you sure you want to delete ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final provider = Provider.of<EmployeeProvider>(context, listen: false);
              Navigator.pop(ctx);
              try {
                await provider.deleteEmployee(employee.id!);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<EmployeeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${provider.errorMessage}', style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchEmployees(),
                  child: const Text('Retry'),
                )
              ],
            ));
          }
          
          // Get unique Departments for Filter
          final departments = ['All', ...provider.employees.map((e) => e.position).toSet()];
          final filteredEmployees = _filterEmployees(provider.employees);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Search
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search Employee...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onChanged: (val) => setState(() => _searchQuery = val),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: departments.contains(_selectedDepartment) ? _selectedDepartment : 'All',
                                icon: const Icon(Icons.filter_list),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() => _selectedDepartment = newValue);
                                  }
                                },
                                items: departments.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Employee List
                Expanded(
                  child: filteredEmployees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('No employees found'),
                            if (provider.employees.isEmpty) ...[
                               const SizedBox(height: 16),
                               ElevatedButton.icon(
                                 onPressed: () => _showEmployeeDialog(context),
                                 icon: const Icon(Icons.add),
                                 label: const Text('Add First Employee'),
                               ),
                            ]
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = filteredEmployees[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              onTap: () => _showEmployeeView(context, employee),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.green[50], // Light green bg
                                foregroundColor: Colors.green[800], // Dark green text
                                child: Text(
                                  employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                              title: Text(employee.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    Icon(Icons.work, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(employee.position, style: TextStyle(color: Colors.grey[800])),
                                    const SizedBox(width: 12),
                                    Icon(Icons.email, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(employee.email, style: TextStyle(color: Colors.grey[600])),
                                  ]),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    Icon(Icons.attach_money, size: 14, color: Colors.green[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Salary: ${employee.salary.toStringAsFixed(2)}', 
                                      style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)
                                    ),
                                  ]),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showEmployeeDialog(context, employee),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmDelete(context, employee),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEmployeeDialog(context),
        backgroundColor: const Color(0xFF1B5E20),
        tooltip: 'Add Employee',
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Employee', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}