class ServiceAnalytics {
  final String serviceType;
  final int totalAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int pendingAppointments;
  final double completionRate;

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
      serviceType: json['service_type'] ?? 'Unknown Service',
      totalAppointments: _parseInt(json['total_appointments']),
      completedAppointments: _parseInt(json['completed_appointments']),
      cancelledAppointments: _parseInt(json['cancelled_appointments']),
      pendingAppointments: _parseInt(json['pending_appointments']),
      completionRate: _parseDouble(json['completion_rate']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Handle percentage strings (e.g., "20.00%")
      final cleanValue = value.replaceAll('%', '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }
}