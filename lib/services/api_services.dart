// ignore_for_file: unused_local_variable
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart'; // Add this import

// ignore: unused_import
import 'package:final_career_coaching/model/request_appointment_model.dart';
import 'package:final_career_coaching/model/session_model.dart';
import 'package:final_career_coaching/model/student_profile_model.dart'
    as profile_model;
import 'package:final_career_coaching/model/student_profile_pictures_model.dart'
    as pictures_model;
import 'package:final_career_coaching/model/student_request_reschedule_model.dart';
import 'package:final_career_coaching/model/time_slot.dart';
import 'package:final_career_coaching/model/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/select_coach_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost/final_career_coaching/api';

  // Fetch list of coaches
  static Future<List<Coach>> fetchCoaches() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost/final_career_coaching/api/select_coach/get_coaches.php'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        // First print the raw response to debug
        print('Raw response: ${response.body}');

        // Then parse the JSON
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Coach.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load coaches. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchCoaches: $e');
      throw Exception('Failed to load coaches: $e');
    }
  }

  //Create a new coach
  static Future<void> createCoach(String coachName, String coachRole) async {
    final response = await http.post(
      Uri.parse(
          'http://localhost/final_career_coaching/api/select_coach/create_coach.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'coach_name': coachName,
        'coach_role': coachRole,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['message'] != null) {
        print("Coach created successfully");
      } else {
        throw Exception('Failed to create coach');
      }
    } else {
      throw Exception('Failed to create coach');
    }
  }

//update a coach
  static Future<void> updateCoach(
      int id, String coachName, String coachRole) async {
    final response = await http.put(
      Uri.parse(
          'http://localhost/final_career_coaching/api/select_coach/update_coach.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'coach_name': coachName,
        'coach_role': coachRole,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['message'] != null) {
        print("Coach updated successfully");
      } else {
        throw Exception('Failed to update coach');
      }
    } else {
      throw Exception('Failed to update coach');
    }
  }

//delete a coach
  static Future<void> deleteCoach(int id) async {
    final response = await http.delete(
      Uri.parse(
          'http://localhost/final_career_coaching/api/select_coach/delete_coach.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['message'] != null) {
        print("Coach deleted successfully");
      } else {
        throw Exception('Failed to delete coach');
      }
    } else {
      throw Exception('Failed to delete coach');
    }
  }

