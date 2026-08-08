import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/timezone_model.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<int> availableLeadTimes = [0, 5, 10, 15, 30, 60];

  static const List<String> allBosses = [
    "Sangoon",
    "Uturi",
    "Bulgasal",
    "Golden Pig King",
    "Nouver",
    "Karanda",
    "Kzarka",
    "Kutum",
    "Garmoth",
    "Muraka",
    "Offin",
    "Quint",
    "Vell",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F121C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141926),
        elevation: 0,
        title: Text(
          'SETTINGS',
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Master Notification Switch Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF191F30),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF242C44)),
                ),
                child: SwitchListTile(
                  activeThumbColor: const Color(0xFFFFB703),
                  title: Text(
                    'Push Notifications',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Receive scheduled alerts when bosses are about to spawn',
                    style: TextStyle(color: Color(0xFF90A4AE), fontSize: 12),
                  ),
                  value: settings.notificationsEnabled,
                  onChanged: (val) async {
                    if (val) {
                      final granted = await NotificationService().requestPermissions();
                      if (!context.mounted) return;
                      if (!granted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification permission is required for push alerts.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                    settings.setNotificationsEnabled(val);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Section: Timezone Settings
              Text(
                'TIMEZONE SETTINGS',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFFFFB703),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select automatic device timezone detection or set custom timezone:',
                style: TextStyle(color: Color(0xFF90A4AE), fontSize: 12),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF191F30),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF242C44)),
                ),
                child: Column(
                  children: [
                    RadioListTile<bool>(
                      activeColor: const Color(0xFFFFB703),
                      title: Text(
                        'Automatic (Device Local Timezone)',
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Active: ${settings.activeTimezoneCode} (UTC${settings.activeOffsetMinutes >= 0 ? '+' : ''}${settings.activeOffsetMinutes ~/ 60})',
                        style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12),
                      ),
                      value: true,
                      groupValue: settings.isAutoTimezone,
                      onChanged: (val) {
                        if (val != null) settings.setAutoTimezone(val);
                      },
                    ),
                    const Divider(color: Color(0xFF242C44), height: 1),
                    RadioListTile<bool>(
                      activeColor: const Color(0xFFFFB703),
                      title: Text(
                        'Manual Timezone Selection',
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        'Choose preferred timezone offset manually',
                        style: TextStyle(color: Color(0xFF90A4AE), fontSize: 12),
                      ),
                      value: false,
                      groupValue: settings.isAutoTimezone,
                      onChanged: (val) {
                        if (val != null) settings.setAutoTimezone(val);
                      },
                    ),
                    if (!settings.isAutoTimezone) ...[
                      const Divider(color: Color(0xFF242C44), height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: DropdownButtonFormField<String>(
                          value: settings.manualTimezoneId,
                          dropdownColor: const Color(0xFF191F30),
                          decoration: InputDecoration(
                            labelText: 'Select Timezone',
                            labelStyle: const TextStyle(color: Color(0xFFFFB703)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF242C44)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFFFFB703)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: TimezoneData.availableOptions.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt.id,
                              child: Text(
                                opt.label,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              settings.setManualTimezoneId(val);
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section: Alert Timing Options (0, -5m, -10m, etc.)
              Text(
                'ALERT TIMING (WHEN TO NOTIFY)',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFFFFB703),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose how many minutes before spawn time you want to be alerted:',
                style: TextStyle(color: Color(0xFF90A4AE), fontSize: 12),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: availableLeadTimes.map((minutes) {
                  final isSelected = settings.selectedLeadTimes.contains(minutes);
                  final label = minutes == 0 ? '0m (At Spawn)' : '-$minutes mins';

                  return FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFFB703),
                    backgroundColor: const Color(0xFF191F30),
                    checkmarkColor: Colors.black,
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFFFB703) : const Color(0xFF242C44),
                    ),
                    labelStyle: GoogleFonts.rajdhani(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    onSelected: settings.notificationsEnabled
                        ? (_) => settings.toggleLeadTime(minutes)
                        : null,
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Section: Boss Selection Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BOSS ALERTS FILTER',
                    style: GoogleFonts.rajdhani(
                      color: const Color(0xFFFFB703),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: settings.notificationsEnabled
                            ? () => settings.enableAllBosses(true)
                            : null,
                        child: const Text('Select All', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12)),
                      ),
                      TextButton(
                        onPressed: settings.notificationsEnabled
                            ? () => settings.enableAllBosses(false)
                            : null,
                        child: const Text('Clear', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF191F30),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF242C44)),
                ),
                child: Column(
                  children: allBosses.asMap().entries.map((entry) {
                    final index = entry.key;
                    final bossName = entry.value;
                    final isChecked = settings.enabledBosses.contains(bossName);

                    return Column(
                      children: [
                        CheckboxListTile(
                          activeColor: const Color(0xFFFFB703),
                          checkColor: Colors.black,
                          title: Text(
                            bossName,
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: isChecked,
                          onChanged: settings.notificationsEnabled
                              ? (_) => settings.toggleBoss(bossName)
                              : null,
                        ),
                        if (index < allBosses.length - 1)
                          const Divider(color: Color(0xFF242C44), height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // Test Notification Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.notifications_active),
                label: Text(
                  'SEND TEST PUSH NOTIFICATION',
                  style: GoogleFonts.rajdhani(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),
                onPressed: () async {
                  final granted = await NotificationService().requestPermissions();
                  if (!context.mounted) return;
                  if (!granted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enable notification permissions in system settings.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  await NotificationService().showTestNotification(
                    bossName: settings.enabledBosses.isNotEmpty
                        ? settings.enabledBosses.first
                        : 'Sangoon',
                    leadMinutes: settings.selectedLeadTimes.isNotEmpty
                        ? settings.selectedLeadTimes.first
                        : 5,
                  );

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test notification sent! Check your notification bar.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // App Version Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'BDO Boss Timer',
                      style: GoogleFonts.cinzel(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'v1.0.9 (Build 10)',
                      style: GoogleFonts.rajdhani(
                        color: const Color(0xFF607D8B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
