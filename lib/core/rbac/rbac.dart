/// EcoSusRural Role-Based Access Control (RBAC).
///
/// Defines the platform account personas, the category-restricted modules and
/// the universal services available to everyone, as specified in the
/// EcoSusRural Architecture & Master Specification Blueprint (section 3).
library;

import 'package:flutter/material.dart';

/// Primary account categories supported by EcoSusRural.
enum EcoRole { buyer, seller, organization }

extension EcoRoleX on EcoRole {
  /// Human-readable label for the role.
  String get label {
    switch (this) {
      case EcoRole.buyer:
        return 'Buyer';
      case EcoRole.seller:
        return 'Seller';
      case EcoRole.organization:
        return 'Organization';
    }
  }

  /// Short key used for storage and API payloads.
  String get key {
    switch (this) {
      case EcoRole.buyer:
        return 'buyer';
      case EcoRole.seller:
        return 'seller';
      case EcoRole.organization:
        return 'organization';
    }
  }

  /// Whether the account has seller-equivalent capabilities (seller or org).
  bool get isSellerEquivalent {
    switch (this) {
      case EcoRole.buyer:
        return false;
      case EcoRole.seller:
      case EcoRole.organization:
        return true;
    }
  }

  /// Whether this role may see the "Upgrade to Seller" entry point.
  /// Only buyers may see it; sellers and organizations must never see it.
  bool get maySeeUpgradeToSeller {
    switch (this) {
      case EcoRole.buyer:
        return true;
      case EcoRole.seller:
      case EcoRole.organization:
        return false;
    }
  }

  IconData get icon {
    switch (this) {
      case EcoRole.buyer:
        return Icons.shopping_bag_outlined;
      case EcoRole.seller:
        return Icons.storefront;
      case EcoRole.organization:
        return Icons.groups_2_outlined;
    }
  }

  Color get color {
    switch (this) {
      case EcoRole.buyer:
        return const Color(0xFF138808);
      case EcoRole.seller:
        return const Color(0xFF000080);
      case EcoRole.organization:
        return const Color(0xFF993300);
    }
  }
}

/// Identifier keys for the category-restricted modules.
enum RestrictedModule { soilLab, b2bDesk, giRegistry, orgConsole }

extension RestrictedModuleX on RestrictedModule {
  String get title {
    switch (this) {
      case RestrictedModule.soilLab:
        return 'Farmer Soil Lab & Agronomy';
      case RestrictedModule.b2bDesk:
        return 'MSME B2B Wholesale & Employee Desk';
      case RestrictedModule.giRegistry:
        return 'Artisan Authenticity & GI Tag Registry';
      case RestrictedModule.orgConsole:
        return 'Organization 30-Seat Admin Dashboard';
    }
  }

  String get subtitle {
    switch (this) {
      case RestrictedModule.soilLab:
        return 'Soil health metrics, AI fertilizer calculator, crop disease scanner & seasonal schedule.';
      case RestrictedModule.b2bDesk:
        return 'Bulk order bidding, negotiation desk, employee metrics & compliance vault.';
      case RestrictedModule.giRegistry:
        return 'Provenance register, GI verification, heritage gallery & bespoke order board.';
      case RestrictedModule.orgConsole:
        return '30-seat member allocation, aggregated inventory, benefit logs & governance suite.';
    }
  }

  IconData get icon {
    switch (this) {
      case RestrictedModule.soilLab:
        return Icons.grass;
      case RestrictedModule.b2bDesk:
        return Icons.factory_outlined;
      case RestrictedModule.giRegistry:
        return Icons.verified_outlined;
      case RestrictedModule.orgConsole:
        return Icons.admin_panel_settings_outlined;
    }
  }

  Color get color {
    switch (this) {
      case RestrictedModule.soilLab:
        return const Color(0xFF2E7D32);
      case RestrictedModule.b2bDesk:
        return const Color(0xFF1A73E8);
      case RestrictedModule.giRegistry:
        return const Color(0xFF6A1B9A);
      case RestrictedModule.orgConsole:
        return const Color(0xFFB8860B);
    }
  }

