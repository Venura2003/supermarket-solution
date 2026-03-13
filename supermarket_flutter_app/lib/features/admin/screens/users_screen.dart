import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/employee.dart';
import '../../products/providers/employee_provider.dart';
import '../../auth/providers/auth_provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<EmployeeProvider>().fetchEmployees());
  }

  void _showUserDialog(Employee employee) {
     showDialog(
      context: context,
      builder: (context) => _UserDialog(employee: employee),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // FAB removed: Employees added via Employee Page
      body: Consumer<EmployeeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }

          final employees = provider.employees;
          
          if (employees.isEmpty) {
             return const Center(child: Text('No employees found. Please add employees in the Employee Management page first.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final emp = employees[index];
              final hasUser = emp.userId != null;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: hasUser ? (emp.isActive ? Colors.green : Colors.grey) : Colors.amber,
                    child: Icon(hasUser ? Icons.person : Icons.person_add, color: Colors.white),
                  ),
                  title: Text(emp.name),
                  subtitle: Text(hasUser 
                    ? 'Username: ${emp.username ?? emp.email}\nRole: ${emp.role}'
                    : 'No System Access',
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasUser ? Colors.blueAccent : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _showUserDialog(emp),
                    child: Text(hasUser ? 'Manage Access' : 'Grant Access'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _UserDialog extends StatefulWidget {
  final Employee employee; // Required employee

  const _UserDialog({required this.employee});

  @override
  State<_UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<_UserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  final _passwordController = TextEditingController();
  
  String _selectedRole = 'Employee';
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.employee.email); // Default username to email
    _isActive = widget.employee.isActive;
    
    if (['Admin', 'Manager', 'Employee', 'Cashier'].contains(widget.employee.role)) {
      _selectedRole = widget.employee.role;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final empProvider = context.read<EmployeeProvider>();
    
    try {
        if (widget.employee.userId == null) {
            // GRANT ACCESS
            final authRole = ['Admin', 'Manager'].contains(_selectedRole) ? 'Admin' : 'Employee';
            final userId = await authProvider.register(
                widget.employee.email, 
                _passwordController.text,
                authRole,
                username: _usernameController.text.trim(),
            );
            
            if (userId == null) throw Exception(authProvider.errorMessage ?? "Registration failed");
            
            final updatedEmp = Employee(
                id: widget.employee.id,
                userId: userId, 
                name: widget.employee.name,
                email: widget.employee.email,
                phone: widget.employee.phone,
                position: _selectedRole, // Update Position with selected Role
                salary: widget.employee.salary,
                hireDate: widget.employee.hireDate,
                role: _selectedRole, // Update role immediately for UI
                isActive: true,
                username: _usernameController.text.trim()
            );
            
            await empProvider.updateEmployee(updatedEmp);
            
        } else {
            // MANAGE ACCESS
             final updatedEmp = Employee(
                id: widget.employee.id,
                userId: widget.employee.userId,
                name: widget.employee.name,
                email: widget.employee.email,
                phone: widget.employee.phone,
                position: _selectedRole, // Update Position with selected Role
                salary: widget.employee.salary,
                hireDate: widget.employee.hireDate,
                role: _selectedRole, // Update role immediately for UI
                isActive: _isActive,
                username: widget.employee.username
            );
            
           await empProvider.updateEmployee(updatedEmp);

           if (_passwordController.text.isNotEmpty) {
             if (_passwordController.text.length < 6) {
               throw Exception('Password must be at least 6 characters');
             }
             await authProvider.changePassword(widget.employee.userId!, _passwordController.text);
           }
        }
        
        if (mounted) Navigator.of(context).pop();
    } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
        if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUser = widget.employee.userId != null;
    
    return AlertDialog(
        title: Text(hasUser ? 'Manage Access' : 'Grant Access'),
        content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
                child: Form(
                    key: _formKey,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Text('Employee: ${widget.employee.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(labelText: 'Username'),
                                enabled: !hasUser, 
                                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                            ),
                            if (!hasUser) ...[
                                TextFormField(
                                    controller: _passwordController,
                                    decoration: const InputDecoration(labelText: 'Password'),
                                    obscureText: true,
                                    validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 chars' : null,
                                ),
                            ] else ...[
                                const SizedBox(height: 16),
                                const Divider(),
                                const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextFormField(
                                    controller: _passwordController,
                                    decoration: const InputDecoration(labelText: 'New Password (Optional)'),
                                    obscureText: true,
                                ),
                            ],
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                                value: _selectedRole,
                                decoration: const InputDecoration(labelText: 'System Role'),
                                items: ['Admin', 'Manager', 'Employee', 'Cashier'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                                onChanged: !hasUser ? (v) => setState(() => _selectedRole = v!) : null,
                            ),
                             if (hasUser)
                                SwitchListTile(
                                    title: const Text('Access Enabled'),
                                    subtitle: const Text('Toggle to revoke system access'),
                                    value: _isActive,
                                    onChanged: (v) => setState(() => _isActive = v),
                                ),
                        ],
                    ),
                ),
            ),
        ),
        actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
                onPressed: _isLoading ? null : _submit, 
                child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(hasUser ? 'Update' : 'Grant')
            ),
        ],
    );
  }
}