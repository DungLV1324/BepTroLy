import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationService dbService = NotificationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông báo"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: dbService.getNotificationStream(),
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
              final bool isRead = notif['isRead'] ?? false;

              // Xử lý ngày tháng từ Timestamp của Firestore
              final Timestamp timestamp = notif['scheduledTime'];
              final DateTime date = timestamp.toDate();
              final String timeStr = DateFormat('dd/MM/yyyy HH:mm').format(date);

              return Card(
                elevation: isRead ? 0 : 2, // Chưa đọc thì nổi lên
                color: isRead ? Colors.grey[100] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isRead ? BorderSide.none : const BorderSide(color: Colors.green, width: 1),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isRead ? Colors.grey : Colors.orangeAccent,
                    child: const Icon(Icons.notifications, color: Colors.white),
                  ),
                  title: Text(
                    notif['title'],
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notif['body']),
                      const SizedBox(height: 4),
                      Text(
                        timeStr,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Bấm vào thì đánh dấu đã đọc
                    dbService.markAsRead(notif['id']);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}