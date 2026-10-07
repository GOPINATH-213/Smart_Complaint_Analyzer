import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_complaint_app/main.dart';
import 'package:smart_complaint_app/core/theme/theme_provider.dart';

void main() {
  testWidgets('App starts and smoke check passes', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MainApp(),
      ),
    );

    // Verify the Splash Screen elements are rendered
    expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
    expect(find.text('Smart Complaint'), findsOneWidget);
  });
}
