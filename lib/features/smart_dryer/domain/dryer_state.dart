/// Smart Solar Dryer domain: transport + operating states.
library;
enum DryerTransportKind { demo, wifi, ble }
enum DryerState {
  notConnected, ready, preparing, running,
  paused, completed, warning, safetyShutdown, unknown,
}
extension DryerStateX on DryerState {
  String get label {
    switch (this) {
      case DryerState.notConnected: return 'Not Connected';
      case DryerState.ready: return 'Ready';
      case DryerState.preparing: return 'Preparing';
      case DryerState.running: return 'Running';
      case DryerState.paused: return 'Paused';
      case DryerState.completed: return 'Completed';
      case DryerState.warning: return 'Warning';
      case DryerState.safetyShutdown: return 'Safety Shutdown';
      case DryerState.unknown: return 'Unknown';
    }
  }
  static DryerState fromWire(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'ready': return DryerState.ready;
      case 'preparing': return DryerState.preparing;
      case 'running': return DryerState.running;
      case 'paused': return DryerState.paused;
      case 'completed': return DryerState.completed;
      case 'warning': return DryerState.warning;
      case 'safety_shutdown': case 'safetyshutdown':
        return DryerState.safetyShutdown;
      default: return DryerState.unknown;
    }
  }
}