  /// Roles allowed to open this module.
  List<EcoRole> get allowedRoles {
    switch (this) {
      case RestrictedModule.soilLab:
        return const [EcoRole.seller, EcoRole.organization];
      case RestrictedModule.b2bDesk:
        return const [EcoRole.seller, EcoRole.organization];
      case RestrictedModule.giRegistry:
        return const [EcoRole.seller, EcoRole.organization];
      case RestrictedModule.orgConsole:
        return const [EcoRole.organization];
    }
  }
}

/// Permission entries used for centralized enforcement.
/// Each [Permission] maps to a capability the app gates behind a role.
enum Permission {
  viewMarketplace,
  purchaseProducts,
  manageOrders,
  makePayments,
  trackDeliveries,
  viewBasicWeather,
  viewMultilingualContent,
  useFreeRuralIntelligenceAI,
  purchaseAISubscription,
  useUnlimitedNavigationAssistance,
  useRemindersAlarmsTimersClocks,
  accessEducationalPublicServices,
  upgradeToSeller,

  manageSellerInformation,
  listAndManageProducts,
  accessSellerDashboard,
  manageInventoryAndOrders,
  accessMandiPrices,
  accessAgriculturalWeather,

  bulkProductListings,
  bulkOrderManagement,
  organizationDashboard,
  multiUserManagement,
  higherProductLimits,
  businessIntelligenceTools,
}

extension PermissionX on Permission {
  /// Roles granted this permission by default.
  List<EcoRole> get allowedRoles {
    switch (this) {
      // Universal — every role
      case Permission.viewMarketplace:
      case Permission.purchaseProducts:
      case Permission.manageOrders:
      case Permission.makePayments:
      case Permission.trackDeliveries:
      case Permission.viewBasicWeather:
      case Permission.viewMultilingualContent:
      case Permission.useFreeRuralIntelligenceAI:
      case Permission.useUnlimitedNavigationAssistance:
      case Permission.useRemindersAlarmsTimersClocks:
      case Permission.accessEducationalPublicServices:
        return const [EcoRole.buyer, EcoRole.seller, EcoRole.organization];

      case Permission.purchaseAISubscription:
        return const [EcoRole.buyer, EcoRole.seller, EcoRole.organization];

      case Permission.upgradeToSeller:
        return const [EcoRole.buyer];

      // Seller-equivalent
      case Permission.manageSellerInformation:
      case Permission.listAndManageProducts:
      case Permission.accessSellerDashboard:
      case Permission.manageInventoryAndOrders:
      case Permission.accessMandiPrices:
      case Permission.accessAgriculturalWeather:
        return const [EcoRole.seller, EcoRole.organization];

      // Organization only
      case Permission.bulkProductListings:
      case Permission.bulkOrderManagement:
      case Permission.organizationDashboard:
      case Permission.multiUserManagement:
      case Permission.higherProductLimits:
      case Permission.businessIntelligenceTools:
        return const [EcoRole.organization];
    }
  }

  /// Whether [role] is granted this permission.
  bool allows(EcoRole role) => allowedRoles.contains(role);
}

/// Universal services available to EVERY persona (buyers included).
const List<(String, IconData, Color, String)> kUniversalServices = [
  ('EcoSusRural AI Assistant', Icons.smart_toy, Color(0xFFF57C00), 'Everyone'),
  ('Marketplace', Icons.storefront, Color(0xFF000080), 'Everyone'),
  ('Circular Economy', Icons.recycling, Color(0xFF138808), 'Everyone'),
  ('EcoBharatPay', Icons.account_balance_wallet, Color(0xFF000080), 'Everyone'),
  ('Expert Advice', Icons.support_agent, Color(0xFF00695C), 'Everyone'),
  ('Schemes, Loans, Insurance & Scholarships', Icons.account_balance, Color(0xFF138808), 'Everyone'),
  ('Smart Solar Dryer', Icons.solar_power, Color(0xFFE65100), 'Everyone'),
];

/// Check whether a role may access a restricted module.
bool moduleAllowed(EcoRole role, RestrictedModule module) {
  return module.allowedRoles.contains(role);
}

/// Check whether a role holds a permission.
bool permissionAllowed(EcoRole role, Permission permission) {
  return permission.allows(role);
}
