// lib/core/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    await _fcm.requestPermission();

    final token = await _fcm.getToken();
    debugPrint('FCM Token: $token');
  }

  Future<void> sendBillReminder(
    String billName,
    DateTime dueDate,
    int daysBefore,
  ) async {
    final reminderDate = dueDate.subtract(Duration(days: daysBefore));
    final now = DateTime.now();

    if (reminderDate.isAfter(now)) {
      final scheduledDate = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        8,
      );

      await _localNotifications.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        'Tagihan Mendekat',
        'Tagihan $billName akan jatuh tempo dalam $daysBefore hari',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'bill_reminder',
            'Reminder Tagihan',
            channelDescription: 'Reminder tagihan yang akan jatuh tempo',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> showBudgetWarning(String category, double percentage) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      '⚠️ Peringatan Budget',
      'Budget $category telah mencapai ${percentage.toStringAsFixed(0)}%',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_warning',
          'Peringatan Budget',
          channelDescription: 'Peringatan saat budget hampir habis',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
