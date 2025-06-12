import 'package:final_career_coaching/Coach%20Screen/coach_home_screen.dart';
import 'package:final_career_coaching/Login%20and%20Signup%20Page/login_page.dart';
import 'package:final_career_coaching/Login%20and%20Signup%20Page/user.dart';
import 'package:final_career_coaching/Student%20Screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_career_coaching/main.dart';

void main() {
  // Initialize SharedPreferences mock before tests
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Test app initialization', (WidgetTester tester) async {
    // Create mock SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Build our app with the mock preferences
    await tester.pumpWidget(MyApp(prefs: prefs));

    // Verify initial state - adjust these expectations based on your actual app
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Test student login flow', (WidgetTester tester) async {
    // Mock that a student is logged in
    SharedPreferences.setMockInitialValues({
      'student_name': 'Test Student',
    });

    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MyApp(prefs: prefs));

    // Verify student home screen is shown
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Test coach login flow', (WidgetTester tester) async {
    // Mock that a coach is logged in
    SharedPreferences.setMockInitialValues({
      'coach_name': 'Test Coach',
    });

    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MyApp(prefs: prefs));

    // Verify coach home screen is shown
    expect(find.byType(CoachScreen), findsOneWidget);
  });
}
