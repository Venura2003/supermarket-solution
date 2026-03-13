import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/employee.dart';
import '../../../features/products/providers/employee_provider.dart';
import '../../auth/providers/auth_provider.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedRole = 'Cashier';
  Employee? _editingEmployee;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<EmployeeProvider>().fetchEmployees());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showEmployeeDialog([Employee? employee]) {
    _editingEmployee = employee;
    _nameController.text = employee?.name ?? '';
    _emailController.text = employee?.email ?? '';
    _selectedRole = employee?.role ?? 'Cashier';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(employee == null ? 'Add Employee' : 'Edit Employee'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Employee Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email is required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: ['Admin', 'Cashier', 'Employee'].contains(_selectedRole) ? _selectedRole : 'Cashier',
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'Cashier', child: Text('Cashier')),
                  DropdownMenuItem(value: 'Employee', child: Text('Employee')),
                ],
                onChanged: (value) { // We use a StatefulBuilder or update the parent state
                    _selectedRole = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
               _saveEmployee();
               Navigator.of(context).pop();
            },
            child: Text(employee == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _saveEmployee() {
    if (!_formKey.currentState!.validate()) return;

    // Get userId from AuthProvider if available
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final int userId = authProvider.userId ?? 0;

    final employee = Employee(
      id: _editingEmployee?.id,
      userId: userId,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _editingEmployee?.phone ?? '', // You may want to add phone field to the form
      position: _selectedRole,
      salary: _editingEmployee?.salary ?? 0.0, // You may want to add salary field to the form
      hireDate: _editingEmployee?.hireDate ?? DateTime.now(), // You may want to add hireDate field to the form
      role: _selectedRole,
    );

    final provider = context.read<EmployeeProvider>();
    if (_editingEmployee == null) {
      provider.addEmployee(employee);
    } else {
      provider.updateEmployee(employee);
    }

    Navigator.of(context).pop();
    _clearForm();
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _selectedRole = 'Cashier';
    _editingEmployee = null;
  }

  void _deleteEmployee(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete "${employee.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<EmployeeProvider>().deleteEmployee(employee.id!);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = context.watch<EmployeeProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Employee Management',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              ElevatedButton.icon(
                onPressed: () => _showEmployeeDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Employee'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (employeeProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if ((employeeProvider.employees.isEmpty && employeeProvider.errorMessage == null) || (employeeProvider.employees.isEmpty && employeeProvider.errorMessage != null))
            Center(
              child: Text(
                employeeProvider.errorMessage == null
                    ? 'No employees found.'
                    : 'Could not load employees. Please try again.',
                style: TextStyle(color: employeeProvider.errorMessage == null ? Colors.black54 : Colors.red),
              ),
            )
          else
            Expanded(
              child: Card(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: employeeProvider.employees.length,
                    itemBuilder: (context, index) {
                      final employee = employeeProvider.employees[index];
                      return ListTile(
                        title: Text(employee.name),
                        subtitle: Text('${employee.email} • ${employee.role}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEmployeeDialog(employee),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEmployee(employee),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}