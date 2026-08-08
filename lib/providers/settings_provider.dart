import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/schedule_service.dart';

import '../models/timezone_model.dart';

class SettingsProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _isAutoTimezone = true;
  String _manualTimezoneId = 'WIB';
  List<int> _selectedLeadTimes = [0, 5, 10, 15]; // Default options: 0m, 5m, 10m, 15m
  List<String> _enabledBosses = [
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

  bool get notificationsEnabled => _notificationsEnabled;
  bool get isAutoTimezone => _isAutoTimezone;
  String get manualTimezoneId => _manualTimezoneId;
  List<int> get selectedLeadTimes => List.unmodifiable(_selectedLeadTimes);
  List<String> get enabledBosses => List.unmodifiable(_enabledBosses);

  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyIsAutoTimezone = 'is_auto_timezone';
  static const String _keyManualTimezoneId = 'manual_timezone_id';
  static const String _keySelectedLeadTimes = 'selected_lead_times';
  static const String _keyEnabledBosses = 'enabled_bosses';

  final ScheduleService _scheduleService;
  final NotificationService _notificationService = NotificationService();

  int get activeOffsetMinutes {
    if (_isAutoTimezone) {
      return DateTime.now().timeZoneOffset.inMinutes;
    }
    final option = TimezoneData.availableOptions.firstWhere(
      (opt) => opt.id == _manualTimezoneId,
      orElse: () => TimezoneData.availableOptions.first,
    );
    return option.offsetMinutes;
  }

  String get activeTimezoneCode {
    if (_isAutoTimezone) {
      final minutes = DateTime.now().timeZoneOffset.inMinutes;
      return TimezoneData.getCodeFromOffset(minutes);
    }
    final option = TimezoneData.availableOptions.firstWhere(
      (opt) => opt.id == _manualTimezoneId,
      orElse: () => TimezoneData.availableOptions.first,
    );
    return option.code;
  }

  SettingsProvider(this._scheduleService) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_keyNotificationsEnabled) ?? true;
    _isAutoTimezone = prefs.getBool(_keyIsAutoTimezone) ?? true;
    _manualTimezoneId = prefs.getString(_keyManualTimezoneId) ?? 'WIB';

    final leadTimesString = prefs.getString(_keySelectedLeadTimes);
    if (leadTimesString != null) {
      final List dynamicList = json.decode(leadTimesString);
      _selectedLeadTimes = dynamicList.cast<int>();
    }

    final bossesString = prefs.getString(_keyEnabledBosses);
    if (bossesString != null) {
      final List dynamicList = json.decode(bossesString);
      _enabledBosses = dynamicList.cast<String>();
    }

    notifyListeners();
    updateScheduledNotifications();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, value);
    notifyListeners();
    updateScheduledNotifications();
  }

  Future<void> toggleLeadTime(int minutes) async {
    if (_selectedLeadTimes.contains(minutes)) {
      _selectedLeadTimes.remove(minutes);
    } else {
      _selectedLeadTimes.add(minutes);
    }
    _selectedLeadTimes.sort();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedLeadTimes, json.encode(_selectedLeadTimes));
    notifyListeners();
    updateScheduledNotifications();
  }

  Future<void> toggleBoss(String bossName) async {
    if (_enabledBosses.contains(bossName)) {
      _enabledBosses.remove(bossName);
    } else {
      _enabledBosses.add(bossName);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEnabledBosses, json.encode(_enabledBosses));
    notifyListeners();
    updateScheduledNotifications();
  }

  Future<void> enableAllBosses(bool enable) async {
    if (enable) {
      _enabledBosses = List.from(ScheduleService.allBosses);
    } else {
      _enabledBosses.clear();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEnabledBosses, json.encode(_enabledBosses));
    notifyListeners();
    updateScheduledNotifications();
  }

  Future<void> setAutoTimezone(bool value) async {
    _isAutoTimezone = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsAutoTimezone, value);
    notifyListeners();
    updateScheduledNotifications();
  }

  Future<void> setManualTimezoneId(String timezoneId) async {
    _manualTimezoneId = timezoneId;
    _isAutoTimezone = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsAutoTimezone, false);
    await prefs.setString(_keyManualTimezoneId, timezoneId);
    notifyListeners();
    updateScheduledNotifications();
  }

  Future<void> updateScheduledNotifications() async {
    if (!_notificationsEnabled) {
      await _notificationService.cancelAllNotifications();
      return;
    }

    final upcoming = _scheduleService.getUpcomingSpawns(
      offsetMinutes: activeOffsetMinutes,
      timezoneCode: activeTimezoneCode,
      daysAhead: 7,
      enabledBosses: _enabledBosses,
    );
    await _notificationService.scheduleBossNotifications(
      upcomingSpawns: upcoming,
      leadTimeMinutes: _selectedLeadTimes,
      enabledBosses: _enabledBosses,
    );
  }
}
