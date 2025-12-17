import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Màu nền xám nhạt từ thiết kế
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: Color(0xFF212121),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Đã đọc tất cả',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('HÔM NAY'),
          const SizedBox(height: 16),
          // Item 1: Cà chua (Sắp hết hạn - Cam)
          _buildNotificationItem(
            title: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Cà chua',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' của bạn sẽ hết hạn trong ',
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  TextSpan(
                    text: '2 ngày tới.',
                    style: TextStyle(
                      color: Color(0xFFFF9800),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            time: '2 giờ trước',
            iconData: Icons.timer,
            // Thay thế icon ảnh tạm thời bằng Icon có sẵn
            iconColor: const Color(0xFFFF9800),
            isUnread: true,
          ),

          const SizedBox(height: 16),
          // Item 2: Sữa tươi (Đã hết hạn - Đỏ)
          _buildNotificationItem(
            title: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Sữa tươi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  TextSpan(
                    text: ' đã hết hạn sử dụng. Hãy kiểm tra và loại bỏ.',
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                ],
              ),
            ),
            time: '1 ngày trước',
            iconData: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFEF4444),
            isUnread: true,
          ),

          const SizedBox(height: 32),
          _buildSectionHeader('TRƯỚC ĐÓ'),
          const SizedBox(height: 16),

          // Item 3: Chào mừng (Xanh)
          _buildNotificationItem(
            title: const Text(
              'Chào mừng bạn! Cảm ơn bạn đã cài đặt ứng dụng. Hãy bắt đầu lên kế hoạch nấu ăn ngay.',
              style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
            ),
            time: '3 ngày trước',
            iconData: Icons.waving_hand,
            // Icon chào
            iconColor: const Color(0xFF4CAF50),
            isUnread: true,
          ),
        ],
      ),
    );
  }

  // Widget tiêu đề section (HÔM NAY, TRƯỚC ĐÓ)
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF757575),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.60,
      ),
    );
  }

  // Widget hiển thị từng dòng thông báo (Tái sử dụng code)
  Widget _buildNotificationItem({
    required Widget title,
    required String time,
    required IconData iconData,
    required Color iconColor,
    bool isUnread = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon bên trái
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          // Nội dung text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Dấu chấm xanh (Unread indicator)
          if (isUnread)
            Container(
              margin: const EdgeInsets.only(top: 8, left: 8),
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
