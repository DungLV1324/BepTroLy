import 'package:beptroly/features/thongbao/view/widgets/notification_item_card.dart';
import 'package:flutter/material.dart';
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

  // Xóa tất cả (khi bấm icon thùng rác)
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
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
            tooltip: "Clear all",
            onPressed: _handleDeleteAll, // Gọi hàm xử lý
          )
        ],
      ),

      // Lắng nghe Stream từ ViewModel
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notificationViewModel.notificationStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final notifications = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final String docId = notif['id'];
              final bool isRead = notif['isRead'] ?? false;

              return Dismissible(
                key: Key(docId),
                direction: DismissDirection.endToStart,

                // Nền khi vuốt
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                ),

                // Logic khi vuốt xong
                onDismissed: (direction) => _handleDeleteOne(docId),

                // Widget hiển thị (Tách ra file riêng)
                child: NotificationItemCard(
                  notif: notif,
                  onTap: () => _handleMarkAsRead(docId, isRead),
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