import 'package:flutter/material.dart';
import 'header_bar.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/products/products_page.dart';
import '../features/category/category_page.dart';
import '../features/cart/cart_page.dart';
import '../features/employees/employees_page.dart';
import '../features/reports/reports_page.dart';
import '../features/settings/settings_page.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    DashboardPage(),
    ProductsPage(),
    CategoryPage(),
    CartPage(),
    EmployeesPage(),
    ReportsPage(),
    SettingsPage(),
  ];

  final List<String> pageTitles = const [
    'Dashboard',
    'Products',
    'Categories',
    'Cart',
    'Employees',
    'Reports',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = 1200;
        double padding = 24;
        if (constraints.maxWidth < 900) {
          maxWidth = 700;
          padding = 12;
        }
        if (constraints.maxWidth < 600) {
          maxWidth = double.infinity;
          padding = 4;
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          body: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  HeaderBar(title: pageTitles[selectedIndex]),
                  Expanded(
                    child: pages[selectedIndex],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
