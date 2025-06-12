class RescheduleRequest {
  final int id;
  final int appointmentId;
  final String studentName;
  final String dateRequest;
  final String timeRequest;
  final String message;
  final String serviceType;
  final int coachId;
  final String? status;
  final String? coachReply;
  final String? replyDate;

  RescheduleRequest({
    required this.id,
    required this.appointmentId,
    required this.studentName,
    required this.dateRequest,
    required this.timeRequest,
    required this.message,
    required this.serviceType,
    required this.coachId,
    this.status,
    this.coachReply,
    this.replyDate,
  });

  factory RescheduleRequest.fromJson(Map<String, dynamic> json) {
    return RescheduleRequest(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      appointmentId: json['appointment_id'] is int
          ? json['appointment_id']
          : int.tryParse(json['appointment_id'].toString()) ?? 0,
      studentName: json['student_name']?.toString() ?? '',
      dateRequest: json['date_request']?.toString() ?? '',
      timeRequest: json['time_request']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      serviceType: json['service_type']?.toString() ?? 'Unknown',
      coachId: json['coach_id'] is int
          ? json['coach_id']
          : int.tryParse(json['coach_id'].toString()) ?? 0,
      status: json['status']?.toString(),
      coachReply: json['coach_reply']?.toString(),
      replyDate: json['reply_date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'student_name': studentName,
      'date_request': dateRequest,
      'time_request': timeRequest,
      'message': message,
      'service_type': serviceType,
      'coach_id': coachId,
      'status': status,
      'coach_reply': coachReply,
      'reply_date': replyDate,
    };
  }
}
