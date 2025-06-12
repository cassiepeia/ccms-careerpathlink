// ignore_for_file: unused_field

import 'dart:convert';
import 'package:final_career_coaching/model/time_slot.dart';
import 'package:http/http.dart' as http;

class TimeSlotApiService {
  static const String _baseUrl = "http://localhost/final_career_coaching/api/time_slot";

  // Get all time slots (optional)
  static Future<List<TimeSlot>> getAllTimeSlots() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost/final_career_coaching/api/time_slot/read_time_slot.php"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => TimeSlot.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load time slots');
        }
      } else {
        throw Exception('Failed to load time slots: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching time slots: $e');
    }
  }

  // Get time slots by coach ID - returns Map<date, List<TimeSlot>>
  static Future<Map<String, List<TimeSlot>>> getTimeSlotsByCoach(int coachId) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost/final_career_coaching/api/time_slot/read_time_slot.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'coach_id': coachId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Map<String, List<TimeSlot>> slotsByDate = {};

        if (data['success'] == true && data['data'] is List) {
          for (var json in data['data']) {
            TimeSlot slot = TimeSlot.fromJson(json);
            slotsByDate.putIfAbsent(slot.dateSlot, () => []).add(slot);
          }
        }

        return slotsByDate;
      } else {
        throw Exception('Failed to load time slots: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching time slots: $e');
    }
  }

  // Create a new time slot
  static Future<bool> createTimeSlot({
    required int coachId,
    required String dateSlot,
    required String day,
    required String startTime,
    required String endTime,
    String status = 'available',
    bool clickable = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost/final_career_coaching/api/time_slot/create_time_slot.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'coach_id': coachId,
          'date_slot': dateSlot,
          'day': day,
          'start_time': startTime,
          'end_time': endTime,
          'status': status,
          'clickable': clickable,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Failed to create time slot: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating time slot: $e');
    }
  }
}