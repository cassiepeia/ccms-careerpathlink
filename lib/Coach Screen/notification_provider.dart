import 'package:final_career_coaching/model/wdt_notifications_model.dart';
import 'package:final_career_coaching/services/wdt_notifications_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NotificationProvider with ChangeNotifier {
  List<WDTNotification> _notifications = [];
  int _unreadCount = 0;

  List<WDTNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  Future<void> loadNotifications(String userId) async {
    try {
      print('🔵 Loading notifications for user: $userId');

      // 1. First check if we're getting any response
      final response = await http.get(
        Uri.parse(
            'http://localhost/final_career_coaching/api/wdt_notifications/get_notifications.php?user_id=$userId'),
      );
      print('Raw API response: ${response.body}');

      // 2. Then parse the response
      _notifications = await NotificationApiService.fetchForUser(userId);

      print('Parsed notifications:');
      for (var n in _notifications) {
        print('ID: ${n.id} | Type: ${n.notificationType} | '
              'Message: ${n.message?.substring(0, 20)}... | '
              'Status: ${n.status}');
      }

      _unreadCount = _notifications.where((n) => n.status == 'Unread').length;
      print('Unread count: $_unreadCount');

      notifyListeners();
    } catch (e) {
      print('ERROR: $e');
      _notifications = [];
      _unreadCount = 0;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await NotificationApiService.updateStatus(notificationId, 'Read');
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(status: 'Read');
        _unreadCount = _notifications.where((n) => n.status == 'Unread').length;
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final unreadIds = _notifications
          .where((n) => n.status == 'Unread')
          .map((n) => n.id)
          .toList();

      for (final id in unreadIds) {
        await NotificationApiService.updateStatus(id, 'Read');
      }

      _notifications = _notifications
          .map((n) => n.status == 'Unread' ? n.copyWith(status: 'Read') : n)
          .toList();

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }
}
