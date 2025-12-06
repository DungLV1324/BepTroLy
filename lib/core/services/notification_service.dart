import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  // Singleton Pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Khởi tạo Service (Gọi ở main.dart)
  Future<void> init() async {
    tz.initializeTimeZones(); // Khởi tạo timezone

    // Cấu hình Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Cấu hình iOS
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // FR3.2: Xử lý khi người dùng bấm vào thông báo
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          // Payload chính là tên nguyên liệu (vd: "Sữa tươi")
          // Logic điều hướng sẽ được xử lý ở Router hoặc Main
          notificationStream.add(response.payload!);
        }
      },
    );
  }

  // Stream để lắng nghe sự kiện bấm thông báo từ UI
  final notificationStream = StreamController<String>.broadcast();

  // Xin quyền (Bắt buộc cho Android 13+)
  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // FR3.1: Lên lịch thông báo
  // triggerDate: Thời gian muốn thông báo hiện lên (ví dụ: 8:00 AM ngày sắp hết hạn)
  Future<void> scheduleExpiryNotification({
    required int id,
    required String title,
    required String body,
    required DateTime triggerDate,
    required String payload, // Truyền tên nguyên liệu vào đây để xử lý FR3.2
  }) async {
    // Nếu ngày trigger đã qua thì không schedule
    if (triggerDate.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(triggerDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_channel_id',
          'Expiry Alerts',
          channelDescription: 'Thông báo hết hạn thực phẩm',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation:
      // UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload, // Dữ liệu đính kèm để Deep Link
    );
  }

  // Hủy thông báo (Khi người dùng xóa món hoặc đã dùng xong)
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}