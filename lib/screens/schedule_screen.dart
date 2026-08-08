import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/boss_schedule_model.dart';
import '../providers/settings_provider.dart';
import '../services/schedule_service.dart';
import '../widgets/boss_card.dart';

class ScheduleScreen extends StatefulWidget {
  final ScheduleService scheduleService;

  const ScheduleScreen({super.key, required this.scheduleService});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    final nowWib = widget.scheduleService.getNowWib();
    int currentDayIdx = nowWib.weekday - 1;
    if (currentDayIdx < 0 || currentDayIdx > 6) currentDayIdx = 0;

    _tabController = TabController(
      length: _days.length,
      vsync: this,
      initialIndex: currentDayIdx,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _calcDisplayTime(BossSpawn spawn, int offsetMinutes) {
    final utcH = (spawn.hourWib - 7 + 24) % 24;
    final utcM = spawn.minuteWib;
    final utcTotalMinutes = utcH * 60 + utcM;
    final targetTotalMinutes = (utcTotalMinutes + offsetMinutes + 1440 * 2) % 1440;
    final targetH = targetTotalMinutes ~/ 60;
    final targetM = targetTotalMinutes % 60;
    return '${targetH.toString().padLeft(2, '0')}:${targetM.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.scheduleService.data;

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final activeOffset = settings.activeOffsetMinutes;
        final tzCode = settings.activeTimezoneCode;
        final nextSpawnObj = widget.scheduleService.getNextSpawn(
          offsetMinutes: activeOffset,
          timezoneCode: tzCode,
        );
        final nextSpawn = nextSpawnObj?.spawn;

        return Scaffold(
          backgroundColor: const Color(0xFF0F121C),
          appBar: AppBar(
            backgroundColor: const Color(0xFF141926),
            elevation: 0,
            title: Text(
              'WEEKLY SCHEDULE ($tzCode)',
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFFFFB703),
              indicatorWeight: 3,
              labelColor: const Color(0xFFFFB703),
              unselectedLabelColor: const Color(0xFF90A4AE),
              labelStyle: GoogleFonts.rajdhani(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: GoogleFonts.rajdhani(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: _days.map((day) => Tab(text: day.toUpperCase())).toList(),
            ),
          ),
          body: data == null
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: _days.map((dayName) {
                    final daySchedule = data.schedule.firstWhere(
                      (ds) => ds.day.toLowerCase() == dayName.toLowerCase(),
                      orElse: () => DaySchedule(day: dayName, spawns: []),
                    );

                    if (daySchedule.spawns.isEmpty) {
                      return Center(
                        child: Text(
                          'No boss spawns scheduled for $dayName.',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: daySchedule.spawns.length,
                      itemBuilder: (context, index) {
                        final spawn = daySchedule.spawns[index];
                        final isNext = nextSpawn != null &&
                            nextSpawn.day == spawn.day &&
                            nextSpawn.timeWib == spawn.timeWib;

                        final displayTime = _calcDisplayTime(spawn, activeOffset);

                        return BossCard(
                          spawn: spawn,
                          isNext: isNext,
                          displayTime: displayTime,
                          timezoneCode: tzCode,
                        );
                      },
                    );
                  }).toList(),
                ),
        );
      },
    );
  }
}
