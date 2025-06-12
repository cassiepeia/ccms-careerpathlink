class PastSession {
  final String studentName;
  final String date;
  final String time;
  final String notes;

  PastSession({
    required this.studentName,
    required this.date,
    required this.time,
    required this.notes,
  });

  factory PastSession.fromJson(Map<String, dynamic> json) {
    return PastSession(
      studentName: json['student_name']?.toString() ?? 'Student',
      date: json['session_date']?.toString() ?? '',
      time: json['session_time']?.toString() ?? '',
      notes: json['session_notes']?.toString() ?? '',
    );
  }
}