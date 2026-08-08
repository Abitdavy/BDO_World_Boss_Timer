import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/boss_schedule_model.dart';
import '../services/schedule_service.dart';

class BossCard extends StatelessWidget {
  final BossSpawn spawn;
  final bool isNext;
  final String? displayTime;
  final String? timezoneCode;

  const BossCard({
    super.key,
    required this.spawn,
    this.isNext = false,
    this.displayTime,
    this.timezoneCode,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = displayTime ?? spawn.timeWib;
    final tzCode = timezoneCode ?? 'WIB';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isNext ? const Color(0xFF1E2638) : const Color(0xFF191F30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isNext ? const Color(0xFFFFB703) : const Color(0xFF242C44),
          width: isNext ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Time badge column
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F121C),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isNext ? const Color(0xFFFFB703) : const Color(0xFF242C44),
              ),
            ),
            child: Column(
              children: [
                Text(
                  timeStr,
                  style: GoogleFonts.orbitron(
                    color: const Color(0xFFFFB703),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tzCode,
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF90A4AE),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '(${spawn.timeUtc} UTC)',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF607D8B),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Boss Avatars
          Row(
            children: spawn.bosses.map((bossName) {
              return Container(
                margin: const EdgeInsets.only(right: 6),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF242C44), width: 1.5),
                ),
                child: ClipOval(
                  child: Image.asset(
                    ScheduleService.getBossImagePath(bossName),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(width: 10),

          // Details column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spawn.bosses.join(' & '),
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                ),
                if (spawn.lomlBoss != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Land of Morning Light: ${spawn.lomlBoss}',
                    style: const TextStyle(
                      color: Color(0xFFFF9800),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          if (isNext)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB703),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'NEXT',
                style: GoogleFonts.rajdhani(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
