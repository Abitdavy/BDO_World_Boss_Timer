import 'package:flutter_test/flutter_test.dart';
import 'package:bdo_wb_timer/services/schedule_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ScheduleService parses schedule format and finds next spawn', () async {
    final service = ScheduleService();
    await service.loadSchedule();

    final nextSpawn = service.getNextSpawn();
    expect(nextSpawn, isNotNull);
    expect(nextSpawn!.spawn.bosses, isNotEmpty);
  });

  test('ScheduleService converts spawn times for different timezones', () async {
    final service = ScheduleService();
    await service.loadSchedule();

    // WIB (+7)
    final spawnWib = service.getNextSpawn(offsetMinutes: 420, timezoneCode: 'WIB');
    expect(spawnWib, isNotNull);
    expect(spawnWib!.timezoneCode, equals('WIB'));

    // WITA (+8)
    final spawnWita = service.getNextSpawn(offsetMinutes: 480, timezoneCode: 'WITA');
    expect(spawnWita, isNotNull);
    expect(spawnWita!.timezoneCode, equals('WITA'));
  });

  test('ScheduleService correctly filters upcoming spawns and next boss by enabledBosses', () async {
    final service = ScheduleService();
    await service.loadSchedule();

    final allUpcoming = service.getUpcomingSpawns();
    expect(allUpcoming, isNotEmpty);

    // Filter only Garmoth
    final garmothUpcoming = service.getUpcomingSpawns(enabledBosses: ['Garmoth']);
    for (final spawn in garmothUpcoming) {
      expect(spawn.spawn.bosses, contains('Garmoth'));
      expect(spawn.spawn.bosses.every((b) => b == 'Garmoth'), isTrue);
    }

    final nextGarmoth = service.getNextSpawn(enabledBosses: ['Garmoth']);
    if (nextGarmoth != null) {
      expect(nextGarmoth.spawn.bosses, contains('Garmoth'));
    }

    // Empty enabled bosses returns no spawns
    final emptyUpcoming = service.getUpcomingSpawns(enabledBosses: []);
    expect(emptyUpcoming, isEmpty);

    final emptyNext = service.getNextSpawn(enabledBosses: []);
    expect(emptyNext, isNull);
  });
}
