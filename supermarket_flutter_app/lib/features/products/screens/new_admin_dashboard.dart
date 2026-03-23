import '../../../screens/product_search_screen.dart';
import '../../../features/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/cart_page.dart';
import '../../shared/sidebar.dart';
import '../../shared/custom_header_bar.dart';
import '../../../core/providers/theme_provider.dart';
import 'product_list_screen.dart';
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
  bool _sidebarOpen = false;

  void _onSidebarTap(int index) {
    setState(() {
      _selectedIndex = index;
      _sidebarOpen = false;
    });
  }

  List<SidebarItem> get _sidebarItems {
    return [
      SidebarItem(
        icon: Icons.dashboard_customize,
        label: 'Dashboard',
        isActive: _selectedIndex == 0,
        onTap: () => _onSidebarTap(0),
      ),
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
        ],
      ),
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
        ],
      ),
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
        ],
      ),
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
          SidebarItem(
            icon: Icons.payments,
            label: 'Payroll',
            isActive: _selectedIndex == 15,
            onTap: () => _onSidebarTap(15),
          ),
        ],
      ),
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
        ],
      ),
      SidebarItem(
        icon: Icons.receipt_long,
        label: 'Receipts Integration',
        isActive: _selectedIndex == 11,
        onTap: () => _onSidebarTap(11),
      ),
      SidebarItem(
        icon: Icons.local_offer,
        label: 'Promotions',
        isActive: _selectedIndex == 10,
        onTap: () => _onSidebarTap(10),
      ),
      SidebarItem(
        icon: Icons.supervisor_account,
        label: 'Users',
        isActive: _selectedIndex == 9,
        onTap: () => _onSidebarTap(9),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeModeProvider>(context);
    final userEmail = authProvider.email ?? 'admin@gmail.com';
    final userRole = authProvider.role ?? 'Admin';
    final isMobile = MediaQuery.of(context).size.width < 800;

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
      case 5: // POS Terminal
      case 6: // Active Cart
        final isWide = MediaQuery.of(context).size.width > 900;
        if (isWide) {
          mainContent = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Product Search (POS Terminal)
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: const ProductSearchScreen(),
                ),
              ),
              // Right: Cart
              Flexible(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.05),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.shopping_cart_outlined, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              "Current Order",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(child: CartPage()),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          // Mobile: POS Terminal = ProductSearchScreen, Active Cart = CartPage
          mainContent = _selectedIndex == 5 ? const ProductSearchScreen() : const CartPage();
        }
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
      case 12:
        mainContent = const GoodsReceivedScreen();
        break;
      case 13:
        mainContent = ProductListScreen();
        break;
      case 14:
        mainContent = const Center(child: Text("Attendance handled by Fingerprint System"));
        break;
      case 15:
        mainContent = const PayrollScreen();
        break;
      case 16:
        mainContent = const PurchaseOrdersScreen();
        break;
      default:
        mainContent = const Center(child: Text('Coming Soon'));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Stack(
          children: [
            CustomHeaderBar(
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
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const AddEditProductScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                                return SlideTransition(position: animation.drive(tween), child: child);
                              },
                            ),
                          );
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
            Positioned(
              right: 12,
              top: 8,
              child: IconButton(
                tooltip: 'Change Theme',
                icon: const Icon(Icons.palette_outlined),
                onPressed: () => _openThemePicker(context, themeProvider),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: isMobile
                ? Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        left: _sidebarOpen ? 0 : -260,
                        top: 0,
                        bottom: 0,
                        width: 260,
                        child: Material(
                          elevation: 16,
                          child: Sidebar(
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
                            items: _sidebarItems,
                            tintOpacity: themeProvider.sidebarTint,
                            accentColor: themeProvider.customPrimaryColor,
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        left: _sidebarOpen ? 260 : 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: mainContent,
                        ),
                      ),
                      if (!_sidebarOpen)
                        Positioned(
                          left: 12,
                          top: 16,
                          child: FloatingActionButton.small(
                            heroTag: 'openSidebar',
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () => setState(() => _sidebarOpen = true),
                          ),
                        ),
                      if (_sidebarOpen)
                        Positioned.fill(
                          left: 260,
                          child: GestureDetector(
                            onTap: () => setState(() => _sidebarOpen = false),
                            child: Container(color: Colors.black.withOpacity(0.2)),
                          ),
                        ),
                    ],
                  )
                : Row(
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
                        items: _sidebarItems,
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