// Create Time Slot
  static Future<int?> fetchCoachId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            "http://localhost/final_career_coaching/api/time_slot/get_coach_id.php?user_id=$userId"),
      );

      print(
          "[API] Fetch Coach ID Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["coach_id"];
      } else {
        throw Exception("Failed to fetch coach ID: ${response.statusCode}");
      }
    } catch (e) {
      print("[API] Error fetching coach ID: $e");
      return null;
    }
  }

  static Future<TimeSlot?> createTimeSlot(
      TimeSlot timeSlot, String userId) async {
    try {
      print("[API] Creating time slot for user $userId: ${timeSlot.toJson()}");
      final response = await http.post(
        Uri.parse(
            'http://localhost/final_career_coaching/api/time_slot/create_time_slot.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "date_slot": timeSlot.dateSlot,
          "day": timeSlot.day,
          "start_time": timeSlot.startTime,
          "end_time": timeSlot.endTime,
        }),
      );

      print(
          "[API] Create Time Slot Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] != null) {
          return TimeSlot.fromJson(responseData['time_slot']);
        } else if (responseData['error'] != null) {
          throw Exception(responseData['error']);
        }
      }
      return null;
    } catch (e) {
      print("[API] Exception creating time slot: $e");
      throw Exception("Failed to create time slot: $e");
    }
  }

  // Read Time Slots | Coach Screen
  static Future<Map<String, List<TimeSlot>>> fetchTimeSlots(
      String userId) async {
    final response = await http.get(
      Uri.parse(
          "http://localhost/final_career_coaching/api/time_slot/read_time_slot.php?coach_id=$userId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Map<String, List<TimeSlot>> slotsByDate = {};

      if (data["time_slots"] != null) {
        for (var json in data["time_slots"]) {
          TimeSlot slot = TimeSlot.fromJson(json);
          slotsByDate.putIfAbsent(slot.dateSlot, () => []).add(slot);
        }
      }

      return slotsByDate;
    } else if (response.statusCode == 400) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData["error"] ?? "Failed to fetch time slots");
    } else {
      throw Exception("Failed to fetch time slots");
    }
  }

  // Update Time Slot
  static Future<bool> updateTimeSlot(TimeSlot timeSlot) async {
    try {
      final response = await http.put(
        Uri.parse(
            "http://localhost/final_career_coaching/api/time_slot/update_time_slot.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(timeSlot.toJson()),
      );

      // Debugging: Print response details
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["message"] == "Time slot updated successfully";
      } else {
        print("Server returned error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }

  // Delete Time Slot
  static Future<bool> deleteTimeSlot(int id) async {
    final response = await http.delete(
      Uri.parse(
          "http://localhost/final_career_coaching/api/time_slot/delete_time_slot.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id.toString()}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["message"] == "Time slot deleted successfully";
    } else {
      return false;
    }
  }

// Signup
  static Future<bool> createUser(
      User user, String password, String? selectedCoachRole) async {
    print("Sending user_id: ${user.id}"); // Debugging

    final response = await http.post(
      Uri.parse(
          "http://localhost/final_career_coaching/api/users/create_user.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": user.id,
        "name": user.name,
        "email": user.email,
        "password": password,
        "role": user.role,
      }),
    );

    print("Raw Response: ${response.body}"); // Debugging

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data.containsKey("success")) {
        return true;
      } else {
        print("Error from API: ${data['error']}");
        return false;
      }
    } catch (e) {
      print("Error parsing JSON: ${response.body}");
      return false;
    }
  }

  static Future<bool> createUserWithProfile(
      Map<String, dynamic> userData) async {
    print("Sending user data: $userData"); // Debugging

    final response = await http.post(
      Uri.parse(
          "http://localhost/final_career_coaching/api/users/create_user.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    print("Raw Response: ${response.body}"); // Debugging

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data.containsKey("success")) {
        return true;
      } else {
        print("Error from API: ${data['error']}");
        return false;
      }
    } catch (e) {
      print("Error parsing JSON: ${response.body}");
      return false;
    }
  }

  // Read (Get Users)
  static Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse(
        "http://localhost/final_career_coaching/api/users/get_users.php"));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      return [];
    }
  }

