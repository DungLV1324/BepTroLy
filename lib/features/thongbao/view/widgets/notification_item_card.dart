import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationItemCard extends StatelessWidget {
  final Map<String, dynamic> notif;
  final VoidCallback onTap;

  const NotificationItemCard({
    super.key,
    required this.notif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isRead = notif['isRead'] ?? false;
    final Timestamp timestamp = notif['scheduledTime'];
    final DateTime date = timestamp.toDate();
    final String timeStr = DateFormat('dd/MM HH:mm').format(date);

    Color cardColor;
    if (isDark) {
      cardColor = isRead ? const Color(0xFF1E1E1E) : const Color(0xFF1B3320);
    } else {
      cardColor = isRead ? Colors.white : const Color(0xFFF0FDF4);
    }

    return Card(
      elevation: isRead ? 0 : 3,
      margin: EdgeInsets.zero,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRead
            ? BorderSide.none
            : BorderSide(
                color: isDark
                    ? const Color(0xFF4CAF50).withOpacity(0.5)
                    : const Color(0xFF4CAF50),
                width: 1,
              ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isRead
              ? (isDark ? Colors.grey[800] : Colors.grey[200])
              : (isDark ? const Color(0xFF2A4D31) : const Color(0xFFE8F5E9)),
          child: Icon(
            Icons.notifications_active,
            color: isRead
                ? Colors.grey
                : (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32)),
          ),
        ),
        title: Text(
          notif['title'],
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 15,
            color: isDark ? Colors.white : const Color(0xFF1A1D26),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notif['body'],
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[700],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
