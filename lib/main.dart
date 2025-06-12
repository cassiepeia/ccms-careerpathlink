import 'package:final_career_coaching/Coach%20Screen/coach_home_screen.dart';
import 'package:final_career_coaching/Coach%20Screen/notification_provider.dart';
import 'package:final_career_coaching/Login%20and%20Signup%20Page/login_page.dart';
import 'package:final_career_coaching/Student%20Screen/home_screen.dart';
import 'package:final_career_coaching/Student%20Screen/notification_provider.dart'
    show StudentNotificationProvider;
import 'package:flutter/material.dart';
import 'package:final_career_coaching/Login%20and%20Signup%20Page/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Create both providers but they'll only be used if needed
        ChangeNotifierProvider(create: (_) => StudentNotificationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Career Coaching',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder<Widget>(
          future: _determineInitialPage(prefs),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return snapshot.data ?? LoginPage();
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  Future<Widget> _determineInitialPage(SharedPreferences prefs) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading

    final studentName = prefs.getString('student_name');
    final coachName = prefs.getString('coach_name');

    if (studentName != null) {
      return HomeScreen(); // Your student home screen
    } else if (coachName != null) {
      return CoachScreen(); // Your coach home screen
    }
    return LoginPage();
  }
}
