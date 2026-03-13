enum PayrollStatus { draft, approved, paid }

class PayrollRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final String monthYear; // e.g., "October 2023"
  final DateTime periodStart;
  final DateTime periodEnd;
  
  final double basicSalary;
  final int workedDays; // New
  final double overtimeHours;
  final double overtimeRate;
  
  final double bonuses;
  final double advances; // New: Salary Advances taken
  final double otherDeductions; // New
  final double epf8; // New: Employee 8%
  final double epf12; // New: Employer 12%
  final double etf3; // New: Employer 3%
  final double tax; // PAYE/APIT
  
  final PayrollStatus status;
  final DateTime generatedDate;

  PayrollRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.monthYear,
    required this.periodStart,
    required this.periodEnd,
    required this.basicSalary,
    this.workedDays = 26,
    this.overtimeHours = 0.0,
    this.overtimeRate = 0.0,
    this.bonuses = 0.0,
    this.advances = 0.0,
    this.otherDeductions = 0.0,
    this.epf8 = 0.0,
    this.epf12 = 0.0,
    this.etf3 = 0.0,
    this.tax = 0.0,
    this.status = PayrollStatus.draft,
    required this.generatedDate,
  });

  factory PayrollRecord.fromJson(Map<String, dynamic> json) {
    return PayrollRecord(
      id: json['id'].toString(),
      employeeId: json['employeeId'].toString(),
      employeeName: json['employeeName'] ?? '',
      monthYear: json['monthYear'] ?? '',
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
      basicSalary: (json['basicSalary'] as num?)?.toDouble() ?? 0.0,
      workedDays: json['workedDays'] ?? 26,
      overtimeHours: (json['overtimeHours'] as num?)?.toDouble() ?? 0.0,
      overtimeRate: (json['overtimeRate'] as num?)?.toDouble() ?? 0.0,
      bonuses: (json['bonuses'] as num?)?.toDouble() ?? 0.0,
      advances: (json['advances'] as num?)?.toDouble() ?? 0.0,
      otherDeductions: (json['otherDeductions'] as num?)?.toDouble() ?? 0.0,
      epf8: (json['epf8'] as num?)?.toDouble() ?? 0.0,
      epf12: (json['epf12'] as num?)?.toDouble() ?? 0.0,
      etf3: (json['etf3'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      status: PayrollStatus.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == (json['status'] as String).toLowerCase(),
          orElse: () => PayrollStatus.draft),
      generatedDate: DateTime.parse(json['generatedDate']),
    );
  }

  // Gross Salary = Basic + Allowances + OT
  double get grossSalary => basicSalary + (overtimeHours * overtimeRate) + bonuses;
  
  // Total Deductions = EPF 8% + Tax + Advances + Other
  double get totalDeductions => epf8 + tax + advances + otherDeductions;
  
  // Net Salary = Gross - Deductions
  double get netSalary => grossSalary - totalDeductions;

  // Cost to Company (CTC) = Gross + EPF 12% + ETF 3%
  double get costToCompany => grossSalary + epf12 + etf3;
}
