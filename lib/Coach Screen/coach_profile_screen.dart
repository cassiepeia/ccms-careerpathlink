// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicons/unicons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoachProfileScreen extends StatefulWidget {
  const CoachProfileScreen({super.key});

  @override
  _CoachProfileScreenState createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen> {
  static const Color primaryColor = Color.fromARGB(255, 185, 22, 28);
  static const Color secondaryColor = Color.fromARGB(255, 255, 255, 255);
  static const Color accentColor = Color.fromARGB(255, 240, 240, 240);
  static const Color lightColor = Color.fromARGB(255, 248, 248, 248);
  static const Color darkColor = Color.fromARGB(255, 51, 51, 51);
  static const Color greyColor = Color.fromARGB(255, 142, 142, 147);

  bool _isLoading = true;
  Uint8List? _profileImage;
  Map<String, dynamic> _coachData = {};
  final List<Map<String, dynamic>> _pastSessions = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _coachData = {
      'userId': '',
      'coach_name': '',
      'position': '',
      'contact': '',
      'address': '',
      'email': '',
    };
    _loadUserIdAndData();
    _loadHardcodedImage();
  }

  Future<void> _loadUserIdAndData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('user_id');

      if (_currentUserId != null) {
        await _loadCoachData();
        await _loadPastSessions();
      } else {
        throw Exception('No user ID found in SharedPreferences');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadHardcodedImage() async {
    try {
      final ByteData imageData =
          await rootBundle.load('assets/1709211669228.jpg');
      setState(() {
        _profileImage = imageData.buffer.asUint8List();
      });
    } catch (e) {
      print('Error loading hardcoded image: $e');
    }
  }

  Future<void> _loadCoachData() async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    try {
      final coaches = await ApiService.getAllCoachProfiles();
      final coach = coaches.firstWhere(
        (c) => c['user_id'] == _currentUserId,
        orElse: () => {},
      );

      if (coach.isNotEmpty) {
        setState(() {
          _coachData = {
            'userId': _currentUserId,
            'coach_id': int.tryParse(coach['id'].toString()) ?? 0,
            'coach_name': coach['coach_name'],
            'position': coach['position'],
            'contact': coach['contact'],
            'address': coach['address'],
            'email': coach['email'],
          };
        });
      } else {
        throw Exception('No coach profile found for current user');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load coach data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPastSessions() async {
    if (_coachData['coach_id'] == null) {
      print('Coach ID is null, cannot load past sessions');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final coachId = int.tryParse(_coachData['coach_id'].toString()) ?? 0;
      if (coachId == 0) {
        print('Invalid coach ID: $coachId');
        throw Exception('Invalid coach ID');
      }

      print('Loading past sessions for coach ID: $coachId');
      final sessions = await ApiService.getCompletedSessionsByCoach(coachId);

      setState(() {
        _pastSessions.clear();
        if (sessions.isNotEmpty) {
          _pastSessions.addAll(sessions
              .map((session) => {
                    'studentName':
                        session['student_name']?.toString() ?? 'Student',
                    'date': session['date_requested']?.toString() ?? '',
                    'time': session['time_requested']?.toString() ?? '',
                    'service_type':
                        session['service_type']?.toString() ?? 'Unknown',
                  })
              .toList());
        }
      });
    } catch (e) {
      print('Error loading past sessions: $e');
      setState(() {
        _pastSessions.clear();
      });
      // Don't show error message for empty sessions as it's a normal case
      if (!e.toString().contains('No completed sessions found')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load past sessions: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _isLoading = true);
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _profileImage = bytes;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture updated')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update image: $e')),
      );
    }
  }

  void _editProfileCompact() {
    final originalValues = {
      'coach_name': _coachData['coach_name'] ?? '',
      'contact': _coachData['contact'] ?? '',
      'address': _coachData['address'] ?? '',
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
                        style: GoogleFonts.poppins(
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
                                      : _buildCoachAvatar(
                                          _coachData['coach_name'] ?? 'Coach',
                                          30),
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
                              bool confirm = await showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  insetPadding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 400),
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: primaryColor,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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

                              if (confirm == true) {
                                setState(() {
                                  _profileImage = null;
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              padding: EdgeInsets.zero,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                SizedBox(width: 4),
                                Text("Remove Profile Picture"),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        _buildEditField(
                          icon: UniconsLine.user,
                          label: 'Coach Name',
                          initialValue: _coachData['coach_name'] ?? '',
                          onChanged: (value) =>
                              _coachData['coach_name'] = value,
                        ),
                        _buildEditField(
                          icon: UniconsLine.phone,
                          label: 'Contact',
                          initialValue: _coachData['contact'] ?? '',
                          onChanged: (value) => _coachData['contact'] = value,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildEditField(
                          icon: UniconsLine.map_marker,
                          label: 'Address',
                          initialValue: _coachData['address'] ?? '',
                          onChanged: (value) => _coachData['address'] = value,
                        ),
                        _buildEditField(
                          icon: UniconsLine.envelope,
                          label: 'Email',
                          initialValue: _coachData['email'] ?? '',
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
                            style: GoogleFonts.poppins(
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
                              final result =
                                  await ApiService.updateCoachProfile(
                                {
                                  'userId': _coachData['userId'].toString(),
                                  'coach_name': _coachData['coach_name'],
                                  'contact': _coachData['contact'],
                                  'address': _coachData['address'],
                                },
                              );

                              if (result['success'] == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Profile updated successfully'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                await _loadCoachData();
                              } else {
                                _coachData['coach_name'] =
                                    originalValues['coach_name'] ?? '';
                                _coachData['contact'] =
                                    originalValues['contact'] ?? '';
                                _coachData['address'] =
                                    originalValues['address'] ?? '';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] ??
                                        'Failed to update profile'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              _coachData['coach_name'] =
                                  originalValues['coach_name'] ?? '';
                              _coachData['contact'] =
                                  originalValues['contact'] ?? '';
                              _coachData['address'] =
                                  originalValues['address'] ?? '';
                            } finally {
                              setState(() => _isLoading = false);
                            }
                          },
                          child: Text(
                            'Save Changes',
                            style: GoogleFonts.poppins(
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : _coachData.isEmpty
              ? Center(
                  child: Text(
                    'No coach profile found',
                    style: GoogleFonts.poppins(fontSize: 16, color: darkColor),
                  ),
                )
              : Column(
                  children: [
                    Container(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 30),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
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
                                      ? Image.memory(_profileImage!,
                                          fit: BoxFit.cover)
                                      : _buildCoachAvatar(
                                          _coachData['coach_name'] ?? 'Coach',
                                          50),
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
                                      border: Border.all(
                                          color: Colors.white, width: 1.5),
                                    ),
                                    child: Icon(
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
                                _coachData['coach_name'] ?? 'Loading...',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  UniconsLine.edit,
                                  size: 22,
                                  color: Colors.white,
                                ),
                                onPressed: _editProfileCompact,
                              ),
                            ],
                          ),
                          Text(
                            'Workforce Development Trainer',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
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
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                border: Border(
                                    left: BorderSide(
                                        color: Colors.grey.shade300)),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      children: const [],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildPastSessionsSection(),
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

  Widget _buildAboutMeSection() {
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
              _buildDetailText(
                  'User ID', _coachData['userId'] ?? 'Not assigned'),
              _buildDetailText('Coach Name', _coachData['coach_name']),
              _buildDetailText('Contact', _coachData['contact']),
              _buildDetailText(
                  'Address', _coachData['address'] ?? 'Not provided'),
              _buildDetailText('Email', _coachData['email'], isEmail: true),
              _buildDetailText('Password', '*****', isPassword: true),
            ],
          ),
        ),
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
                      color: Color(0xFF9F9F9F)),
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
                        onPressed: () async {
                          bool confirm = await showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              insetPadding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 400),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.lock_outline,
                                        size: 40,
                                        color: const Color.fromARGB(
                                            255, 185, 22, 28),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Reset Password?",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Text(
                                          "A new password will be sent to your registered email. Continue?",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
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
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 185, 22, 28),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              "Continue",
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

                          if (confirm == true) {
                            final email = _coachData['email'];
                            if (email != null && email.isNotEmpty) {
                              try {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                );

                                final response =
                                    await ApiService.resetCoachPassword(email);

                                Navigator.of(context)
                                    .pop(); // Close loading dialog

                                if (response['success'] == true) {
                                  await showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => Dialog(
                                      insetPadding: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 400),
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
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Text(
                                                  "A new password has been sent to your email address.",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 185, 22, 28),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Text(
                                                  "OK",
                                                  style: GoogleFonts.poppins(
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
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response['message'] ??
                                          'Failed to reset password'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } catch (e) {
                                Navigator.of(context)
                                    .pop(); // Close loading dialog if still open
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'No email address found for this account'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(left: 8.0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Change Password?',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Color(0xFF3771C8),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF3771C8),
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
                style:
                    GoogleFonts.inter(fontSize: 12, color: Color(0xFFFF0000)),
              ),
            ),
        ],
      ),
    );
  }

  bool _showAllSessions = false;

  Widget _buildPastSessionsSection() {
    final sessionsToShow =
        _showAllSessions ? _pastSessions : _pastSessions.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
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
            'Past Sessions',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: const Color(0xFFFF0000),
            ),
          ),
          const SizedBox(height: 15),
          _pastSessions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 50, color: greyColor),
                        const SizedBox(height: 10),
                        Text(
                          'No completed sessions yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: greyColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your completed sessions will appear here',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: greyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    ...sessionsToShow
                        .map((session) => _buildSessionCard(session))
                        .toList(),
                    if (_pastSessions.length > 2)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllSessions = !_showAllSessions;
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _showAllSessions ? 'View Less' : 'View More',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _showAllSessions
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Student: ${session['studentName'] ?? 'Student'}',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Completed',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  (session['service_type'] ?? 'Unknown')
                      .toString()
                      .toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date: ${_formatDate(session['date']!)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Time: ${_formatTime(session['time']!)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return "${_getMonthName(parsedDate.month)} ${parsedDate.day.toString().padLeft(2, '0')}, ${parsedDate.year}";
    } catch (e) {
      return date;
    }
  }

  String _formatTime(String time) {
    try {
      DateTime parsedTime = DateTime.parse("1970-01-01 $time");
      String startHour =
          parsedTime.hour % 12 == 0 ? '12' : (parsedTime.hour % 12).toString();
      String startMinute = parsedTime.minute.toString().padLeft(2, '0');
      String startAmPm = parsedTime.hour < 12 ? 'AM' : 'PM';
      String startTime = '$startHour:$startMinute $startAmPm';

      DateTime endTime = parsedTime.add(const Duration(minutes: 30));
      String endHour =
          endTime.hour % 12 == 0 ? '12' : (endTime.hour % 12).toString();
      String endMinute = endTime.minute.toString().padLeft(2, '0');
      String endAmPm = endTime.hour < 12 ? 'AM' : 'PM';
      String formattedEndTime = '$endHour:$endMinute $endAmPm';

      return '$startTime - $formattedEndTime';
    } catch (e) {
      return time;
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "";
    }
  }

  Widget _buildCoachAvatar(String name, double radius) {
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
}

class ApiService {
  static Future<List<Map<String, dynamic>>> getAllCoachProfiles() async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/coach_profile/update_coach_profile.php");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true) {
          return List<Map<String, dynamic>>.from(responseBody['data']);
        } else {
          throw Exception(responseBody['error'] ?? 'No coach profiles found');
        }
      } else {
        throw Exception(
            'Failed to load coach profiles. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllCoachProfiles: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateCoachProfile(
      Map<String, dynamic> profileData) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/coach_profile/update_coach_profile.php");

    try {
      final updateData = {
        'userId': profileData['userId'].toString(),
        'coach_name': profileData['coach_name']?.toString() ?? '',
        'contact': profileData['contact']?.toString() ?? '',
        'address': profileData['address']?.toString() ?? '',
      };

      print('Sending update request with data: $updateData');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(updateData),
      );

      print('Update response: ${response.statusCode} - ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': responseBody['success'] ?? false,
          'message': responseBody['message'] ?? 'Update completed',
          'affected_rows': responseBody['affected_rows'] ?? 0,
        };
      } else {
        throw Exception(responseBody['error'] ??
            'Failed to update profile. Status: ${response.statusCode}');
      }
    } on FormatException catch (e) {
      print('JSON parsing error: $e');
      throw Exception('Failed to parse server response');
    } on http.ClientException catch (e) {
      print('Network error: $e');
      throw Exception('Network error occurred. Please check your connection.');
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> resetCoachPassword(String email) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/users/wdt_reset_password.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Password reset completed',
          'error': data['error'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to reset password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error resetting password: $e',
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getCompletedSessionsByCoach(
      int coachId) async {
    try {
      final url = Uri.parse(
          "http://localhost/final_career_coaching/api/past_session_coach_screen/read_past_session.php?coach_id=$coachId");

      final response = await http.get(url);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['success'] == true) {
          return List<Map<String, dynamic>>.from(responseBody['data']);
        } else {
          throw Exception(responseBody['message'] ??
              'No completed sessions found for this coach');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getCompletedSessionsByCoach: $e');
      rethrow;
    }
  }

  fetchRescheduleRequests() {}
}
