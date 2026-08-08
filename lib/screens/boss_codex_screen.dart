import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/schedule_service.dart';

class BossCodexScreen extends StatelessWidget {
  final ScheduleService scheduleService;

  const BossCodexScreen({super.key, required this.scheduleService});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> bosses = [
      {
        'name': 'Sangoon',
        'location': '',
        'desc': 'Giant Tiger General of Beomnae Valley',
        'loml': true,
      },
      {
        'name': 'Uturi',
        'location': '',
        'desc': 'Monkey Warrior General of Martial God Arena',
        'loml': true,
      },
      {
        'name': 'Bulgasal',
        'location': '',
        'desc': 'Ancient Fire & Iron Beast of Holbon',
        'loml': true,
      },
      {
        'name': 'Golden Pig King',
        'location': '',
        'desc': 'Greedy Armored Boar King of Golden Pig Cave',
        'loml': true,
      },
      {
        'name': 'Nouver',
        'location': '',
        'desc': 'Ferocious Sand Dragon of Valencia Desert',
        'loml': false,
      },
      {
        'name': 'Karanda',
        'location': '',
        'desc': 'Ruler of the Harpy Ridge',
        'loml': false,
      },
      {
        'name': 'Kzarka',
        'location': '',
        'desc': 'Lord of Corruption sealed in Serendia Shrine',
        'loml': false,
      },
      {
        'name': 'Kutum',
        'location': '',
        'desc': 'Ancient Mechanical Serpent of Scarlet Sand Chamber',
        'loml': false,
      },
      {
        'name': 'Garmoth',
        'location': '',
        'desc': 'Crimson Dragon of Drieghan',
        'loml': false,
      },
      {
        'name': 'Muraka',
        'location': '',
        'desc': 'King of Ogres in Mansha Forest',
        'loml': false,
      },
      {
        'name': 'Offin',
        'location': '',
        'desc': 'Mirumok Destroyer in Kamasylvia',
        'loml': false,
      },
      {
        'name': 'Quint',
        'location': '',
        'desc': 'First Troll Giant in Quint Hill',
        'loml': false,
      },
      {
        'name': 'Vell',
        'location': '',
        'desc': 'Heart of the Ocean in Margoria Sea',
        'loml': false,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F121C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141926),
        elevation: 0,
        title: Text(
          'BOSS CODEX',
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: bosses.length,
        itemBuilder: (context, index) {
          final boss = bosses[index];
          final String name = boss['name'];
          final String location = boss['location'];
          final bool isLoml = boss['loml'];
          final String imgPath = ScheduleService.getBossImagePath(name);

          return GestureDetector(
            onTap: () => _showBossDetails(context, boss),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF191F30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF242C44)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.asset(
                              imgPath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (isLoml)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9800),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'LoML',
                                style: GoogleFonts.rajdhani(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (location.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            location,
                            style: const TextStyle(
                              color: Color(0xFF00E5FF),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBossDetails(BuildContext context, Map<String, dynamic> boss) {
    final String name = boss['name'];
    final String location = boss['location'];
    final String desc = boss['desc'];
    final String imgPath = ScheduleService.getBossImagePath(name);

    // Find upcoming spawns for this boss
    final upcoming = scheduleService
        .getUpcomingSpawns(daysAhead: 7)
        .where((s) => s.spawn.bosses.contains(name))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141926),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFB703), width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(imgPath, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          desc,
                          style: const TextStyle(
                            color: Color(0xFF90A4AE),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'UPCOMING SPAWNS (WIB)',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFFFFB703),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              if (upcoming.isEmpty)
                const Text(
                  'No upcoming spawns found for this boss.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                )
              else
                ...upcoming.take(3).map((u) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${u.spawn.day} @ ${u.spawn.timeWib} WIB',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        if (location.isNotEmpty)
                          Text(
                            'Location: $location',
                            style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12),
                          ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
