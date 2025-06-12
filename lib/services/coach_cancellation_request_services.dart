// ignore_for_file: unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:final_career_coaching/model/coach_cancellation_request.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CancellationRequestService {
  static const String _baseUrl = 'http://localhost/final_career_coaching/api';

// Create a new cancellation request
  static Future<CoachCancellationRequest> createRequest({
  required int? appointmentId,
  required int? coachId,
  required String? studentName,
  required String? originalDate,
  required String? originalTime,
  required String? reason,
}) async {
  // Add validation for required fields
  if (appointmentId == null || coachId == null || studentName == null || 
      originalDate == null || originalTime == null || reason == null) {
    throw Exception('All fields are required');
  }

  print('Sending cancellation request with data:');
print(jsonEncode({
  'appointment_id': appointmentId,
  'coach_id': coachId,
  'student_name': studentName,
  'original_date': originalDate,
  'original_time': originalTime,
  'reason': reason,
}));

  final url = Uri.parse('http://localhost/final_career_coaching/api/coach_cancellation/create_cancellation_request.php');
  
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'appointment_id': appointmentId,
      'coach_id': coachId,
      'student_name': studentName,
      'original_date': originalDate,
      'original_time': originalTime,
      'reason': reason,
    }),
  );

print('API Response: ${response.body}');
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return CoachCancellationRequest.fromJson(data);
  } else {
    throw Exception('Failed to create cancellation request: ${response.body}');
  } 
}

//Mark as Completed
static Future<void> markAsCompleted({
  required int appointmentId,
  required int coachId,
  required String studentName,
  required String originalDate,
  required String originalTime,
}) async {
  final url = Uri.parse('http://localhost/final_career_coaching/api/coach_cancellation/mark_as_completed.php');
  
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'appointment_id': appointmentId,
      'coach_id': coachId,
      'student_name': studentName,
      'original_date': originalDate,
      'original_time': originalTime,
    }),
  );

  print('API Response: ${response.body}');
  final responseData = jsonDecode(response.body);
  if (response.statusCode != 200 || responseData['success'] != true) {
    throw Exception(responseData['error'] ?? 'Failed to mark as completed');
  }
}


  // Get all cancellation requests (with optional filters)
  static Future<List<CoachCancellationRequest>> getRequests({
    int? coachId,
    String? studentName,
    String? status,
  }) async {
    final queryParams = {
      if (coachId != null) 'coach_id': coachId.toString(),
      if (studentName != null) 'student_name': studentName,
      if (status != null) 'status': status,
    };

    final url = Uri.parse('http://localhost/final_career_coaching/api/coach_cancellation/read_cancellation_requests.php')
        .replace(queryParameters: queryParams);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      
      if (data is List) {
        return data.map((json) => CoachCancellationRequest.fromJson(json)).toList();
      } else if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => CoachCancellationRequest.fromJson(json))
              .toList();
        }
      }
      throw Exception('Unexpected response format');
    } else {
      throw Exception('Failed to load cancellation requests: ${response.body}');
    }
  }

  // Add this to your ApiService class
static Future<CoachCancellationRequest?> getCancellationRequestByAppointmentId(int appointmentId) async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost/final_career_coaching/api/coach_cancellation/read_cancellation_requests.php')
          .replace(queryParameters: {'appointment_id': appointmentId.toString()}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        if (data['data'] is List && (data['data'] as List).isNotEmpty) {
          return CoachCancellationRequest.fromJson(data['data'][0]);
        } else if (data['data'] is Map) {
          return CoachCancellationRequest.fromJson(data['data']);
        }
      }
    }
    return null;
  } catch (e) {
    debugPrint('Error fetching cancellation request: $e');
    return null;
  }
}

  // Get a single cancellation request by ID
  static Future<CoachCancellationRequest> getRequestById(int id) async {
    final url = Uri.parse('http://localhost/final_career_coaching/api/coach_cancellation/read_cancellation_requests.php?id=$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CoachCancellationRequest.fromJson(data);
    } else {
      throw Exception('Failed to load cancellation request: ${response.body}');
    }
  }

  // Update a cancellation request (student reply or status)
  static Future<CoachCancellationRequest> updateRequest({
    required int id,
    String? studentReply,
    String? status,
  }) async {
    final url = Uri.parse('http://localhost/final_career_coaching/api/coach_cancellation/update_cancellation_request.php');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        if (studentReply != null) 'student_reply': studentReply,
        if (status != null) 'status': status,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CoachCancellationRequest.fromJson(data);
    } else {
      throw Exception('Failed to update cancellation request: ${response.body}');
    }
  }

  // Delete a cancellation request
  static Future<void> deleteRequest(int id) async {
    final url = Uri.parse('http://localhost/final_career_coaching/api/coach_cancellation/delete_cancellation_request.php');

    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete cancellation request: ${response.body}');
    }
  }

  // Get pending requests count for a coach
  static Future<int> getPendingRequestsCount(int coachId) async {
    final url = Uri.parse('http://localhost/final_career_coaching/api/coach_cancellation/read_cancellation_requests.php?coach_id=$coachId&status=Pending');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.length;
    } else {
      throw Exception('Failed to get pending requests count: ${response.body}');
    }
  }

   // Submit student reply to cancellation request
  static Future<CoachCancellationRequest> submitStudentReply({
    required int cancellationId,
    required String studentReply,
  }) async {
    final url = Uri.parse('http://localhost/final_career_coaching/api/coach_cancellation/student_create_reply.php');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': cancellationId,
          'student_reply': studentReply,
        }),
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          return CoachCancellationRequest.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to submit reply');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to submit reply');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}