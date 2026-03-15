import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // Web support
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/products/providers/product_provider.dart';
import 'features/products/providers/category_provider.dart';
import 'features/products/providers/employee_provider.dart';
import 'features/products/providers/report_provider.dart';
import 'features/finance/providers/finance_provider.dart'; // Import Finance Provider
import 'features/procurement/providers/purchase_order_provider.dart'; // Import PO Provider
import 'features/products/providers/notification_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/admin/providers/orders_provider.dart';
import 'features/admin/providers/inventory_provider.dart';
import 'features/grn/providers/grn_provider.dart';
import 'features/supplier/providers/supplier_provider.dart';
import 'features/employees/providers/attendance_provider.dart';
import 'features/employees/providers/payroll_provider.dart';
import 'core/providers/cart_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/products/screens/new_admin_dashboard.dart'; // Using the NEW dashboard
// import 'features/products/screens/admin_dashboard.dart';
import 'layout/app_layout.dart';
import 'features/products/screens/employee_dashboard.dart';
import 'screens/product_search_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';

import 'features/auth/screens/settings_screen.dart'; // Import Settings Screen

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize sqflite FFI for desktop platforms so sqflite works on Windows/Linux/macOS
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  if (kIsWeb) {
    // Initialize sqflite for web
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProxyProvider<AuthProvider, PurchaseOrderProvider>(
          create: (context) => PurchaseOrderProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => PurchaseOrderProvider(auth),
        ),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => GrnProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProxyProvider<AttendanceProvider, PayrollProvider>(
            create: (context) => PayrollProvider(context.read<AttendanceProvider>()),
            update: (context, attendance, previous) => PayrollProvider(attendance),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeModeProvider()),
        ChangeNotifierProxyProvider<AuthProvider, FinanceProvider>(
          create: (context) => FinanceProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => FinanceProvider(auth),
        ),
      ],
      child: Consumer<ThemeModeProvider>(
        builder: (context, themeProvider, _) {
          // Determine the actual ThemeData based on provider state
          final activeTheme = themeProvider.currentTheme;
          
          return MaterialApp(
          title: 'Supermarket App',
          debugShowCheckedModeBanner: false,
          theme: activeTheme, // Use dynamic theme
          themeMode: ThemeMode.light, // Force light mode so it always uses the `theme` property which we control dynamically
          home: const AuthWrapper(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/admin': (context) => const NewAdminDashboard(),
            '/employee': (context) => const EmployeeDashboard(),
            '/product-search': (context) => const ProductSearchScreen(),
            '/cart': (context) => const CartScreen(),
            '/checkout': (context) => const CheckoutScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await context.read<AuthProvider>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      final role = authProvider.role;
      if (role == 'Admin') {
        // Use new desktop layout
        return const NewAdminDashboard();
      } else if (role == 'Employee') {
        return const EmployeeDashboard();
      }
    }

    return const LoginScreen();
  }
}
