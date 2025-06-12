// import 'package:final_career_coaching/Career%20Center%20Screen/career_center_screen.dart';
// import 'package:final_career_coaching/Coach%20Screen/coach_home_screen.dart';
// import 'package:final_career_coaching/Student%20Screen/home_screen.dart';
// import 'package:final_career_coaching/model/user_model.dart';
// import 'package:final_career_coaching/services/api_services.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _userIdController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   String _selectedRole = 'Student';
//   String? _selectedCoachRole;
//   bool _isLoading = false;
//   String? _errorMessage;
//   bool _isLogin = true;
//   bool _obscurePassword = true;

//   // Focus nodes
//   final FocusNode _userIdFocus = FocusNode();
//   final FocusNode _nameFocus = FocusNode();
//   final FocusNode _emailFocus = FocusNode();
//   final FocusNode _passwordFocus = FocusNode();

//   @override
//   void dispose() {
//     _userIdFocus.dispose();
//     _nameFocus.dispose();
//     _emailFocus.dispose();
//     _passwordFocus.dispose();
//     super.dispose();
//   }

//   Future<void> saveUserId(String userId) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('user_id', userId);
//   }

//   Future<String?> getUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('user_id');
//   }

//   void _login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     List<User> users = await ApiService.getUsers();

//     final foundUser = users.firstWhere(
//       (user) => user.name == _nameController.text && user.role == _selectedRole,
//       orElse: () => User(id: '', name: "", email: "", role: ""),
//     );

//     if (foundUser.id.isNotEmpty) {
//       print("User ID found: ${foundUser.id}, Role: ${foundUser.role}");

//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('user_id', foundUser.id);
//       await prefs.setString('user_role', foundUser.role);

//       Widget nextScreen;
//       if (foundUser.role == "Coach") {
//         nextScreen = CoachScreen();
//       } else if (foundUser.role == "Career Center") {
//         nextScreen = CareerCenterScreen();
//       } else if (foundUser.role == "Student") {
//         nextScreen = HomeScreen();
//       } else {
//         print("Error: Invalid role received - ${foundUser.role}");
//         return;
//       }

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => nextScreen),
//       );
//     } else {
//       setState(() {
//         _errorMessage = "Invalid Full Name or Role";
//       });
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future<void> checkStoredUserInfo() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedUserId = prefs.getString('user_id');
//     String? storedUserRole = prefs.getString('user_role');

//     print("Stored user_id: $storedUserId");
//     print("Stored user_role: $storedUserRole");
//   }

//   void _signup() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (_selectedRole == "Coach" && _selectedCoachRole == null) {
//       setState(() {
//         _errorMessage = "Please select a coach role.";
//       });
//       return;
//     }

//     if (!_isLogin &&
//         !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//             .hasMatch(_emailController.text)) {
//       setState(() {
//         _errorMessage = "Please enter a valid email address.";
//       });
//       return;
//     }

//     if (_passwordController.text.length < 6) {
//       setState(() {
//         _errorMessage = "Password must be at least 6 characters long.";
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       User newUser = User(
//         id: _userIdController.text,
//         name: _nameController.text,
//         email: _emailController.text,
//         role: _selectedRole,
//       );

//       bool success = await ApiService.createUser(
//         newUser,
//         _passwordController.text,
//         _selectedCoachRole,
//       );

//       if (success) {
//         _formKey.currentState!.reset();
//         setState(() {
//           _isLogin = true;
//           _errorMessage = "Signup successful! Please login.";
//           _selectedRole = 'Student';
//           _selectedCoachRole = null;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Account created successfully! Please login.'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         setState(() {
//           _errorMessage = "Signup failed. User ID may already exist.";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = "An error occurred. Please try again.";
//       });
//       print("Signup error: $e");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (_errorMessage != null)
//                 Text(
//                   _errorMessage!,
//                   style: TextStyle(
//                     color: _errorMessage!.contains("successful")
//                         ? Colors.green
//                         : Colors.red,
//                   ),
//                 ),
//               DropdownButtonFormField<String>(
//                 value: _selectedRole,
//                 items: ['Student', 'Coach', 'Career Center']
//                     .map((role) =>
//                         DropdownMenuItem(value: role, child: Text(role)))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedRole = value!;
//                   });
//                 },
//                 decoration: InputDecoration(labelText: 'Select Role'),
//               ),
//               if (_selectedRole == "Coach" && !_isLogin) ...[
//                 SizedBox(height: 10),
//                 DropdownButtonFormField<String>(
//                   value: _selectedCoachRole,
//                   items: [
//                     'Executive Coach',
//                     'Interview Expert',
//                     'CV Specialist',
//                     'Career Advisor'
//                   ]
//                       .map((role) =>
//                           DropdownMenuItem(value: role, child: Text(role)))
//                       .toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCoachRole = value!;
//                     });
//                   },
//                   decoration: InputDecoration(labelText: 'Select Coach Role'),
//                 ),
//               ],
//               SizedBox(height: 10),
//               if (!_isLogin)
//                 TextFormField(
//                   controller: _userIdController,
//                   focusNode: _userIdFocus,
//                   textInputAction: TextInputAction.next,
//                   onFieldSubmitted: (_) =>
//                       FocusScope.of(context).requestFocus(_nameFocus),
//                   decoration: InputDecoration(
//                     labelText: 'User ID (00-00000)',
//                     prefixIcon: Icon(Icons.person),
//                   ),
//                   keyboardType: TextInputType.text,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your User ID';
//                     }
//                     RegExp regex = RegExp(r'^\d{2}-\d{5}$');
//                     if (!regex.hasMatch(value)) {
//                       return 'Invalid format. Use 00-00000';
//                     }
//                     return null;
//                   },
//                 ),
//               TextFormField(
//                 controller: _nameController,
//                 focusNode: _nameFocus,
//                 textInputAction: TextInputAction.next,
//                 onFieldSubmitted: (_) =>
//                     FocusScope.of(context).requestFocus(_emailFocus),
//                 decoration: InputDecoration(
//                   labelText: 'Full Name',
//                   prefixIcon: Icon(Icons.person_outline),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your full name';
//                   }
//                   return null;
//                 },
//               ),
//               if (!_isLogin) ...[
//                 SizedBox(height: 10),
//                 TextFormField(
//                   controller: _emailController,
//                   focusNode: _emailFocus,
//                   textInputAction: TextInputAction.next,
//                   onFieldSubmitted: (_) =>
//                       FocusScope.of(context).requestFocus(_passwordFocus),
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     prefixIcon: Icon(Icons.email),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                         .hasMatch(value)) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//               ],
//               SizedBox(height: 10),
//               TextFormField(
//                 controller: _passwordController,
//                 focusNode: _passwordFocus,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   prefixIcon: Icon(Icons.lock),
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscurePassword
//                         ? Icons.visibility
//                         : Icons.visibility_off),
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                   helperText: 'At least 6 characters',
//                 ),
//                 obscureText: _obscurePassword,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your password';
//                   }
//                   if (value.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               _isLoading
//                   ? CircularProgressIndicator()
//                   : Column(
//                       children: [
//                         ElevatedButton(
//                           onPressed: _isLogin ? _login : _signup,
//                           child: Text(_isLogin ? 'Login' : 'Sign Up'),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             setState(() {
//                               _isLogin = !_isLogin;
//                               _errorMessage = null;
//                             });
//                           },
//                           child: Text(
//                             _isLogin
//                                 ? "Don't have an account? Sign Up"
//                                 : "Already have an account? Login",
//                           ),
//                         ),
//                       ],
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
