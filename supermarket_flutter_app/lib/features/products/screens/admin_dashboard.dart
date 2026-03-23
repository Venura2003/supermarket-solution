import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/sidebar.dart';
import '../../shared/custom_header_bar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/theme_prefs.dart';
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
import '../../../features/products/screens/reports_screen.dart';
import '../../../features/dashboard/dashboard_page.dart';
import '../../admin/screens/inventory_screen.dart';
import '../../admin/screens/orders_screen.dart';
import '../../admin/screens/users_screen.dart';
import '../../admin/screens/promotions_screen.dart';
import '../../admin/screens/receipts_integration_screen.dart';
import '../../admin/screens/goods_received_screen.dart'; // Import GR Screen
import '../../cart/cart_page.dart';

import 'add_edit_product_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  int _selectedTheme = 0;
  Color? _customPrimary;
  double _sidebarTint = 0.12;
  bool _headerFullColor = false;

  final List<ThemeData> _themePresets = [
    AppTheme.lightTheme,
    AppTheme.lightTheme.copyWith(
      colorScheme: AppTheme.colorScheme.copyWith(primary: const Color(0xFF6A1B9A), background: const Color(0xFFF7F3FB), surface: Colors.white),
      scaffoldBackgroundColor: const Color(0xFFF7F3FB),
    ),
    AppTheme.lightTheme.copyWith(
      colorScheme: AppTheme.colorScheme.copyWith(primary: const Color(0xFF00897B), background: const Color(0xFFF2F7F5), surface: Colors.white),
      scaffoldBackgroundColor: const Color(0xFFF2F7F5),
    ),
    AppTheme.lightTheme.copyWith(
      colorScheme: AppTheme.colorScheme.copyWith(primary: const Color(0xFFEF6C00), background: const Color(0xFFFFF8F1), surface: Colors.white),
      scaffoldBackgroundColor: const Color(0xFFFFF8F1),
    ),
    // Dark theme preset
    ThemeData.dark().copyWith(
      colorScheme: ThemeData.dark().colorScheme.copyWith(primary: const Color(0xFF90CAF9)),
      scaffoldBackgroundColor: const Color(0xFF0B0B0B),
      appBarTheme: ThemeData.dark().appBarTheme.copyWith(backgroundColor: const Color(0xFF121212)),
    ),
  ];

  void _onSidebarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _colorToHex(Color c) {
    final a = c.alpha.toRadixString(16).padLeft(2, '0');
    final r = c.red.toRadixString(16).padLeft(2, '0');
    final g = c.green.toRadixString(16).padLeft(2, '0');
    final b = c.blue.toRadixString(16).padLeft(2, '0');
    return (a + r + g + b).toUpperCase();
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
    _loadSavedPrefs();
  }

  Future<void> _loadSavedPrefs() async {
    final idx = await ThemePrefs.loadSelectedTheme();
    final color = await ThemePrefs.loadCustomPrimary();
    final tint = await ThemePrefs.loadSidebarTint();
    final headerFull = await ThemePrefs.loadHeaderFullColor();
    setState(() {
      if (idx != null && idx >= 0 && idx < _themePresets.length) _selectedTheme = idx;
      _customPrimary = color;
      _sidebarTint = tint ?? _sidebarTint;
      _headerFullColor = headerFull ?? _headerFullColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userEmail = authProvider.email ?? 'admin@gmail.com';
    final userRole = authProvider.role ?? 'Admin';

    Widget mainContent;
    switch (_selectedIndex) {
      case 0:
          mainContent = DashboardPage(onSwitchTab: _onSidebarTap); // Restored: shows KPI, analytics, low stock, etc.
        break;
      case 0:
        mainContent = DashboardPage(onSwitchTab: _onSidebarTap);
        break;
      case 2:
        mainContent = CategoryManagementScreen();
        break;
      case 3:
        mainContent = EmployeesPage(); // Updated to use the new EmployeesPage
        break;
      case 4:
        mainContent = ReportsScreen();
        break;
      case 5:
        mainContent = _AdminPosView();
        break;
      case 6:
        mainContent = CartScreen();
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
      default:
        mainContent = const Center(child: Text('Coming Soon'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final ThemeData pageTheme = _themePresets[_selectedTheme];
        final ThemeData effective = (_customPrimary != null)
            ? pageTheme.copyWith(
                colorScheme: pageTheme.colorScheme.copyWith(primary: _customPrimary),
                appBarTheme: pageTheme.appBarTheme.copyWith(backgroundColor: pageTheme.colorScheme.surface),
              )
            : pageTheme;

        return Theme(
          data: effective,
          child: Scaffold(
            backgroundColor: effective.colorScheme.background,
            appBar: CustomHeaderBar(
              appName: 'FreshMart Lanka',
              userName: userEmail,
              userRole: userRole,
              onLogout: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              fullColor: _headerFullColor,
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
                    title: const Text('Create New'),
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
                          child: Row(children: [Icon(Icons.inventory, color: Colors.blue), SizedBox(width: 12), Text('Product')]),
                        ),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() => _selectedIndex = 2); // Switch to Categories
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(children: [Icon(Icons.category, color: Colors.orange), SizedBox(width: 12), Text('Category')]),
                        ),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() => _selectedIndex = 3); // Switch to Employees
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(children: [Icon(Icons.person_add, color: Colors.green), SizedBox(width: 12), Text('Employee')]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            body: Stack(
              children: [
                Row(
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
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    isActive: _selectedIndex == 0,
                    onTap: () => _onSidebarTap(0),
                  ),
                  SidebarItem(
                    icon: Icons.inventory,
                    label: 'Products',
                    isActive: _selectedIndex == 1,
                    onTap: () => _onSidebarTap(1),
                  ),
                  SidebarItem(
                    icon: Icons.category,
                    label: 'Categories',
                    isActive: _selectedIndex == 2,
                    onTap: () => _onSidebarTap(2),
                  ),
                  SidebarItem(
                    icon: Icons.people,
                    label: 'Employees',
                    isActive: _selectedIndex == 3,
                    onTap: () => _onSidebarTap(3),
                  ),
                  SidebarItem(
                    icon: Icons.analytics,
                    label: 'Reports',
                    isActive: _selectedIndex == 4,
                    onTap: () => _onSidebarTap(4),
                  ),
                  SidebarItem(
                    icon: Icons.search,
                    label: 'POS Search',
                    isActive: _selectedIndex == 5,
                    onTap: () => _onSidebarTap(5),
                  ),
                  SidebarItem(
                    icon: Icons.shopping_cart,
                    label: 'Cart',
                    isActive: _selectedIndex == 6,
                    onTap: () => _onSidebarTap(6),
                  ),
                  SidebarItem(
                    icon: Icons.inventory_2,
                    label: 'Inventory',
                    isActive: _selectedIndex == 7,
                    onTap: () => _onSidebarTap(7),
                  ),
                  SidebarItem(
                    icon: Icons.list_alt,
                    label: 'Orders',
                    isActive: _selectedIndex == 8,
                    onTap: () => _onSidebarTap(8),
                  ),
                  SidebarItem(
                    icon: Icons.person_search,
                    label: 'Users',
                    isActive: _selectedIndex == 9,
                    onTap: () => _onSidebarTap(9),
                  ),
                  SidebarItem(
                    icon: Icons.local_offer,
                    label: 'Promotions',
                    isActive: _selectedIndex == 10,
                    onTap: () => _onSidebarTap(10),
                  ),
                  SidebarItem(
                    icon: Icons.receipt_long,
                    label: 'Receipts',
                    isActive: _selectedIndex == 11,
                    onTap: () => _onSidebarTap(11),
                  ),
                  SidebarItem(
                    icon: Icons.input,
                    label: 'Goods Received (GR)', // New Menu Item
                    isActive: _selectedIndex == 12,
                    onTap: () => _onSidebarTap(12),
                  ),
                ],
                tintOpacity: _sidebarTint,
                accentColor: _customPrimary,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: mainContent,
                ),
              ),
                  ],
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
                        onPressed: () => _openThemePicker(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openThemePicker(BuildContext context) {
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
                  ...List.generate(_themePresets.length, (i) {
                    final ThemeData t = _themePresets[i];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTheme = i;
                          _customPrimary = null;
                        });
                        ThemePrefs.saveSelectedTheme(i);
                        ThemePrefs.saveCustomPrimary(null);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 84,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: t.colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: i == _selectedTheme ? t.colorScheme.primary : Colors.transparent, width: 2),
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
                ],
              ),
              const SizedBox(height: 12),

              // Custom color input
              Padding(
                // Use padding to space out the custom color section
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))]),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Custom primary (hex)'),
                        const SizedBox(height: 8),
                          Row(children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: _customPrimary != null ? '#${_colorToHex(_customPrimary!)}' : ''),
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              decoration: const InputDecoration(hintText: '#RRGGBB or #AARRGGBB', isDense: true),
                              onSubmitted: (val) {
                                final hex = val.replaceAll('#', '').trim();
                                try {
                                  final color = Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
                                  setState(() => _customPrimary = color);
                                  ThemePrefs.saveCustomPrimary(color);
                                } catch (_) {}
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (_customPrimary != null) {
                                ThemePrefs.saveCustomPrimary(_customPrimary);
                                setState(() => _selectedTheme = 0);
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Apply'),
                          )
                        ])
                      ]),
                    ),
                  ),
              ),

                  // Header full color toggle
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))]),
                    child: Row(children: [
                      const Expanded(child: Text('Header full color')),
                      Switch(
                        value: _headerFullColor,
                        onChanged: (v) async {
                          setState(() => _headerFullColor = v);
                          await ThemePrefs.saveHeaderFullColor(v);
                        },
                      )
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // Sidebar tint slider
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Sidebar tint'),
                      Slider(
                        value: _sidebarTint,
                        min: 0.0,
                        max: 0.4,
                        divisions: 20,
                        label: _sidebarTint.toStringAsFixed(2),
                        onChanged: (v) => setState(() => _sidebarTint = v),
                        onChangeEnd: (v) async {
                          await ThemePrefs.saveSidebarTint(v);
                        },
                      ),
                    ]),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminPosView extends StatelessWidget {
  const _AdminPosView();

  @override
  Widget build(BuildContext context) {
    // Current theme from context
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side: Product Search (Main Area)
        Expanded(
          flex: 3, 
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: theme.cardColor,
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
            child: ProductSearchScreen(),
          ),
        ),
        // Right Side: Cart (Ticket Panel)
        Flexible(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
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
                    color: theme.primaryColor.withOpacity(0.05),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Current Order", 
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold, 
                            color: theme.primaryColor
                          )
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: CartPage()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
