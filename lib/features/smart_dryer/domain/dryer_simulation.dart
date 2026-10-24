/// Explicitly simulated tray and water-balance data, separate from real sensors.
library;

class DryerSimulatedTray {
  final int id;
  final bool inserted;
  final bool loaded;
  final String cropName;
  final double massKg;
  final double? moisturePct;
  final double progress;
  const DryerSimulatedTray({required this.id, required this.inserted, required this.loaded,
    required this.cropName, required this.massKg, this.moisturePct, required this.progress});

  factory DryerSimulatedTray.fromMap(Map<String, dynamic> m) => DryerSimulatedTray(
    id: (m['id'] as num).toInt(), inserted: m['inserted'] == true, loaded: m['loaded'] == true,
    cropName: m['cropName']?.toString() ?? 'Empty', massKg: (m['massKg'] as num?)?.toDouble() ?? 0,
    moisturePct: (m['moisturePct'] as num?)?.toDouble(), progress: (m['progress'] as num?)?.toDouble() ?? 0);

  Map<String, dynamic> toMap() => {'id': id, 'inserted': inserted, 'loaded': loaded,
    'cropName': cropName, 'massKg': massKg, 'moisturePct': moisturePct, 'progress': progress};
}

class DryerSimulationSnapshot {
  final bool doorOpen;
  final double sunlight;
  final double waterRemovedKg;
  final double currentMassKg;
  final double? moisturePct;
  final double evapKgPerHour;
  final int simulationSpeed;
  final int elapsedSimulatedSec;
  final List<DryerSimulatedTray> trays;
  const DryerSimulationSnapshot({required this.doorOpen, required this.sunlight,
    required this.waterRemovedKg, required this.currentMassKg, this.moisturePct,
    required this.evapKgPerHour, required this.simulationSpeed, required this.elapsedSimulatedSec, required this.trays});

  factory DryerSimulationSnapshot.fromMap(Map<String, dynamic> m) => DryerSimulationSnapshot(
    doorOpen: m['doorOpen'] == true, sunlight: (m['sunlight'] as num?)?.toDouble() ?? 0,
    waterRemovedKg: (m['waterRemovedKg'] as num?)?.toDouble() ?? 0,
    currentMassKg: (m['currentMassKg'] as num?)?.toDouble() ?? 0,
    moisturePct: (m['moisturePct'] as num?)?.toDouble(), evapKgPerHour: (m['evapKgPerHour'] as num?)?.toDouble() ?? 0,
    simulationSpeed: (m['simulationSpeed'] as num?)?.toInt() ?? 1,
    elapsedSimulatedSec: (m['elapsedSimulatedSec'] as num?)?.toInt() ?? 0,
    trays: (m['trays'] as List? ?? []).whereType<Map>().map((e) => DryerSimulatedTray.fromMap(Map<String, dynamic>.from(e))).toList(growable: false));

  Map<String, dynamic> toMap() => {'doorOpen': doorOpen, 'sunlight': sunlight,
    'waterRemovedKg': waterRemovedKg, 'currentMassKg': currentMassKg, 'moisturePct': moisturePct,
    'evapKgPerHour': evapKgPerHour, 'simulationSpeed': simulationSpeed,
    'elapsedSimulatedSec': elapsedSimulatedSec, 'trays': trays.map((e) => e.toMap()).toList()};
}
