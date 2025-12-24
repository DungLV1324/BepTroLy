import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/app_toast.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationService notificationService = NotificationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông báo"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
            tooltip: "Xóa tất cả",
            onPressed: () => _confirmDeleteAll(context, notificationService),
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: notificationService.getNotificationStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Chưa có thông báo nào"),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final String docId = notif['id'];

              return Dismissible(
                key: Key(docId), // Key duy nhất để xác định item
                direction: DismissDirection.endToStart, // Vuốt từ Phải sang Trái

                // Nền đỏ hiện ra khi vuốt
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                ),

                // Xử lý khi vuốt xong
                onDismissed: (direction) {
                  // Gọi service xóa trên Firebase
                  notificationService.deleteNotificationDoc(docId);

                  AppToast.show(context,ActionType.delete,"Thông báo");
                },
                child: _buildNotificationItem(notif, notificationService),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notif, NotificationService notificationService) {
    final bool isRead = notif['isRead'] ?? false;
    final Timestamp timestamp = notif['scheduledTime'];
    final DateTime date = timestamp.toDate();
    final String timeStr = DateFormat('dd/MM HH:mm').format(date);

    return Card(
      elevation: isRead ? 0 : 3,
      margin: EdgeInsets.zero, // Margin đã xử lý ở ListView
      color: isRead ? Colors.white : const Color(0xFFF0FDF4), // Chưa đọc thì nền xanh nhạt
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRead ? BorderSide.none : const BorderSide(color: Color(0xFF4CAF50), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isRead ? Colors.grey[200] : const Color(0xFFE8F5E9),
          child: Icon(
              Icons.notifications_active,
              color: isRead ? Colors.grey : const Color(0xFF2E7D32)
          ),
        ),
        title: Text(
          notif['title'],
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 15,
            color: const Color(0xFF1A1D26),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notif['body'],
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              timeStr,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        onTap: () {
          // Đánh dấu đã đọc
          if (!isRead) {
            notificationService.markAsRead(notif['id']);
          }
        },
      ),
    );
  }

  // Hàm hiển thị hộp thoại xác nhận xóa tất cả
  void _confirmDeleteAll(BuildContext context, NotificationService notificationService) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Xóa tất cả?"),
          content: const Text("Bạn có chắc muốn xóa sạch hộp thư thông báo không?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
            TextButton(
                onPressed: () {
                  notificationService.deleteAllNotifications();
                  Navigator.pop(ctx);
                },
                child: const Text("Xóa", style: TextStyle(color: Colors.red))
            ),
          ],
        )
    );
  }
}