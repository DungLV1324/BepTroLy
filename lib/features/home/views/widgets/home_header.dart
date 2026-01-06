import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../thongbao/view/notification_screen.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String? photoUrl;

  const HomeHeader({super.key, required this.userName, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                context.push('/settings');
              },
              child: ClipOval(
                child: Image(
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  image: (photoUrl != null && photoUrl!.isNotEmpty)
                      ? NetworkImage(photoUrl!) as ImageProvider
                      : const AssetImage('assets/images/icon_app.png'),
                ),
              ),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
