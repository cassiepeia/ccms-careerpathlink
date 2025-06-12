class WDTNotification {
  final int id;
  final String userId;
  final String studentName;
  final String notificationType;
  final int? appointmentId;
  final String? serviceType;
  final DateTime? dateRequested;
  final String? timeRequested;
  final String? message;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WDTNotification({
    required this.id,
    required this.userId,
    required this.studentName,
    required this.notificationType,
    this.appointmentId,
    this.serviceType,
    this.dateRequested,
    this.timeRequested,
    this.message,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory WDTNotification.fromJson(Map<String, dynamic> json) {
    return WDTNotification(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      notificationType: json['notification_type']?.toString() ?? '',
      appointmentId: json['appointment_id'] is int
          ? json['appointment_id']
          : json['appointment_id'] != null
              ? int.tryParse(json['appointment_id'].toString())
              : null,
      serviceType: json['service_type']?.toString(),
      dateRequested: json['date_requested'] != null
          ? DateTime.tryParse(json['date_requested'].toString())
          : null,
      timeRequested: json['time_requested']?.toString(),
      message: json['message']?.toString(),
      status: json['status']?.toString() ?? 'Unread',
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  String get displayType {
    switch (notificationType) {
      case 'New Appointment':
        return 'New Appointment Request';
      case 'Reschedule Request':
        return 'Reschedule Requested';
      case 'Cancellation':
        return 'Appointment Cancelled';
      case 'Appointment Accepted':
        return 'Appointment Accepted';
      case 'Appointment Declined':
        return 'Appointment Declined';
      case 'Reschedule Accepted':
        return 'Reschedule Accepted';
      case 'Reschedule Declined':
        return 'Reschedule Declined';
      default:
        return notificationType;
    }
  }

  bool get isUnread => status == 'Unread';
  bool get isRead => status == 'Read';
  bool get isDismissed => status == 'Dismissed';

  WDTNotification copyWith({
    int? id,
    String? userId,
    String? studentName,
    String? notificationType,
    int? appointmentId,
    String? serviceType,
    DateTime? dateRequested,
    String? timeRequested,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WDTNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      studentName: studentName ?? this.studentName,
      notificationType: notificationType ?? this.notificationType,
      appointmentId: appointmentId ?? this.appointmentId,
      serviceType: serviceType ?? this.serviceType,
      dateRequested: dateRequested ?? this.dateRequested,
      timeRequested: timeRequested ?? this.timeRequested,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
