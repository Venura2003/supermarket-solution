import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/custom_header_bar.dart';
import '../../shared/sidebar.dart'; // Import the shared Sidebar
import '../../../screens/product_search_screen.dart';
import '../../../screens/cart_screen.dart';
import '../../../screens/checkout_screen.dart';
import '../../cart/cart_page.dart';
import '../../admin/screens/orders_screen.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userEmail = authProvider.email ?? 'cashier@freshmart.lk';
    final userRole = authProvider.role ?? 'Employee';
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        
        Widget bodyContent;
        
        // Define the content based on selection
        if (isWide) {
          if (_selectedIndex == 0) {
            // POS View (Search + Cart)
            bodyContent = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Side: Product Search (Main Area)
                Expanded(
                  flex: 3, 
                  child: Container(
                    margin: const EdgeInsets.all(16),
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
                    margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
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
                              Text(
                                "Current Order", 
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold, 
                                  color: theme.primaryColor
                                )
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
             // Orders View
             bodyContent = Container(
               margin: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ]
               ),
               clipBehavior: Clip.antiAlias,
               child: const OrdersScreen()
             );
          }
        } else {
          // Mobile Layout Logic
          if (_selectedIndex == 0) {
            bodyContent = const ProductSearchScreen();
          } else if (_selectedIndex == 1) {
            bodyContent = const CartScreen(); // Mobile Cart
          } else if (_selectedIndex == 2) {
            bodyContent = const CheckoutScreen();
          } else {
            bodyContent = const OrdersScreen();
          }
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor, // Use theme background
          appBar: CustomHeaderBar(
            appName: 'FreshMart POS',
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
                if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            fullColor: true, // Use full color header like Admin
          ),
          body: isWide 
            ? Row(
                children: [
                  // Use the Admin-style Sidebar
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
                        if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    },
                    items: [
                      SidebarItem(
                        icon: Icons.point_of_sale,
                        label: 'New Sale',
                        isActive: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                      ),
                      SidebarItem(
                        icon: Icons.receipt_long,
                        label: 'Order History',
                        isActive: _selectedIndex == 1, // Map to index 1 manually for Sidebar
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                    ],
                  ),
                  Expanded(child: bodyContent),
                ],
              )
            : bodyContent,
          bottomNavigationBar: isWide
              ? null
              : BottomNavigationBar(
                  currentIndex: (_selectedIndex > 3) ? 0 : _selectedIndex,
                  onTap: _onNavTap,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: theme.primaryColor,
                  unselectedItemColor: Colors.grey,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'POS'),
                    BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
                    BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Checkout'),
                    BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
                  ],
                ),
        );
      },
    );
  }
}