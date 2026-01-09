import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  Stream<List<Map<String, dynamic>>> get notificationStream => _service.getNotificationStream();

  // Đánh dấu đã đọc
  Future<void> markAsRead(String docId) async {
    await _service.markAsRead(docId);
  }

  // Xóa 1 thông báo
  Future<void> deleteNotification(String docId) async {
    await _service.deleteNotificationDoc(docId);
  }

  // Xóa tất cả
  Future<void> deleteAllNotifications() async {
    await _service.deleteAllNotifications();
  }
}