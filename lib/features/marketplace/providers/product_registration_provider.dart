import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/smart_product_models.dart';

class ProductRegistrationNotifier extends StateNotifier<List<SmartProductModel>> {
  ProductRegistrationNotifier() : super([]) {
    _loadDrafts();
  }

  static const String _storageKey = 'ecosus_smart_product_drafts_v1';

  Future<void> _loadDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final List decoded = jsonDecode(raw);
        final list = decoded.map((item) {
          final map = Map<String, dynamic>.from(item);
          return SmartProductModel(
            id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            productName: map['productName'] ?? '',
            category: map['category'] ?? 'Dried fruits',
            subcategory: map['subcategory'] ?? '',
            description: map['description'] ?? '',
            brand: map['brand'] ?? '',
            businessName: map['businessName'] ?? '',
            country: map['country'] ?? 'India',
            state: map['state'] ?? '',
            district: map['district'] ?? '',
            city: map['city'] ?? '',
            pincode: map['pincode'] ?? '',
            origin: map['origin'] ?? '',
            productionMethod: map['productionMethod'] ?? '',
            ingredients: map['ingredients'] ?? '',
            dimensions: map['dimensions'] ?? '',
            stock: (map['stock'] as num?)?.toInt() ?? 100,
            price: (map['price'] as num?)?.toDouble() ?? 499.0,
            currency: map['currency'] ?? 'INR',
            minimumOrderQuantity: (map['minimumOrderQuantity'] as num?)?.toInt() ?? 1,
            packagingDetails: map['packagingDetails'] ?? '',
            storageInstructions: map['storageInstructions'] ?? '',
            shelfLife: map['shelfLife'] ?? '',
            imagePaths: List<String>.from(map['imagePaths'] ?? []),
            primaryImagePath: map['primaryImagePath'] ?? '',
            approvalStatus: ProductApprovalStatus.values.firstWhere(
              (e) => e.name == map['approvalStatus'],
              orElse: () => ProductApprovalStatus.draft,
            ),
            batches: (map['batches'] as List? ?? []).map((b) => ProductBatchModel.fromJson(b)).toList(),
            certifications: (map['certifications'] as List? ?? []).map((c) => CertificationRequirementItem(
              requirementName: c['requirementName'] ?? '',
              category: c['category'] ?? '',
              status: CertRequirementStatus.values.firstWhere((s) => s.name == c['status'], orElse: () => CertRequirementStatus.notApplicable),
              explanation: c['explanation'] ?? '',
              isMandatory: c['isMandatory'] ?? false,
              uploadedDocName: c['uploadedDocName'],
              expiryDate: DateTime.tryParse(c['expiryDate'] ?? ''),
            )).toList(),
            isGiAssociated: map['isGiAssociated'] ?? false,
            giRegistrationNumber: map['giRegistrationNumber'] ?? '',
            updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
          );
        }).toList();
        state = list;
      }
    } catch (_) {}
  }

  Future<void> saveDraft(SmartProductModel product) async {
    final existingIndex = state.indexWhere((p) => p.id == product.id);
    List<SmartProductModel> updated;
    if (existingIndex >= 0) {
      updated = [...state];
      updated[existingIndex] = product;
    } else {
      updated = [product, ...state];
    }
    state = updated;
    await _persist();
  }

  Future<void> deleteProduct(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(state.map((p) => p.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  /// Automatically generate dynamic certification requirements based on product category & claims
  List<CertificationRequirementItem> generateRequirementsForCategory(String category, bool isOrganic, bool isGi) {
    final list = <CertificationRequirementItem>[];

    if (category.toLowerCase().contains('dried') || category.toLowerCase().contains('herb') || category.toLowerCase().contains('vegetable') || category.toLowerCase().contains('organic')) {
      list.add(const CertificationRequirementItem(
        requirementName: 'FSSAI Registration / License',
        category: 'Food Safety',
        status: CertRequirementStatus.missingRequiredDocument,
        explanation: 'Mandatory statutory food safety registration for edible food products and agricultural processing under FSS Act.',
        isMandatory: true,
      ));
      list.add(const CertificationRequirementItem(
        requirementName: 'Food Safety Testing Report',
        category: 'Quality Lab Test',
        status: CertRequirementStatus.verificationPending,
        explanation: 'Laboratory test report ensuring absence of heavy metals, pesticide residues, and moisture compliance.',
        isMandatory: true,
      ));
      list.add(const CertificationRequirementItem(
        requirementName: 'Nutritional & Ingredient Labeling Compliance',
        category: 'Packaging',
        status: CertRequirementStatus.underReview,
        explanation: 'Package labeling showing manufacturing date, net weight, ingredients, and FSSAI logo.',
        isMandatory: true,
      ));
    }

    if (isOrganic) {
      list.add(const CertificationRequirementItem(
        requirementName: 'NPOP / PGS-India Organic Certification',
        category: 'Organic Standards',
        status: CertRequirementStatus.missingRequiredDocument,
        explanation: 'Required to market and label any agricultural or processed product as certified organic in domestic and export markets.',
        isMandatory: true,
      ));
    }

    if (isGi) {
      list.add(const CertificationRequirementItem(
        requirementName: 'GI Authorized-User Evidence',
        category: 'Geographical Indication',
        status: CertRequirementStatus.missingRequiredDocument,
        explanation: 'Official Geographical Indication (GI) registry certificate demonstrating authorized user status for the registered GI commodity.',
        isMandatory: true,
      ));
    }

    if (category.toLowerCase().contains('handicraft') || category.toLowerCase().contains('handloom')) {
      list.add(const CertificationRequirementItem(
        requirementName: 'Artisan / Weaver Identity Proof & Authenticity Record',
        category: 'Craft Authenticity',
        status: CertRequirementStatus.verified,
        explanation: 'Artisan ID card or weaver cluster registration confirming genuine handmade craft origin.',
        isMandatory: true,
      ));
    }

    if (category.toLowerCase().contains('compost') || category.toLowerCase().contains('vermicompost')) {
      list.add(const CertificationRequirementItem(
        requirementName: 'Fertiliser (Control) Order (FCO) Quality Standard',
        category: 'Regulatory Standards',
        status: CertRequirementStatus.missingRequiredDocument,
        explanation: 'Mandatory quality assay and nutrient content report complying with FCO standards for soil inputs.',
        isMandatory: true,
      ));
    }

    if (list.isEmpty) {
      list.add(const CertificationRequirementItem(
        requirementName: 'Business Registration / MSME Udyam Certificate',
        category: 'General Compliance',
        status: CertRequirementStatus.verified,
        explanation: 'Basic enterprise establishment verification.',
        isMandatory: false,
      ));
    }

    return list;
  }
}

final productRegistrationProvider = StateNotifierProvider<ProductRegistrationNotifier, List<SmartProductModel>>((ref) {
  return ProductRegistrationNotifier();
});
