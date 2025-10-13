// This is a basic Flutter widget test for the som_home app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:som_home/main.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    // Initialize Hive for testing
    await Hive.initFlutter();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the app loads successfully
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verify that we can find some basic UI elements
    expect(find.byType(AppBar), findsWidgets);
  });
}
