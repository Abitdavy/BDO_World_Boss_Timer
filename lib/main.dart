import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/boss_codex_screen.dart';
import 'screens/settings_screen.dart';
import 'services/notification_service.dart';
import 'services/schedule_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications service
  await NotificationService().init();

  final scheduleService = ScheduleService();
  await scheduleService.loadSchedule();

  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(scheduleService),
      child: BdoBossTimerApp(scheduleService: scheduleService),
    ),
  );
}

class BdoBossTimerApp extends StatelessWidget {
  final ScheduleService scheduleService;

  const BdoBossTimerApp({super.key, required this.scheduleService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BDO Boss Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F121C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB703),
          secondary: Color(0xFFFF3366),
          surface: Color(0xFF191F30),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: MainNavigationContainer(scheduleService: scheduleService),
    );
  }
}

class MainNavigationContainer extends StatefulWidget {
  final ScheduleService scheduleService;

  const MainNavigationContainer({super.key, required this.scheduleService});

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    NotificationService().selectTabNotifier.addListener(_onTabNotification);
  }

  void _onTabNotification() {
    final tabIndex = NotificationService().selectTabNotifier.value;
    if (tabIndex != null && mounted) {
      setState(() {
        _currentIndex = tabIndex;
      });
      NotificationService().selectTabNotifier.value = null;
    }
  }

  @override
  void dispose() {
    NotificationService().selectTabNotifier.removeListener(_onTabNotification);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        scheduleService: widget.scheduleService,
        onOpenSettings: () {
          setState(() {
            _currentIndex = 3;
          });
        },
      ),
      ScheduleScreen(scheduleService: widget.scheduleService),
      BossCodexScreen(scheduleService: widget.scheduleService),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF242C44), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF141926),
          selectedItemColor: const Color(0xFFFFB703),
          unselectedItemColor: const Color(0xFF607D8B),
          selectedLabelStyle: GoogleFonts.rajdhani(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.rajdhani(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer),
              label: 'Timer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Boss Codex',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
