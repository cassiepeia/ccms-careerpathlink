class DepartmentEngagement {
  final String department;
  final int totalStudents;
  final int activeStudents;
  final int totalAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int pendingAppointments;
  final double engagementRate;
  final double completionRate;
  final String mostActiveYear;
  final double percentageOfTotal;

  DepartmentEngagement({
    required this.department,
    required this.totalStudents,
    required this.activeStudents,
    required this.totalAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.pendingAppointments,
    required this.engagementRate,
    required this.completionRate,
    required this.mostActiveYear,
    required this.percentageOfTotal,
  });

  factory DepartmentEngagement.fromJson(Map<String, dynamic> json) {
    return DepartmentEngagement(
      department: json['department'] ?? 'Unknown',
      totalStudents: json['total_students'] ?? 0,
      activeStudents: json['active_students'] ?? 0,
      totalAppointments: json['total_appointments'] ?? 0,
      completedAppointments: json['completed_appointments'] ?? 0,
      cancelledAppointments: json['cancelled_appointments'] ?? 0,
      pendingAppointments: json['pending_appointments'] ?? 0,
      engagementRate: json['engagement_rate']?.toDouble() ?? 0.0,
      completionRate: json['completion_rate']?.toDouble() ?? 0.0,
      mostActiveYear: json['most_active_year'] ?? 'N/A',
      percentageOfTotal: json['percentage_of_total']?.toDouble() ?? 0.0,
    );
  }
}
