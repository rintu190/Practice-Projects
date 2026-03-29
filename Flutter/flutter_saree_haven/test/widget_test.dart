import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_saree_haven/main.dart';
import 'package:flutter_saree_haven/features/cart/cart_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartService()),
        ],
        child: const SareeHavenApp(),
      ),
    );

    // Verify that the home screen loads with the app name
    expect(find.text('Saree Haven'), findsOneWidget);
    
    // Verify bottom nav items exist
    expect(find.text('Home'), findsOneWidget);
  });
}
