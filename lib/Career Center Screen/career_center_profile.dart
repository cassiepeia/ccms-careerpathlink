// ignore_for_file: unused_field
import 'package:final_career_coaching/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unicons/unicons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:final_career_coaching/Login%20and%20Signup%20Page/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class CareerCenterProfile {
  final String userId;
  String name;
  String contact;
  final String email;
  final String? position;
  String? address;

  CareerCenterProfile({
    required this.userId,
    required this.name,
    required this.contact,
    required this.email,
    this.position,
    this.address,
  });

  factory CareerCenterProfile.fromJson(Map<String, dynamic> json) {
    return CareerCenterProfile(
      userId: json['user_id'] ?? 'Not assigned',
      name: json['name'] ?? 'Unknown',
      contact: json['contact'] ?? 'Not provided',
      email: json['email'] ?? 'Not provided',
      position: json['position'],
      address: json['address'],
    );
  }
}

class CareerCenterProfileScreen extends StatefulWidget {
  const CareerCenterProfileScreen({super.key});

  @override
  _CareerCenterProfileScreenState createState() =>
      _CareerCenterProfileScreenState();
}

class _CareerCenterProfileScreenState extends State<CareerCenterProfileScreen> {
  static const Color primaryColor = Color.fromARGB(255, 185, 22, 28);
  static const Color secondaryColor = Color.fromARGB(255, 255, 255, 255);
  static const Color accentColor = Color.fromARGB(255, 240, 240, 240);
  static const Color lightColor = Color.fromARGB(255, 248, 248, 248);
  static const Color darkColor = Color.fromARGB(255, 51, 51, 51);
  static const Color greyColor = Color.fromARGB(255, 142, 142, 147);

  late Future<CareerCenterProfile> _profileFuture;
  CareerCenterProfile? _profileData;
  bool _isLoading = true;
  String _errorMessage = '';
  Uint8List? _profileImage;

  @override
  void initState() {
    super.initState();
    final userId = User.currentUser?.userId ?? '';
    _profileFuture = _fetchProfile(userId);
    _loadHardcodedImage();
  }

  Future<void> _loadHardcodedImage() async {
    try {
      final ByteData imageData =
          await rootBundle.load('assets/1743121683181.jpg');
      setState(() {
        _profileImage = imageData.buffer.asUint8List();
      });
    } catch (e) {
      print('Error loading hardcoded image: $e');
    }
  }

