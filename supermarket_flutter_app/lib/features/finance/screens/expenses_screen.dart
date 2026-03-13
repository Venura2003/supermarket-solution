import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../finance/providers/finance_provider.dart';
import '../models/finance_transaction.dart';
import '../../../core/theme/app_theme.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Other';
  DateTime _selectedAddDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<FinanceProvider>().fetchOverview(
      startDate: _startDate, 
      endDate: _endDate
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currencyFormat = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance & Expenses'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Overview & Transactions', icon: Icon(Icons.analytics_outlined)),
            Tab(text: 'Manage Expenses', icon: Icon(Icons.receipt_long)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDateRange,
            tooltip: 'Filter by Date',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(provider, currencyFormat),
                _buildManageExpensesTab(provider),
              ],
            ),
    );
  }

  Widget _buildOverviewTab(FinanceProvider provider, NumberFormat format) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SUMMARY CARDS
          Row(
            children: [
              _buildSummaryCard(
                'Income', 
                provider.totalIncome, 
                Colors.green.shade50, 
                Colors.green.shade800, 
                Icons.arrow_upward,
                format
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                'Expenses', 
                provider.totalExpenses, 
                Colors.red.shade50, 
                Colors.red.shade800, 
                Icons.arrow_downward,
                format
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                'Net Profit', 
                provider.netProfit, 
                provider.netProfit >= 0 ? Colors.blue.shade50 : Colors.orange.shade50, 
                provider.netProfit >= 0 ? Colors.blue.shade900 : Colors.deepOrange.shade900, 
                Icons.account_balance_wallet,
                format
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (provider.error != null) 
                 Text(provider.error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),

          // TRANSACTIONS LIST
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: provider.transactions.isEmpty 
                  ? Center(child: Text("No transactions found for this period", style: TextStyle(color: Colors.grey.shade600)))
                  : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: provider.transactions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final t = provider.transactions[index];
                      final isIncome = t.type == TransactionType.income;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                          child: Icon(
                            isIncome ? Icons.attach_money : Icons.money_off,
                            color: isIncome ? Colors.green.shade800 : Colors.red.shade800,
                            size: 20
                          ),
                        ),
                        title: Text(t.description, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text("${DateFormat('MMM dd, yyyy').format(t.date)} • ${t.category}"),
                        trailing: Text(
                          "${isIncome ? '+' : '-'} ${format.format(t.amount)}",
                          style: TextStyle(
                            color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                          ),
                        ),
                      );
                    },
                  ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color bg, Color text, IconData icon, NumberFormat format) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: text.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: text, size: 24),
                Text(title, style: TextStyle(color: text.withOpacity(0.8), fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                format.format(amount),
                style: TextStyle(color: text, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- EXISTING MANAGER TAB (Refactored slightly) ---
  Widget _buildManageExpensesTab(FinanceProvider provider) {
    final format = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 2);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Record Operational Expense"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _showAddExpenseDialog(context),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.expenses.isEmpty 
          ? Center(child: Text("No operational expenses recorded", style: TextStyle(color: Colors.grey.shade600)))
          : ListView.builder(
            itemCount: provider.expenses.length,
            itemBuilder: (context, index) {
              final expense = provider.expenses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.grey.shade100, child: const Icon(Icons.receipt, color: Colors.grey)),
                  title: Text(expense.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${DateFormat('yyyy-MM-dd').format(expense.date)} • ${expense.category}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(format.format(expense.amount), 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      const SizedBox(width: 8),
                      IconButton(
                         icon: const Icon(Icons.delete_outline, color: Colors.grey),
                         // Use provider.deleteExpense directly (assuming it's public)
                         onPressed: () => _confirmDelete(provider, expense.id)
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _confirmDelete(FinanceProvider provider, int id) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Delete Expense?"),
      content: const Text("Are you sure you want to delete this record?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
        TextButton(onPressed: () {
          Navigator.pop(ctx);
          // Assuming deleteExpense returns Future
          provider.deleteExpense(id).then((_) {
             // Reload overview if needed to update totals
             if (context.mounted) {
               context.read<FinanceProvider>().fetchOverview(startDate: _startDate, endDate: _endDate);
             }
          });
        }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
      ],
    ));
  }
 
  void _showAddExpenseDialog(BuildContext context) {
    // Reset form
    _descController.clear();
    _amountController.clear();
    // Don't call setState here as we are not using State for these anymore/or using StatefulBuilder
    // Actually we need to reset the variables that retain state in the dialog
    // Best to reset them
    
    // We need to use local variables for the dialog state or a fresh StatefulBuilder
    // The previous implementation used class level variables which is okay if we reset them
    _selectedCategory = 'Other';
    _selectedAddDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Operational Expense'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
                    validator: (val) => val!.isEmpty ? 'Enter description' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Amount', prefixIcon: Icon(Icons.attach_money)),
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Enter amount' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category)),
                    items: context.read<FinanceProvider>().categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => _selectedCategory = val!),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("Date: ${DateFormat('yyyy-MM-dd').format(_selectedAddDate)}"),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedAddDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setDialogState(() => _selectedAddDate = picked);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await context.read<FinanceProvider>().addExpense(
                  _descController.text,
                  double.parse(_amountController.text),
                  _selectedCategory,
                  _selectedAddDate,
                );
                // Also refresh overview
                if (context.mounted) {
                  context.read<FinanceProvider>().fetchOverview(startDate: _startDate, endDate: _endDate);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Save Expense'),
          ),
        ],
      ),
    );
  }
}
