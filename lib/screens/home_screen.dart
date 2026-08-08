import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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

  void _showFilterBottomSheet(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141926),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Consumer<SettingsProvider>(
          builder: (context, currentSettings, child) {
            final allBosses = ScheduleService.allBosses;
            final enabledCount = currentSettings.enabledBosses.length;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF242C44),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header title & actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BOSS FILTER',
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$enabledCount of ${allBosses.length} bosses active',
                            style: GoogleFonts.rajdhani(
                              color: const Color(0xFF90A4AE),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => currentSettings.enableAllBosses(true),
                            child: Text(
                              'Select All',
                              style: GoogleFonts.rajdhani(
                                color: const Color(0xFF00E5FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => currentSettings.enableAllBosses(false),
                            child: Text(
                              'Clear',
                              style: GoogleFonts.rajdhani(
                                color: Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF242C44), height: 1),
                  const SizedBox(height: 12),

                  // Boss List
                  Expanded(
                    child: ListView.separated(
                      itemCount: allBosses.length,
                      separatorBuilder: (_, index) => const Divider(color: Color(0xFF242C44), height: 1),
                      itemBuilder: (context, index) {
                        final bossName = allBosses[index];
                        final isSelected = currentSettings.enabledBosses.contains(bossName);
                        final imagePath = ScheduleService.getBossImagePath(bossName);

                        return CheckboxListTile(
                          activeColor: const Color(0xFFFFB703),
                          checkColor: Colors.black,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          secondary: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFFFFB703) : const Color(0xFF242C44),
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(imagePath, fit: BoxFit.cover),
                            ),
                          ),
                          title: Text(
                            bossName,
                            style: GoogleFonts.rajdhani(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          value: isSelected,
                          onChanged: (_) => currentSettings.toggleBoss(bossName),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
          enabledBosses: settings.enabledBosses,
        );

        final upcomingList = widget.scheduleService.getUpcomingSpawns(
          offsetMinutes: activeOffset,
          timezoneCode: tzCode,
          daysAhead: 3,
          enabledBosses: settings.enabledBosses,
        );

        final isFiltered = settings.enabledBosses.length < ScheduleService.allBosses.length;

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
                          icon: Badge(
                            isLabelVisible: isFiltered,
                            label: Text('${settings.enabledBosses.length}'),
                            backgroundColor: const Color(0xFFFF3366),
                            child: Icon(
                              Icons.filter_list_rounded,
                              color: isFiltered ? const Color(0xFFFFB703) : const Color(0xFF90A4AE),
                            ),
                          ),
                          onPressed: () => _showFilterBottomSheet(context, settings),
                          tooltip: 'Filter Bosses',
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_active_outlined, color: Color(0xFFFFB703)),
                          onPressed: widget.onOpenSettings,
                          tooltip: 'Notification Settings',
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
                          Row(
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
                              if (isFiltered) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFB703).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFFFB703), width: 0.8),
                                  ),
                                  child: Text(
                                    '${settings.enabledBosses.length}/${ScheduleService.allBosses.length}',
                                    style: GoogleFonts.rajdhani(
                                      color: const Color(0xFFFFB703),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.tune,
                                  color: isFiltered ? const Color(0xFFFFB703) : const Color(0xFF90A4AE),
                                  size: 20,
                                ),
                                onPressed: () => _showFilterBottomSheet(context, settings),
                                tooltip: 'Filter Bosses',
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Color(0xFF90A4AE), size: 20),
                                onPressed: () => setState(() {}),
                                tooltip: 'Refresh',
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      if (upcomingList.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              isFiltered
                                  ? 'No upcoming spawns match your boss filter.'
                                  : 'No upcoming spawns scheduled.',
                              style: const TextStyle(color: Colors.white54),
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
