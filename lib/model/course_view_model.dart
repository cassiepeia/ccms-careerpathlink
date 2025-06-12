class CourseEngagement {
  final String course;
  final int totalStudents;
  final int activeStudents;
  final int totalAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int pendingAppointments;
  final double engagementRate;
  final double completionRate;

  CourseEngagement({
    required this.course,
    required this.totalStudents,
    required this.activeStudents,
    required this.totalAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.pendingAppointments,
    required this.engagementRate,
    required this.completionRate,
  });

  factory CourseEngagement.fromJson(Map<String, dynamic> json) {
    return CourseEngagement(
      course: json['course'] ?? 'Unknown',
      totalStudents: json['total_students'] ?? 0,
      activeStudents: json['active_students'] ?? 0,
      totalAppointments: json['total_appointments'] ?? 0,
      completedAppointments: json['completed_appointments'] ?? 0,
      cancelledAppointments: json['cancelled_appointments'] ?? 0,
      pendingAppointments: json['pending_appointments'] ?? 0,
      engagementRate: (json['engagement_rate'] ?? 0).toDouble(),
      completionRate: (json['completion_rate'] ?? 0).toDouble(),
    );
  }
}
