import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../../products/providers/employee_provider.dart';

class AttendanceProvider with ChangeNotifier {
  final List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoading = false;

  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;

  // Simulate loading data
  Future<void> fetchAttendanceForDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate API

    // Mock data if empty
    if (_attendanceRecords.isEmpty) {
      _mockData(date);
    }
    _isLoading = false;
    notifyListeners();
  }


  // Fetch summary for a specific month (for Payroll linkage)
  Future<Map<String, int>> getAttendanceSummaryForEmployee(String employeeId, DateTime month) async {
    // In a real backend, this would be an API call: /attendance/summary?employeeId=X&month=Y
    // Summary: { 'present': 24, 'late': 2, 'absent': 0, 'otHours': 10 }
    
    // Simulating...
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock logic based on month
    return {
      'workedDays': 24, // Assumed attended days
      'absentDays': 2,
      'lateDays': 1,
      'otHours': 5, // 5 hours of Overtime
    };
  }

  void _mockData(DateTime date) {
    _attendanceRecords.clear();
    // Assuming we have some employees, let's create mock records
    // In a real app, we'd fetch employees first, then check their attendance status
    _attendanceRecords.addAll([
       AttendanceRecord(
         id: '1', 
         employeeId: 'EMP001', 
         employeeName: 'John Doe', 
         date: date,
         checkIn: date.add(const Duration(hours: 8, minutes: 15)),
         status: AttendanceStatus.present
       ),
       AttendanceRecord(
         id: '2', 
         employeeId: 'EMP002', 
         employeeName: 'Jane Smith', 
         date: date,
         checkIn: date.add(const Duration(hours: 8, minutes: 0)),
         checkOut: date.add(const Duration(hours: 17, minutes: 0)),
         status: AttendanceStatus.present
       ),
       AttendanceRecord(
         id: '3', 
         employeeId: 'EMP003', 
         employeeName: 'Mike Johnson', 
         date: date,
         status: AttendanceStatus.absent,
         notes: 'Sick Leave'
       ),
    ]);
  }

  Future<void> markCheckIn(String employeeId, String name) async {
    final now = DateTime.now();
    // Check if record exists for today
    final existingIndex = _attendanceRecords.indexWhere((r) => r.employeeId == employeeId && _isSameDay(r.date, now));
    
    if (existingIndex >= 0) {
      // Already checked in?
      return;
    }

    final newRecord = AttendanceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: employeeId,
      employeeName: name,
      date: now,
      checkIn: now,
      status: AttendanceStatus.present,
    );
    _attendanceRecords.add(newRecord);
    notifyListeners();
  }

  Future<void> markCheckOut(String employeeId) async {
    final now = DateTime.now();
    final index = _attendanceRecords.indexWhere((r) => r.employeeId == employeeId && _isSameDay(r.date, now));
    
    if (index >= 0) {
      // Update existing record
      final old = _attendanceRecords[index];
      _attendanceRecords[index] = AttendanceRecord(
        id: old.id,
        employeeId: old.employeeId,
        employeeName: old.employeeName,
        date: old.date,
        checkIn: old.checkIn,
        checkOut: now,
        status: old.status,
        notes: old.notes,
      );
      notifyListeners();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
