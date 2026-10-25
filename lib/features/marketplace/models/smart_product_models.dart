enum ProductApprovalStatus {
  draft,
  submitted,
  documentationIncomplete,
  pendingVerification,
  qualityInspectionRequired,
  approved,
  rejected,
  suspended,
}

enum CertRequirementStatus {
  verified,
  underReview,
  missingRequiredDocument,
  verificationPending,
  notApplicable,
  expiredOrRejected,
}

class ProductBatchModel {
  final String batchNumber;
  final DateTime productionDate;
  final DateTime expiryDate;
  final int quantity;
  final String processingFacility;
  final String inspectionStatus;
  final String labTestReference;

  const ProductBatchModel({
    required this.batchNumber,
    required this.productionDate,
    required this.expiryDate,
    required this.quantity,
    required this.processingFacility,
    this.inspectionStatus = 'Pending Inspection',
    this.labTestReference = '',
  });

  Map<String, dynamic> toJson() => {
        'batchNumber': batchNumber,
        'productionDate': productionDate.toIso8601String(),
        'expiryDate': expiryDate.toIso8601String(),
        'quantity': quantity,
        'processingFacility': processingFacility,
        'inspectionStatus': inspectionStatus,
        'labTestReference': labTestReference,
      };

  factory ProductBatchModel.fromJson(Map<String, dynamic> json) => ProductBatchModel(
        batchNumber: json['batchNumber'] ?? '',
        productionDate: DateTime.tryParse(json['productionDate'] ?? '') ?? DateTime.now(),
        expiryDate: DateTime.tryParse(json['expiryDate'] ?? '') ?? DateTime.now().add(const Duration(days: 365)),
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        processingFacility: json['processingFacility'] ?? '',
        inspectionStatus: json['inspectionStatus'] ?? 'Pending Inspection',
        labTestReference: json['labTestReference'] ?? '',
      );
}

class CertificationRequirementItem {
  final String requirementName;
  final String category;
  final CertRequirementStatus status;
  final String explanation;
  final bool isMandatory;
  final String? uploadedDocName;
  final DateTime? expiryDate;

  const CertificationRequirementItem({
    required this.requirementName,
    required this.category,
    required this.status,
    required this.explanation,
    required this.isMandatory,
    this.uploadedDocName,
    this.expiryDate,
  });

  CertificationRequirementItem copyWith({
    CertRequirementStatus? status,
    String? uploadedDocName,
    DateTime? expiryDate,
  }) {
    return CertificationRequirementItem(
      requirementName: requirementName,
      category: category,
      status: status ?? this.status,
      explanation: explanation,
      isMandatory: isMandatory,
      uploadedDocName: uploadedDocName ?? this.uploadedDocName,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'requirementName': requirementName,
        'category': category,
        'status': status.name,
        'explanation': explanation,
        'isMandatory': isMandatory,
        'uploadedDocName': uploadedDocName,
        'expiryDate': expiryDate?.toIso8601String(),
      };
}

class SmartProductModel {
  final String id;
  final String productName;
  final String category;
  final String subcategory;
  final String description;
  final String brand;
  final String businessName;
  final String country;
  final String state;
  final String district;
  final String city;
  final String pincode;
  final String origin;
  final String productionMethod;
  final String ingredients;
  final String dimensions;
  final int stock;
  final double price;
  final String currency;
  final int minimumOrderQuantity;
  final String packagingDetails;
  final String storageInstructions;
  final String shelfLife;
  final List<String> imagePaths;
  final String primaryImagePath;
  final ProductApprovalStatus approvalStatus;
  final List<ProductBatchModel> batches;
  final List<CertificationRequirementItem> certifications;
  final bool isGiAssociated;
  final String giRegistrationNumber;
  final DateTime updatedAt;

  const SmartProductModel({
    required this.id,
    required this.productName,
    required this.category,
    required this.subcategory,
    required this.description,
    required this.brand,
    required this.businessName,
    required this.country,
    required this.state,
    required this.district,
    required this.city,
    required this.pincode,
    required this.origin,
    required this.productionMethod,
    required this.ingredients,
    required this.dimensions,
    required this.stock,
    required this.price,
    this.currency = 'INR',
    this.minimumOrderQuantity = 1,
    required this.packagingDetails,
    required this.storageInstructions,
    required this.shelfLife,
    this.imagePaths = const [],
    this.primaryImagePath = '',
    this.approvalStatus = ProductApprovalStatus.draft,
    this.batches = const [],
    this.certifications = const [],
    this.isGiAssociated = false,
    this.giRegistrationNumber = '',
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'category': category,
        'subcategory': subcategory,
        'description': description,
        'brand': brand,
        'businessName': businessName,
        'country': country,
        'state': state,
        'district': district,
        'city': city,
        'pincode': pincode,
        'origin': origin,
        'productionMethod': productionMethod,
        'ingredients': ingredients,
        'dimensions': dimensions,
        'stock': stock,
        'price': price,
        'currency': currency,
        'minimumOrderQuantity': minimumOrderQuantity,
        'packagingDetails': packagingDetails,
        'storageInstructions': storageInstructions,
        'shelfLife': shelfLife,
        'imagePaths': imagePaths,
        'primaryImagePath': primaryImagePath,
        'approvalStatus': approvalStatus.name,
        'batches': batches.map((b) => b.toJson()).toList(),
        'certifications': certifications.map((c) => c.toJson()).toList(),
        'isGiAssociated': isGiAssociated,
        'giRegistrationNumber': giRegistrationNumber,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
