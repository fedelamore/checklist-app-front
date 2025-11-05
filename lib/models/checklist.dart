import 'dart:convert';

enum ChecklistStatus { pending, completed }

enum SyncStatus { localOnly, syncing, synced }

class Checklist {
  Checklist({
    required this.id,
    required this.driverName,
    required this.driverDocument,
    required this.vehiclePlate,
    required this.odometer,
    required this.odometerPhotoPath,
    required this.evaluation,
    required this.photoPaths,
    required this.signature,
    required this.createdAt,
    this.notes,
    this.status = ChecklistStatus.pending,
    this.syncStatus = SyncStatus.localOnly,
  });

  final String id;
  final String driverName;
  final String driverDocument;
  final String vehiclePlate;
  final int odometer;
  final String odometerPhotoPath;
  final String evaluation;
  final List<String> photoPaths;
  final String signature;
  final DateTime createdAt;
  final String? notes;
  ChecklistStatus status;
  SyncStatus syncStatus;

  bool get isComplete => status == ChecklistStatus.completed;

  Checklist copyWith({
    ChecklistStatus? status,
    SyncStatus? syncStatus,
    String? notes,
  }) {
    return Checklist(
      id: id,
      driverName: driverName,
      driverDocument: driverDocument,
      vehiclePlate: vehiclePlate,
      odometer: odometer,
      odometerPhotoPath: odometerPhotoPath,
      evaluation: evaluation,
      photoPaths: List<String>.from(photoPaths),
      signature: signature,
      createdAt: createdAt,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driverName': driverName,
      'driverDocument': driverDocument,
      'vehiclePlate': vehiclePlate,
      'odometer': odometer,
      'odometerPhotoPath': odometerPhotoPath,
      'evaluation': evaluation,
      'photoPaths': photoPaths,
      'signature': signature,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'status': status.name,
      'syncStatus': syncStatus.name,
    };
  }

  factory Checklist.fromMap(Map<String, dynamic> map) {
    return Checklist(
      id: map['id'] as String,
      driverName: map['driverName'] as String,
      driverDocument: map['driverDocument'] as String,
      vehiclePlate: map['vehiclePlate'] as String,
      odometer: (map['odometer'] as num).toInt(),
      odometerPhotoPath: map['odometerPhotoPath'] as String,
      evaluation: map['evaluation'] as String,
      photoPaths: (map['photoPaths'] as List<dynamic>).cast<String>(),
      signature: map['signature'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      notes: map['notes'] as String?,
      status: ChecklistStatus.values.byName(map['status'] as String),
      syncStatus: SyncStatus.values.byName(map['syncStatus'] as String),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Checklist.fromJson(String source) =>
      Checklist.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
