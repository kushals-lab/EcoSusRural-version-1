/// Alerts + device identity. Pure Dart.
library;
import 'dryer_state.dart';
class DryerAlert {
  final String id;
  final String code;
  final String message;
  final DateTime raisedAt;
  final bool fromController;
  const DryerAlert({
    required this.id, required this.code, required this.message,
    required this.raisedAt, this.fromController = false,
  });
  Map<String, dynamic> toMap() => {
    'id': id, 'code': code, 'message': message,
    'raisedAt': raisedAt.toIso8601String(), 'fromController': fromController,
  };
  factory DryerAlert.fromMap(Map<String, dynamic> m) => DryerAlert(
    id: '${m['id']}', code: '${m['code']}',
    message: '${m['message']}',
    raisedAt: DateTime.tryParse('${m['raisedAt']}') ?? DateTime.now(),
    fromController: m['fromController'] == true,
  );
}
class DryerDeviceInfo {
  final String deviceId;
  final String name;
  final DryerTransportKind transport;
  final String? address;
  const DryerDeviceInfo({
    required this.deviceId, required this.name,
    required this.transport, this.address,
  });
}
