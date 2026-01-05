import 'package:flutter/material.dart';

import '../../../thongbao/view/notification_screen.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String? photoUrl;

  const HomeHeader({
    super.key,
    required this.userName,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              // Nếu có ảnh mạng thì hiện, không thì hiện icon mặc định
              backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
                  ? NetworkImage(photoUrl!)
                  : null,
              child: (photoUrl == null || photoUrl!.isEmpty)
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello,',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                // 3. Hiển thị Tên thật
                Text(
                  '$userName!',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Cắt bớt nếu tên quá dài
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 28),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          },
        ),
      ],
    );
  }
}