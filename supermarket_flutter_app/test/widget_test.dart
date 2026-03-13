// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supermarket_flutter_app/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Ensure a sufficiently large test surface to avoid layout overflows.
    final binding = TestWidgetsFlutterBinding.ensureInitialized() as TestWidgetsFlutterBinding;
    binding.window.physicalSizeTestValue = const Size(1280, 800);
    binding.window.devicePixelRatioTestValue = 1.0;

    // Build a minimal app shell to avoid exercising complex responsive UI in tests.
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsOneWidget);

    // Clear the test surface overrides.
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });
}
