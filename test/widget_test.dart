import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:trustcard/main.dart';
import 'package:trustcard/providers/auth_provider.dart';
import 'package:trustcard/providers/card_provider.dart';

void main() {
  testWidgets('TrustCard app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CardProvider()),
        ],
        child: MaterialApp(
          home: const Scaffold(
            body: Center(
              child: Text('TrustCard App'),
            ),
          ),
        ),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text('TrustCard App'), findsOneWidget);
  });
}
