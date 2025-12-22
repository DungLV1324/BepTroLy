import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _userId = "user_test_01";
  // Singleton pattern (để gọi ở đâu cũng được)
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Timezone
    tzdata.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    // Phòng trường hợp Saigon
    final String timeZoneName =
    timezoneInfo.identifier == 'Asia/Saigon'
        ? 'Asia/Ho_Chi_Minh'
        : timezoneInfo.identifier;

    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  //Hàm xin quyền
  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  //Hàm lên lịch thông báo
  Future<void> scheduleExpiryNotification({
    required int id,
    required String title,
    required String body,
    required DateTime expiryDate,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledTime = now.add(const Duration(seconds: 10));

    print("Đang đặt lịch thông báo vào lúc: $scheduledTime"); // Xem log để chắc chắn

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pantry_expiry_channel',
          'Pantry Expiry',
          channelDescription: 'Thông báo hết hạn thực phẩm',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showInstantNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'test_channel_id',
      'Test Channel',
      channelDescription: 'Kênh test thông báo',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // <--- Kiểm tra kỹ cái này ở Cách 2
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Test thành công!',
      'Nếu bạn thấy cái này nghĩa là cấu hình cơ bản đã OK.',
      platformChannelSpecifics,
    );
  }

  // Hủy thông báo (Khi người dùng xóa món ăn hoặc ăn xong)
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print("Đã hủy thông báo ID: $id");
  }

  CollectionReference get _notificationRef {
    return _db.collection('users').doc(_userId).collection('notifications');
  }

  // 1. Hàm lưu lịch sử thông báo
  Future<void> addNotificationLog({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await _notificationRef.add({
      'notificationId': notificationId,
      'title': title,
      'body': body,
      'scheduledTime': Timestamp.fromDate(scheduledTime), // Thời điểm sẽ thông báo
      'createdAt': FieldValue.serverTimestamp(),          // Thời điểm tạo
      'isRead': false,                                    // Trạng thái đã đọc chưa
      'type': 'expiry_alert',                             // Loại thông báo (để sau này lọc)
    });
  }

  // 2. Hàm lấy danh sách thông báo (Stream)
  Stream<List<Map<String, dynamic>>> getNotificationStream() {
    // Sắp xếp: Cái mới nhất (hoặc sắp diễn ra) lên đầu
    return _notificationRef
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Lưu lại ID để xử lý đọc/xóa
        return data;
      }).toList();
    });
  }

  // 3. Hàm đánh dấu đã đọc
  Future<void> markAsRead(String notificationId) async {
    await _notificationRef.doc(notificationId).update({'isRead': true});
  }

  Future<void> deleteNotificationLog(int notificationId) async {
    // Tìm các thông báo có notificationId trùng khớp
    final querySnapshot = await _notificationRef
        .where('notificationId', isEqualTo: notificationId)
        .get();

    // Xóa tất cả các document tìm được (thường chỉ có 1 cái)
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}