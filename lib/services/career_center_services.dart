import 'dart:convert';
import 'package:final_career_coaching/model/career_center_profile_model.dart';
import 'package:final_career_coaching/model/coach_model.dart';
import 'package:final_career_coaching/model/course_view_model.dart';
import 'package:final_career_coaching/model/department_insight.dart';
import 'package:final_career_coaching/model/service_analytics_model.dart';
import 'package:final_career_coaching/model/student_insight_model.dart';
import 'package:final_career_coaching/model/vw_year_level_engagement_model.dart';
import 'package:http/http.dart' as http;

class EngagementService {
  // Get all year level engagement data
  static Future<List<YearLevelEngagement>> getAllYearLevelEngagement() async {
    final url = Uri.parse("http://localhost/final_career_coaching/api/year_level_distribution/vw_year_level_engagement.php");

    try {
      final response = await http.get(url);
      print('Raw API response: ${response.body}'); // Debug print
      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (responseBody['success'] == true) {
          return (responseBody['data'] as List)
              .map((json) => YearLevelEngagement.fromJson(json))
              .toList();
        } else {
          throw Exception(responseBody['message'] ?? 'Failed to load engagement data');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllYearLevelEngagement: $e');
      rethrow;
    }
  }

  // Get engagement data for a specific year level
  static Future<YearLevelEngagement> getEngagementByYearLevel(String yearLevel) async {
    final url = Uri.parse("http://localhost/final_career_coaching/api/year_level_distribution/vw_year_level_engagement.php");
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'year_level': yearLevel}),
      );

      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (responseBody['success'] == true && responseBody['data'].isNotEmpty) {
          return YearLevelEngagement.fromJson(responseBody['data'][0]);
        } else {
          throw Exception(responseBody['message'] ?? 'Engagement data not found for this year level');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getEngagementByYearLevel: $e');
      rethrow;
    }
  }

   // =============== COACH ENDPOINTS =============== //

  static Future<List<Coach>> getAllCoaches() async {
    final url = Uri.parse("http://localhost/final_career_coaching/api/service_details/coach_display_mapping.php");
    print('Fetching coaches from: $url');

    try {
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          final coaches = (responseBody['data'] as List)
              .map((json) => Coach.fromJson(json))
              .toList();
          print('Successfully fetched ${coaches.length} coaches');
          return coaches;
        } else {
          throw Exception(responseBody['message'] ?? 'Failed to load coaches');
        }
      } else {
        throw Exception('Server responded with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllCoaches: $e');
      rethrow;
    }
  }

  static Future<Coach> getCoachById(int coachId) async {
    final url = Uri.parse("http://localhost/final_career_coaching/api/service_details/coach_display_mapping.php");
    print('Fetching coach $coachId from: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'coach_id': coachId}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          final coach = Coach.fromJson(responseBody['data']);
          print('Successfully fetched coach: ${coach.coachName}');
          return coach;
        } else {
          throw Exception(responseBody['message'] ?? 'Coach not found');
        }
      } else {
        throw Exception('Server responded with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getCoachById: $e');
      rethrow;
    }
  }

  // =============== ANALYTICS ENDPOINTS =============== //

 static Future<List<ServiceAnalytics>> getServiceAnalytics() async {
  final url = Uri.parse("http://localhost/final_career_coaching/api/service_details/coach_display_mapping.php?action=get_analytics");
  
  try {
    final response = await http.get(url);
    print('Service Analytics API Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      
      if (responseBody['success'] == true) {
        // Correctly access the services array from the data object
        final Map<String, dynamic> data = responseBody['data'];
        final List<dynamic> servicesData = data['services'];
        
        // Convert to ServiceAnalytics objects
        final List<ServiceAnalytics> analytics = servicesData
            .map((item) => ServiceAnalytics.fromJson(item))
            .toList();
        
        // Ensure all service types are present
        final allServices = ['Career Coaching', 'Mock Interview', 'CV Review'];
        final Map<String, ServiceAnalytics> analyticsMap = {};
        
        // Initialize with default values
        for (var service in allServices) {
          analyticsMap[service] = ServiceAnalytics(
            serviceType: service,
            totalAppointments: 0,
            completedAppointments: 0,
            cancelledAppointments: 0,
            pendingAppointments: 0,
            completionRate: 0.0,
          );
        }
        
        // Update with actual data
        for (var analytic in analytics) {
          analyticsMap[analytic.serviceType] = analytic;
        }
        
        return analyticsMap.values.toList();
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to load analytics');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in getServiceAnalytics: $e');
    rethrow;
  }
}

// =============== STUDENT INSIGHT =============== //


  static Future<ServiceAnalytics> getAnalyticsByService(String serviceType) async {
    print('Fetching analytics for service: $serviceType');
    try {
      final analytics = await getServiceAnalytics();
      final result = analytics.firstWhere(
        (a) => a.serviceType == serviceType,
        orElse: () => throw Exception('Service "$serviceType" not found'),
      );
      print('Successfully fetched analytics for $serviceType');
      return result;
    } catch (e) {
      print('Error in getAnalyticsByService: $e');
      rethrow;
    }
  }

 static Future<List<GenderEngagement>> getGenderEngagementAnalytics() async {
  final url = Uri.parse("http://localhost/final_career_coaching/api/student_insight/vw_gender_engagement.php?action=get_gender_analytics");
  
  try {
    final response = await http.get(url);
    print('Gender Analytics API Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      
      if (responseBody['success'] == true) {
        final List<dynamic> data = responseBody['data'];
        return data.map((json) => GenderEngagement.fromJson(json)).toList();
      } else {
        throw Exception(responseBody['error'] ?? 'Failed to load gender analytics');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in getGenderEngagementAnalytics: $e');
    rethrow;
  }
}

  // =============== DEPARTMENT INSIGHT =============== //

  static Future<List<DepartmentEngagement>> getDepartmentEngagementAnalytics() async {
    final url = Uri.parse("http://localhost/final_career_coaching/api/department_insight/vw_department_engagement.php");
    
    try {
      final response = await http.get(url);
      print('Raw API response: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        
        // Debug the decoded response structure
        print('Decoded response: $responseBody');
        
        if (responseBody['success'] == true) {
          final List<dynamic> data = responseBody['data'];
          
          // Debug individual items
          for (var item in data) {
            print('Department engagement item: $item');
            
            // Additional validation for numeric fields
            if (item['engagement_rate'] == null) {
              print('Warning: engagement_rate is null for ${item['department']}');
            }
            if (item['completion_rate'] == null) {
              print('Warning: completion_rate is null for ${item['department']}');
            }
          }
          
          return data.map((json) => DepartmentEngagement.fromJson(json)).toList();
        } else {
          throw Exception(responseBody['message'] ?? 'Failed to load department analytics');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getDepartmentEngagementAnalytics: $e');
      rethrow;
    }
  }

  // Optional: Get engagement data for a specific department
  static Future<DepartmentEngagement?> getDepartmentAnalytics(String departmentName) async {
    try {
      final allDepartments = await getDepartmentEngagementAnalytics();
      return allDepartments.firstWhere(
        (dept) => dept.department.toLowerCase() == departmentName.toLowerCase(),
        orElse: () => throw Exception('Department "$departmentName" not found'),
      );
    } catch (e) {
      print('Error in getDepartmentAnalytics: $e');
      rethrow;
    }
  }

    // =============== COURSE INSIGHT =============== //

   static Future<List<CourseEngagement>> getCourseEngagement() async {
    final response = await http.get(Uri.parse('http://localhost/final_career_coaching/api/course/view_course.php'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((json) => CourseEngagement.fromJson(json))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load course engagement data');
      }
    } else {
      throw Exception('Failed to load course engagement data');
    }
  }

   // =============== PROFILE SCREEN =============== //

   // Create a new career center profile
  static Future<CareerCenterProfile> createProfile(CareerCenterProfile profile) async {
    final response = await http.post(
      Uri.parse('http://localhost/final_career_coaching/api/career_center_profile/create_career_center.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(profile.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw Exception(responseData['error']);
      }
      return profile;
    } else {
      throw Exception('Failed to create profile');
    }
  }

  // Get career center profile by user ID
  static Future<CareerCenterProfile> getProfile(String userId) async {
    final response = await http.get(
      Uri.parse('http://localhost/final_career_coaching/api/career_center_profile/get_career_center.php?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      if (responseData.isNotEmpty) {
        return CareerCenterProfile.fromJson(responseData[0]);
      } else {
        throw Exception('Profile not found');
      }
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  // Get all career center profiles
  static Future<List<CareerCenterProfile>> getAllProfiles() async {
    final response = await http.get(
      Uri.parse('http://localhost/final_career_coaching/api/career_center_profile/get_career_center.php'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((json) => CareerCenterProfile.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch profiles');
    }
  }

  // Update career center profile
  Future<void> updateProfile(CareerCenterProfile profile) async {
  try {
    // Create the JSON map manually as a fallback
    final profileJson = {
      'user_id': profile.userId,
      'name': profile.name,
      'contact': profile.contact,
      'email': profile.email,
      'position': profile.position,
    };

    final response = await http.put(
      Uri.parse('http://localhost/final_career_coaching/api/career_center_profile/update_career_center.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(profileJson), // Use the manually created map
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

  // Delete career center profile
  static Future<void> deleteProfile(String userId) async {
    final response = await http.delete(
      Uri.parse('http://localhost/final_career_coaching/api/career_center_profile/delete_career_center.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw Exception(responseData['error']);
      }
    } else {
      throw Exception('Failed to delete profile');
    }
  }

}