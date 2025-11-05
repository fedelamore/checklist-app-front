import 'package:checklist_app/models/checklist.dart';
import 'package:checklist_app/providers/checklist_provider.dart';
import 'package:checklist_app/repositories/checklist_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class InMemoryChecklistRepository extends ChecklistRepository {
  final List<Checklist> _storage = [];

  @override
  Future<List<Checklist>> loadAll() async => List.unmodifiable(_storage);

  @override
  Future<void> saveAll(List<Checklist> checklists) async {
    _storage
      ..clear()
      ..addAll(checklists);
  }

  @override
  Future<void> upsert(Checklist checklist, List<Checklist> current) async {
    final index = _storage.indexWhere((c) => c.id == checklist.id);
    if (index >= 0) {
      _storage[index] = checklist;
    } else {
      _storage.add(checklist);
    }
  }

  @override
  Future<void> delete(String id, List<Checklist> current) async {
    _storage.removeWhere((c) => c.id == id);
  }
}

void main() {
  group('ChecklistProvider', () {
    late ChecklistProvider provider;
    late InMemoryChecklistRepository repository;

    setUp(() {
      repository = InMemoryChecklistRepository();
      provider = ChecklistProvider(repository: repository);
    });

    test('adiciona checklist e atualiza estado', () async {
      final checklist = Checklist(
        id: 'CHK-1',
        driverName: 'João Motorista',
        driverDocument: '123456789',
        vehiclePlate: 'ABC1234',
        odometer: 1000,
        odometerPhotoPath: '/tmp/odo.jpg',
        evaluation: '😀 Excelente',
        photoPaths: const ['/tmp/photo1.jpg'],
        signature: 'signature-data',
        createdAt: DateTime(2023, 8, 10),
        notes: 'Tudo certo',
      );

      await provider.addChecklist(checklist);

      expect(provider.all, hasLength(1));
      expect(provider.byStatus(ChecklistStatus.pending), hasLength(1));
      expect(repository._storage, hasLength(1));
    });

    test('atualiza status e remove checklist', () async {
      final checklist = Checklist(
        id: 'CHK-2',
        driverName: 'Maria Motorista',
        driverDocument: '987654321',
        vehiclePlate: 'XYZ9876',
        odometer: 2000,
        odometerPhotoPath: '/tmp/odo2.jpg',
        evaluation: '😐 Ok',
        photoPaths: const ['/tmp/photo2.jpg'],
        signature: 'signature-data',
        createdAt: DateTime(2023, 8, 11),
      );

      await provider.addChecklist(checklist);

      final updated = checklist.copyWith(status: ChecklistStatus.completed);
      await provider.updateChecklist(updated);

      expect(provider.byStatus(ChecklistStatus.completed), hasLength(1));

      await provider.deleteChecklist(checklist.id);
      expect(provider.all, isEmpty);
    });
  });
}
