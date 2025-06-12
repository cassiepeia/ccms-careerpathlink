// ignore_for_file: unused_field

import 'dart:convert';
import 'package:final_career_coaching/model/analytics_reports_model.dart';
import 'package:http/http.dart' as http;

class AnalyticsReportService {
  static const String _baseUrl = 'http://localhost/final_career_coaching/api/analytics';

  // Get all available report types (from local model)
  static List<AnalyticsReport> getAllReportTypes() {
    return AnalyticsReport.allReports;
  }

  // Download a report and get it as CSV data
  static Future<AnalyticsReport> downloadReport(String reportType) async {
    final response = await http.post(
      Uri.parse('http://localhost/final_career_coaching/api/analytics/report.php'),
      body: {'report_type': reportType},
    );

    if (response.statusCode == 200) {
      // Check if the response is CSV
      if (response.headers['content-type']?.contains('text/csv') ?? false) {
        return AnalyticsReport.fromCsv(reportType, response.body);
      } else {
        // Handle case where the response isn't CSV
        try {
          final data = json.decode(response.body);
          if (data['error'] != null) {
            throw Exception(data['error']);
          }
        } catch (e) {
          // Not JSON either
        }
        throw Exception('Unexpected response format from server');
      }
    } else {
      throw Exception('Failed to download report. Status code: ${response.statusCode}');
    }
  }

  // Alternative method to get report data as JSON (if you modify your PHP)
  static Future<List<Map<String, dynamic>>> getReportData(String reportType) async {
    final response = await http.post(
      Uri.parse('http://localhost/final_career_coaching/api/analytics/report.php'),
      body: {'report_type': reportType, 'format': 'json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      } else if (data['data'] is List) {
        return (data['data'] as List).cast<Map<String, dynamic>>();
      } else if (data['error'] != null) {
        throw Exception(data['error']);
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load report data. Status code: ${response.statusCode}');
    }
  }

  // Method to get report metadata (if you want to get display info from server)
  static Future<AnalyticsReport> getReportInfo(String reportType) async {
    final response = await http.get(
      Uri.parse('http://localhost/final_career_coaching/api/analytics/report_info.php?report_type=$reportType'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return AnalyticsReport(
          reportType: data['data']['report_type'],
          displayName: data['data']['display_name'],
          description: data['data']['description'],
        );
      } else {
        throw Exception(data['message'] ?? 'Failed to load report info');
      }
    } else {
      throw Exception('Failed to load report info');
    }
  }

   static Future<String> downloadAllReports() async {
    // Simulate downloading all reports and returning the file path
    await Future.delayed(Duration(seconds: 2)); // Simulate delay
    return '/path/to/all_reports.zip'; // Replace with actual implementation
  }
}