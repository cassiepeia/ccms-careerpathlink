class Appointment {
  final int id;
  final String studentName;
  final String dateRequested;
  final String? timeRequested;
  final String profileImageUrl;
  final int coachId;
  final int studentId;
  final String serviceType;

  Appointment({
    required this.id,
    required this.studentName,
    required this.dateRequested,
    this.timeRequested,
    required this.profileImageUrl,
    required this.coachId,
    required this.studentId,
    required this.serviceType,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      studentName: json['student_name'],
      dateRequested: json['date_requested'],
      timeRequested: json['time_requested'],
      profileImageUrl: json['profile_image_url'],
      coachId: json['coach_id'],
      studentId: json['student_id'],
      serviceType: json['service_type'] ?? 'Unknown Service',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id.toString(),
      "student_name": studentName,
      "date_requested": dateRequested,
      "time_requested": timeRequested,
      "profile_image_url": profileImageUrl,
      "service_type": serviceType,
      "coach_id": coachId.toString(),
    };
  }
}
