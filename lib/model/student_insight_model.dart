class GenderEngagement {
  final String gender;
  final int totalStudents;
  final int activeStudents;
  final int totalAppointments;
  final int completedAppointments;
  final double engagementRate;
  final double completionRate;
  final double percentageDistribution;

  GenderEngagement({
    required this.gender,
    required this.totalStudents,
    required this.activeStudents,
    required this.totalAppointments,
    required this.completedAppointments,
    required this.engagementRate,
    required this.completionRate,
    required this.percentageDistribution,
  });

  factory GenderEngagement.fromJson(Map<String, dynamic> json) {
    return GenderEngagement(
      gender: json['gender']?.toString() ?? 'Unknown',
      totalStudents: _parseInt(json['total_students']),
      activeStudents: _parseInt(json['active_students']),
      totalAppointments: _parseInt(json['total_appointments']),
      completedAppointments: _parseInt(json['completed_appointments']),
      engagementRate: _parsePercentage(json['engagement_rate']),
      completionRate: _parsePercentage(json['completion_rate']),
      percentageDistribution: _parseDouble(json['percentage_distribution']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parsePercentage(dynamic value) {
    if (value == null) return 0.0;
    final String strValue = value.toString().replaceAll('%', '');
    return double.tryParse(strValue) ?? 0.0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
