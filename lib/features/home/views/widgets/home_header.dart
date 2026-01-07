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
                child: (photoUrl != null && photoUrl!.isNotEmpty)
                    ? Image.network(
                        photoUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        // Nếu link ảnh từ Firebase bị lỗi, nó sẽ tự hiện ảnh icon_app này
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              'assets/images/icon_app.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                      )
                    : Image.asset(
                        'assets/images/icon_app.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
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
