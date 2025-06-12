class StudentNotification {
  final int id;
  final String userId;
  final String notificationType;
  final int? appointmentId;
  final String? serviceType;
  final DateTime? dateRequested;
  final String? timeRequested;
  final String? message;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  StudentNotification({
    required this.id,
    required this.userId,
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

  factory StudentNotification.fromJson(Map<String, dynamic> json) {
    return StudentNotification(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id']?.toString() ?? '',
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'notification_type': notificationType,
      'appointment_id': appointmentId,
      'service_type': serviceType,
      'date_requested': dateRequested?.toIso8601String(),
      'time_requested': timeRequested,
      'message': message,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get displayType {
    switch (notificationType) {
      case 'Accepted Appointment':
        return 'Appointment Accepted';
      case 'Declined Appointment':
        return 'Appointment Declined';
      case 'Accepted Reschedule Request':
        return 'Reschedule Accepted';
      case 'Declined Reschedule Request':
        return 'Reschedule Declined';
      case 'Completed Appointment':
        return 'Appointment Completed';
      case 'Cancelled Appointment':
        return 'Appointment Cancelled';
      case 'Reschedule Requested':
        return 'Reschedule Request';
      case 'Cancellation Requested':
        return 'Cancellation Request';
      default:
        return notificationType;
    }
  }

  bool get isUnread => status == 'Unread';
  bool get isRead => status == 'Read';
  bool get isDismissed => status == 'Dismissed';

  StudentNotification copyWith({
    int? id,
    String? userId,
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
    return StudentNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
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
