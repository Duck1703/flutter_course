import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract interface class LocalNotificationService {
  Future<void> initialize();

  Future<bool> hasPermission();

  Future<bool> requestPermission();

  Future<void> scheduleDaily({required int hour, required int minute});

  Future<void> cancelDaily();
}

class LocalNotificationServiceImpl implements LocalNotificationService {
  static const _dailyNotificationId = 1001;
  static const _channelId = 'daily_quiz_notification';
  static const _channelName = 'Daily Quiz Challenge';
  static const _channelDescription = 'Daily quiz reminders';
  static const _notificationTitle = 'Daily Challenge Ready!';
  static const _notificationBody =
      'Your daily quiz is waiting. Can you top the leaderboard today?';

  final FlutterLocalNotificationsPlugin _plugin;
  var _isInitialized = false;

  LocalNotificationServiceImpl({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    tz.initializeTimeZones();
    await _setLocalTimeZone();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(settings: initializationSettings);
    _isInitialized = true;
  }

  @override
  Future<bool> hasPermission() async {
    await initialize();

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? true;
    }

    return true;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      return await androidImplementation.requestNotificationsPermission() ??
          true;
    }

    final iosImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosImplementation != null) {
      return await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    }

    final macOsImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    if (macOsImplementation != null) {
      return await macOsImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    }

    return !kIsWeb;
  }

  @override
  Future<void> scheduleDaily({required int hour, required int minute}) async {
    await initialize();
    await cancelDaily();

    await _plugin.zonedSchedule(
      id: _dailyNotificationId,
      title: _notificationTitle,
      body: _notificationBody,
      scheduledDate: _nextDailyTime(hour: hour, minute: minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_quiz',
    );
  }

  @override
  Future<void> cancelDaily() async {
    await initialize();
    await _plugin.cancel(id: _dailyNotificationId);
  }

  Future<void> _setLocalTimeZone() async {
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  tz.TZDateTime _nextDailyTime({required int hour, required int minute}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
