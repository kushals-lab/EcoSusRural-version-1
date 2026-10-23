/// Dryer access roles mapped onto existing EcoSusRural personas.
library;
import '../../../core/rbac/rbac.dart';
enum DryerAccess { viewer, operator, admin }
DryerAccess dryerAccessFor(EcoRole role) {
  switch (role) {
    case EcoRole.farmer: return DryerAccess.operator;
    case EcoRole.msme: return DryerAccess.operator;
    case EcoRole.organization: return DryerAccess.admin;
    case EcoRole.artisan: return DryerAccess.viewer;
    case EcoRole.buyer: return DryerAccess.viewer;
  }
}
extension DryerAccessX on DryerAccess {
  bool get canView => true;
  bool get canOperate => this != DryerAccess.viewer;
  bool get canConfigure => this == DryerAccess.admin;
  String get label {
    switch (this) {
      case DryerAccess.viewer: return 'Viewer';
      case DryerAccess.operator: return 'Operator';
      case DryerAccess.admin: return 'Administrator';
    }
  }
}
