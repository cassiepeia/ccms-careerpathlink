class YearLevelEngagement {
  final String yearLevel;
  final int totalStudents;
  final int activeStudents;
  final int totalAppointments;
  final int completedAppointments;
  final double studentDistribution;
  final double engagementRate;

  YearLevelEngagement({
    required this.yearLevel,
    required this.totalStudents,
    required this.activeStudents,
    required this.totalAppointments,
    required this.completedAppointments,
    required this.studentDistribution,
    required this.engagementRate,
  });

  factory YearLevelEngagement.fromJson(Map<String, dynamic> json) {
    return YearLevelEngagement(
      yearLevel: json['year_level'] ?? 'Unknown',
      totalStudents: _parseInt(json['total_students']),
      activeStudents: _parseInt(json['active_students']),
      totalAppointments: _parseInt(json['total_appointments']),
      completedAppointments: _parseInt(json['completed_appointments']),
      studentDistribution: _parseDouble(json['student_distribution']),
      engagementRate: _parseDouble(json['engagement_rate']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  String toString() {
    return 'YearLevelEngagement{yearLevel: $yearLevel, totalStudents: $totalStudents, activeStudents: $activeStudents, totalAppointments: $totalAppointments, completedAppointments: $completedAppointments, studentDistribution: $studentDistribution, engagementRate: $engagementRate}';
  }
}
