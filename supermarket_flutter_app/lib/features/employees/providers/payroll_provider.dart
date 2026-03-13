import 'package:flutter/material.dart';
import '../models/payroll_model.dart';
import '../services/payroll_service.dart';
import 'attendance_provider.dart';  // Import AttendanceProvider
import '../../products/providers/employee_provider.dart';

class PayrollProvider with ChangeNotifier {
  final PayrollApiService _api = PayrollApiService();
  List<PayrollRecord> _payrolls = [];
  
  // Need reference to attendance
  final AttendanceProvider? _attendanceProvider;

  PayrollProvider(this._attendanceProvider); // Constructor Injection

  bool _isLoading = false;

  List<PayrollRecord> get payrolls => _payrolls;
  bool get isLoading => _isLoading;

  // Add Salary Advance
  Future<void> addSalaryAdvance(String employeeId, double amount, String note) async {
    try {
      await _api.createAdvance({
        'employeeId': int.tryParse(employeeId) ?? 0,
        'amount': amount,
        'note': note,
        'date': DateTime.now().toIso8601String(),
      });
      notifyListeners();
    } catch (e) {
      print('Error adding advance: $e');
      rethrow;
    }
  }

  Future<double> _getPendingAdvancesTotal(String employeeId) async {
    try {
      final list = await _api.getPendingAdvances(employeeId);
      double total = 0.0;
      for (var item in list) {
        total += (item['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      print('Error fetching advances: $e');
      return 0.0;
    }
  }
  
  // Mark advances as deducted (Handled by backend now)
  void _markAdvancesDeducted(String employeeId) {
    // Backend handles this on payroll creation
  }

  Future<void> fetchPayrollHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      _payrolls = await _api.getPayrollHistory();
    } catch (e) {
      print('Error fetching payroll history: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // void _mockData() { ... }

  Future<void> generatePayrollForMonth(String monthYear, List<Map<String, dynamic>> employees) async {
    _isLoading = true;
    notifyListeners();

    for (var emp in employees) {
      await _generateSingle(monthYear, emp);
    }
    
    // Refresh fully from API
    await fetchPayrollHistory();
  }

  Future<void> generatePayrollForEmployee(String monthYear, Map<String, dynamic> emp) async {
    _isLoading = true;
    notifyListeners();
    await _generateSingle(monthYear, emp);
    await fetchPayrollHistory();
  }

  Future<void> _generateSingle(String monthYear, Map<String, dynamic> emp) async {
      final empId = emp['id'].toString();
      final double basic = (emp['salary'] as num?)?.toDouble() ?? 30000.0;
      
      // -- REAL WORLD CHANGE --
      // Step 1: Get Attendance Summary from AttendanceProvider
      // Assume "monthYear" format is "Month YYYY". Need to parse it to DateTime.
      // For now, assume current month or parse roughly.
      final now = DateTime.now();
      final summary = await _attendanceProvider?.getAttendanceSummaryForEmployee(empId, now) ?? {};
      
      final int workedDays = summary['workedDays'] ?? 24;
      final int absentDays = summary['absentDays'] ?? 2;
      final int otHours = summary['otHours'] ?? 5; // e.g., 5 hours OT
      
      const int standardWorkDays = 26; // Standard working days per month
      
      // Calculate No-Pay Deduction
      // If workedDays < standardWorkDays, deduct. Or specifically use 'absentDays'.
      // Simple formula: Daily Rate = Basic / 30 (or 26 depending on policy)
      final double dailyRate = basic / 30.0;
      final double noPayDeduction = dailyRate * absentDays;
      
      // Calculate OT Pay
      // Formula: (Basic / 200) * 1.5 * OT Hours
      final double hourlyRate = basic / 200.0;
      final double otRate = hourlyRate * 1.5;
      final double otAmount = otRate * otHours;
      
      // allowances could be fetched from employee details ideally
      final double transportAllowance = 5000.0; // Flat allowance example
      final double attendanceAllowance = (absentDays == 0) ? 2000.0 : 0.0; // Bonus if no absent days
      
      final double totalEarnings = basic + otAmount + transportAllowance + attendanceAllowance - noPayDeduction;

      // 2. Advances (Async fetch)
      final double advances = await _getPendingAdvancesTotal(empId);
      
      // 3. EPF/ETF (Sri Lanka Standard)
      // EPF is usually calculated on (Basic + Budgetary Relief) - excludes OT/Transport usually.
      // Let's assume EPF Base = Basic - NoPayDeduction
      final double epfBase = (basic - noPayDeduction) > 0 ? (basic - noPayDeduction) : 0;
      
      // EPF Employee 8%
      final double epf8 = epfBase * 0.08;
      
      // EPF Employer 12%
      final double epf12 = epfBase * 0.12;
      
      // ETF Employer 3%
      final double etf3 = epfBase * 0.03;
      
      // PAYE Tax (APIT) - Simplified logic here (e.g. if earnings > 100k)
      double tax = 0.0;
      if (totalEarnings > 100000) {
        tax = (totalEarnings - 100000) * 0.06; // Mock 6% tax on excess
      }
      
      final double totalDeductions = epf8 + advances + tax;
      final double netSalary = totalEarnings - totalDeductions;
      
      final newRecord = PayrollRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        employeeId: empId,
        employeeName: emp['name'],
        monthYear: monthYear,
        periodStart: DateTime(now.year, now.month, 1),
        periodEnd: DateTime(now.year, now.month + 1, 0),
        basicSalary: basic,
        workedDays: workedDays,
        overtimeHours: otHours.toDouble(),
        overtimeRate: otRate,
        bonuses: (transportAllowance + attendanceAllowance), // Group allowances as bonuses for now
        advances: advances,
        otherDeductions: noPayDeduction, // Track No-Pay here
        epf8: epf8,
        epf12: epf12,
        etf3: etf3,
        tax: tax,
        status: PayrollStatus.draft,
        generatedDate: DateTime.now(),
      );

      // Save to mock storage or API
      
      // Construct API Payload (Refined with new calculations)
      final payrollData = {
        'employeeId': int.tryParse(empId) ?? 0,
        'monthYear': monthYear, // "March 2026"
        'periodStart': DateTime(now.year, now.month, 1).toIso8601String(),
        'periodEnd': DateTime(now.year, now.month + 1, 0).toIso8601String(),
        'basicSalary': basic,
        'workedDays': workedDays,
        'overtimeHours': otHours.toDouble(),
        'overtimeRate': otRate,
        'bonuses': (transportAllowance + attendanceAllowance),
        'advances': advances,
        'otherDeductions': noPayDeduction,
        'epf8': epf8,
        'epf12': epf12,
        'etf3': etf3,
        'tax': tax,
        'netSalary': netSalary,
      };

      try {
        await _api.createPayroll(payrollData);
        // Add to local list immediately for UI feedback
        _payrolls.add(newRecord);
      } catch (e) {
        print('Error generating payroll record: $e');
      }
  }

  Future<void> approvePayroll(String id) async {
    // API call to update status would go here
    notifyListeners();
  }
}
