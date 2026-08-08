import 'package:flutter_test/flutter_test.dart';
import 'package:bdo_wb_timer/services/schedule_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ScheduleService parses new schedule format and finds next spawn', () async {
    final service = ScheduleService();
    await service.loadSchedule();

    final nextSpawn = service.getNextSpawn();
    expect(nextSpawn, isNotNull);

    print('Next spawn day: ${nextSpawn!.spawn.day}');
    print('Next spawn time: ${nextSpawn.spawn.timeWib}');
    print('Next spawn bosses: ${nextSpawn.spawn.bosses}');
    print('Calculated UTC time: ${nextSpawn.spawn.timeUtc}');
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

    // Verify WITA time is +1 hour relative to WIB
    print('WIB display time: ${spawnWib.displayTime}');
    print('WITA display time: ${spawnWita.displayTime}');
  });
}
