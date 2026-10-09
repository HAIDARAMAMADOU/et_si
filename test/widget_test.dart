import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:et_si/features/auth/presentation/auth_screens.dart';

void main() {
  testWidgets('L’accueil présente le concept ET SI ?', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    expect(find.text('ET SI ?'), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