//Reset Password
  static Future<Map<String, dynamic>> sendPasswordReset(String userId) async {
    try {
      final response = await http.post(
        Uri.parse(
            "http://localhost/final_career_coaching/api/users/send_password_reset.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Failed to connect to server'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

// Reset Password for WDT
// Add this to your ApiService class
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

// Password Reset for Career Center
  static Future<bool> resetCareerCenterPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(
            "http://localhost/final_career_coaching/api/users/career_center_reset_password.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data.containsKey("success")) {
        return true;
      } else if (data.containsKey("error")) {
        // More specific error handling
        if (data["error"] == "No user found with this email") {
          throw Exception("No account found with this email address");
        } else if (data["error"] ==
            "This email is not registered as a Career Center Director account") {
          throw Exception(
              "This email is not registered as a Career Center Director account");
        } else {
          throw Exception(data["error"]);
        }
      } else {
        throw Exception("Failed to reset password");
      }
    } catch (e) {
      throw Exception("Error resetting password: ${e.toString()}");
    }
  }

  // Update User
  static Future<bool> updateUser(User user) async {
    final response = await http.put(
      Uri.parse(
          "http://localhost/final_career_coaching/api/users/update_user.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    final data = jsonDecode(response.body);
    return response.statusCode == 200 && data.containsKey("success");
  }

  // Delete User
  static Future<bool> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse(
          "http://localhost/final_career_coaching/api/users/delete_user.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id.toString()}),
    );

    final data = jsonDecode(response.body);
    return response.statusCode == 200 && data.containsKey("success");
  }

//Read time slots by coach ID | Student Screen
  static Future<List<TimeSlot>> fetchTimeSlotsByCoach(int coachId) async {
    final response = await http.get(Uri.parse(
        "http://localhost/final_career_coaching/api/time_slot/read_time_slot.php?coach_id=$coachId"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body); // Parse as Map
      print("API Response: $jsonResponse"); // Debugging

      if (jsonResponse.containsKey("time_slots")) {
        final List<dynamic> data = jsonResponse["time_slots"]; // Extract List
        return data.map((json) => TimeSlot.fromJson(json)).toList();
      } else {
        throw Exception("Key 'time_slots' not found in API response");
      }
    } else {
      throw Exception("Failed to load time slots");
    }
  }

// Create a new student profile
  static Future<bool> createStudentProfile(
      profile_model.StudentProfile student) async {
    final response = await http.post(
      Uri.parse(
          'http://localhost/final_career_coaching/api/student_profile/create_student_profile.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(student.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.containsKey("success");
    } else {
      return false;
    }
  }

  // Read all student profiles
  static Future<profile_model.StudentProfile?> getStudentProfile(
      String userId) async {
    try {
      print("Fetching profile for user ID: $userId");

      final response = await http.get(
        Uri.parse(
            'http://localhost/final_career_coaching/api/student_profile/read_student_profiles.php?user_id=$userId'),
      );

      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey("error")) {
          print("Error fetching student profile: ${data["error"]}");
          return null;
        }

        return profile_model.StudentProfile.fromJson(data);
      } else {
        print("Error fetching student profile: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception in API call: $e");
      return null;
    }
  }

// Create profile picture
  static Future<pictures_model.StudentProfilePicture?> createProfilePicture(
    String userId,
    dynamic imageFile,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://localhost/final_career_coaching/api/student_profile_picture/create_profile_picture.php'),
      );

      request.fields['user_id'] = userId;

      if (kIsWeb) {
        final bytes = imageFile as Uint8List;
        request.files.add(http.MultipartFile.fromBytes(
          'profile_picture',
          bytes,
          filename: 'profile_$userId.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          (imageFile as File).path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        if (jsonResponse['success'] == true) {
          // Save to local storage
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_image_url', jsonResponse['image_url']);

          return pictures_model.StudentProfilePicture(
            id: 0,
            userId: userId,
            imagePath: jsonResponse['image_path'],
            imageUrl: jsonResponse['image_url'],
            mimeType: 'image/jpeg',
            fileSize: 0,
            uploadedAt: DateTime.now(),
          );
        }
      }
      return null;
    } catch (e) {
      print('Error creating profile picture: $e');
      return null;
    }
  }

  static Future<pictures_model.StudentProfilePicture?> getProfilePicture(
      String userId) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost/final_career_coaching/api/student_profile_picture/read_profile_picture.php'),
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost', // Add Origin header
        },
        body: json.encode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['error'] != null) {
          print('Error from server: ${data['error']}');
          return null;
        }

        // For localhost, skip verification and trust the server response
        if (data['image_url'] != null && data['image_url'].isNotEmpty) {
          // Ensure the URL is properly formatted
          String imageUrl = data['image_url'];
          if (!imageUrl.startsWith('http://localhost')) {
            imageUrl =
                'http://localhost/final_career_coaching/${data['image_path']}';
          }

          return pictures_model.StudentProfilePicture(
            id: 0,
            userId: userId,
            imagePath: data['image_path'],
            imageUrl: imageUrl,
            mimeType: 'image/jpeg',
            fileSize: 0,
            uploadedAt: DateTime.now(),
          );
        }
        return null;
      } else {
        print('Server returned status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading profile picture: $e');
      return null;
    }
  }

  static Future<Uint8List?> getImage(String imageUrl) async {
    try {
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'Origin':
              'http://localhost/final_career_coaching/api/student_profile_picture/get_image.php'
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Failed to load image. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }

// Update Profile Picture (similar to create)
  static Future<pictures_model.StudentProfilePicture?> updateProfilePicture(
    String userId,
    dynamic imageFile,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://localhost/final_career_coaching/api/student_profile_picture/update_profile_picture.php'),
      );

      request.fields['user_id'] = userId;

      if (kIsWeb) {
        final bytes = imageFile as Uint8List;
        request.files.add(http.MultipartFile.fromBytes(
          'profile_picture',
          bytes,
          filename: 'profile_$userId.jpg',
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          (imageFile as File).path,
        ));
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return pictures_model.StudentProfilePicture.fromJson(
            json.decode(responseData));
      }
      return null;
    } catch (e) {
      print('Error updating profile picture: $e');
      return null;
    }
  }

