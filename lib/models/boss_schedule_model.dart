class BossSpawn {
  final String timeWib;
  final String timeUtc;
  final List<String> bosses;
  final String? lomlBoss;
  final String location;
  final String day;

  BossSpawn({
    required this.timeWib,
    required this.timeUtc,
    required this.bosses,
    this.lomlBoss,
    required this.location,
    required this.day,
  });

  factory BossSpawn.fromJson(Map<String, dynamic> json, String dayName) {
    final wib = json['time_wib'] ?? json['time'] ?? '';
    final utc = json['time_utc'] ?? _calcUtcFromWib(wib);
    return BossSpawn(
      timeWib: wib,
      timeUtc: utc,
      bosses: List<String>.from(json['bosses'] ?? []),
      lomlBoss: json['loml_boss'],
      location: json['location'] ?? '',
      day: dayName,
    );
  }

  static String _calcUtcFromWib(String wib) {
    if (wib.isEmpty || !wib.contains(':')) return '';
    final parts = wib.split(':');
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return '';
    final utcH = (h - 7 + 24) % 24;
    return '${utcH.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  // Parse time_wib into hour and minute
  int get hourWib => int.parse(timeWib.split(':')[0]);
  int get minuteWib => int.parse(timeWib.split(':')[1]);
}

class DaySchedule {
  final String day;
  final List<BossSpawn> spawns;

  DaySchedule({
    required this.day,
    required this.spawns,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    final dayName = json['day'] ?? '';
    final rawSpawns = json['spawns'] as List? ?? [];
    return DaySchedule(
      day: dayName,
      spawns: rawSpawns.map((s) => BossSpawn.fromJson(s, dayName)).toList(),
    );
  }
}

class BossScheduleData {
  final String server;
  final String timezone;
  final String utcOffset;
  final List<String> bosses;
  final String weeklyReset;
  final List<DaySchedule> schedule;

  BossScheduleData({
    required this.server,
    required this.timezone,
    required this.utcOffset,
    required this.bosses,
    required this.weeklyReset,
    required this.schedule,
  });

  factory BossScheduleData.fromJson(Map<String, dynamic> json) {
    final rawSchedule = json['schedule'] as List? ?? [];
    return BossScheduleData(
      server: json['server'] ?? 'SEA',
      timezone: json['timezone'] ?? 'WIB',
      utcOffset: json['utc_offset'] ?? '+07:00',
      bosses: List<String>.from(json['bosses'] ?? []),
      weeklyReset: json['weekly_reset'] ?? '',
      schedule: rawSchedule.map((d) => DaySchedule.fromJson(d)).toList(),
    );
  }
}

class UpcomingSpawn {
  final BossSpawn spawn;
  final DateTime spawnTimeUtc;
  final DateTime spawnTimeTarget;
  final String displayTime;
  final String displayDay;
  final String timezoneCode;
  final Duration timeUntil;

  UpcomingSpawn({
    required this.spawn,
    required this.spawnTimeUtc,
    required this.spawnTimeTarget,
    required this.displayTime,
    required this.displayDay,
    required this.timezoneCode,
    required this.timeUntil,
  });

  DateTime get spawnTimeWib => spawnTimeUtc.add(const Duration(hours: 7));
}
