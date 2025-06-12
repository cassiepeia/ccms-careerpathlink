// ignore_for_file: unused_field

import 'dart:convert';
import 'package:final_career_coaching/model/wdt_notifications_model.dart';
import 'package:http/http.dart' as http;

class NotificationApiService {
  static const String _baseUrl =
      'http://localhost/final_career_coaching/api/wdt_notifications';

  // Get notifications for user
  static Future<List<WDTNotification>> fetchForUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost/final_career_coaching/api/wdt_notifications/get_notifications.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> jsonList = responseData['notifications'];
          return jsonList
              .map((json) => WDTNotification.fromJson(json))
              .toList();
        } else {
          throw Exception(
              responseData['error'] ?? 'Failed to load notifications');
        }
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchForUser: $e');
      rethrow;
    }
  }

  // Get notifications for student
  static Future<List<WDTNotification>> fetchForStudent(
      String studentName) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost/final_career_coaching/api/wdt_notifications/get_notifications.php?student_name=$studentName'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> jsonList = responseData['notifications'];
          return jsonList
              .map((json) => WDTNotification.fromJson(json))
              .toList();
        } else {
          throw Exception(
              responseData['error'] ?? 'Failed to load notifications');
        }
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchForStudent: $e');
      rethrow;
    }
  }

  // Get unread count for user
  static Future<int> getUnreadCountForUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost/final_career_coaching/api/wdt_notifications/get_unread_count.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData['unread_count'] ?? 0;
        } else {
          throw Exception(
              responseData['error'] ?? 'Failed to get unread count');
        }
      } else {
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUnreadCountForUser: $e');
      rethrow;
    }
  }

  // Get unread count for student
  static Future<int> getUnreadCountForStudent(String studentName) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost/final_career_coaching/api/wdt_notifications/get_unread_count.php?student_name=$studentName'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData['unread_count'] ?? 0;
        } else {
          throw Exception(
              responseData['error'] ?? 'Failed to get unread count');
        }
      } else {
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUnreadCountForStudent: $e');
      rethrow;
    }
  }

  // Create notification
  static Future<WDTNotification> createNotification({
    required String userId,
    required String studentName,
    required String notificationType,
    int? appointmentId,
    String? serviceType,
    DateTime? dateRequested,
    String? timeRequested,
    String? message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost/final_career_coaching/api/wdt_notifications/create_notification.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'student_name': studentName,
          'notification_type': notificationType,
          'appointment_id': appointmentId,
          'service_type': serviceType,
          'date_requested': dateRequested?.toIso8601String(),
          'time_requested': timeRequested,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return WDTNotification.fromJson({
            'id': responseData['notification_id'],
            'user_id': userId,
            'student_name': studentName,
            'notification_type': notificationType,
            'appointment_id': appointmentId,
            'service_type': serviceType,
            'date_requested': dateRequested?.toIso8601String(),
            'time_requested': timeRequested,
            'message': message,
            'status': 'Unread',
            'created_at': DateTime.now().toIso8601String(),
          });
        } else {
          throw Exception(
              responseData['error'] ?? 'Failed to create notification');
        }
      } else {
        throw Exception(
            'Failed to create notification: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in createNotification: $e');
      rethrow;
    }
  }

  // Update notification status
  static Future<void> updateStatus(int id, String status) async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://localhost/final_career_coaching/api/wdt_notifications/update_notification_status.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'status': status,
        }),
      );

      if (response.statusCode != 200) {
        final responseData = jsonDecode(response.body);
        throw Exception(
            responseData['error'] ?? 'Failed to update notification status');
      }
    } catch (e) {
      print('Error in updateStatus: $e');
      rethrow;
    }
  }

  // Delete notification
  static Future<void> deleteNotification(int id) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'http://localhost/final_career_coaching/api/wdt_notifications/delete_notification.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode != 200) {
        final responseData = jsonDecode(response.body);
        throw Exception(
            responseData['error'] ?? 'Failed to delete notification');
      }
    } catch (e) {
      print('Error in deleteNotification: $e');
      rethrow;
    }
  }
}
