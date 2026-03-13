import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'providers/payroll_provider.dart';
import 'models/payroll_model.dart';
import '../products/providers/employee_provider.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  String _selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PayrollProvider>().fetchPayrollHistory();
      context.read<EmployeeProvider>().fetchEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payrollProvider = context.watch<PayrollProvider>();
    final employeeProvider = context.watch<EmployeeProvider>();
    
    // Get all employees and current payrolls
    final allEmployees = employeeProvider.employees;
    final payrollHistory = payrollProvider.payrolls;
    
    // Filter payrolls for selected month
    final currentMonthPayrolls = payrollHistory.where((p) => p.monthYear == _selectedMonth).toList();
    
    double totalPayout = currentMonthPayrolls.fold(0, (sum, item) => sum + item.netSalary);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payroll Management', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Manage employee salaries for $_selectedMonth', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                  ],
                ),
                Row(
                  children: [
                    // Salary Advance Button
                    OutlinedButton.icon(
                      onPressed: () => _showSalaryAdvanceDialog(context),
                      icon: const Icon(Icons.money),
                      label: const Text('Salary Advance'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Month Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                           value: _selectedMonth,
                           items: [
                             DateFormat('MMMM yyyy').format(DateTime.now()),
                             DateFormat('MMMM yyyy').format(DateTime.now().subtract(const Duration(days: 30))),
                           ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                           onChanged: (v) {
                             if (v != null) setState(() => _selectedMonth = v);
                           }
                         ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showGenerateDialog(context),
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Process All Pending'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.primaryColor.withOpacity(0.8), theme.primaryColor]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('Total Payout ($_selectedMonth)', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                       const SizedBox(height: 8),
                       Text(
                         NumberFormat.currency(symbol: 'LKR ').format(totalPayout), 
                         style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
                      ),
                     ],
                   ),
                   const Icon(Icons.account_balance_wallet, color: Colors.white24, size: 64)
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Combined Employee Payroll Table
            Expanded(
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: payrollProvider.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : allEmployees.isEmpty 
                      ? const Center(child: Text("No employees found. Add employees in the Employee Management page."))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text("Employee Payroll Status", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: DataTable2(
                                columns: const [
                                  DataColumn(label: Text('Employee')),
                                  DataColumn(label: Text('Role')),
                                  DataColumn(label: Text('Basic Salary')),
                                  DataColumn(label: Text('Net Salary')), // Will be '-' if not generated
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: allEmployees.map((employee) {
                                    // Find existing record for this employee in this month
                                    final record = currentMonthPayrolls.firstWhere(
                                      (p) => p.employeeId == employee.id.toString(),
                                      orElse: () => PayrollRecord( // Dummy/Null object pattern
                                        id: '', 
                                        employeeId: '', 
                                        employeeName: '', 
                                        monthYear: '', 
                                        periodStart: DateTime.now(), 
                                        periodEnd: DateTime.now(), 
                                        basicSalary: 0, 
                                        status: PayrollStatus.draft, 
                                        generatedDate: DateTime.now()
                                      )
                                    );
                                    
                                    final bool hasRecord = record.id.isNotEmpty;

                                    return DataRow(cells: [
                                      DataCell(Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14, 
                                            backgroundColor: Colors.grey.shade200, 
                                            child: Text(employee.name.isNotEmpty ? employee.name[0] : '?')
                                          ),
                                          const SizedBox(width: 8),
                                          Text(employee.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        ],
                                      )),
                                      DataCell(Text(employee.position)),
                                      DataCell(Text(NumberFormat.compact().format(employee.salary))),
                                      DataCell(Text(
                                        hasRecord ? NumberFormat.currency(symbol: 'Rs ', decimalDigits: 0).format(record.netSalary) : '-',
                                        style: TextStyle(fontWeight: hasRecord ? FontWeight.bold : FontWeight.normal, color: hasRecord ? Colors.black : Colors.grey),
                                      )),
                                      DataCell(hasRecord 
                                        ? _buildStatusChip(record.status)
                                        : Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                                            child: const Text('PENDING', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                          )
                                      ),
                                      DataCell(
                                        hasRecord 
                                          ? IconButton(
                                              icon: const Icon(Icons.remove_red_eye, color: Colors.blue), 
                                              onPressed: () => _showPayslip(context, record),
                                              tooltip: 'View Payslip',
                                            )
                                          : ElevatedButton(
                                              onPressed: () {
                                                 context.read<PayrollProvider>().generatePayrollForEmployee(_selectedMonth, employee.toJson());
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                minimumSize: const Size(0, 32) // Compact button
                                              ),
                                              child: const Text('Process'),
                                            )
                                      ),
                                    ]);
                                }).toList(),
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

  Widget _buildStatusChip(PayrollStatus status) {
    Color color;
    switch(status) {
      case PayrollStatus.paid: color = Colors.green; break;
      case PayrollStatus.approved: color = Colors.blue; break;
      case PayrollStatus.draft: color = Colors.orange; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showGenerateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Process Payroll'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Generate payroll for all active employees for the current month?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Month', border: OutlineInputBorder()),
              controller: TextEditingController(text: _selectedMonth),
              readOnly: true,
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final emps = context.read<EmployeeProvider>().employees;
              await context.read<PayrollProvider>().generatePayrollForMonth(
                _selectedMonth, 
                emps.map((e) => e.toJson()).toList()
              );
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payroll generated successfully')));
            },
            child: const Text('Generate'),
          )
        ],
      ),
    );
  }

  void _showSalaryAdvanceDialog(BuildContext context) {
    // Only fetch employees if needed, but they should be in provider
    final employees = context.read<EmployeeProvider>().employees;
    String? selectedEmpId = employees.isNotEmpty ? employees.first.id.toString() : null;
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Salary Advance'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedEmpId,
                  decoration: const InputDecoration(labelText: 'Employee', border: OutlineInputBorder()),
                  items: employees.map((e) => DropdownMenuItem(
                    value: e.id.toString(),
                    child: Text(e.name),
                  )).toList(),
                  onChanged: (v) => setState(() => selectedEmpId = v),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (LKR)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Note (Reason)', border: OutlineInputBorder()),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (selectedEmpId != null && amountController.text.isNotEmpty) {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    try {
                      await context.read<PayrollProvider>().addSalaryAdvance(selectedEmpId!, amount, noteController.text);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Advance Added')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                      }
                    }
                  }
                },
                child: const Text('Add Advance'),
              )
            ],
          );
        }
      ),
    );
  }

  void _showPayslip(BuildContext context, PayrollRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                 const Text('PAYSLIP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 2)),
                 const Text('FreshMart ERP', style: TextStyle(color: Colors.grey)),
               ]),
               const Divider(height: 32),
               
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                     const Text('Employee', style: TextStyle(color: Colors.grey, fontSize: 12)),
                     Text(record.employeeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     Text('ID: ${record.employeeId}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                   ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                     const Text('Period', style: TextStyle(color: Colors.grey, fontSize: 12)),
                     Text(record.monthYear, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     Text('Worked Days: ${record.workedDays}', style: const TextStyle(fontWeight: FontWeight.w500)),
                   ]),
                 ],
               ),
               
               const SizedBox(height: 32),
               
               Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text('EARNINGS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                         const SizedBox(height: 8),
                         _payslipRow('Basic Salary', record.basicSalary),
                         if(record.overtimeHours > 0) _payslipRow('Overtime (${record.overtimeHours}hrs @ ${record.overtimeRate.toStringAsFixed(1)}/hr)', record.overtimeHours * record.overtimeRate),
                         if(record.bonuses > 0) _payslipRow('Allowances (Transport/Bonus)', record.bonuses),
                         const Divider(),
                         _payslipRow('Gross Earnings', record.grossSalary, isTotal: true),
                       ],
                     ),
                   ),
                   const SizedBox(width: 32),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text('DEDUCTIONS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                         const SizedBox(height: 8),
                         if(record.otherDeductions > 0) _payslipRow('No-Pay Deduction', record.otherDeductions),
                         _payslipRow('EPF (8%)', record.epf8),
                         if(record.tax > 0) _payslipRow('PAYE Tax', record.tax),
                         if(record.advances > 0) _payslipRow('Salary Advance', record.advances),
                         const Divider(),
                         _payslipRow('Total Deductions', record.totalDeductions, isTotal: true),
                       ],
                     ),
                   ),
                 ],
               ),

               const SizedBox(height: 16),
               Container(
                 padding: const EdgeInsets.all(8),
                 color: Colors.grey[100],
                 child: Column(
                   children: [
                     const Text('Company Contributions (Not deducted from Pay)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                         Text('EPF (12%): ${NumberFormat.compact().format(record.epf12)}', style: const TextStyle(fontSize: 10)),
                         Text('ETF (3%): ${NumberFormat.compact().format(record.etf3)}', style: const TextStyle(fontSize: 10)),
                       ],
                     )
                   ],
                 ),
               ),
               
               const Divider(height: 32, thickness: 2),
               
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   const Text('NET PAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                   Text(NumberFormat.currency(symbol: 'LKR ').format(record.netSalary), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.blueAccent)),
                 ],
               ),
               
               const SizedBox(height: 32),
               
               Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                 TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                 const SizedBox(width: 12),
                 ElevatedButton.icon(
                   onPressed: () => _printPdf(record),
                   icon: const Icon(Icons.print, size: 16),
                   label: const Text('Print / PDF'),
                 )
               ])
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _printPdf(PayrollRecord record) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('FreshMart ERP - Payslip', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text('Employee: ${record.employeeName}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('ID: ${record.employeeId}'),
                  ]),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                    pw.Text('Period: ${record.monthYear}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(record.generatedDate)}'),
                  ]),
                ]
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('EARNINGS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                        pw.SizedBox(height: 5),
                        _pdfRow('Basic Salary', record.basicSalary),
                        if(record.overtimeHours > 0) _pdfRow('Overtime', record.overtimeHours * record.overtimeRate),
                        if(record.bonuses > 0) _pdfRow('Bonuses', record.bonuses),
                        pw.Divider(),
                        _pdfRow('Gross Earnings', record.grossSalary, isTotal: true),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                     child: pw.Column(
                       crossAxisAlignment: pw.CrossAxisAlignment.start,
                       children: [
                         pw.Text('DEDUCTIONS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                         pw.SizedBox(height: 5),
                         _pdfRow('EPF (8%)', record.epf8),
                         if(record.tax > 0) _pdfRow('Tax', record.tax),
                         if(record.advances > 0) _pdfRow('Advances', record.advances),
                         pw.Divider(),
                         _pdfRow('Total Deductions', record.totalDeductions, isTotal: true),
                       ],
                     ),
                   ),
                ]
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2),
              pw.Row(
                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                 children: [
                   pw.Text('NET PAY', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                   pw.Text(NumberFormat.currency(symbol: 'LKR ').format(record.netSalary), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                 ]
               ),
               pw.SizedBox(height: 40),
               pw.Text('Employer Contributions: EPF 12% (${record.epf12}) | ETF 3% (${record.etf3})', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  pw.Widget _pdfRow(String label, double amount, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(NumberFormat.currency(symbol: '').format(amount), style: pw.TextStyle(fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }


  Widget _payslipRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(NumberFormat.currency(symbol: '').format(amount), style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

// Mock DataTable2 for simplicity if package missing, else use standard DataTable wrapped in SingleChildScrollView
class DataTable2 extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  const DataTable2({super.key, required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    // If empty
    if (rows.isEmpty) {
       return const Center(child: Text("No records found"));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns,
          rows: rows,
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
        ),
      ),
    );
  }
}

