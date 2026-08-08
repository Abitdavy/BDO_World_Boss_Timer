import 'package:flutter_test/flutter_test.dart';
import 'package:bdo_wb_timer/services/schedule_service.dart';
import 'package:bdo_wb_timer/main.dart';
import 'package:provider/provider.dart';
import 'package:bdo_wb_timer/providers/settings_provider.dart';

void main() {
  testWidgets('App loads cleanly test', (WidgetTester tester) async {
    final scheduleService = ScheduleService();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(scheduleService),
        child: BdoBossTimerApp(scheduleService: scheduleService),
      ),
    );
    expect(find.byType(BdoBossTimerApp), findsOneWidget);
  });
}
