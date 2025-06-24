import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> initialize(BuildContext context) async {
    // Inisialisasi timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Android initialization
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notifikasi diklik: ${response.payload}");
      },
    );

    // Minta permission untuk Android 13+
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          await Permission.notification.request();
        }
      }
    }
  }

  /// Notifikasi berdasarkan hari & jam (sudah ada)
  Future<void> scheduleNotification(
      String id, DateTime scheduledDateTime) async {
    final tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(
      scheduledDateTime,
      tz.local,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id.hashCode,
      'Pengingat Imunisasi',
      'Halo Bunda, waktunya melakukan imunisasi!',
      scheduledTZDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'jadwal_channel_id',
          'Jadwal Imunisasi',
          channelDescription: 'Notifikasi untuk pengingat imunisasi',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  /// Notifikasi hanya berdasarkan tanggal (jam 08:00 default)
  Future<void> scheduleDailyReminderByDate({
    required String id,
    required DateTime date,
  }) async {
    // Atur waktu notifikasi: jam 08:00 pagi di hari yang ditentukan
    final scheduledDate = tz.TZDateTime.from(
      DateTime(date.year, date.month, date.day, 6, 0),
      tz.local,
    );

    // Jadwalkan notifikasi sekali saja
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id.hashCode + 10000, // Tambahkan offset agar tidak bentrok dengan ID lain
      'Pengingat Hari Imunisasi',
      'Hari ini ada jadwal imunisasi. Jangan lupa ya!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hari_channel_id',
          'Pengingat Hari Imunisasi',
          channelDescription:
              'Notifikasi yang muncul di pagi hari saat jadwal imunisasi tiba',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null, // Supaya hanya sekali di tanggal & jam itu
    );
  }
}
