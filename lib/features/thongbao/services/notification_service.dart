import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> init() async {
    if (_isInitialized) return;

    //Cấu hình Timezone
    tzdata.initializeTimeZones();
    if (!kIsWeb) {
      try {
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();

        final String timeZoneName =
        timezoneInfo.identifier == 'Asia/Saigon'
            ? 'Asia/Ho_Chi_Minh'
            : timezoneInfo.identifier;

        tz.setLocalLocation(tz.getLocation(timeZoneName));
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
      }
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

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _isInitialized = true;
  }

  //Hàm xin quyền
  Future<void> requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleExpiryNotification({
    required int id,
    required String title,
    required String body,
    required DateTime expiryDate,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledTime = tz.TZDateTime.from(expiryDate, tz.local);

    scheduledTime = tz.TZDateTime(
      tz.local,
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      6, 0, 0,
    );

    if (scheduledTime.isBefore(now)) {

      // Kiểm tra có phải hôm nay không
      if (scheduledTime.year == now.year &&
          scheduledTime.month == now.month &&
          scheduledTime.day == now.day) {

        print("⚠️ Là hôm nay! Set lại lịch +20 giây.");
        scheduledTime = now.add(const Duration(seconds: 20));

      } else {
        return;
      }
    } else {
      print("✅ Logic: Scheduled > Now -> Chưa đến 8h sáng, đặt lịch bình thường.");
    }

    print("🚀 CHỐT LỊCH ID $id: $scheduledTime");

    await _flutterLocalNotificationsPlugin.zonedSchedule(
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
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Hủy thông báo (Khi người dùng xóa món ăn hoặc ăn xong)
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  CollectionReference get _notificationRef {
    final user = _auth.currentUser;
    // 3. Kiểm tra đăng nhập
    if (user == null) {
      throw Exception("Người dùng chưa đăng nhập! Không thể truy cập thông báo.");
    }
    // Lấy ID động từ Firebase Auth
    return _db.collection('users').doc(user.uid).collection('notifications');
  }

  // 2. Hàm lấy danh sách thông báo (Stream)
  Stream<List<Map<String, dynamic>>> getNotificationStream() {
    if (_auth.currentUser == null) {
      return Stream.value([]);
    }

    return _notificationRef
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // 1. Hàm lưu lịch sử thông báo
  Future<void> addNotificationLog({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (_auth.currentUser == null) return;
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

  // 3. Hàm đánh dấu đã đọc
  Future<void> markAsRead(String notificationId) async {
    await _notificationRef.doc(notificationId).update({'isRead': true});
  }

  Future<void> deleteNotificationLog(int notificationId) async {
    // Tìm các thông báo có notificationId trùng khớp
    final querySnapshot = await _notificationRef
        .where('notificationId', isEqualTo: notificationId)
        .get();

    // Xóa tất cả các document tìm được
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> deleteNotificationDoc(String docId) async {
    await _notificationRef.doc(docId).delete();
  }

  // Hàm xóa TẤT CẢ thông báo
  Future<void> deleteAllNotifications() async {
    var snapshots = await _notificationRef.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }
}