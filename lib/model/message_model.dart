class Message {
  final int id;
  final String senderName;
  final String time;
  final String content;
  final int appointmentId;
  final String? coachReply; // Add this field
  final String? replyDate; // Add this field

  Message({
    required this.id,
    required this.senderName,
    required this.time,
    required this.content,
    required this.appointmentId,
    this.coachReply,
    this.replyDate,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: int.tryParse(json['id'].toString()) ?? 0,
      senderName: json['student_name']?.toString() ?? '',
      time: json['time_request']?.toString() ?? '',
      content: json['message']?.toString() ?? '',
      appointmentId: int.tryParse(json['appointment_id'].toString()) ?? 0,
      coachReply: json['coach_reply']?.toString(), // Add this
      replyDate: json['reply_date']?.toString(), // Add this
    );
  }
}