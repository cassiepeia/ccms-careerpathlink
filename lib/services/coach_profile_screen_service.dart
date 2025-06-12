import 'dart:convert';
import 'dart:nativewrappers/_internal/vm/lib/ffi_patch.dart';
import 'package:http/http.dart' as http;

class CoachProfileService {
  static const String baseUrl =
      "http://localhost/final_career_coaching/api/coach_profile";

  // Get all coach profiles
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

  // Get single coach profile by ID
  static Future<Map<String, dynamic>> getCoachProfileById(int id) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/coach_profile/get_coach_profile.php?id=$id");

    try {
      final response = await http.get(url);

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['success'] == true) {
          return Map<String, dynamic>.from(responseBody['data']);
        } else {
          throw Exception(responseBody['message'] ?? 'Coach profile not found');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getCoachProfileById: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateCoachProfile(
      Map<String, dynamic> profileData) async {
    final url = Uri.parse(
        "http://localhost/final_career_coaching/api/coach_profile/update_coach_profile.php");

    try {
      // Keep userId as string (don't convert to int)
      final updateData = {
        'userId': profileData['userId'].toString(), // Keep as string
        'coach_name': profileData['coach_name']?.toString() ?? '',
        'contact': profileData['contact']?.toString() ?? '',
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
}
