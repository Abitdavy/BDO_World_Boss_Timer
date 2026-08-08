class TimezoneOption {
  final String id;
  final String label;
  final String code;
  final int offsetMinutes;

  const TimezoneOption({
    required this.id,
    required this.label,
    required this.code,
    required this.offsetMinutes,
  });
}

class TimezoneData {
  static const List<TimezoneOption> availableOptions = [
    TimezoneOption(
      id: 'WIB',
      label: 'WIB - Waktu Indonesia Barat (UTC+7)',
      code: 'WIB',
      offsetMinutes: 420,
    ),
    TimezoneOption(
      id: 'WITA',
      label: 'WITA - Waktu Indonesia Tengah (UTC+8)',
      code: 'WITA',
      offsetMinutes: 480,
    ),
    TimezoneOption(
      id: 'WIT',
      label: 'WIT - Waktu Indonesia Timur (UTC+9)',
      code: 'WIT',
      offsetMinutes: 540,
    ),
    TimezoneOption(
      id: 'SGT',
      label: 'SGT / MYT - Singapore / Malaysia (UTC+8)',
      code: 'SGT',
      offsetMinutes: 480,
    ),
    TimezoneOption(
      id: 'JST',
      label: 'JST / KST - Japan / Korea (UTC+9)',
      code: 'JST',
      offsetMinutes: 540,
    ),
    TimezoneOption(
      id: 'UTC',
      label: 'UTC - Coordinated Universal Time (UTC+0)',
      code: 'UTC',
      offsetMinutes: 0,
    ),
    TimezoneOption(
      id: 'EST',
      label: 'EST / EDT - US Eastern (UTC-5)',
      code: 'EST',
      offsetMinutes: -300,
    ),
    TimezoneOption(
      id: 'CST',
      label: 'CST / CDT - US Central (UTC-6)',
      code: 'CST',
      offsetMinutes: -360,
    ),
    TimezoneOption(
      id: 'PST',
      label: 'PST / PDT - US Pacific (UTC-8)',
      code: 'PST',
      offsetMinutes: -480,
    ),
    TimezoneOption(
      id: 'CET',
      label: 'CET - Central European Time (UTC+1)',
      code: 'CET',
      offsetMinutes: 60,
    ),
  ];

  static String getCodeFromOffset(int minutes) {
    switch (minutes) {
      case 420:
        return 'WIB';
      case 480:
        return 'WITA';
      case 540:
        return 'WIT';
      case 0:
        return 'UTC';
      case -300:
        return 'EST';
      case -360:
        return 'CST';
      case -480:
        return 'PST';
      case 60:
        return 'CET';
      default:
        final sign = minutes >= 0 ? '+' : '-';
        final hours = (minutes.abs() ~/ 60);
        final mins = (minutes.abs() % 60);
        if (mins == 0) {
          return 'UTC$sign$hours';
        }
        return 'UTC$sign$hours:${mins.toString().padLeft(2, '0')}';
    }
  }
}