// Delete Profile Picture
  static Future<bool> deleteProfilePicture(String userId) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost/final_career_coaching/api/student_profile_picture/delete_profile_picture.php'),
        body: {'user_id': userId},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting profile picture: $e');
      return false;
    }
  }

  // Update student profile
  static Future<bool> modifyStudentProfile(
      profile_model.StudentProfile student) async {
    // Ensure we do not send empty values
    Map<String, dynamic> updatedData = student.toJson();
    updatedData.removeWhere((key, value) => value == ""); // Remove empty fields

    final response = await http.post(
      Uri.parse(
          'http://localhost/final_career_coaching/api/student_profile/update_student_profile.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    print("API Response Status: ${response.statusCode}");
    print("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey("success")) {
        print("Profile updated successfully!");
        return true;
      } else {
        print("Error updating profile: ${data["error"]}");
        return false;
      }
    } else {
      print("Server error: ${response.statusCode}");
      return false;
    }
  }

  // Delete student profile
  static Future<bool> deleteStudentProfile(int id) async {
    final response = await http.delete(
      Uri.parse(
          'http://localhost/final_career_coaching/api/student_profile/delete_student_profile.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.containsKey("success");
    } else {
      return false;
    }
  }

  // Fetch all appointment requests
  static Future<List<Appointment>> getPendingAppointments() async {
    const String apiUrl =
        "http://localhost/final_career_coaching/api/request_appointments/read_requests.php";

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final coachId = await getCoachId(userId);
      print('Fetching appointments for coach ID: $coachId');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'coach_id': coachId}),
      );

      print('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => Appointment.fromJson(json)).toList();
        } else {
          throw Exception(responseData['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching appointments: $e');
      throw Exception('Failed to load appointments. Please try again.');
    }
  }

  static Future<int> getCoachId(String userId) async {
    const String apiUrl =
        "http://localhost/final_career_coaching/api/request_appointments/get_coach_id.php"; // Use 10.0.2.2 for Android emulator

    try {
      print('Getting coach ID for user: $userId');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'user_id': userId}),
      );

      print('Coach ID Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print('Found coach ID: ${responseData['coach_id']}');
          return responseData['coach_id'];
        } else {
          throw Exception(responseData['error'] ?? 'Failed to get coach ID');
        }
      } else {
        throw Exception("HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Error getting coach ID: $e");
      throw Exception(
          "Failed to get coach information. Please ensure you're logged in as a coach.");
    }
  }

  // Function to create a new appointment request
  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null || userId.isEmpty) {
      print("Error: user_id is NULL or EMPTY.");
      return null;
    }

    print("Retrieved user_id: $userId"); // ✅ Debugging
    return userId;
  }

  static Future<bool> createAppointment(
      Map<String, dynamic> requestData) async {
    String? userId = await getUserId();
    if (userId == null) {
      print("Error: No user logged in.");
      return false;
    }

    // Get WDT's user ID from the coach ID
    try {
      final coachResponse = await http.get(
        Uri.parse(
            "http://localhost/final_career_coaching/api/coaches/get_coach.php?id=${requestData['coach_id']}"),
      );

      if (coachResponse.statusCode == 200) {
        final coachData = jsonDecode(coachResponse.body);
        requestData['wdt_user_id'] = coachData['user_id'];
      }
    } catch (e) {
      print("Error fetching coach data: $e");
    }

    print("Sending request: ${jsonEncode(requestData)}");

    try {
      final response = await http.post(
        Uri.parse(
            "http://localhost/final_career_coaching/api/request_appointments/create_request.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.body.isEmpty) {
        print("API Error: Empty response from server.");
        return false;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data.containsKey("success")) {
        return true;
      } else {
        print("API Error: ${data['error']}");
        return false;
      }
    } catch (e) {
      print("API Error: $e");
      return false;
    }
  }

// Add to your ApiService
  static Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('user_name'); // Make sure you store this during login
  }

  static Future<List<Map<String, String>>> fetchBookedSlots() async {
    const String apiUrl =
        "http://localhost/final_career_coaching/api/request_appointments/create_request.php";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List bookedSlots = data['booked_slots'];

        return bookedSlots.map<Map<String, String>>((slot) {
          return {
            "date": slot['date_requested'] as String,
            "time": slot['time_requested'] as String,
            "status": slot['status'] as String,
            "service_type": slot['service_type'] as String,
          };
        }).toList();
      }
      throw Exception("Failed to load booked slots");
    } catch (e) {
      print("API Error: $e");
      return [];
    }
  }

  // Delete an appointment request by ID
  static Future<bool> deleteAppointment(int id) async {
    final response = await http.post(
      Uri.parse(
          "http://localhost/final_career_coaching/api/request_appointments/delete_request.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id.toString()}),
    );

    return response.statusCode == 200 &&
        jsonDecode(response.body)["success"] != null;
  }

// Coach Screen: Accept or decline an appointment
  static Future<bool> acceptAppointment(int appointmentId) async {
    try {
      // Changed localhost to your server IP/domain
      final response = await http.post(
        Uri.parse(
            'http://localhost/final_career_coaching/api/coach_accept_or_decline_appointments/accept_appointment.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': appointmentId, 'action': 'accept'}),
      );

      print("Raw API Response: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            return true;
          } else {
            throw Exception(data['error'] ?? 'Failed to accept appointment');
          }
        } on FormatException {
          throw Exception("Invalid server response: ${response.body}");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in acceptAppointment: $e");
      rethrow;
    }
  }

  Future<bool> updateAppointmentStatus(int id, String action) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/coach_accept_or_decline_appointments/update_appointment_status.php");

    final Map<String, dynamic> requestBody = {
      "id": id,
      "action": action,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("Request Body: ${jsonEncode(requestBody)}");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["success"] != null;
      } else {
        print("Error response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error updating appointment status: $e");
      return false;
    }
  }

