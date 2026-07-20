import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webapp/core/theme/app_theme.dart';
import 'package:webapp/features/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding screen renders first page', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: OnboardingScreen(onComplete: () {}),
      ),
    );

    expect(find.text('Build Stunning Sites'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
