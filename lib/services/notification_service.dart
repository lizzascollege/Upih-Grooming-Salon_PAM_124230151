import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;

  Future<void> initNotifications() async {
    if (_isInitialized) {
      debugPrint('Notification service already initialized');
      return;
    }

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();

    _isInitialized = true;
    debugPrint('✅ Notification service initialized successfully');
  }

  Future<bool> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidPlugin?.requestNotificationsPermission();
      debugPrint('Android notification permission: ${granted ?? false}');
      return granted ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final bool? granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      debugPrint('iOS notification permission: ${granted ?? false}');
      return granted ?? false;
    }
    return false;
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📲 Notification tapped with payload: ${response.payload}');
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'booking_reminder_channel',
      'Booking Reminders',
      channelDescription: 'Notifications for upcoming grooming appointments',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE17055),
      playSound: true,
      enableVibration: true,
      ticker: 'Grooming Reminder',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
      debugPrint('✅ Instant notification sent: $title');
    } catch (e) {
      debugPrint('❌ Error showing instant notification: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint('⚠️ Scheduled time is in the past, notification not scheduled (ID: $id)');
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'booking_reminder_channel',
      'Booking Reminders',
      channelDescription: 'Notifications for upcoming grooming appointments',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE17055),
      playSound: true,
      enableVibration: true,
      ticker: 'Grooming Reminder',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('✅ Notification scheduled (ID: $id) for ${_formatDateTime(scheduledTime)}');
    } catch (e) {
      debugPrint('❌ Error scheduling notification (ID: $id): $e');
    }
  }

  Future<void> scheduleBookingReminders({
    required int bookingId,
    required String petName,
    required String salonName,
    required DateTime bookingTime,
  }) async {
    final reminder24h = bookingTime.subtract(const Duration(hours: 24));
    if (reminder24h.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: bookingId * 10 + 1,
        title: '🐾 Grooming Tomorrow!',
        body: 'Don\'t forget: $petName has grooming at $salonName tomorrow at ${_formatTime(bookingTime)}',
        scheduledTime: reminder24h,
        payload: 'booking_$bookingId',
      );
    }

    final reminder2h = bookingTime.subtract(const Duration(hours: 2));
    if (reminder2h.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: bookingId * 10 + 2,
        title: '⏰ Grooming in 2 Hours',
        body: '$petName grooming appointment at $salonName is coming up soon!',
        scheduledTime: reminder2h,
        payload: 'booking_$bookingId',
      );
    }

    final reminder30m = bookingTime.subtract(const Duration(minutes: 30));
    if (reminder30m.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: bookingId * 10 + 3,
        title: '🚗 Time to Go!',
        body: 'Your grooming appointment is in 30 minutes at $salonName. Time to head out!',
        scheduledTime: reminder30m,
        payload: 'booking_$bookingId',
      );
    }

    debugPrint('📅 All booking reminders scheduled for booking ID: $bookingId');
  }

  Future<void> showBookingConfirmation({
    required String petName,
    required String salonName,
    required DateTime bookingTime,
  }) async {
    await showInstantNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '✅ Booking Confirmed!',
      body: '$petName grooming at $salonName on ${_formatDate(bookingTime)}',
      payload: 'booking_confirmed',
    );
  }

  Future<void> showBookingCancellation({
    required String petName,
    required String salonName,
  }) async {
    await showInstantNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '❌ Booking Cancelled',
      body: '$petName grooming at $salonName has been cancelled',
      payload: 'booking_cancelled',
    );
  }

  Future<void> showPaymentSuccess({
    required String petName,
    required String amount,
  }) async {
    await showInstantNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '💳 Payment Successful',
      body: 'Payment of $amount for $petName grooming has been processed',
      payload: 'payment_success',
    );
  }

  Future<void> cancelNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
      debugPrint('🗑️ Notification cancelled (ID: $id)');
    } catch (e) {
      debugPrint('❌ Error cancelling notification (ID: $id): $e');
    }
  }

  Future<void> cancelBookingReminders(int bookingId) async {
    await cancelNotification(bookingId * 10 + 1);
    await cancelNotification(bookingId * 10 + 2);
    await cancelNotification(bookingId * 10 + 3);
    debugPrint('🗑️ All reminders cancelled for booking ID: $bookingId');
  }

  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('🗑️ All notifications cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling all notifications: $e');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    final pending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    debugPrint('📋 Pending notifications: ${pending.length}');
    for (var notif in pending) {
      debugPrint('  - ID: ${notif.id}, Title: ${notif.title}');
    }
    return pending;
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, ${_formatTime(dateTime)}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
  }
}