// Decline request appointment
  static Future<bool> declineAppointment(int appointmentId) async {
    final response = await http.post(
      Uri.parse(
          'http://localhost/final_career_coaching/api/coach_accept_or_decline_appointments/coach_decline_appointment.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": appointmentId,
        "action": "decline" // ONLY CHANGE MADE - added this line
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] != null;
    } else {
      print("Error: ${response.statusCode}, ${response.body}");
      return false;
    }
  }

  // Add this method to fetch scheduled appointments
static Future<List<Appointment>> getScheduledAppointments() async {
  const String apiUrl = 
      "http://localhost/final_career_coaching/api/request_appointments/read_schedules.php";

  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception('User not logged in');
    }

    final coachId = await getCoachId(userId);
    print('Fetching scheduled appointments for coach ID: $coachId');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'coach_id': coachId}),
    );

    print('API Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) => Appointment.fromJson(json)).toList();
      } else {
        throw Exception(responseData['error'] ?? 'Unknown error');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching scheduled appointments: $e');
    throw Exception('Failed to load scheduled appointments. Please try again.');
  }
}

  static Future<Map<String, List<Session>>> fetchSessions(String userId) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/sessions/get_sessions.php?user_id=$userId");

    try {
      final response = await http.get(url);
      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey("error")) {
          print("API Error: ${responseData["error"]}");
          return {};
        }

        // Debug print all received data
        print("All Sessions Data: $responseData");

        List<Session> upcomingSessions = [];
        List<Session> pastSessions = [];
        List<Session> pendingSessions = [];
        List<Session> cancelledSessions = [];

        // Process upcoming sessions
        if (responseData.containsKey("upcoming_sessions")) {
          upcomingSessions = (responseData["upcoming_sessions"] as List)
              .map((json) => Session.fromJson(json))
              .toList();
          print("Found ${upcomingSessions.length} upcoming sessions");
        }

        // Process past sessions
        if (responseData.containsKey("past_sessions")) {
          pastSessions = (responseData["past_sessions"] as List)
              .map((json) => Session.fromJson(json))
              .toList();
          print("Found ${pastSessions.length} past sessions");
        }

        // Process pending sessions
        if (responseData.containsKey("pending_sessions")) {
          pendingSessions = (responseData["pending_sessions"] as List)
              .map((json) => Session.fromJson(json))
              .toList();
          print("Found ${pendingSessions.length} pending sessions");
        }

        // Process cancelled sessions
        if (responseData.containsKey("cancelled_sessions")) {
          cancelledSessions = (responseData["cancelled_sessions"] as List)
              .map((json) => Session.fromJson(json))
              .toList();
          print("Found ${cancelledSessions.length} cancelled sessions");
        }

        return {
          "upcoming_sessions": upcomingSessions,
          "past_sessions": pastSessions,
          "pending_sessions": pendingSessions,
          "cancelled_sessions": cancelledSessions,
        };
      } else {
        print("Failed to fetch sessions. Status code: ${response.statusCode}");
        return {};
      }
    } catch (e) {
      print("API Error: $e");
      return {};
    }
  }

  // Create a new reschedule request
  static Future<String> createRescheduleRequest(
      RescheduleRequest request) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/student_request_reschedule/create_reschedule.php");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );
      final data = jsonDecode(response.body);
      return data["success"] ?? data["error"] ?? "Unknown response";
    } catch (e) {
      return "Error: $e";
    }
  }

  // Fetch all reschedule requests
  static List<RescheduleRequest> _cachedRescheduleRequests = [];
  // Add a public getter method
  static List<RescheduleRequest> get cachedRescheduleRequests =>
      _cachedRescheduleRequests;

  static Future<List<RescheduleRequest>> fetchRescheduleRequests() async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/student_request_reschedule/read_reschedule.php");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);

        if (decodedResponse is List) {
          _cachedRescheduleRequests = decodedResponse
              .map((json) => RescheduleRequest.fromJson(json))
              .toList();
          return _cachedRescheduleRequests;
        } else {
          print("Unexpected response format: $decodedResponse");
          return [];
        }
      } else {
        print(
            "Failed to fetch reschedule requests. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("API Exception: $e");
      return [];
    }
  }

  static Future<RescheduleRequest?> getPendingRequest(int appointmentId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost/final_career_coaching/api/student_request_reschedule/read_reschedule.php?appointment_id=$appointmentId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final pendingRequests =
            data.where((request) => request['status'] == 'Pending').toList();
        if (pendingRequests.isNotEmpty) {
          return RescheduleRequest.fromJson(pendingRequests.first);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching pending request: $e');
      return null;
    }
  }

