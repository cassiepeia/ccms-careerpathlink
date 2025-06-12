class ServiceAnalytics {
  final String serviceType;
  final int totalAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int pendingAppointments;
  final String completionRate;

  ServiceAnalytics({
    required this.serviceType,
    required this.totalAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.pendingAppointments,
    required this.completionRate,
  });

  factory ServiceAnalytics.fromJson(Map<String, dynamic> json) {
    return ServiceAnalytics(
      serviceType: json['service_type'],
      totalAppointments: json['total_appointments'],
      completedAppointments: json['completed_appointments'],
      cancelledAppointments: json['cancelled_appointments'],
      pendingAppointments: json['pending_appointments'],
      completionRate: json['completion_rate'],
    );
  }
}