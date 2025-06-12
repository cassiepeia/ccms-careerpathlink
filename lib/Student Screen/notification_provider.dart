// student_notification_provider.dart
import 'package:flutter/foundation.dart';
import 'package:final_career_coaching/model/student_notification_model.dart';
import 'package:final_career_coaching/services/student_notifications_service.dart';

class StudentNotificationProvider with ChangeNotifier {
  List<StudentNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<StudentNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => n.isUnread).length;

  Future<void> loadNotifications(String studentName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await NotificationService.fetchAll(studentName);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      // First update the backend
      await NotificationService.updateStatus(notificationId, 'Read');

      // Then update the local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          status: 'Read',
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      // Get all unread notification IDs
      final unreadIds =
          _notifications.where((n) => n.isUnread).map((n) => n.id).toList();

      // Update all in backend
      for (final id in unreadIds) {
        await NotificationService.updateStatus(id, 'Read');
      }

      // Update local state
      _notifications = _notifications
          .map((n) => n.isUnread
              ? n.copyWith(status: 'Read', updatedAt: DateTime.now())
              : n)
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }
}
