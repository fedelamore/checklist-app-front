import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/checklist.dart';

class ChecklistRepository {
  ChecklistRepository({SharedPreferences? preferences}) : _preferences = preferences;

  static const _storageKey = 'checklists';
  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<List<Checklist>> loadAll() async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(_storageKey) ?? <String>[];
    return raw
        .map((item) => Checklist.fromMap(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<Checklist> checklists) async {
    final prefs = await _prefs;
    final payload =
        checklists.map((checklist) => jsonEncode(checklist.toMap())).toList();
    await prefs.setStringList(_storageKey, payload);
  }

  Future<void> upsert(Checklist checklist, List<Checklist> current) async {
    final updated = [
      checklist,
      ...current.where((item) => item.id != checklist.id),
    ];
    await saveAll(updated);
  }

  Future<void> delete(String id, List<Checklist> current) async {
    final updated = current.where((item) => item.id != id).toList();
    await saveAll(updated);
  }
}
