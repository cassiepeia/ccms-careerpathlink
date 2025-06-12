import 'package:final_career_coaching/Career%20Center%20Screen/career_center_screen.dart';
import 'package:final_career_coaching/Coach%20Screen/coach_home_screen.dart';
import 'package:final_career_coaching/Login%20and%20Signup%20Page/signup_page.dart';
import 'package:final_career_coaching/Student%20Screen/home_screen.dart';
import 'package:final_career_coaching/model/user_model.dart';
import 'package:final_career_coaching/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static Future<void> saveUserData(String userId, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    await prefs.setString('user_role', role);
  }

  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  static Future<String?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_role');
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _selectedRole = TextEditingController(text: '');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _selectedRole.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<User> users = await ApiService.getUsers();

      final foundUser = users.firstWhere(
        (user) =>
            user.id == _userIdController.text &&
            user.role == _selectedRole.text,
        orElse: () => User(id: '', name: "", email: "", role: ""),
      );

      if (foundUser.id.isNotEmpty) {
        await UserPreferences.saveUserData(foundUser.id, foundUser.role);
        print('Saved user ID (${foundUser.role}): ${foundUser.id}');

        Widget nextScreen;
        if (foundUser.role == "Workforce Development Trainer") {
          nextScreen = CoachScreen();
        } else if (foundUser.role == "Career Center Director") {
          nextScreen = CareerCenterScreen();
        } else if (foundUser.role == "Student") {
          nextScreen = HomeScreen();
        } else {
          print("Error: Invalid role received - ${foundUser.role}");
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid credentials for selected role')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during login: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatUserId(String input) {
    String digitsOnly = input.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length > 7) {
      digitsOnly = digitsOnly.substring(0, 7);
    }
    if (digitsOnly.length > 2) {
      return '${digitsOnly.substring(0, 2)}-${digitsOnly.substring(2)}';
    }
    return digitsOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.grey[600],
        ),
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.grey,
            ),
      ),
      child: Scaffold(
        body: Row(
          children: [
            Expanded(
              child: Container(
                color: const Color(0xFF8B0000),
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo.png', height: 250),
                    const SizedBox(height: 30),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'UNC ',
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: 'CareerPathlink',
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Career Development Portal',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Please login to continue',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 40),
                      DropdownButtonFormField<String>(
                        value: _selectedRole.text.isNotEmpty
                            ? _selectedRole.text
                            : null,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.account_circle,
                              color: Colors.grey),
                          labelText: 'Login As',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          floatingLabelStyle:
                              TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.grey),
                        style: TextStyle(color: Colors.black),
                        items: [
                          'Student',
                          'Workforce Development Trainer',
                          'Career Center Director'
                        ]
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedRole.text = value ?? ''),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select your role'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _userIdController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.grey),
                          labelText: 'User ID',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          floatingLabelStyle:
                              TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.grey[600],
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(7),
                        ],
                        onChanged: (value) {
                          final formattedText = _formatUserId(value);
                          if (formattedText != value) {
                            _userIdController.value = TextEditingValue(
                              text: formattedText,
                              selection: TextSelection.collapsed(
                                  offset: formattedText.length),
                            );
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your User ID';
                          }
                          final digitsOnly = value.replaceAll('-', '');
                          if (digitsOnly.length != 7) {
                            return 'User ID must be 7 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.grey),
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          floatingLabelStyle:
                              TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.grey[600],
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your password'
                            : null,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B0000),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 3,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'LOGIN',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SignUpPage()),
                            ).then((_) {
                              _userIdController.clear();
                              _passwordController.clear();
                              _selectedRole.clear();
                              _formKey.currentState?.reset();
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: GoogleFonts.inter(color: Colors.grey[600]),
                              children: [
                                TextSpan(
                                  text: 'Sign up',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF8B0000),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
