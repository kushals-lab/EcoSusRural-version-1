/// Dryer access roles mapped onto existing EcoSusRural personas.
library;
enum DryerAccess { viewer, operator, admin }
DryerAccess dryerAccessFor(String roleName) {
  switch (roleName) {
    case 'farmer': return DryerAccess.operator;
    case 'msme': return DryerAccess.operator;
    case 'organization': return DryerAccess.admin;
    case 'artisan': return DryerAccess.viewer;
    case 'buyer': return DryerAccess.viewer;
    default: return DryerAccess.viewer;
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
