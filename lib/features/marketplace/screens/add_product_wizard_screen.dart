import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/smart_product_models.dart';
import '../providers/product_registration_provider.dart';

class AddProductWizardScreen extends ConsumerStatefulWidget {
  final SmartProductModel? editProduct;
  const AddProductWizardScreen({super.key, this.editProduct});

  @override
  ConsumerState<AddProductWizardScreen> createState() => _AddProductWizardScreenState();
}

class _AddProductWizardScreenState extends ConsumerState<AddProductWizardScreen> {
  static const Color _primaryGreen = Color(0xFF1B4D3E);
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers for Step 1 & 3
  late final TextEditingController _nameCtrl;
  late final TextEditingController _subcatCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _businessCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _districtCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _pincodeCtrl;
  late final TextEditingController _originCtrl;
  late final TextEditingController _methodCtrl;
  late final TextEditingController _ingredientsCtrl;
  late final TextEditingController _dimensionsCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _moqCtrl;
  late final TextEditingController _packagingCtrl;
  late final TextEditingController _storageCtrl;
  late final TextEditingController _shelfLifeCtrl;
  late final TextEditingController _giNumCtrl;

  String _selectedCategory = 'Dried fruits';
  bool _isOrganic = false;
  bool _isGi = false;
  final List<String> _images = [];
  String _primaryImage = '';
  final List<ProductBatchModel> _batches = [];
  List<CertificationRequirementItem> _certifications = [];

