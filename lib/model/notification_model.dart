class NotificationModel {
  final int id;
  final int userId;
  final int senderId;
  final int appointmentId;
  final String notificationType;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final int studentId;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.senderId,
    required this.appointmentId,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    required this.studentId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      print("🟢 [Model] Parsing notification JSON: ${json['id']}");
      
      final model = NotificationModel(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        senderId: json['sender_id'] as int,
        appointmentId: json['appointment_id'] as int,
        notificationType: json['notification_type'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        isRead: json['is_read'] == 1,
        createdAt: DateTime.parse(json['created_at']),
        readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
        studentId: json['student_id'] as int,
      );

      print("🟢 [Model] Successfully parsed notification: ${model.toString()}");
      return model;
    } catch (e) {
      print("🔴 [Model] Error parsing notification:");
      print("🔴 [Model] Error: $e");
      print("🔴 [Model] Problematic JSON: $json");
      print("🔴 [Model] Stack trace: ${e is Error ? e.stackTrace : ''}");
      rethrow;
    }
  }

  @override
  String toString() {
    return 'NotificationModel{'
           'id: $id, '
           'type: $notificationType, '
           'title: "$title", '
           'isRead: $isRead, '
           'createdAt: ${createdAt.toIso8601String()}, '
           'studentId: $studentId'
           '}';
  }

  // Optional: Add toJson if needed for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'sender_id': senderId,
      'appointment_id': appointmentId,
      'notification_type': notificationType,
      'title': title,
      'message': message,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'student_id': studentId,
    };
  }
}