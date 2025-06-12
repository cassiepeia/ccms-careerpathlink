class AnalyticsReport {
  final String reportType;
  final String displayName;
  final String description;
  final String? csvData; // Will hold the downloaded CSV data if needed
  DateTime? generatedAt;

  AnalyticsReport({
    required this.reportType,
    required this.displayName,
    required this.description,
    this.csvData,
    this.generatedAt,
  });

  // Factory constructor for creating report type instances
  factory AnalyticsReport.fromType(String reportType) {
    switch (reportType) {
      case 'course_engagement':
        return AnalyticsReport(
          reportType: reportType,
          displayName: 'Course Engagement Report',
          description: 'Shows engagement metrics by academic course',
        );
      case 'department_engagement':
        return AnalyticsReport(
          reportType: reportType,
          displayName: 'Department Engagement Report',
          description: 'Shows engagement metrics by department',
        );
      case 'gender_engagement':
        return AnalyticsReport(
          reportType: reportType,
          displayName: 'Gender Engagement Report',
          description: 'Shows engagement metrics by gender',
        );
      case 'service_analytics':
        return AnalyticsReport(
          reportType: reportType,
          displayName: 'Service Analytics Report',
          description: 'Shows service usage and completion rates',
        );
      case 'year_level_engagement':
        return AnalyticsReport(
          reportType: reportType,
          displayName: 'Year Level Engagement Report',
          description: 'Shows engagement metrics by year level',
        );
      default:
        throw ArgumentError('Invalid report type');
    }
  }

  // Get all available report types
  static List<AnalyticsReport> get allReports => [
        AnalyticsReport.fromType('course_engagement'),
        AnalyticsReport.fromType('department_engagement'),
        AnalyticsReport.fromType('gender_engagement'),
        AnalyticsReport.fromType('service_analytics'),
        AnalyticsReport.fromType('year_level_engagement'),
      ];

  // Method to download the report (to be called from your service/API handler)
  Future<void> downloadReport() async {
    // This would call your PHP endpoint and trigger the download
    // Implementation depends on how you're handling HTTP requests
    // Example:
    // final response = await http.post(
    //   Uri.parse('your-php-file.php'),
    //   body: {'report_type': reportType},
    // );
    
    // For direct download (browser will handle it):
    // window.open('your-php-file.php?report_type=$reportType', '_blank');
    
    // Update generatedAt timestamp
    generatedAt = DateTime.now();
  }

  // If you need to parse the CSV data (optional)
  factory AnalyticsReport.fromCsv(String reportType, String csvData) {
    final report = AnalyticsReport.fromType(reportType);
    return AnalyticsReport(
      reportType: report.reportType,
      displayName: report.displayName,
      description: report.description,
      csvData: csvData,
      generatedAt: DateTime.now(),
    );
  }
}