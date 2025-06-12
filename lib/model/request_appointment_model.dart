class Appointment {
  final int id;
  final String studentName;
  final String dateRequested;
  final String timeRequested;
  final String profileImageUrl;
  final String serviceType;
  final int coachId;
  final String status;
  final bool? hasPendingReschedule;

  Appointment({
    required this.id,
    required this.studentName,
    required this.dateRequested,
    required this.timeRequested,
    required this.profileImageUrl,
    required this.serviceType,
    required this.coachId,
    required this.status,
    this.hasPendingReschedule,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      studentName: json['student_name'] as String,
      dateRequested: json['date_requested'] as String,
      timeRequested: json['time_requested'] as String,
      profileImageUrl: json['profile_image_url'] as String? ?? '',
      serviceType: json['service_type'] as String,
      coachId: json['coach_id'] is int
          ? json['coach_id']
          : int.parse(json['coach_id'].toString()),
      status: json['status'] as String? ?? 'Pending',
      hasPendingReschedule: json['has_pending_reschedule'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'student_name': studentName,
        'date_requested': dateRequested,
        'time_requested': timeRequested,
        'profile_image_url': profileImageUrl,
        'service_type': serviceType,
        'coach_id': coachId,
        'status': status,
        'has_pending_reschedule': hasPendingReschedule ?? false,
      };
}