// ✅ Helper function to check if an appointment has a reschedule request
  static bool hasRequestedReschedule(int appointmentId) {
    return cachedRescheduleRequests
        .any((req) => req.appointmentId == appointmentId);
  }

//Coach create reply for reschedule request
  static Future<Map<String, dynamic>> submitCoachReply({
    required String requestId,
    required String coachId,
    required String replyMessage,
  }) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/student_request_reschedule/coach_create_reply.php");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'id': requestId,
          'coach_id': coachId,
          'coach_reply': replyMessage,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Reply submitted successfully',
          'data': data['data'] ?? {},
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to submit reply',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': "Network error: ${e.toString()}",
      };
    }
  }

  static Future<List<RescheduleRequest>> getPendingRescheduleRequests() async {
    const String apiUrl =
        "http://localhost/final_career_coaching/api/student_request_reschedule/read_reschedule.php";

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final coachId = await getCoachId(userId);
      print('Fetching reschedule requests for coach ID: $coachId');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'coach_id': coachId}),
      );

      print('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }

        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'] ?? [];
          return data.map((json) {
            try {
              return RescheduleRequest.fromJson(json);
            } catch (e) {
              print('Error parsing reschedule request: $e');
              print('Problematic JSON: $json');
              throw Exception('Failed to parse reschedule request data');
            }
          }).toList();
        } else {
          throw Exception(responseData['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reschedule requests: $e');
      throw Exception('Failed to load reschedule requests: ${e.toString()}');
    }
  }

  static Future<bool> acceptRescheduleRequest({
    required String requestId,
    required int coachId,
    required String coachReply,
  }) async {
    const String apiUrl =
        "http://localhost/final_career_coaching/api/student_request_reschedule/accepted_reschedule.php";

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': requestId,
          'coach_id': coachId,
          'coach_reply': coachReply,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error accepting reschedule request: $e');
      throw Exception('Failed to accept reschedule request: $e');
    }
  }

  static Future<bool> declineRescheduleRequest({
    required String requestId,
    required int coachId,
    required String coachReply,
  }) async {
    const String apiUrl =
        "http://localhost/final_career_coaching/api/student_request_reschedule/decline_reschedule.php";

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': requestId,
          'coach_id': coachId,
          'coach_reply': coachReply,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error declining reschedule request: $e');
      throw Exception('Failed to decline reschedule request: $e');
    }
  }

  // Get all replies by a specific coach (your existing method)
  static Future<List<dynamic>> getCoachReplies(String coachId) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/student_request_reschedule/get_coach_replies.php?coach_id=$coachId");

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['replies'] ?? [];
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch replies');
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  // Update a reschedule request
  static Future<String> updateRescheduleRequest(
      RescheduleRequest request) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/student_request_reschedule/update_reschedule.php");
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );
      final data = jsonDecode(response.body);
      return data["success"] ?? data["error"] ?? "Unknown response";
    } catch (e) {
      return "Error: $e";
    }
  }

  // Delete a reschedule request
  static Future<String> deleteRescheduleRequest(int id) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/student_request_reschedule/delete_reschedule.php");
    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id.toString()}),
      );
      final data = jsonDecode(response.body);
      return data["success"] ?? data["error"] ?? "Unknown response";
    } catch (e) {
      return "Error: $e";
    }
  }

  // ✅ Helper function to format TimeOfDay to HH:mm:ss
  static String formatTimeOfDay(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";
  }

  // ✅ Submit reschedule request
  static Future<Map<String, dynamic>> submitRescheduleRequest({
    required int appointmentId,
    required String studentName,
    required String dateRequest,
    required String timeRequest,
    required String message,
  }) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/student_request_reschedule/create_reschedule.php");

    try {
      print("Submitting reschedule request...");
      print("URL: $url");
      print("Request Method: POST");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "appointment_id": appointmentId.toString(),
          "student_name": studentName,
          "date_request": dateRequest,
          "time_request": timeRequest,
          "message": message,
        }),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "error":
              "Failed to submit request. Server returned ${response.statusCode}."
        };
      }
    } catch (e) {
      print("API Exceptionmark_as_completed.php: $e");
      return {"error": "Error: $e"};
    }
  }

  // Accepted request schedule
  static Future<List<Map<String, dynamic>>> fetchAcceptedAppointments() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost/final_career_coaching/api/coach_accept_or_decline_appointments/fetch_accepted_appointments.php'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Filter out past appointments and return upcoming ones
        DateTime now = DateTime.now();
        List<Map<String, dynamic>> upcomingAppointments = [];

        for (var appointment in data) {
          try {
            DateTime appointmentDate = DateTime.parse(appointment['date']);
            if (appointmentDate.isAfter(now)) {
              upcomingAppointments.add(Map<String, dynamic>.from(appointment));
            }
          } catch (e) {
            print("Error parsing date: $e");
          }
        }

        return upcomingAppointments;
      } else {
        print(
            "Error fetching appointments: ${response.statusCode}, ${response.body}");
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      print("Network error: $e");
      throw Exception('Network error occurred');
    }
  }

  static Future<Map<String, dynamic>?> _getStudentUserByName(
      String studentName) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost/final_career_coaching/api/students/getUserByName.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'student_name': studentName}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting student user: $e');
      return null;
    }
  }

  // // Get appointment status tracking history
  static Future<List<Map<String, dynamic>>> getAppointmentStatusHistory(
      int appointmentId) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/coach_accept_or_decline_appointments/get_status_history.php?appointment_id=$appointmentId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      return [];
    } catch (e) {
      print("Error fetching appointment status history: $e");
      return [];
    }
  }

