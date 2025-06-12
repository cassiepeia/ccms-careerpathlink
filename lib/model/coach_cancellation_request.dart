class CoachCancellationRequest {
  final int? id;
  final int? appointmentId;
  final int? coachId;
  final String? studentName;
  final String? originalDate;
  final String? originalTime;
  final String? reason;
  final String? requestDate;
  final String? studentReply;
  final String? replyDate;
  final String? status;
  final String? coachName;

  CoachCancellationRequest({
    this.id,
    this.appointmentId,
    this.coachId,
    this.studentName,
    this.originalDate,
    this.originalTime,
    this.reason,
    this.requestDate,
    this.studentReply,
    this.replyDate,
    this.status,
    this.coachName,
  });

  factory CoachCancellationRequest.fromJson(Map<String, dynamic> json) {
    return CoachCancellationRequest(
      id: json['id'] as int?,
      appointmentId: json['appointment_id'] as int?,
      coachId: json['coach_id'] as int?,
      studentName: json['student_name'] as String?,
      originalDate: json['original_date'] as String?,
      originalTime: json['original_time'] as String?,
      reason: json['reason'] as String?,
      requestDate: json['request_date'] as String?,
      studentReply: json['student_reply'] as String?,
      replyDate: json['reply_date'] as String?,
      status: json['status'] as String?,
      coachName: json['coach_name'] as String?,
    );
  }
}