  Future<CareerCenterProfile> _fetchProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost/final_career_coaching/api/career_center_profile/get_career_center.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        if (responseData.isNotEmpty) {
          setState(() {
            _profileData = CareerCenterProfile.fromJson(responseData[0]);
            _isLoading = false;
          });
          return _profileData!;
        } else {
          throw Exception('Profile not found');
        }
      } else {
        throw Exception(
            'Failed to fetch profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<void> _updateProfile(
      BuildContext context, CareerCenterProfile updatedProfile) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      await updateProfile(updatedProfile);

      final userId = User.currentUser?.userId ?? '';
      setState(() {
        _profileFuture = _fetchProfile(userId);
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  Future<void> updateProfile(CareerCenterProfile profile) async {
    try {
      final profileJson = {
        'user_id': profile.userId,
        'name': profile.name,
        'contact': profile.contact,
        'email': profile.email,
        'position': profile.position,
        'address': profile.address,
      };

      final response = await http.put(
        Uri.parse(
            'http://localhost/final_career_coaching/api/career_center_profile/update_career_center.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profileJson),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['error'] != null) {
          throw Exception(responseData['error']);
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _profileImage = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<bool?> _showRemoveProfilePictureDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 40,
                  color: primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  "Remove Profile Picture?",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Are you sure you want to remove your profile picture?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Remove",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showResetPasswordDialog() async {
    final email = _profileData?.email;
    if (email == null) return;

    bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  "Reset Password?",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "A new password will be sent to your registered email. Continue?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Continue",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (shouldReset == true) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final response = await http.post(
          Uri.parse(
              "http://localhost/final_career_coaching/api/users/career_center_reset_password.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'email': email}),
        );

        Navigator.of(context).pop();

        final data = jsonDecode(response.body);
        if (response.statusCode == 200 && data.containsKey("success")) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 40,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Password Reset Successful",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "A new password has been sent to your email address.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "OK",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (data.containsKey("error")) {
          throw Exception(data["error"]);
        } else {
          throw Exception("Failed to reset password");
        }
      } catch (e) {
        Navigator.of(context).pop();

        String errorMessage;
        if (e.toString().contains("No account found with this email address")) {
          errorMessage = "No account found with this email address";
        } else if (e
            .toString()
            .contains("not registered as a Career Center Director account")) {
          errorMessage =
              "This email is not registered as a Career Center Director account.\nPlease contact support if you believe this is an error.";
        } else {
          errorMessage = "Error resetting password: ${e.toString()}";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _editProfileCompact() {
    final currentProfile = _profileData;
    if (currentProfile == null) return;

    final originalValues = {
      'name': currentProfile.name,
      'contact': currentProfile.contact,
      'address': currentProfile.address,
    };

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.3,
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 2.0,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _profileImage != null
                                      ? Image.memory(_profileImage!,
                                          fit: BoxFit.cover)
                                      : _buildCCAvatar(currentProfile.name, 30),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2.0),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_profileImage != null)
                          TextButton(
                            onPressed: () async {
                              bool? confirm =
                                  await _showRemoveProfilePictureDialog();

                              if (confirm == true) {
                                setState(() {
                                  _profileImage = null;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile picture removed'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "Remove Profile Picture",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        _buildEditField(
                          icon: UniconsLine.user,
                          label: 'Name',
                          initialValue: currentProfile.name,
                          onChanged: (value) => currentProfile.name = value,
                        ),
                        _buildEditField(
                          icon: UniconsLine.map_marker,
                          label: 'Address',
                          initialValue: currentProfile.address ?? '',
                          onChanged: (value) => currentProfile.address = value,
                        ),
                        _buildEditField(
                          icon: UniconsLine.phone,
                          label: 'Contact',
                          initialValue: currentProfile.contact,
                          onChanged: (value) => currentProfile.contact = value,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildEditField(
                          icon: UniconsLine.envelope,
                          label: 'Email',
                          initialValue: currentProfile.email,
                          enabled: false,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(
                              color: primaryColor,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            try {
                              setState(() => _isLoading = true);

                              final updatedProfile = CareerCenterProfile(
                                userId: currentProfile.userId,
                                name: currentProfile.name,
                                contact: currentProfile.contact,
                                email: currentProfile.email,
                                position: currentProfile.position,
                                address: currentProfile.address,
                              );

                              await _updateProfile(context, updatedProfile);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              currentProfile.name =
                                  originalValues['name'] ?? '';
                              currentProfile.contact =
                                  originalValues['contact'] ?? '';
                              currentProfile.address =
                                  originalValues['address'];
                            } finally {
                              setState(() => _isLoading = false);
                            }
                          },
                          child: Text(
                            'Save Changes',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }

  Widget _buildEditField({
    required IconData icon,
    required String label,
    required String initialValue,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    final controller = TextEditingController(text: initialValue);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          prefixIcon: Icon(icon, size: 18, color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDetailText(String label, String? value,
      {bool isEmail = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                child: Text(
                  '$label:',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: const Color(0xFF9F9F9F)),
                ),
              ),
              Flexible(
                child: Row(
                  children: [
                    Text(
                      value ?? 'N/A',
                      style:
                          GoogleFonts.inter(fontSize: 14, color: Colors.black),
                    ),
                    if (isPassword)
                      TextButton(
                        onPressed: _showResetPasswordDialog,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(left: 8.0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Change Password?',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF3771C8),
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF3771C8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (isEmail)
            Padding(
              padding: const EdgeInsets.only(left: 140, top: 4),
              child: Text(
                'If you lost your password, a new password can be sent to this email.',
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFFFF0000)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAboutMeSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_profileData == null) {
      return const Center(child: Text('No profile data available'));
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About Me',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              _buildDetailText('User ID', _profileData?.userId),
              _buildDetailText('Name', _profileData?.name),
              _buildDetailText('Address', _profileData?.address),
              _buildDetailText('Contact', _profileData?.contact),
              _buildDetailText('Email', _profileData?.email, isEmail: true),
              _buildDetailText('Password', '*****', isPassword: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCCAvatar(String name, double radius) {
    final initials = name.isEmpty
        ? '?'
        : name.split(' ').length > 1
            ? '${name.split(' ')[0][0]}${name.split(' ').last[0]}'.toUpperCase()
            : name[0].toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.shade800,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return FutureBuilder<CareerCenterProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final profile = snapshot.data!;

        return Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _profileImage != null
                          ? Image.memory(_profileImage!, fit: BoxFit.cover)
                          : _buildCCAvatar(profile.name, 50),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _editProfileCompact,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    profile.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      UniconsLine.edit,
                      size: 22,
                      color: Colors.white,
                    ),
                    onPressed: _editProfileCompact,
                  ),
                ],
              ),
              Text(
                profile.position ?? 'Career Center Director',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildAboutMeSection(),
                          const SizedBox(height: 20),
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
    );
  }
}
