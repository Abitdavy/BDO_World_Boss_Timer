import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/boss_schedule_model.dart';
import '../providers/settings_provider.dart';
import '../services/schedule_service.dart';
import '../widgets/next_boss_card.dart';
import '../widgets/boss_card.dart';

class HomeScreen extends StatefulWidget {
  final ScheduleService scheduleService;
  final VoidCallback onOpenSettings;

  const HomeScreen({
    super.key,
    required this.scheduleService,
    required this.onOpenSettings,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    widget.scheduleService.loadSchedule();
    _startClock();
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final activeOffset = settings.activeOffsetMinutes;
        final tzCode = settings.activeTimezoneCode;
        final nowTarget = widget.scheduleService.getNowTarget(activeOffset);

        final formattedTime = DateFormat('HH:mm:ss').format(nowTarget);
        final formattedDate = DateFormat('EEEE, dd MMM yyyy').format(nowTarget);

        final nextSpawn = widget.scheduleService.getNextSpawn(
          offsetMinutes: activeOffset,
          timezoneCode: tzCode,
        );

        final upcomingList = widget.scheduleService.getUpcomingSpawns(
          offsetMinutes: activeOffset,
          timezoneCode: tzCode,
          daysAhead: 3,
        );

        return Scaffold(
          backgroundColor: const Color(0xFF0F121C),
          body: CustomScrollView(
            slivers: [
              // Custom Gaming App Bar
              SliverAppBar(
                expandedHeight: 110.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF0F121C),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 10),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF141926), Color(0xFF0F121C)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFB703), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFB703).withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'BDO BOSS TIMER',
                                    style: GoogleFonts.cinzel(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFF00E5FF), width: 0.8),
                                    ),
                                    child: Text(
                                      'SEA ($tzCode)',
                                      style: GoogleFonts.rajdhani(
                                        color: const Color(0xFF00E5FF),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$formattedDate • $formattedTime $tzCode',
                                style: GoogleFonts.rajdhani(
                                  color: const Color(0xFFFFB703),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_active_outlined, color: Color(0xFFFFB703)),
                          onPressed: widget.onOpenSettings,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Next Boss Card
                      NextBossCard(
                        upcomingSpawn: nextSpawn,
                        onRefresh: () => setState(() {}),
                      ),

                      const SizedBox(height: 24),

                      // Section Title: Upcoming Spawns
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'UPCOMING SPAWNS',
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Color(0xFF90A4AE), size: 20),
                            onPressed: () => setState(() {}),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      if (upcomingList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'No upcoming spawns scheduled.',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        )
                      else
                        ...upcomingList.take(5).map((upcoming) {
                          final isNext = upcoming == nextSpawn;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 4, top: 4),
                                child: Text(
                                  '${upcoming.displayDay} at ${upcoming.displayTime} ${upcoming.timezoneCode}',
                                  style: GoogleFonts.rajdhani(
                                    color: const Color(0xFF90A4AE),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              BossCard(
                                spawn: upcoming.spawn,
                                isNext: isNext,
                                displayTime: upcoming.displayTime,
                                timezoneCode: upcoming.timezoneCode,
                              ),
                            ],
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
