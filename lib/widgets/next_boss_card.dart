import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/boss_schedule_model.dart';
import '../services/schedule_service.dart';

class NextBossCard extends StatefulWidget {
  final UpcomingSpawn? upcomingSpawn;
  final VoidCallback? onRefresh;

  const NextBossCard({
    super.key,
    required this.upcomingSpawn,
    this.onRefresh,
  });

  @override
  State<NextBossCard> createState() => _NextBossCardState();
}

class _NextBossCardState extends State<NextBossCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(NextBossCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.upcomingSpawn != oldWidget.upcomingSpawn) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.upcomingSpawn == null) return;

    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    if (widget.upcomingSpawn == null) return;
    final nowUtc = DateTime.now().toUtc();
    final diff = widget.upcomingSpawn!.spawnTimeUtc.difference(nowUtc);

    if (diff.isNegative) {
      widget.onRefresh?.call();
    } else {
      if (mounted) {
        setState(() {
          _remaining = diff;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext me) {
    if (widget.upcomingSpawn == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF191F30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF242C44)),
        ),
        child: const Center(
          child: Text(
            'No upcoming spawn found for this week.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final spawn = widget.upcomingSpawn!.spawn;
    final displayTime = widget.upcomingSpawn!.displayTime;
    final displayDay = widget.upcomingSpawn!.displayDay;
    final tzCode = widget.upcomingSpawn!.timezoneCode;
    final hours = _twoDigits(_remaining.inHours);
    final minutes = _twoDigits(_remaining.inMinutes.remainder(60));
    final seconds = _twoDigits(_remaining.inSeconds.remainder(60));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2638), Color(0xFF141926)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB703).withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFB703).withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3366).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFF3366), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3366),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'NEXT WORLD BOSS',
                        style: GoogleFonts.rajdhani(
                          color: const Color(0xFFFF3366),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$tzCode $displayTime ($displayDay)',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFFFFB703),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Boss Images & Titles Row
            Row(
              children: [
                // Boss avatars stack
                SizedBox(
                  height: 70,
                  width: spawn.bosses.length > 1 ? 110 : 70,
                  child: Stack(
                    children: spawn.bosses.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final bossName = entry.value;
                      return Positioned(
                        left: idx * 35.0,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFB703), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              ScheduleService.getBossImagePath(bossName),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spawn.bosses.join(' & '),
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Live Countdown Timer Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F121C),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF242C44)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTimeUnit(hours, 'HOURS'),
                  _buildTimerDivider(),
                  _buildTimeUnit(minutes, 'MINUTES'),
                  _buildTimerDivider(),
                  _buildTimeUnit(seconds, 'SECONDS'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: const Color(0xFFFFB703),
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF90A4AE),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerDivider() {
    return Text(
      ':',
      style: GoogleFonts.orbitron(
        color: const Color(0xFFFFB703).withValues(alpha: 0.6),
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
