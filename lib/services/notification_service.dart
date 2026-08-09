import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/boss_schedule_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final ValueNotifier<int?> selectTabNotifier = ValueNotifier<int?>(null);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        selectTabNotifier.value = 0;
      },
    );

    final NotificationAppLaunchDetails? launchDetails =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      selectTabNotifier.value = 0;
    }

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> showTestNotification({required String bossName, required int leadMinutes}) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'bdo_boss_channel_v3',
      'BDO World Boss Notifications',
      channelDescription: 'Alerts for BDO World Boss Spawns',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'BDO Boss Alert',
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );
    const details = NotificationDetails(android: androidDetails);

    final String leadText = leadMinutes == 0
        ? 'is spawning NOW!'
        : 'spawns in $leadMinutes minutes!';

    await _notificationsPlugin.show(
      id: 9999,
      title: '⚔️ BDO Boss Alert: $bossName',
      body: '$bossName $leadText Get ready!',
      notificationDetails: details,
      payload: 'timer',
    );
  }

  Future<void> scheduleBossNotifications({
    required List<UpcomingSpawn> upcomingSpawns,
    required List<int> leadTimeMinutes,
    required List<String> enabledBosses,
  }) async {
    await init();
    await _notificationsPlugin.cancelAll();

    int notificationId = 1000;
    final nowUtc = DateTime.now().toUtc();

    for (final upcoming in upcomingSpawns) {
      final spawn = upcoming.spawn;
      final spawnTimeUtc = upcoming.spawnTimeUtc;

      final activeBosses = spawn.bosses.where((b) => enabledBosses.contains(b)).toList();
      if (activeBosses.isEmpty) continue;

      final bossNamesString = activeBosses.join(' & ');

      for (final minutesBefore in leadTimeMinutes) {
        final alertTimeUtc = spawnTimeUtc.subtract(Duration(minutes: minutesBefore));
        if (alertTimeUtc.isBefore(nowUtc)) continue;

        final tzAlertTime = tz.TZDateTime.from(alertTimeUtc, tz.UTC);

        final String bodyText = minutesBefore == 0
            ? '$bossNamesString ${activeBosses.length > 1 ? "are" : "is"} spawning NOW!'
            : '$bossNamesString spawns in $minutesBefore minutes (${upcoming.timezoneCode} ${upcoming.displayTime})!';

        const notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            'bdo_boss_channel_v3',
            'BDO World Boss Notifications',
            channelDescription: 'Alerts for BDO World Boss Spawns',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ),
        );

        try {
          await _notificationsPlugin.zonedSchedule(
            id: notificationId++,
            title: '⚔️ Boss Alert: $bossNamesString',
            body: bodyText,
            scheduledDate: tzAlertTime,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: 'timer',
          );
        } catch (_) {
          // Fallback if exact alarm permission is restricted on Android 12+
          try {
            await _notificationsPlugin.zonedSchedule(
              id: notificationId++,
              title: '⚔️ Boss Alert: $bossNamesString',
              body: bodyText,
              scheduledDate: tzAlertTime,
              notificationDetails: notificationDetails,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              payload: 'timer',
            );
          } catch (_) {}
        }
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
