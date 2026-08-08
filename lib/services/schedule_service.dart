import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/boss_schedule_model.dart';

class ScheduleService {
  BossScheduleData? _data;

  BossScheduleData? get data => _data;

  static const Map<String, int> dayToWeekday = {
    'Monday': DateTime.monday,
    'Tuesday': DateTime.tuesday,
    'Wednesday': DateTime.wednesday,
    'Thursday': DateTime.thursday,
    'Friday': DateTime.friday,
    'Saturday': DateTime.saturday,
    'Sunday': DateTime.sunday,
  };

  static const Map<String, String> bossImageAssets = {
    'Sangoon': 'assets/bosses/Sangoon.jfif',
    'Uturi': 'assets/bosses/Uturi.png',
    'Bulgasal': 'assets/bosses/Bulgasal.jfif',
    'Golden Pig King': 'assets/bosses/Golden Pig King.png',
    'Nouver': 'assets/bosses/Nouver.jfif',
    'Karanda': 'assets/bosses/Karanda.jfif',
    'Kzarka': 'assets/bosses/Kzarka.webp',
    'Kutum': 'assets/bosses/Kutum.webp',
    'Garmoth': 'assets/bosses/Garmoth.jfif',
    'Muraka': 'assets/bosses/Muraka.jfif',
    'Offin': 'assets/bosses/Offin.webp',
    'Quint': 'assets/bosses/Quint.jfif',
    'Vell': 'assets/bosses/Vell.jfif',
  };

  static String getBossImagePath(String bossName) {
    return bossImageAssets[bossName] ?? 'assets/images/logo.jpg';
  }

  Future<BossScheduleData> loadSchedule() async {
    if (_data != null) return _data!;
    final jsonString = await rootBundle.loadString('assets/data/boss_schedule.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _data = BossScheduleData.fromJson(jsonMap);
    return _data!;
  }

  /// Get current UTC time
  DateTime getNowUtc() {
    return DateTime.now().toUtc();
  }

  /// Get current time in target timezone
  DateTime getNowTarget(int offsetMinutes) {
    return getNowUtc().add(Duration(minutes: offsetMinutes));
  }

  /// Get current time forced or adjusted to WIB (UTC+7)
  DateTime getNowWib() {
    return getNowTarget(420);
  }

  /// Find all upcoming spawn occurrences within the next X days
  List<UpcomingSpawn> getUpcomingSpawns({
    int offsetMinutes = 420,
    String timezoneCode = 'WIB',
    int daysAhead = 7,
  }) {
    if (_data == null) return [];
    final nowUtc = getNowUtc();
    final nowWib = getNowWib();
    final List<UpcomingSpawn> result = [];

    // Check next `daysAhead` days starting from today
    for (int dayOffset = 0; dayOffset <= daysAhead; dayOffset++) {
      final checkDateWib = nowWib.add(Duration(days: dayOffset));
      final weekdayNameWib = _weekdayToString(checkDateWib.weekday);

      final daySchedule = _data!.schedule.firstWhere(
        (ds) => ds.day.toLowerCase() == weekdayNameWib.toLowerCase(),
        orElse: () => DaySchedule(day: weekdayNameWib, spawns: []),
      );

      for (final spawn in daySchedule.spawns) {
        final spawnTimeWib = DateTime.utc(
          checkDateWib.year,
          checkDateWib.month,
          checkDateWib.day,
          spawn.hourWib,
          spawn.minuteWib,
        );

        final spawnTimeUtc = spawnTimeWib.subtract(const Duration(hours: 7));

        if (spawnTimeUtc.isAfter(nowUtc)) {
          final timeUntil = spawnTimeUtc.difference(nowUtc);
          final spawnTimeTarget = spawnTimeUtc.add(Duration(minutes: offsetMinutes));
          final displayTime =
              '${spawnTimeTarget.hour.toString().padLeft(2, '0')}:${spawnTimeTarget.minute.toString().padLeft(2, '0')}';
          final displayDay = _weekdayToString(spawnTimeTarget.weekday);

          result.add(UpcomingSpawn(
            spawn: spawn,
            spawnTimeUtc: spawnTimeUtc,
            spawnTimeTarget: spawnTimeTarget,
            displayTime: displayTime,
            displayDay: displayDay,
            timezoneCode: timezoneCode,
            timeUntil: timeUntil,
          ));
        }
      }
    }

    result.sort((a, b) => a.spawnTimeUtc.compareTo(b.spawnTimeUtc));
    return result;
  }

  /// Get the immediate next spawn
  UpcomingSpawn? getNextSpawn({
    int offsetMinutes = 420,
    String timezoneCode = 'WIB',
  }) {
    final upcoming = getUpcomingSpawns(
      offsetMinutes: offsetMinutes,
      timezoneCode: timezoneCode,
      daysAhead: 7,
    );
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  String _weekdayToString(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }
}
