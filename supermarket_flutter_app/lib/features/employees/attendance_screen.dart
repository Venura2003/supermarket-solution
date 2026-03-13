import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'models/attendance_model.dart';
import '../../core/models/employee.dart';
import 'providers/attendance_provider.dart';
import '../products/providers/employee_provider.dart'; // Corrected import path

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<EmployeeProvider>().fetchEmployees();
       context.read<AttendanceProvider>().fetchAttendanceForDate(_selectedDate);
    });
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    context.read<AttendanceProvider>().fetchAttendanceForDate(_selectedDate);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attProvider = context.watch<AttendanceProvider>();
    final empProvider = context.watch<EmployeeProvider>();
    
    // Merge Employees with Attendance Records
    final allEmployees = empProvider.employees;
    final records = attProvider.attendanceRecords.where((r) => 
      r.date.year == _selectedDate.year && 
      r.date.month == _selectedDate.month && 
      r.date.day == _selectedDate.day
    ).toList();

    int present = records.where((r) => r.status == AttendanceStatus.present || r.status == AttendanceStatus.late).length;
    int absent = allEmployees.length - present; // Rough estimate
    int late = records.where((r) => r.status == AttendanceStatus.late).length;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attendance', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Manage employee check-ins and daily logs', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                  ],
                ),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.dividerColor)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: () => _changeDate(-1), icon: const Icon(Icons.chevron_left)),
                        const SizedBox(width: 12),
                        Text(DateFormat('EEE, MMM d, yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 12),
                        IconButton(onPressed: () => _changeDate(1), icon: const Icon(Icons.chevron_right)),
                      ],
                    ),
                  ),
                )
              ],
            ),
            
            const SizedBox(height: 24),
            
            // KPI Cards
            Row(
              children: [
                Expanded(child: _buildKpiCard(theme, 'Present', '$present', Colors.green, Icons.check_circle)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard(theme, 'Absent', '$absent', Colors.red, Icons.cancel)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard(theme, 'Late Arrivals', '$late', Colors.orange, Icons.access_time)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard(theme, 'On Leave', '0', Colors.blue, Icons.beach_access)), // Mocked
              ],
            ),

            const SizedBox(height: 32),

            // Employee List Table
            Expanded(
              child: Card(
                elevation: 0,
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.dividerColor)),
                child: attProvider.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text("Employee Logs", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: allEmployees.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final emp = allEmployees[index];
                              // Find record or create dummy
                              final record = records.firstWhere(
                                (r) => r.employeeId == emp.id.toString(), 
                                orElse: () => AttendanceRecord(
                                   id: '', employeeId: emp.id.toString(), employeeName: emp.name, date: _selectedDate, status: AttendanceStatus.absent
                                )
                              );
                              
                              return _buildEmployeeRow(theme, emp, record, context);
                            },
                          ),
                        ),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeRow(ThemeData theme, Employee emp, AttendanceRecord record, BuildContext context) {
    final dateFormat = DateFormat('hh:mm a');
    final bool hasCheckIn = record.checkIn != null;
    final bool hasCheckOut = record.checkOut != null;

    final Color statusColor = _getStatusColor(record.status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            child: Text(emp.name.isNotEmpty ? emp.name[0] : '?', style: TextStyle(color: theme.primaryColor)),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emp.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Text(emp.position, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3))
                ),
                child: Text(
                  _getStatusText(record.status),
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),
          
          // Check In
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Check In", style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(
                  hasCheckIn ? dateFormat.format(record.checkIn!) : '--:--',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Check Out
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Check Out", style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(
                  hasCheckOut ? dateFormat.format(record.checkOut!) : '--:--',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!hasCheckIn)
                   ElevatedButton(
                      onPressed: () {
                         if (!_isToday(_selectedDate)) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Can only modify today's attendance")));
                            return;
                         }
                         context.read<AttendanceProvider>().markCheckIn(emp.id.toString(), emp.name);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('Check In'),
                   )
                else if (!hasCheckOut)
                   ElevatedButton(
                      onPressed: () {
                         if (!_isToday(_selectedDate)) {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Can only modify today's attendance")));
                             return;
                         }
                         context.read<AttendanceProvider>().markCheckOut(emp.id.toString());
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                      child: const Text('Check Out'),
                   )
                else
                   const Chip(label: Text("Done"), backgroundColor: Colors.transparent, side: BorderSide(color: Colors.green))
              ],
            ),
          )
        ],
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    if (status == AttendanceStatus.present) return Colors.green;
    if (status == AttendanceStatus.absent) return Colors.red;
    if (status == AttendanceStatus.late) return Colors.orange;
    if (status == AttendanceStatus.onLeave) return Colors.blue; 
    return Colors.grey;
  }

  String _getStatusText(AttendanceStatus status) {
    if (status == AttendanceStatus.onLeave) return 'On Leave';
    return status.name[0].toUpperCase() + status.name.substring(1);
  }

  Widget _buildKpiCard(ThemeData theme, String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
         boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
         ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(title, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontWeight: FontWeight.w600)),
                   Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.headlineSmall?.color)),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