  final List<String> _categories = [
    'Dried fruits',
    'Dried vegetables',
    'Dried herbs',
    'Organic and conventional agricultural products',
    'Compost and vermicompost',
    'Handicrafts',
    'Handloom products',
    'GI-associated products',
    'Rural MSME products',
    'Natural fibre products',
    'Recycled and sustainable goods',
    'Community hub products',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.editProduct;
    _nameCtrl = TextEditingController(text: p?.productName ?? '');
    _subcatCtrl = TextEditingController(text: p?.subcategory ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _brandCtrl = TextEditingController(text: p?.brand ?? '');
    _businessCtrl = TextEditingController(text: p?.businessName ?? 'EcoSusRural Artisan Hub');
    _countryCtrl = TextEditingController(text: p?.country ?? 'India');
    _stateCtrl = TextEditingController(text: p?.state ?? 'Uttar Pradesh');
    _districtCtrl = TextEditingController(text: p?.district ?? '');
    _cityCtrl = TextEditingController(text: p?.city ?? '');
    _pincodeCtrl = TextEditingController(text: p?.pincode ?? '');
    _originCtrl = TextEditingController(text: p?.origin ?? '');
    _methodCtrl = TextEditingController(text: p?.productionMethod ?? '');
    _ingredientsCtrl = TextEditingController(text: p?.ingredients ?? '');
    _dimensionsCtrl = TextEditingController(text: p?.dimensions ?? '500g pouch');
    _stockCtrl = TextEditingController(text: p?.stock.toString() ?? '150');
    _priceCtrl = TextEditingController(text: p?.price.toString() ?? '450');
    _moqCtrl = TextEditingController(text: p?.minimumOrderQuantity.toString() ?? '1');
    _packagingCtrl = TextEditingController(text: p?.packagingDetails ?? 'Vacuum sealed foil pouch');
    _storageCtrl = TextEditingController(text: p?.storageInstructions ?? 'Store in cool dry place');
    _shelfLifeCtrl = TextEditingController(text: p?.shelfLife ?? '12 months');
    _giNumCtrl = TextEditingController(text: p?.giRegistrationNumber ?? '');

    if (p != null) {
      _selectedCategory = p.category;
      _isOrganic = p.category.toLowerCase().contains('organic');
      _isGi = p.isGiAssociated;
      _images.addAll(p.imagePaths);
      _primaryImage = p.primaryImagePath;
      _batches.addAll(p.batches);
      _certifications = p.certifications;
    } else {
      _images.add('https://picsum.photos/seed/ecosusrural1/400/400');
      _primaryImage = _images.first;
      _certifications = ref.read(productRegistrationProvider.notifier).generateRequirementsForCategory(_selectedCategory, _isOrganic, _isGi);
      _batches.add(ProductBatchModel(
        batchNumber: 'BATCH-${DateTime.now().year}-01',
        productionDate: DateTime.now().subtract(const Duration(days: 10)),
        expiryDate: DateTime.now().add(const Duration(days: 355)),
        quantity: 150,
        processingFacility: 'Community Hub Unit A',
      ));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _subcatCtrl.dispose();
    _descCtrl.dispose();
    _brandCtrl.dispose();
    _businessCtrl.dispose();
    _countryCtrl.dispose();
    _stateCtrl.dispose();
    _districtCtrl.dispose();
    _cityCtrl.dispose();
    _pincodeCtrl.dispose();
    _originCtrl.dispose();
    _methodCtrl.dispose();
    _ingredientsCtrl.dispose();
    _dimensionsCtrl.dispose();
    _stockCtrl.dispose();
    _priceCtrl.dispose();
    _moqCtrl.dispose();
    _packagingCtrl.dispose();
    _storageCtrl.dispose();
    _shelfLifeCtrl.dispose();
    _giNumCtrl.dispose();
    super.dispose();
  }

  void _addPresetImage() {
    if (_images.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 10 images allowed per product.')));
      return;
    }
    final seed = DateTime.now().millisecondsSinceEpoch;
    final url = 'https://picsum.photos/seed/$seed/400/400';
    setState(() {
      _images.add(url);
      if (_primaryImage.isEmpty) {
        _primaryImage = url;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product photograph added successfully.')));
  }

  void _updateCertifications() {
    setState(() {
      _certifications = ref.read(productRegistrationProvider.notifier).generateRequirementsForCategory(_selectedCategory, _isOrganic, _isGi);
    });
  }

  SmartProductModel _buildProductObject(ProductApprovalStatus status) {
    return SmartProductModel(
      id: widget.editProduct?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      productName: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'New Rural Product',
      category: _selectedCategory,
      subcategory: _subcatCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      businessName: _businessCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      origin: _originCtrl.text.trim(),
      productionMethod: _methodCtrl.text.trim(),
      ingredients: _ingredientsCtrl.text.trim(),
      dimensions: _dimensionsCtrl.text.trim(),
      stock: int.tryParse(_stockCtrl.text.trim()) ?? 100,
      price: double.tryParse(_priceCtrl.text.trim()) ?? 499.0,
      minimumOrderQuantity: int.tryParse(_moqCtrl.text.trim()) ?? 1,
      packagingDetails: _packagingCtrl.text.trim(),
      storageInstructions: _storageCtrl.text.trim(),
      shelfLife: _shelfLifeCtrl.text.trim(),
      imagePaths: _images,
      primaryImagePath: _primaryImage.isNotEmpty ? _primaryImage : (_images.isNotEmpty ? _images.first : ''),
      approvalStatus: status,
      batches: _batches,
      certifications: _certifications,
      isGiAssociated: _isGi,
      giRegistrationNumber: _giNumCtrl.text.trim(),
      updatedAt: DateTime.now(),
    );
  }

  void _saveAsDraft() async {
    final product = _buildProductObject(ProductApprovalStatus.draft);
    await ref.read(productRegistrationProvider.notifier).saveDraft(product);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product draft saved locally (offline-first).')));
    Navigator.pop(context);
  }

  void _submitForApproval() async {
    if (_nameCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in required product name and price.')));
      setState(() => _currentStep = 0);
      return;
    }
    final product = _buildProductObject(ProductApprovalStatus.submitted);
    await ref.read(productRegistrationProvider.notifier).saveDraft(product);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [Icon(Icons.verified_user, color: Color(0xFF1B4D3E)), SizedBox(width: 8), Text('Submitted for Approval')]),
        content: const Text('Your product has been submitted successfully along with batch and certification details. It is pending quality-control inspection and admin approval.'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _buildStep1Info(),
      _buildStep2Images(),
      _buildStep3Inventory(),
      _buildStep4CertRequirements(),
      _buildStep5UploadDocs(),
      _buildStep6Batches(),
      _buildStep7Review(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(widget.editProduct != null ? 'Edit Product & Compliance' : 'Add Smart Product & Compliance',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              color: Colors.white,
              child: Row(
                children: [
                  Text('Step ${_currentStep + 1} of 7', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                  const Spacer(),
                  Text(_stepTitle(_currentStep), style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
                ],
              ),
            ),
            LinearProgressIndicator(value: (_currentStep + 1) / 7, color: _primaryGreen, backgroundColor: Colors.grey.shade200),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.r),
                  child: steps[_currentStep],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.r),
              color: Colors.white,
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: _saveAsDraft,
                    child: const Text('Save Draft'),
                  ),
                  SizedBox(width: 8.w),
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Previous'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen, foregroundColor: Colors.white),
                    onPressed: () {
                      if (_currentStep < 6) {
                        setState(() => _currentStep++);
                      } else {
                        _submitForApproval();
                      }
                    },
                    child: Text(_currentStep == 6 ? 'Submit for Approval' : 'Continue'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stepTitle(int step) {
    switch (step) {
      case 0: return 'Basic Information';
      case 1: return 'Product Images (Up to 10)';
      case 2: return 'Price & Inventory';
      case 3: return 'Required Certifications';
      case 4: return 'Upload Compliance Docs';
      case 5: return 'Quality & Batch Details';
      case 6: return 'Review & Submit';
      default: return '';
    }
  }

  Widget _buildStep1Info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product & Business Information', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        SizedBox(height: 12.h),
        TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Product Name *', border: OutlineInputBorder())),
        SizedBox(height: 12.h),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Product Category *', border: OutlineInputBorder()),
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedCategory = val;
                _isOrganic = val.toLowerCase().contains('organic');
                _updateCertifications();
              });
            }
          },
        ),
        SizedBox(height: 12.h),
        TextFormField(controller: _subcatCtrl, decoration: const InputDecoration(labelText: 'Subcategory (e.g. Alphonso Mangoes)', border: OutlineInputBorder())),
        SizedBox(height: 12.h),
        TextFormField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Product Description *', border: OutlineInputBorder())),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _brandCtrl, decoration: const InputDecoration(labelText: 'Brand / Producer', border: OutlineInputBorder()))),
            SizedBox(width: 8.w),
            Expanded(child: TextFormField(controller: _businessCtrl, decoration: const InputDecoration(labelText: 'Business Name', border: OutlineInputBorder()))),
          ],
        ),
        SizedBox(height: 16.h),
        Text('Production & Origin Location', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _countryCtrl, decoration: const InputDecoration(labelText: 'Country', border: OutlineInputBorder()))),
            SizedBox(width: 8.w),
            Expanded(child: TextFormField(controller: _stateCtrl, decoration: const InputDecoration(labelText: 'State', border: OutlineInputBorder()))),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _districtCtrl, decoration: const InputDecoration(labelText: 'District', border: OutlineInputBorder()))),
            SizedBox(width: 8.w),
            Expanded(child: TextFormField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City / Village', border: OutlineInputBorder()))),
            SizedBox(width: 8.w),
            Expanded(child: TextFormField(controller: _pincodeCtrl, decoration: const InputDecoration(labelText: 'PIN Code', border: OutlineInputBorder()))),
          ],
        ),
        SizedBox(height: 12.h),
        TextFormField(controller: _originCtrl, decoration: const InputDecoration(labelText: 'Product Origin Story / Geographical Source', border: OutlineInputBorder())),
        SizedBox(height: 16.h),
        SwitchListTile(
          title: const Text('Certified Organic Product?'),
          subtitle: const Text('Enables NPOP / PGS verification requirements'),
          value: _isOrganic,
          activeThumbColor: _primaryGreen,
          onChanged: (val) {
            setState(() {
              _isOrganic = val;
              _updateCertifications();
            });
          },
        ),
        SwitchListTile(
          title: const Text('GI (Geographical Indication) Associated?'),
          subtitle: const Text('Enables GI authorized-user verification'),
          value: _isGi,
          activeThumbColor: _primaryGreen,
          onChanged: (val) {
            setState(() {
              _isGi = val;
              _updateCertifications();
            });
          },
        ),
        if (_isGi) ...[
          SizedBox(height: 8.h),
          TextFormField(controller: _giNumCtrl, decoration: const InputDecoration(labelText: 'GI Registration / Authorized User Number', border: OutlineInputBorder())),
        ],
      ],
    );
  }

  Widget _buildStep2Images() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Multiple Product Images (Up to 10)', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        SizedBox(height: 4.h),
        const Text('Upload high-resolution photographs. Set primary image.'),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            for (int i = 0; i < _images.length; i++)
              Stack(
                children: [
                  Container(
                    width: 90.r,
                    height: 90.r,
                    decoration: BoxDecoration(
                      border: Border.all(color: _images[i] == _primaryImage ? _primaryGreen : Colors.grey.shade300, width: _images[i] == _primaryImage ? 3 : 1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(_images[i], fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _images.removeAt(i);
                        if (_primaryImage.isEmpty && _images.isNotEmpty) _primaryImage = _images.first;
                      }),
                      child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 14, color: Colors.white)),
                    ),
                  ),
                  if (_images[i] == _primaryImage)
                    Positioned(
                      bottom: 2,
                      left: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        color: _primaryGreen,
                        child: const Text('Primary', style: TextStyle(fontSize: 9, color: Colors.white)),
                      ),
                    ),
                ],
              ),
            if (_images.length < 10)
              GestureDetector(
                onTap: _addPresetImage,
                child: Container(
                  width: 90.r,
                  height: 90.r,
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10.r), border: Border.all(color: Colors.grey.shade400)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo, color: _primaryGreen),
                      SizedBox(height: 4.h),
                      Text('Add Photo', style: TextStyle(fontSize: 10.sp, color: _primaryGreen)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3Inventory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pricing, Stock & Packaging', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Selling Price (₹) *', border: OutlineInputBorder()))),
            SizedBox(width: 8.w),
            Expanded(child: TextFormField(controller: _stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Available Stock *', border: OutlineInputBorder()))),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _moqCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min Order Qty (MOQ)', border: OutlineInputBorder()))),
            SizedBox(width: 8.w),
            Expanded(child: TextFormField(controller: _dimensionsCtrl, decoration: const InputDecoration(labelText: 'Weight / Dimensions', border: OutlineInputBorder()))),
          ],
        ),
        SizedBox(height: 12.h),
        TextFormField(controller: _packagingCtrl, decoration: const InputDecoration(labelText: 'Packaging Details', border: OutlineInputBorder())),
        SizedBox(height: 12.h),
        TextFormField(controller: _storageCtrl, decoration: const InputDecoration(labelText: 'Storage Instructions', border: OutlineInputBorder())),
        SizedBox(height: 12.h),
        TextFormField(controller: _shelfLifeCtrl, decoration: const InputDecoration(labelText: 'Shelf Life / Expiry duration', border: OutlineInputBorder())),
      ],
    );
  }

  Widget _buildStep4CertRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dynamic Certification Requirements', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        SizedBox(height: 4.h),
        const Text('Based on category, ingredients, and regulatory compliance claims.'),
        SizedBox(height: 12.h),
        for (final req in _certifications)
          Card(
            margin: EdgeInsets.only(bottom: 10.h),
            child: ListTile(
              leading: Icon(
                req.status == CertRequirementStatus.verified ? Icons.check_circle : Icons.warning_amber_rounded,
                color: req.status == CertRequirementStatus.verified ? Colors.green : Colors.orange,
              ),
              title: Text(req.requirementName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.h),
                  Text(req.explanation, style: TextStyle(fontSize: 11.sp)),
                  SizedBox(height: 4.h),
                  Text('Status: ${req.status.name.toUpperCase()} ${req.isMandatory ? '(Mandatory)' : '(Optional)'}',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: req.isMandatory ? Colors.red.shade700 : Colors.grey.shade700)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStep5UploadDocs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload Compliance Certificates & Test Reports', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        SizedBox(height: 4.h),
        const Text('Upload PDFs, lab test reports, and official certificates securely.'),
        SizedBox(height: 16.h),
        for (int i = 0; i < _certifications.length; i++)
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r), border: Border.all(color: Colors.grey.shade300)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_certifications[i].requirementName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                SizedBox(height: 6.h),
                Text('Document: ${_certifications[i].uploadedDocName ?? 'No document uploaded yet'}', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700)),
                SizedBox(height: 8.h),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _certifications[i] = _certifications[i].copyWith(
                        status: CertRequirementStatus.underReview,
                        uploadedDocName: 'Compliance_Doc_${i + 1}.pdf',
                        expiryDate: DateTime.now().add(const Duration(days: 365)),
                      );
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document uploaded successfully. Queued for verification.')));
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Certificate / Report'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStep6Batches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Batch Management & Traceability', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        SizedBox(height: 4.h),
        const Text('Manage production batches for QR traceability and quality inspection.'),
        SizedBox(height: 12.h),
        for (final b in _batches)
          Card(
            margin: EdgeInsets.only(bottom: 10.h),
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Batch: ${b.batchNumber}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                  SizedBox(height: 4.h),
                  Text('Quantity: ${b.quantity} units | Facility: ${b.processingFacility}', style: TextStyle(fontSize: 11.sp)),
                  Text('Inspection Status: ${b.inspectionStatus}', style: TextStyle(fontSize: 11.sp, color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen, foregroundColor: Colors.white),
          onPressed: () {
            setState(() {
              _batches.add(ProductBatchModel(
                batchNumber: 'BATCH-${DateTime.now().year}-${_batches.length + 1}',
                productionDate: DateTime.now(),
                expiryDate: DateTime.now().add(const Duration(days: 365)),
                quantity: 100,
                processingFacility: 'Primary Processing Facility',
              ));
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New Production Batch'),
        ),
      ],
    );
  }

  Widget _buildStep7Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review & Submit for Quality Approval', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey.shade300)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product Name: ${_nameCtrl.text}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              SizedBox(height: 4.h),
              Text('Category: $_selectedCategory'),
              Text('Price: ₹ ${_priceCtrl.text} | Stock: ${_stockCtrl.text} units'),
              Text('Images Uploaded: ${_images.length} images'),
              Text('Batches: ${_batches.length} batch(es) registered'),
              Text('Certifications: ${_certifications.length} compliance requirement(s) tracked'),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        const Text('Note: Products are reviewed by authorized quality-control personnel before being published on the public marketplace.'),
      ],
    );
  }
}
