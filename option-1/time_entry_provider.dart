import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeEntry {
  final String title;
  final double hours;
  final String date;
  final String project;
  final String task;

  TimeEntry({
    required this.title,
    required this.hours,
    required this.date,
    required this.project,
    required this.task,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'hours': hours,
      'date': date,
      'project': project,
      'task': task,
    };
  }

  factory TimeEntry.fromJson(
    Map<String, dynamic> json,
  ) {
    return TimeEntry(
      title: json['title'] as String,
      hours: (json['hours'] as num).toDouble(),
      date: json['date'] as String,
      project: json['project'] as String,
      task: json['task'] as String,
    );
  }
}

class TimeEntryProvider extends ChangeNotifier {
  static const String _storageKey = 'time_entries';

  // Empty list
  List<TimeEntry> _entries = [];

  List<TimeEntry> get timeEntries =>
      List.unmodifiable(_entries);

  Future<void> loadEntries() async {
    final prefs =
        await SharedPreferences.getInstance();

    final storedData =
        prefs.getString(_storageKey);

    if (storedData == null) {
      _entries = [];
      notifyListeners();
      return;
    }

    final List<dynamic> data =
        jsonDecode(storedData);

    _entries = data
        .map(
          (item) => TimeEntry.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    notifyListeners();
  }

  Future<void> addEntry(
    TimeEntry entry,
  ) async {
    _entries.add(entry);
    await saveEntries();
    notifyListeners();
  }

  Future<void> deleteEntry(
    int index,
  ) async {
    if (index < 0 ||
        index >= _entries.length) {
      return;
    }

    _entries.removeAt(index);
    await saveEntries();
    notifyListeners();
  }

  Future<void> saveEntries() async {
    final prefs =
        await SharedPreferences.getInstance();

    final data = _entries
        .map(
          (entry) => entry.toJson(),
        )
        .toList();

    await prefs.setString(
      _storageKey,
      jsonEncode(data),
    );
  }
}
