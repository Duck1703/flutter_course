import 'package:ai_millionaire_course/services/local_notification_service.dart';

class FakeLocalNotificationService implements LocalNotificationService {
  bool permissionGranted;
  bool requestResult;
  int initializeCount = 0;
  int requestCount = 0;
  int scheduleCount = 0;
  int cancelCount = 0;
  int? lastHour;
  int? lastMinute;
  bool throwOnRequest = false;
  bool throwOnSchedule = false;

  FakeLocalNotificationService({
    this.permissionGranted = false,
    bool? requestResult,
  }) : requestResult = requestResult ?? permissionGranted;

  @override
  Future<void> initialize() async {
    initializeCount++;
  }

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<bool> requestPermission() async {
    requestCount++;
    if (throwOnRequest) {
      throw StateError('request failed');
    }

    permissionGranted = requestResult;
    return requestResult;
  }

  @override
  Future<void> scheduleDaily({required int hour, required int minute}) async {
    if (throwOnSchedule) {
      throw StateError('schedule failed');
    }

    scheduleCount++;
    lastHour = hour;
    lastMinute = minute;
  }

  @override
  Future<void> cancelDaily() async {
    cancelCount++;
  }
}
