// ignore_for_file: unused_field

import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_career_coaching/Coach%20Screen/request_schedule_screen.dart'
    as requestScreen;
import 'package:final_career_coaching/Coach%20Screen/schedules_screen.dart'
    as scheduleScreen;
import 'package:final_career_coaching/Student%20Screen/message_screen.dart';
import 'package:final_career_coaching/Student%20Screen/session_widgets.dart';
import 'package:final_career_coaching/model/student_profile_model.dart'
    as profile_model;
import 'package:final_career_coaching/model/student_profile_pictures_model.dart';
import 'package:final_career_coaching/model/student_request_reschedule_model.dart';
import 'package:final_career_coaching/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:final_career_coaching/model/student_profile_model.dart';
import 'package:final_career_coaching/model/session_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  // Updated color palette to match student profile
  static const Color primaryColor =
      Color.fromARGB(255, 185, 22, 28); // Matching red
  static const Color secondaryColor =
      Color.fromARGB(255, 255, 255, 255); // White
  static const Color accentColor =
      Color.fromARGB(255, 240, 240, 240); // Light grey
  static const Color lightColor =
      Color.fromARGB(255, 248, 248, 248); // Off-white
  static const Color darkColor = Color.fromARGB(255, 51, 51, 51); // Dark grey
  static const Color greyColor =
      Color.fromARGB(255, 142, 142, 147); // Neutral grey

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _isLoading = true;
  profile_model.StudentProfile? _student;
  File? _profileImage;
  Uint8List? _webImage;
  bool _imageLoading = false;
  StudentProfilePicture? _profilePicture;

  // State variables for sessions
  List<Session> _upcomingSessions = [];
  List<Session> _pastSessions = [];
  List<Session> _pendingSessions = [];
  List<Session> cancelledSessions = [];

  // State variables for showing all sessions
  final bool _showAllUpcoming = false;
  final bool _showAllPast = false;
  // bool _showAllPending = false;

  @override
  void initState() {
    super.initState();
    print("Initializing StudentProfileScreen...");
    _loadInitialData();
    _loadProfilePicture();
    ApiService.fetchRescheduleRequests().then((_) {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ApiService.fetchRescheduleRequests().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadInitialData() async {
    await _loadStudentData();
    await _loadProfilePicture();
    await _loadSessions();
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildStudentAvatar(String name, double radius) {
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

  Widget _buildDefaultAvatar() {
    return _buildStudentAvatar(_student?.studentName ?? 'Student', 45);
  }

  Widget _buildProfileAvatar() {
    if (_imageLoading) {
      return CircleAvatar(
        radius: 45,
        backgroundColor: Colors.grey[200],
        child: CircularProgressIndicator(),
      );
    }
    return CircleAvatar(
      radius: 45,
      backgroundImage: AssetImage('assets/student_profile.jpg'),
    );
  }

  Widget _buildProfileImageWidget() {
    return CircleAvatar(
      radius: 45,
      backgroundImage: AssetImage('assets/student_profile.jpg'),
      child: _imageLoading ? CircularProgressIndicator() : null,
    );
  }

  Future<void> _loadStudentData() async {
    try {
      String? userId = await _getLoggedInUserId();
      if (userId == null) return;

      final studentData = await ApiService.getStudentProfile(userId);
      if (studentData != null) {
        setState(() {
          _student = studentData;
        });
      }
    } catch (e) {
      print('Error loading student data: $e');
    }
  }

  Future<void> _loadProfilePictureFromLocalAndServer() async {
    try {
      String? userId = await _getLoggedInUserId();
      if (userId == null) return;

      setState(() => _imageLoading = true);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? localImageUrl = prefs.getString('profile_image_url');

      if (localImageUrl != null && localImageUrl.isNotEmpty) {
        localImageUrl =
            localImageUrl.replaceAll('192.168.254.104', 'localhost');

        setState(() {
          _profilePicture = StudentProfilePicture(
            id: 0,
            userId: userId,
            imagePath: localImageUrl ?? '',
            imageUrl: localImageUrl ?? '',
            mimeType: 'image/jpeg',
            fileSize: 0,
            uploadedAt: DateTime.now(),
          );
        });
      }

      final picture = await ApiService.getProfilePicture(userId);
      if (picture != null && picture.imageUrl.isNotEmpty) {
        setState(() {
          _profilePicture = picture;
          _profileImage = null;
          _webImage = null;
        });

        await _saveImageLocally(picture.imageUrl);
      }
    } catch (e) {
      print('Error loading profile picture: $e');
    } finally {
      if (mounted) {
        setState(() => _imageLoading = false);
      }
    }
  }

  Future<void> _loadSessions() async {
    try {
      print("Loading sessions...");
      String? userId = await _getLoggedInUserId();
      print("Sessions - User ID: $userId");
      if (userId == null) {
        print("Error: No logged-in user found!");
        return;
      }

      Map<String, List<Session>> sessionData =
          await ApiService.fetchSessions(userId);

      print(
          "Upcoming Sessions: ${sessionData['upcoming_sessions']?.length ?? 0}");
      print("Past Sessions: ${sessionData['past_sessions']?.length ?? 0}");
      print(
          "Pending Sessions: ${sessionData['pending_sessions']?.length ?? 0}");
      print(
          "Cancelled Sessions: ${sessionData['cancelled_sessions']?.length ?? 0}");

      setState(() {
        _upcomingSessions = sessionData['upcoming_sessions'] ?? [];
        _pastSessions = sessionData['past_sessions'] ?? [];
        _pendingSessions = sessionData['pending_sessions'] ?? [];
        cancelledSessions = sessionData['cancelled_sessions'] ?? [];
      });
    } catch (e) {
      print("Error loading sessions: $e");
    }
  }

  Widget _buildIconButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: color),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  void _editProfile() {
    print("Navigate to Edit Profile Screen");
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() => _imageLoading = true);

        String? userId = await _getLoggedInUserId();
        if (userId == null) return;

        dynamic imageFile;
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          imageFile = bytes;
        } else {
          imageFile = File(pickedFile.path);
        }

        try {
          final result =
              await ApiService.createProfilePicture(userId, imageFile);

          if (result != null) {
            // Normalize the URL
            String normalizedUrl = result.imageUrl;
            if (!normalizedUrl.startsWith('http')) {
              normalizedUrl =
                  'http://localhost/final_career_coaching/${result.imagePath}';
            }

            setState(() {
              _profilePicture = StudentProfilePicture(
                id: result.id,
                userId: userId,
                imagePath: result.imagePath,
                imageUrl: normalizedUrl,
                mimeType: result.mimeType,
                fileSize: result.fileSize,
                uploadedAt: result.uploadedAt,
              );
              if (kIsWeb) {
                _webImage = imageFile as Uint8List;
              } else {
                _profileImage = imageFile as File;
              }
            });

            // Save to local storage
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('profile_image_url', normalizedUrl);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile picture uploaded successfully!')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${e.toString()}')),
          );
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _imageLoading = false);
    }
  }

  Future<void> _saveImageLocally(String imageUrl) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_url', imageUrl);
    } catch (e) {
      print('Error saving image URL locally: $e');
    }
  }

  // Modify your _loadProfilePicture method
  Future<void> _loadProfilePicture() async {
    try {
      String? userId = await _getLoggedInUserId();
      if (userId == null) return;

      setState(() => _imageLoading = true);

      // First check local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedUrl = prefs.getString('profile_image_url');

      if (cachedUrl != null && cachedUrl.isNotEmpty) {
        // Normalize the URL to use http
        cachedUrl = cachedUrl.replaceAll('https://', 'http://');
        bool isValid = await _verifyImageUrl(cachedUrl);
        if (isValid) {
          setState(() {
            _profilePicture = StudentProfilePicture(
              id: 0, // Temporary ID
              userId: userId,
              imagePath: cachedUrl ?? '',
              imageUrl: cachedUrl ?? '',
              mimeType: 'image/jpeg',
              fileSize: 0,
              uploadedAt: DateTime.now(),
            );
          });
          return;
        }
      }

      // If no valid cached image, fetch from server
      final picture = await ApiService.getProfilePicture(userId);
      if (picture != null && picture.imageUrl.isNotEmpty) {
        // Normalize the URL to use http
        String normalizedUrl =
            picture.imageUrl.replaceAll('https://', 'http://');
        if (!normalizedUrl.startsWith('http')) {
          normalizedUrl =
              'http://localhost/final_career_coaching/${picture.imagePath}';
        }

        setState(() {
          _profilePicture = StudentProfilePicture(
            id: picture.id,
            userId: userId,
            imagePath: picture.imagePath,
            imageUrl: normalizedUrl,
            mimeType: picture.mimeType,
            fileSize: picture.fileSize,
            uploadedAt: picture.uploadedAt,
          );
        });

        // Update cache with normalized URL
        await prefs.setString('profile_image_url', normalizedUrl);
      }
    } catch (e) {
      print('Error loading profile picture: $e');
    } finally {
      if (mounted) {
        setState(() => _imageLoading = false);
      }
    }
  }

  Future<bool> _verifyImageUrl(String url) async {
    try {
      // Skip verification for localhost URLs
      if (url.contains('localhost')) return true;

      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying image URL: $e');
      return false;
    }
  }

  Future<String?> _getLoggedInUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");
    print("Retrieved user ID from SharedPreferences: $userId");
    return userId;
  }

  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return "${_getMonthName(parsedDate.month)} ${parsedDate.day.toString().padLeft(2, '0')}, ${parsedDate.year}";
  }

  String _formatTime(String time) {
    DateTime parsedTime = DateTime.parse("1970-01-01 $time");
    String startHour =
        parsedTime.hour % 12 == 0 ? '12' : (parsedTime.hour % 12).toString();
    String startMinute = parsedTime.minute.toString().padLeft(2, '0');
    String startAmPm = parsedTime.hour < 12 ? 'AM' : 'PM';
    String startTime = '$startHour:$startMinute $startAmPm';

    DateTime endTime = parsedTime.add(Duration(minutes: 30));
    String endHour =
        endTime.hour % 12 == 0 ? '12' : (endTime.hour % 12).toString();
    String endMinute = endTime.minute.toString().padLeft(2, '0');
    String endAmPm = endTime.hour < 12 ? 'AM' : 'PM';
    String formattedEndTime = '$endHour:$endMinute $endAmPm';

    return '$startTime - $formattedEndTime';
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

  void _editName() {
    final originalValues = {
      'name': _student?.studentName ?? '',
      'department': _student?.department ?? '',
      'course': _student?.course ?? '',
      'level': _student?.level ?? '',
      'address': _student?.address ?? '',
      'contact': _student?.contact ?? '',
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
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 185, 22, 28),
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

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar Section
                        GestureDetector(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? pickedFile = await picker.pickImage(
                                source: ImageSource.gallery);

                            if (pickedFile != null) {
                              setState(() => _imageLoading = true);

                              String? userId = await _getLoggedInUserId();
                              if (userId == null) return;

                              dynamic imageFile;
                              if (kIsWeb) {
                                final bytes = await pickedFile.readAsBytes();
                                imageFile = bytes;
                              } else {
                                imageFile = File(pickedFile.path);
                              }

                              try {
                                final result =
                                    await ApiService.createProfilePicture(
                                        userId, imageFile);

                                if (result != null) {
                                  setState(() {
                                    _profilePicture = result;
                                    if (kIsWeb) {
                                      _webImage = imageFile as Uint8List;
                                    } else {
                                      _profileImage = imageFile as File;
                                    }
                                  });

                                  await _saveImageLocally(result.imageUrl);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Profile picture uploaded successfully!')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Upload failed: ${e.toString()}')),
                                );
                              } finally {
                                setState(() => _imageLoading = false);
                              }
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 185, 22, 28),
                                    width: 2.0,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/student_profile.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 185, 22, 28),
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

                        // Remove Profile Button
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
                                          Icons.delete_outline,
                                          size: 40,
                                          color: const Color.fromARGB(
                                              255,
                                              185,
                                              22,
                                              28), // Changed to match edit profile red
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "Remove Profile Picture?",
                                          style: GoogleFonts.inter(
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
                                            style: GoogleFonts.inter(
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
                                                style: GoogleFonts.inter(
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
                                                backgroundColor: const Color
                                                    .fromARGB(255, 185, 22,
                                                    28), // Changed to match edit profile red
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
                                                "Remove",
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

                            if (confirm == true) {
                              setState(() => _imageLoading = true);
                              try {
                                String? userId = await _getLoggedInUserId();
                                if (userId != null) {
                                  bool success =
                                      await ApiService.deleteProfilePicture(
                                          userId);
                                  if (success) {
                                    setState(() {
                                      _profilePicture = null;
                                      _profileImage = null;
                                      _webImage = null;
                                    });
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.remove('profile_image_url');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Profile picture removed successfully'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Failed to remove profile picture: $e'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } finally {
                                setState(() => _imageLoading = false);
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color.fromARGB(255, 185, 22,
                                28), // Changed to match edit profile red
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

                        // Compact form fields
                        _buildEditField(
                          icon: UniconsLine.user,
                          label: 'Name',
                          initialValue: _student?.studentName,
                          onChanged: (value) => _student?.studentName = value,
                        ),

                        _buildEditField(
                          icon: UniconsLine.building,
                          label: 'Department',
                          initialValue: _student?.department,
                          onChanged: (value) => _student?.department = value,
                          enabled:
                              false, // Add this line to make it non-editable
                        ),

                        _buildEditField(
                          icon: UniconsLine.book_alt,
                          label: 'Course',
                          initialValue: _student?.course,
                          onChanged: (value) => _student?.course = value,
                          enabled:
                              false, // Add this line to make it non-editable
                        ),

                        _buildEditField(
                          icon: UniconsLine.graduation_cap,
                          label: 'Level',
                          initialValue: _student?.level,
                          onChanged: (value) => _student?.level = value,
                          enabled:
                              false, // Add this line to make it non-editable
                        ),

                        _buildEditField(
                          icon: UniconsLine.map_marker,
                          label: 'Address',
                          initialValue: _student?.address,
                          onChanged: (value) => _student?.address = value,
                        ),

                        _buildEditField(
                          icon: UniconsLine.phone,
                          label: 'Contact',
                          initialValue: _student?.contact,
                          onChanged: (value) => _student?.contact = value,
                          keyboardType: TextInputType.phone,
                        ),

                        _buildEditField(
                          icon: UniconsLine.envelope,
                          label: 'Email',
                          initialValue: _student?.email,
                          enabled: false,
                        ),
                      ],
                    ),
                  ),
                ),

                // Buttons
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 185, 22, 28),
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
                              color: const Color.fromARGB(255, 185, 22, 28),
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
                            backgroundColor:
                                const Color.fromARGB(255, 185, 22, 28),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            try {
                              setState(() => _isLoading = true);
                              if (_student == null) return;

                              final updatedProfile = StudentProfile(
                                studentNo: _student!.studentNo,
                                studentName: _student!.studentName,
                                department: _student!.department,
                                course: _student!.course,
                                level: _student!.level,
                                address: _student!.address,
                                contact: _student!.contact,
                                email: _student!.email,
                              );

                              if (await ApiService.modifyStudentProfile(
                                  updatedProfile)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Profile updated successfully'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                await _loadStudentData();
                              } else {
                                _student?.studentName =
                                    originalValues['name'] ?? '';
                                _student?.department =
                                    originalValues['department'] ?? '';
                                _student?.course =
                                    originalValues['course'] ?? '';
                                _student?.level = originalValues['level'] ?? '';
                                _student?.address =
                                    originalValues['address'] ?? '';
                                _student?.contact =
                                    originalValues['contact'] ?? '';
                              }
                            } finally {
                              setState(() => _isLoading = false);
                            }
                          },
                          child: Text(
                            'Save',
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
    required String? initialValue,
    ValueChanged<String>? onChanged,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
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
          prefixIcon: Icon(icon,
              size: 18, color: const Color.fromARGB(255, 185, 22, 28)),
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

  void _showRescheduleDialog(Session session) async {
    final now = DateTime.now();
    final sessionDateTime =
        DateTime.parse("${session.sessionDate} ${session.sessionTime}");
    final difference = sessionDateTime.difference(now);
    final isTooClose = difference.inMinutes <= 15;

    if (isTooClose) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Rescheduling is not allowed within 15 minutes of the session"),
        ),
      );
      return;
    }

    TextEditingController messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder(
                      tween: ColorTween(
                        begin: Colors.grey[300],
                        end: requestScreen.darkDeclineColor,
                      ),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, color, child) => Icon(
                        Icons.schedule_rounded,
                        size: 48,
                        color: color as Color?,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Reschedule Session",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[200] ?? Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_outline,
                                  size: 20, color: Colors.grey[600]),
                              const SizedBox(width: 12),
                              Text(
                                "Current Appointment:",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${_formatDate(session.sessionDate)} • ${_formatTime(session.sessionTime)}",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Reason for rescheduling:",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: messageController,
                      maxLines: 4,
                      minLines: 3,
                      decoration: InputDecoration(
                        hintText: "Explain why you need to reschedule...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please provide a reason";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Note: Rescheduling this appointment will notify the coach.",
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            child: TextButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                foregroundColor: Colors.grey[700],
                              ),
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 1, end: 1),
                          duration: const Duration(milliseconds: 150),
                          builder: (context, scale, child) => Transform.scale(
                            scale: scale as double,
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        setState(() => isSubmitting = true);
                                        try {
                                          final response = await ApiService
                                              .submitRescheduleRequest(
                                            appointmentId: int.parse(
                                                session.appointmentId),
                                            studentName:
                                                _student?.studentName ?? "",
                                            message:
                                                messageController.text.trim(),
                                            dateRequest: session.sessionDate,
                                            timeRequest: session.sessionTime,
                                          );

                                          if (response.containsKey("success") &&
                                              mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text(response["success"]),
                                              ),
                                            );
                                            Navigator.pop(context);
                                            setState(() {});
                                          } else if (response
                                                  .containsKey("error") &&
                                              mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text(response["error"]),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Error: ${e.toString().replaceAll('Exception: ', '')}'),
                                              ),
                                            );
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(
                                                () => isSubmitting = false);
                                          }
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: requestScreen.darkDeclineColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 1,
                                shadowColor:
                                    requestScreen.darkDeclineShadowColor,
                              ),
                              child: Text(
                                isSubmitting
                                    ? "Processing..."
                                    : "Submit Request",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
      },
    );
  }

  ImageProvider<Object>? _getProfileImage() {
    return AssetImage('assets/student_profile.jpg');
  }

  @override
  Widget build(BuildContext context) {
    if (_student == null && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Failed to load profile data", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: Text("Retry"),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: const Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: Color.fromARGB(255, 185, 22, 28),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Profile Header Section (non-scrollable)
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 185, 22, 28),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
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
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/student_profile.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _editName,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _student?.studentName ?? 'Loading...',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              UniconsLine.edit,
                              size: 22,
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: _editName,
                          ),
                        ],
                      ),
                      Text(
                        _student?.course ?? 'Student',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                // Main Content (scrollable sections)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About Me Section (with separate scroll)
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                _buildSingleProfileContainer(),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Sessions Section (with separate scroll)
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(color: Colors.grey.shade300)),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  children: const [],
                                ),
                                const SizedBox(height: 16),
                                CombinedSessionsView(
                                  upcomingSessions: _upcomingSessions,
                                  pastSessions: _pastSessions,
                                  pendingSessions: _pendingSessions,
                                  cancelledSessions: cancelledSessions,
                                  onReschedule: _showRescheduleDialog,
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
    );
  }

  Widget _buildSessionCard(Session session, {bool isUpcoming = false}) {
    bool hasRequestedReschedule =
        ApiService.hasRequestedReschedule(int.parse(session.appointmentId));

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(bottom: 20),
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
                Text(
                  'Coach: ${session.coachName}',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    session.serviceType,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${_formatDate(session.sessionDate)}',
                      style:
                          GoogleFonts.inter(fontSize: 14, color: Colors.black),
                    ),
                    Text(
                      'Time: ${_formatTime(session.sessionTime)}',
                      style:
                          GoogleFonts.inter(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
                if (isUpcoming)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ElevatedButton(
                      onPressed: hasRequestedReschedule
                          ? null
                          : () => _showRescheduleDialog(session),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasRequestedReschedule
                            ? Colors.grey
                            : const Color.fromARGB(255, 207, 2, 2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        minimumSize: const Size(0, 40),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasRequestedReschedule
                                ? Icons.hourglass_empty
                                : Icons.loop,
                            color: hasRequestedReschedule
                                ? Color.fromARGB(255, 185, 22, 28)
                                : Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasRequestedReschedule
                                ? "Awaiting Confirmation"
                                : "Reschedule",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleProfileContainer() {
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
              _buildDetailText('Student No', _student?.studentNo),
              _buildDetailText('Department', _student?.department),
              _buildDetailText('Course', _student?.course),
              _buildDetailText('Level', _student?.level),
              _buildDetailText('Address', _student?.address),
              _buildDetailText('Contact', _student?.contact),
              _buildDetailText('Email', _student?.email, isEmail: true),
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
                                        style: GoogleFonts.inter(
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
                                          style: GoogleFonts.inter(
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
                                              style: GoogleFonts.inter(
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

                          if (confirm == true) {
                            try {
                              // Show loading dialog
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                              );

                              String? userId = await _getLoggedInUserId();
                              if (userId != null) {
                                final response =
                                    await ApiService.sendPasswordReset(userId);

                                // Close loading dialog
                                Navigator.of(context).pop();

                                if (response.containsKey('success')) {
                                  // Show success dialog
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
                                                style: GoogleFonts.inter(
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
                                                  style: GoogleFonts.inter(
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
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response['error'] ??
                                          'Failed to reset password'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              // Close loading dialog if still open
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
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
}