// Create a new coach profile
  static Future<Map<String, dynamic>> createCoachProfile({
    required String userId,
    required String coachName,
    required String email,
    String? position,
    String? contact,
  }) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/coach_profile/create_coach_profile.php");

    try {
      final requestBody = {
        'user_id': userId,
        'coach_name': coachName,
        'email': email,
        if (position != null) 'position': position,
        if (contact != null) 'contact': contact,
      };

      print('Creating coach profile with data: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['success'] == true) {
          return responseBody;
        } else {
          throw Exception(
              responseBody['error'] ?? 'Failed to create coach profile');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in createCoachProfile: $e');
      rethrow;
    }
  }

  // Get all coach profiles
  static Future<List<Map<String, dynamic>>> getAllCoachProfiles() async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/coach_profile/get_coach_profile.php");

    try {
      print('Fetching all coach profiles');

      final response = await http.get(url);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['success'] == true) {
          return List<Map<String, dynamic>>.from(responseBody['data']);
        } else {
          throw Exception(
              responseBody['error'] ?? 'Failed to fetch coach profiles');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllCoachProfiles: $e');
      rethrow;
    }
  }

  // Get a single coach profile by ID
  static Future<Map<String, dynamic>> getCoachProfileById(int id) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/coach_profile/get_coach_profile.php");

    try {
      final requestBody = {
        'id': id,
      };

      print('Fetching coach profile with ID: $id');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['success'] == true) {
          return responseBody['data'];
        } else {
          throw Exception(responseBody['error'] ?? 'Coach profile not found');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getCoachProfileById: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateCoachProfile({
    required String userId,
    String? coachName,
    String? position,
    String? contact,
    String? email,
    String? address,
  }) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/coach_profile/update_coach_profile.php");

    try {
      final requestBody = {
        'userId': userId,
        if (coachName != null) 'coach_name': coachName,
        if (position != null) 'position': position,
        if (contact != null) 'contact': contact,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
      };

      print('Updating coach profile with data: $requestBody');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['success'] == true) {
          return responseBody;
        } else {
          throw Exception(
              responseBody['error'] ?? 'Failed to update coach profile');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateCoachProfile: $e');
      rethrow;
    }
  }

  // Delete a coach profile
  static Future<Map<String, dynamic>> deleteCoachProfile(int id) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/coach_profile/delete_coach_profile.php");

    try {
      final requestBody = {
        'id': id,
      };

      print('Deleting coach profile with ID: $id');

      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['success'] == true) {
          return responseBody;
        } else {
          throw Exception(
              responseBody['error'] ?? 'Failed to delete coach profile');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in deleteCoachProfile: $e');
      rethrow;
    }
  }

  // Get completed sessions by coach ID
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

  static getRequests({required String studentName, required String status}) {}
}
