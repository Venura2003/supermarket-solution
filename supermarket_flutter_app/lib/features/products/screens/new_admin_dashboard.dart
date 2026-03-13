import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/cart_page.dart'; // Import CartPage (POS with Barcode)
import '../../shared/sidebar.dart';
import '../../shared/custom_header_bar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import 'product_list_screen.dart';
import '../../../screens/product_search_screen.dart';
import '../../../screens/cart_screen.dart';
import '../../../screens/checkout_screen.dart';
import '../../../features/dashboard/widgets/kpi_cards.dart';
import '../../../features/dashboard/widgets/sales_analytics_chart.dart';
import '../../../features/dashboard/widgets/low_stock_alerts_panel.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../../features/products/providers/product_provider.dart';
import '../../../features/products/providers/category_provider.dart';
import '../../../features/products/providers/employee_provider.dart';
import '../../../features/products/providers/report_provider.dart';
import '../../admin/providers/orders_provider.dart';
import '../../admin/providers/inventory_provider.dart';
import '../../../features/products/screens/category_management_screen.dart';
import '../../employees/employees_page.dart';
import '../../employees/payroll_screen.dart';
import '../../../features/products/screens/reports_screen.dart';
import '../../../features/dashboard/dashboard_page.dart';
import '../../admin/screens/inventory_screen.dart';
import '../../admin/screens/orders_screen.dart';
import '../../admin/screens/users_screen.dart';
import '../../admin/screens/promotions_screen.dart';
import '../../admin/screens/receipts_integration_screen.dart';
import '../../admin/screens/goods_received_screen.dart'; 
import '../../finance/screens/expenses_screen.dart'; 
import '../../procurement/screens/purchase_orders_screen.dart'; 

import 'add_edit_product_screen.dart';

class NewAdminDashboard extends StatefulWidget {
  const NewAdminDashboard({super.key});

  @override
  State<NewAdminDashboard> createState() => _NewAdminDashboardState();
}

class _NewAdminDashboardState extends State<NewAdminDashboard> {
  int _selectedIndex = 0;

