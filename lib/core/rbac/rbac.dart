/// EcoSusRural Role-Based Access Control (RBAC).
///
/// Defines the platform account personas, the category-restricted modules and
/// the universal services available to everyone, as specified in the
/// EcoSusRural Architecture & Master Specification Blueprint (section 3).
library;

import 'package:flutter/material.dart';

/// Platform account personas.
enum EcoRole { buyer, farmer, msme, artisan, organization }

extension EcoRoleX on EcoRole {
  String get label {
    switch (this) {
      case EcoRole.buyer:
        return 'Buyer';
      case EcoRole.farmer:
        return 'Farmer';
      case EcoRole.msme:
        return 'MSME';
      case EcoRole.artisan:
        return 'Artisan / Craftsman';
      case EcoRole.organization:
        return 'Organization';
    }
  }

  /// The mandatory identity metric each persona must provide.
  String get identityMetric {
    switch (this) {
      case EcoRole.buyer:
        return 'Location & consumer profile';
      case EcoRole.farmer:
        return 'Land holding (acres), crop type, soil region';
      case EcoRole.msme:
        return 'employee_count (mandatory number)';
      case EcoRole.artisan:
        return 'Craft cluster ID & GI-tag number';
      case EcoRole.organization:
        return 'member_count (mandatory number)';
    }
  }

  IconData get icon {
    switch (this) {
      case EcoRole.buyer:
        return Icons.shopping_bag_outlined;
      case EcoRole.farmer:
        return Icons.agriculture;
      case EcoRole.msme:
        return Icons.factory_outlined;
      case EcoRole.artisan:
        return Icons.handyman_outlined;
      case EcoRole.organization:
        return Icons.groups_2_outlined;
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

  /// The only persona allowed to open this module.
  EcoRole get allowedRole {
    switch (this) {
      case RestrictedModule.soilLab:
        return EcoRole.farmer;
      case RestrictedModule.b2bDesk:
        return EcoRole.msme;
      case RestrictedModule.giRegistry:
        return EcoRole.artisan;
      case RestrictedModule.orgConsole:
        return EcoRole.organization;
    }
  }
}

/// Universal services available to EVERY persona (buyers included).
const List<(String, IconData, Color, String)> kUniversalServices = [
  ('EcoSusRural AI Assistant', Icons.smart_toy, Color(0xFFF57C00), 'Everyone'),
  ('Marketplace', Icons.storefront, Color(0xFF1565C0), 'Everyone'),
  ('Circular Economy', Icons.recycling, Color(0xFF2E7D32), 'Everyone'),
  ('EcoBharatPay', Icons.account_balance_wallet, Color(0xFF1A73E8), 'Everyone'),
  ('Expert Advice', Icons.support_agent, Color(0xFF00695C), 'Everyone'),
  ('Schemes, Loans, Insurance & Scholarships', Icons.account_balance, Color(0xFF558B2F), 'Everyone'),
  ('Smart Solar Dryer', Icons.solar_power, Color(0xFFE65100), 'Everyone'),
];
