import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/checklist.dart';
import '../repositories/checklist_repository.dart';

class ChecklistProvider extends ChangeNotifier {
  ChecklistProvider({ChecklistRepository? repository})
      : _repository = repository ?? ChecklistRepository();

  final ChecklistRepository _repository;
  final List<Checklist> _checklists = [];
  bool _isLoading = false;

  List<Checklist> get all => List.unmodifiable(_checklists);
  bool get isLoading => _isLoading;

  List<Checklist> byStatus(ChecklistStatus status) {
    return _checklists.where((c) => c.status == status).toList();
  }

  Future<void> loadChecklists() async {
    _isLoading = true;
    notifyListeners();
    final stored = await _repository.loadAll();
    _checklists
      ..clear()
      ..addAll(stored);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addChecklist(Checklist checklist) async {
    _checklists.insert(0, checklist);
    notifyListeners();
    await _repository.upsert(checklist, _checklists);
  }

  Future<void> updateChecklist(Checklist checklist) async {
    final index = _checklists.indexWhere((c) => c.id == checklist.id);
    if (index == -1) return;
    _checklists[index] = checklist;
    notifyListeners();
    await _repository.upsert(checklist, _checklists);
  }

  Future<void> deleteChecklist(String id) async {
    _checklists.removeWhere((c) => c.id == id);
    notifyListeners();
    await _repository.delete(id, _checklists);
  }

  String generateId() {
    final now = DateTime.now();
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'CHK-${DateFormat("yyyyMMddHHmmss").format(now)}-$random';
  }
}
