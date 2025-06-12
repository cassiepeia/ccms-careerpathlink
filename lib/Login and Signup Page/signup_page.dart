import 'package:final_career_coaching/model/user_model.dart';
import 'package:final_career_coaching/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _selectedRole = TextEditingController(text: '');
  final TextEditingController _selectedCoachRole =
      TextEditingController(text: '');
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _yearLevelController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> departments = [
    'School of Social and Natural Sciences',
    'College of Engineering and Architecture',
    'School of Business and Accountancy',
    'School of Computer and Information Sciences',
    'School of Law',
    'School of Teacher Education',
    'College of Criminal Justice Education',
    'School of Nursing and Allied Health Sciences'
  ];

  final List<String> courses = [
    'Bachelor of Arts in Psychology',
    'Bachelor of Arts in Political Science',
    'Bachelor of Science in Biology',
    'Bachelor of Science in Civil Engineering',
    'Bachelor of Science in Interior Design',
    'Bachelor of Science in Architecture',
    'Expanded Tertiary Education Equivalent & Accreditation',
    'Bachelor of Science in Accountancy',
    'Bachelor of Science in Tourism Management',
    'Bachelor of Science in Librarian & Information Science',
    'Bachelor of Science in Computer Science',
    'Bachelor of Science in Information Technology',
    'Juris Doctor',
    'Bachelor of Elementary Education',
    'Bachelor of Secondary Education',
    'Bachelor of Physical Education',
    'Bachelor of Science in Criminology',
    'Bachelor of Science in Forensic Science',
    'Bachelor of Science in Nursing'
  ];

  final List<String> yearLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    '5th Year'
  ];

  String _formatUserId(String input) {
    // Remove all non-digit characters
    String digitsOnly = input.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 7 digits
    if (digitsOnly.length > 8) {
      digitsOnly = digitsOnly.substring(0, 8);
    }

    // Add hyphen after first 2 digits if there are more digits
    if (digitsOnly.length > 2) {
      return '${digitsOnly.substring(0, 2)}-${digitsOnly.substring(2)}';
    }

    return digitsOnly;
  }

  final List<String> genders = ['Male', 'Female'];

  @override
  void dispose() {
    _userIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _selectedRole.dispose();
    _selectedCoachRole.dispose();
    _departmentController.dispose();
    _courseController.dispose();
    _yearLevelController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare data based on role
      Map<String, dynamic> userData = {
        'user_id': _userIdController.text,
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': _selectedRole.text,
      };

      // Add role-specific fields
      if (_selectedRole.text == 'Student') {
        userData.addAll({
          'department': _departmentController.text,
          'course': _courseController.text,
          'year_level': _yearLevelController.text,
          'address': _addressController.text,
          'contact': _contactController.text,
          'gender': _genderController.text,
        });
      } else if (_selectedRole.text == 'Workforce Development Trainer' ||
          _selectedRole.text == 'Career Center') {
        userData.addAll({
          'address': _addressController.text,
          'contact': _contactController.text,
        });
      }

      bool success = await ApiService.createUserWithProfile(
        userData,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Account created successfully! Please login.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed. User ID may already exist.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
      print("Signup error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStudentFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person, color: Colors.grey),
            labelText: 'Full Name',
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter your full name'
              : null,
        ),
        const SizedBox(height: 20),

        // Gender Dropdown
        DropdownButtonFormField<String>(
          value: _genderController.text.isEmpty ? null : _genderController.text,
          hint: const Text('Gender'),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.transgender, color: Colors.grey),
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: genders
              .map((gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  ))
              .toList(),
          onChanged: (value) =>
              setState(() => _genderController.text = value ?? ''),
          validator: (value) => value == null || value.isEmpty
              ? 'Please select your gender'
              : null,
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: _userIdController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.badge, color: Colors.grey),
            labelText: 'User ID',
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            // hintText: '19-42344',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(7), // Limit to 7 digits
          ],
          onChanged: (value) {
            // Format the text as user types
            final formattedText = _formatUserId(value);
            if (formattedText != value) {
              _userIdController.value = TextEditingValue(
                text: formattedText,
                selection:
                    TextSelection.collapsed(offset: formattedText.length),
              );
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter User ID';
            // Remove hyphen for validation
            final digitsOnly = value.replaceAll('-', '');
            if (digitsOnly.length != 7) return 'User ID must be 7 digits';
            return null;
          },
        ),
        const SizedBox(height: 20),

        DropdownButtonFormField<String>(
          hint: const Text('Department'),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.school, color: Colors.grey),
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: departments
              .map((dept) => DropdownMenuItem(
                    value: dept,
                    child: Text(dept),
                  ))
              .toList(),
          onChanged: (value) =>
              setState(() => _departmentController.text = value ?? ''),
          validator: (value) => value == null || value.isEmpty
              ? 'Please select department'
              : null,
        ),
        const SizedBox(height: 20),

        DropdownButtonFormField<String>(
          hint: const Text('Course'),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.menu_book, color: Colors.grey),
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: courses
              .map((course) => DropdownMenuItem(
                    value: course,
                    child: Text(course),
                  ))
              .toList(),
          onChanged: (value) =>
              setState(() => _courseController.text = value ?? ''),
          validator: (value) =>
              value == null || value.isEmpty ? 'Please select course' : null,
        ),
        const SizedBox(height: 20),

        DropdownButtonFormField<String>(
          hint: const Text('Year Level'),
          decoration: InputDecoration(
            prefixIcon:
                const Icon(Icons.format_list_numbered, color: Colors.grey),
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: yearLevels
              .map((year) => DropdownMenuItem(
                    value: year,
                    child: Text(year),
                  ))
              .toList(),
          onChanged: (value) =>
              setState(() => _yearLevelController.text = value ?? ''),
          validator: (value) => value == null || value.isEmpty
              ? 'Please select year level'
              : null,
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.home, color: Colors.grey),
            labelText: 'Address',
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter address' : null,
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: _contactController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.phone, color: Colors.grey),
            labelText: 'Contact',
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter contact number';
            }
            if (value.length != 11) return 'Contact must be exactly 11 digits';
            return null;
          },
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email, color: Colors.grey),
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter email';
            if (!value.contains('@')) return 'Please enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock, color: Colors.grey),
            labelText: 'Password',
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter password' : null,
        ),
      ],
    );
  }

  Widget _buildCoachFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person, color: Colors.grey),
            labelText: 'Full Name',
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter your full name'
              : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _userIdController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.badge, color: Colors.grey),
            labelText: 'Job ID',
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            // hintText: '19-42344',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(7), // Limit to 7 digits
          ],
          onChanged: (value) {
            // Format the text as user types
            final formattedText = _formatUserId(value);
            if (formattedText != value) {
              _userIdController.value = TextEditingValue(
                text: formattedText,
                selection:
                    TextSelection.collapsed(offset: formattedText.length),
              );
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter Job ID';
            // Remove hyphen for validation
            final digitsOnly = value.replaceAll('-', '');
            if (digitsOnly.length != 7) return 'Job ID must be 7 digits';
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.home, color: Colors.grey),
            labelText: 'Address',
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter address' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _contactController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.phone, color: Colors.grey),
            labelText: 'Contact',
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter contact number';
            }
            if (value.length != 11) return 'Contact must be exactly 11 digits';
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email, color: Colors.grey),
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter email';
            if (!value.contains('@')) return 'Please enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock, color: Colors.grey),
            labelText: 'Password',
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter password' : null,
        ),
      ],
    );
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
            // Left Half - Branding Section (unchanged)
            Expanded(
              child: Container(
                color: const Color(0xFF8B0000),
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 250,
                    ),
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

            // Right Half - Signup Form
            Expanded(
              child: Column(
                children: [
                  // Fixed header section - Aligned to left
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 40, 40, 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Account',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Join UNC CareerPathlink',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Scrollable form section
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // Role Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedRole.text.isEmpty
                                  ? null
                                  : _selectedRole.text,
                              hint: const Text('Sign Up As'),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.account_circle,
                                    color: Colors.grey),
                                labelStyle: TextStyle(color: Colors.grey[600]),
                                floatingLabelStyle:
                                    TextStyle(color: Colors.grey[600]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: [
                                'Student',
                                'Workforce Development Trainer',
                                'Career Center'
                              ]
                                  .map((role) => DropdownMenuItem(
                                        value: role,
                                        child: Text(role),
                                      ))
                                  .toList(),
                              onChanged: (value) => setState(
                                  () => _selectedRole.text = value ?? ''),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please select your role'
                                      : null,
                            ),
                            const SizedBox(height: 20),

                            // Dynamic form fields based on role
                            if (_selectedRole.text == 'Student') ...[
                              _buildStudentFormFields(),
                            ] else if (_selectedRole.text ==
                                    'Workforce Development Trainer' ||
                                _selectedRole.text == 'Career Center') ...[
                              _buildCoachFormFields(),
                            ],

                            const SizedBox(height: 30),

                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _signup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B0000),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 3,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        'SIGN UP',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Login Prompt
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => LoginPage()),
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: "Already have an account? ",
                                    style: GoogleFonts.inter(
                                        color: Colors.grey[600]),
                                    children: [
                                      TextSpan(
                                        text: 'Login',
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
          ],
        ),
      ),
    );
  }
}
