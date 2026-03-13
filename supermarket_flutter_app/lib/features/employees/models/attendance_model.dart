enum AttendanceStatus { present, absent, late, onLeave, halfDay }

class AttendanceRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date; 
  DateTime? checkIn;
  DateTime? checkOut;
  AttendanceStatus status;
  String? notes;

  AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.status = AttendanceStatus.absent,
    this.notes,
  });

  // Computed: Hours worked
  double get hoursWorked {
    if (checkIn == null || checkOut == null) return 0.0;
    return checkOut!.difference(checkIn!).inMinutes / 60.0;
  }
}