  void _onSidebarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Load dashboard data when dashboard is selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedIndex == 0) {
        context.read<DashboardProvider>().loadDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeModeProvider>(context);
    final userEmail = authProvider.email ?? 'admin@gmail.com';
    final userRole = authProvider.role ?? 'Admin';

    Widget mainContent;

    switch (_selectedIndex) {
      case 0:
        mainContent = DashboardPage(onSwitchTab: _onSidebarTap);
        break;
      case 1:
        mainContent = const ExpensesScreen(); 
        break;
      case 2:
        mainContent = const CategoryManagementScreen();
        break;
      case 3:
        mainContent = const EmployeesPage(); 
        break;
      case 4:
        mainContent = const ReportsScreen();
        break;
      case 5:
        mainContent = const ProductSearchScreen();
        break;
      case 6:
        mainContent = const CartPage();
        break;
      case 7:
        mainContent = const InventoryScreen();
        break;
      case 8:
        mainContent = const OrdersScreen();
        break;
      case 9:
        mainContent = const UsersScreen();
        break;
      case 10:
        mainContent = const PromotionsScreen();
        break;
      case 11:
        mainContent = const ReceiptsIntegrationScreen();
        break;
      case 12: // Goods Received (GR)
        mainContent = const GoodsReceivedScreen();
        break;
      case 13: // Products
        mainContent = ProductListScreen();
        break;
      case 14: // Attendance
        // mainContent = const AttendanceScreen();
         mainContent = const Center(child: Text("Attendance handled by Fingerprint System"));
        break;
      case 15: // Payroll
        mainContent = const PayrollScreen();
        break;
      case 16: // Purchase Orders
        mainContent = const PurchaseOrdersScreen();
        break;
      default:
        mainContent = const Center(child: Text('Coming Soon'));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomHeaderBar(
        appName: 'FreshMart ERP',
        userName: userEmail,
        userRole: userRole,
        onLogout: () async {
          await authProvider.logout();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        },
        fullColor: themeProvider.headerFullColor,
        onSearch: (value) {
          if (value.isNotEmpty) {
            Navigator.of(context).pushNamed('/product-search', arguments: value);
          }
        },
        onSync: () async {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing data...')));
          await Future.wait([
            context.read<DashboardProvider>().loadDashboardData(),
            context.read<ProductProvider>().loadProducts(),
            context.read<CategoryProvider>().fetchCategories(),
            context.read<EmployeeProvider>().fetchEmployees(),
            context.read<ReportProvider>().loadDailyReport(),
            context.read<OrdersProvider>().fetchOrders(),
            context.read<InventoryProvider>().fetchItems(),
          ]);
          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data synchronized successfully'), backgroundColor: Colors.green));
          }
        },
        onNew: () {
          showDialog(
            context: context,
            builder: (ctx) => SimpleDialog(
              title: const Text('Quick Actions'),
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditProductScreen()));
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(children: [Icon(Icons.inventory, color: Colors.blue), SizedBox(width: 12), Text('New Product')]),
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _selectedIndex = 5);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(children: [Icon(Icons.point_of_sale, color: Colors.green), SizedBox(width: 12), Text('New Sale')]),
                  ),
                ),
                 SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _selectedIndex = 1);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(children: [Icon(Icons.monetization_on, color: Colors.red), SizedBox(width: 12), Text('Record Expense')]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Row(
              children: [
        Sidebar(
          userName: userEmail,
          userRole: userRole,
          onLogout: () async {
             final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Logout')),
                  ],
                ),
              );
              if (shouldLogout == true) {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              }
          },
          items: [
            SidebarItem(
              icon: Icons.dashboard_customize,
              label: 'Dashboard',
              isActive: _selectedIndex == 0,
              onTap: () => _onSidebarTap(0),
            ),

                  
                  // SALES & POS MODULE
                  SidebarItem(
                    icon: Icons.point_of_sale,
                    label: 'Sales & POS',
                    children: [
                      SidebarItem(
                        icon: Icons.search,
                        label: 'POS Terminal',
                        isActive: _selectedIndex == 5,
                        onTap: () => _onSidebarTap(5),
                      ),
                      SidebarItem(
                        icon: Icons.shopping_cart,
                        label: 'Active Cart',
                        isActive: _selectedIndex == 6,
                        onTap: () => _onSidebarTap(6),
                      ),
                      // Removed Sales Receipts & Promotions per user request
                    ]
                  ),

                  // INVENTORY MODULE
                  SidebarItem(
                    icon: Icons.inventory_2,
                    label: 'Inventory',
                    children: [
                      SidebarItem(
                        icon: Icons.list_alt,
                        label: 'Product List',
                        isActive: _selectedIndex == 13,
                        onTap: () => _onSidebarTap(13),
                      ),
                      SidebarItem(
                        icon: Icons.category,
                        label: 'Categories',
                        isActive: _selectedIndex == 2,
                        onTap: () => _onSidebarTap(2),
                      ),
                      SidebarItem(
                        icon: Icons.warehouse,
                        label: 'Stock Levels',
                        isActive: _selectedIndex == 7,
                        onTap: () => _onSidebarTap(7),
                      ),
                      SidebarItem(
                        icon: Icons.assignment,
                        label: 'Purchase Orders',
                        isActive: _selectedIndex == 16,
                        onTap: () => _onSidebarTap(16),
                      ),
                      SidebarItem(
                        icon: Icons.input,
                        label: 'Goods Received (GRN)',
                        isActive: _selectedIndex == 12,
                        onTap: () => _onSidebarTap(12),
                      ),
                    ]
                  ),

                  // FINANCE MODULE
                  SidebarItem(
                    icon: Icons.account_balance,
                    label: 'Finance',
                    children: [
                      SidebarItem(
                        icon: Icons.monetization_on,
                        label: 'Expenses & Income',
                        isActive: _selectedIndex == 1,
                        onTap: () => _onSidebarTap(1),
                      ),
                       SidebarItem(
                        icon: Icons.analytics,
                        label: 'Financial Reports',
                        isActive: _selectedIndex == 4,
                        onTap: () => _onSidebarTap(4),
                      ),
                    ]
                  ),

                  // HR MODULE
                  SidebarItem(
                    icon: Icons.people_alt,
                    label: 'HR & Payroll',
                    children: [
                      SidebarItem(
                        icon: Icons.badge,
                        label: 'Employees',
                        isActive: _selectedIndex == 3,
                        onTap: () => _onSidebarTap(3),
                      ),
                      // SidebarItem( // Removed Attendance for Fingerprint Sync
                      //   icon: Icons.access_time,
                      //   label: 'Attendance',
                      //   isActive: _selectedIndex == 14,
                      //   onTap: () => _onSidebarTap(14),
                      // ),
                      SidebarItem(
                        icon: Icons.payments,
                        label: 'Payroll',
                        isActive: _selectedIndex == 15,
                        onTap: () => _onSidebarTap(15),
                      ),
                    ]
                  ),

                  // ACCESS CONTROL
                  SidebarItem(
                    icon: Icons.admin_panel_settings,
                    label: 'Administration',
                    children: [
                       SidebarItem(
                        icon: Icons.manage_accounts,
                        label: 'System Users',
                        isActive: _selectedIndex == 9,
                        onTap: () => _onSidebarTap(9),
                      ),
                    ]
                  ),
                ],
                tintOpacity: themeProvider.sidebarTint,
                accentColor: themeProvider.customPrimaryColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: mainContent,
                ),
              ),
                  ],
                ),
              ),

                // Theme picker button - top right
                Positioned(
                  right: 30,
                  top: 12,
                  child: SafeArea(
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        tooltip: 'Change theme',
                        icon: const Icon(Icons.palette_outlined),
                        onPressed: () => _openThemePicker(context, themeProvider),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _openThemePicker(BuildContext context, ThemeModeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose theme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  ...List.generate(themeProvider.presets.length, (i) {
                    final ThemeData t = themeProvider.presets[i];
                    return GestureDetector(
                       onTap: () {
                        themeProvider.setSelectedTheme(i);
                        themeProvider.setCustomPrimaryColor(null);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 84,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: t.colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: i == themeProvider.selectedThemeIndex ? t.colorScheme.primary : Colors.transparent, width: 2),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(radius: 18, backgroundColor: t.colorScheme.primary),
                            const SizedBox(height: 8),
                            Text('Preset ${i + 1}', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }),
                  
                  // Custom Color Picker Button
                  GestureDetector(
                    onTap: () async {
                      Navigator.of(context).pop();
                      // Simple color picker dialog can be added here
                    },
                    child: Container(
                      width: 84,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Icon(Icons.colorize),
                           SizedBox(height: 8),
                           Text('Custom', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}