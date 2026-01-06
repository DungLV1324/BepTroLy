import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../shared/widgets/app_toast.dart';
import '../viewmodel/notification_view_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationViewModel _notificationViewModel = NotificationViewModel();

  // Xóa 1 cái (khi vuốt)
  void _handleDeleteOne(String docId) {
    _notificationViewModel.deleteNotification(docId);
    if (mounted) AppToast.show(context, ActionType.delete, "expiration notification.");
  }

  // Đọc 1 cái (khi bấm vào)
  void _handleMarkAsRead(String docId, bool isRead) {
    if (!isRead) {
      _notificationViewModel.markAsRead(docId);
    }
  }

  // Xóa tất cả
  void _handleDeleteAll() async {
    // Dùng DialogHelper chung
    final bool? confirm = await DialogHelper.showConfirmDialog(
      context: context,
      title: "Clear all?",
      content: "Are you sure you want to clear all notifications?",
      confirmText: "Clear",
      confirmColor: Colors.red,
    );

    if (confirm == true) {
      await _notificationViewModel.deleteAllNotifications();
      if (mounted) AppToast.show(context, ActionType.delete, "All notifications");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Expiration notification", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _notificationViewModel.notificationStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
                  tooltip: "Clear all",
                  onPressed: _handleDeleteAll,
                );
              }
              return const SizedBox.shrink(); // Ẩn nếu rỗng
            },
          )
        ],
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notificationViewModel.notificationStream,
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Empty State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final notifications = snapshot.data!;

          // 3. List Data
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final String docId = notif['id'];
              final bool isRead = notif['isRead'] ?? false;

              final Timestamp? timestamp = notif['scheduledTime'];
              final DateTime scheduledTime = timestamp != null
                  ? timestamp.toDate()
                  : DateTime.now();

              final bool isFuture = scheduledTime.isAfter(DateTime.now());

              // Format text
              final String timeString = DateFormat('HH:mm').format(scheduledTime);
              final String dateString = DateFormat('dd/MM').format(scheduledTime);
              final String itemName = notif['title'] ?? "Dish";

              String displayText;
              if (isFuture) {
                displayText = "I will remind you later $timeString - $itemName expiring soon";
              } else {
                displayText = "I mentioned it at the time. $timeString ($dateString) - $itemName";
              }

              // Màu sắc & Style
              final Color bgColor = isFuture ? Colors.grey.shade50 : Colors.white;
              final Color iconColor = isFuture ? Colors.orange : Colors.green;
              final IconData iconData = isFuture ? Icons.access_time_filled : Icons.check_circle;
              final FontWeight textWeight = isFuture ? FontWeight.normal : FontWeight.w500;

              return Dismissible(
                key: Key(docId),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                ),
                onDismissed: (direction) => _handleDeleteOne(docId),

                child: Card(
                  elevation: isFuture ? 0 : 2,
                  color: bgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isFuture ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
                  ),
                  child: InkWell(
                    onTap: () => _handleMarkAsRead(docId, isRead),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Icon(iconData, color: iconColor, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayText,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: isRead ? FontWeight.normal : textWeight,
                                  ),
                                ),
                                if (!isRead && !isFuture) ...[
                                  const SizedBox(height: 4),
                                  const Text(
                                    "New",
                                    style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                                  )
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text("No notifications yet", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}