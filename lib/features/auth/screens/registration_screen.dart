import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization/language_provider.dart';
import '../../../core/widgets/pincode_verify_field.dart';
import '../providers/auth_provider.dart';
import '../../weather/screens/location_selection_screen.dart';
import '../../presentation/onboarding_tutorial_screen.dart';

enum _AccountType { buyer, seller, organisation }

enum _SellerRole { farmer, sarpanch, artisan, craftsman, msme, ngoHead, shgFpo }

enum _OrgType { ngo, shg, panchayat, fpo }

enum _IdType { aadhaar, pan }

enum _Plan { freeTrial, threeMonth, oneYear, payPerUse }

class RegistrationScreen extends ConsumerStatefulWidget {
  /// When opened from "Become a Seller" (or any upgrade entry point), the
  /// wizard starts on that account type instead of Buyer.
  /// Accepted values: 'buyer', 'seller', 'organisation'.
  final String? initialAccountType;

  const RegistrationScreen({super.key, this.initialAccountType});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  static const _secureStorage = FlutterSecureStorage();
  Timer? _draftTimer;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _idController = TextEditingController();
  final _bankController = TextEditingController();
  final _ifscController = TextEditingController();
  final _orgNameController = TextEditingController();
  final _headNameController = TextEditingController();

  static const Color _primaryGreen = Color(0xFF1B4D3E);

  int _step = 0;
  _AccountType _type = _AccountType.buyer;
  final Set<_SellerRole> _roles = {_SellerRole.farmer};
  _OrgType _orgType = _OrgType.ngo;
  _IdType _idType = _IdType.aadhaar;
  _Plan _plan = _Plan.freeTrial;

  bool _emailVerified = true;
  bool _pennyDropDone = false;
  bool _isSubmitting = false;
  final Map<String, bool> _docUploads = {};

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _nameController, _phoneController, _emailController,
      _addressController, _pincodeController,
      _orgNameController, _headNameController,
    ]) {
      controller.addListener(_scheduleDraftSave);
    }
    _restoreDraft();
    // Upgrade entry points (e.g. "Become a Seller") pre-select the type.
    switch (widget.initialAccountType) {
      case 'seller':
        _type = _AccountType.seller;
        break;
      case 'organisation':
        _type = _AccountType.organisation;
        break;
      default:
        _type = _AccountType.buyer;
    }
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _idController.dispose();
    _bankController.dispose();
    _ifscController.dispose();
    _orgNameController.dispose();
    _headNameController.dispose();
    super.dispose();
  }

  String? get _draftKey {
    final uid = ref.read(authProvider).user?.uid;
    return uid == null ? null : 'ecosus.registration.draft.v1.$uid';
  }

  void _scheduleDraftSave() {
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 500), () async {
      final key = _draftKey;
      if (key == null) return;
      final values = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'organisation': _orgNameController.text.trim(),
        'head': _headNameController.text.trim(),
      };
      try {
        await _secureStorage.write(key: key, value: jsonEncode(values));
      } catch (_) { /* Keep the form usable if storage is unavailable. */ }
    });
  }

  Future<void> _restoreDraft() async {
    final key = _draftKey;
    if (key == null) return;
    try {
      final raw = await _secureStorage.read(key: key);
      if (raw == null || !mounted) return;
      final values = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      _nameController.text = values['name'] as String? ?? '';
      _phoneController.text = values['phone'] as String? ?? '';
      _emailController.text = values['email'] as String? ?? '';
      _addressController.text = values['address'] as String? ?? '';
      _pincodeController.text = values['pincode'] as String? ?? '';
      _orgNameController.text = values['organisation'] as String? ?? '';
      _headNameController.text = values['head'] as String? ?? '';
    } catch (_) { /* Ignore corrupt or unavailable draft data. */ }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _buildTypeStep(),
      _buildCommonStep(),
      _buildDocsStep(),
      _buildReviewStep(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          '${ref.tr('registrationTitle')} · $_typeLabel',
          style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: steps[_step.clamp(0, steps.length - 1)],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: Row(
            children: [
              if (_step > 0)
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      side: const BorderSide(color: _primaryGreen),
                    ),
                    onPressed: () => setState(() => _step--),
                    child: Text(ref.tr('back'),
                        style: const TextStyle(color: _primaryGreen)),
                  ),
                ),
              if (_step > 0) SizedBox(width: 10.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: _isSubmitting ? null : _next,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _step == 3
                              ? ref.tr('createMyAccount')
                              : ref.tr('next'),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= STEP 0: account type =================
  Widget _buildTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ref.tr('chooseAccountType'),
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _primaryGreen)),
        SizedBox(height: 16.h),
        _typeCard(ref.tr('buyerRole'), Icons.shopping_bag, _AccountType.buyer,
            ref.tr('buyerDocsNote')),
        SizedBox(height: 12.h),
        _typeCard(ref.tr('sellerRole'), Icons.storefront, _AccountType.seller,
            ref.tr('sellerDocsNote')),
        SizedBox(height: 12.h),
        _typeCard(
            ref.tr('accountTypeOrganisation'),
            Icons.groups,
            _AccountType.organisation,
            '${ref.tr('orgTypeNgo')} · ${ref.tr('orgTypeShg')} · ${ref.tr('orgTypePanchayat')} · ${ref.tr('orgTypeFpo')}'),
        SizedBox(height: 20.h),
        _noteTile(Icons.devices, ref.tr('oneDeviceNote')),
        SizedBox(height: 10.h),
        _noteTile(Icons.verified, ref.tr('reVerifyNote')),
      ],
    );
  }

  Widget _typeCard(
      String title, IconData icon, _AccountType type, String subtitle) {
    final selected = _type == type;
    return InkWell(
      onTap: () => setState(() => _type = type),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color:
              selected ? _primaryGreen.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
              color: selected ? _primaryGreen : Colors.grey.shade300,
              width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? _primaryGreen : Colors.grey[600], size: 28.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  SizedBox(height: 2.h),
                  Text(subtitle,
                      style:
                          TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? _primaryGreen : Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _noteTile(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(children: [
        Icon(icon, color: _primaryGreen, size: 18),
        SizedBox(width: 8.w),
        Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]))),
      ]),
    );
  }

  // ================= STEP 1: common details =================
  Widget _buildCommonStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ref.tr('personalDetailsStep'),
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: _primaryGreen)),
        SizedBox(height: 12.h),
        if (_type == _AccountType.organisation) ...[
          TextFormField(
            controller: _orgNameController,
            decoration: _inputDecoration(ref.tr('orgName'), Icons.apartment),
            validator: (v) =>
                v == null || v.isEmpty ? ref.tr('nameRequired') : null,
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _headNameController,
            decoration: _inputDecoration(ref.tr('headName'), Icons.person_pin),
            validator: (v) =>
                v == null || v.isEmpty ? ref.tr('nameRequired') : null,
          ),
          SizedBox(height: 12.h),
        ],
        TextFormField(
          controller: _nameController,
          decoration: _inputDecoration(ref.tr('fullLegalName'), Icons.person),
          validator: (v) =>
              v == null || v.isEmpty ? ref.tr('nameRequired') : null,
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: _inputDecoration(ref.tr('mobileNumber'), Icons.phone)
              .copyWith(counterText: ''),
          validator: (v) {
            if (v == null || v.isEmpty) return ref.tr('mobileRequired');
            if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
              return ref.tr('mobileInvalid');
            }
            return null;
          },
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _emailController,
          onChanged: (_) => setState(() => _emailVerified = false),
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(ref.tr('emailAddress'), Icons.email),
          validator: (v) =>
              v == null || !v.contains('@') ? ref.tr('emailInvalid') : null,
        ),
        SizedBox(height: 12.h),
        PincodeVerifyField(
          controller: _pincodeController,
          addressController: _addressController,
          labelText: ref.tr('pinCode'),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          decoration: _inputDecoration(ref.tr('deliveryAddress'), Icons.home),
          validator: (v) =>
              v == null || v.isEmpty ? ref.tr('addressRequired') : null,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primaryGreen, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF1B4D3E), width: 2),
      ),
    );
  }

  // ================= STEP 2: role-specific documents =================
  Widget _buildDocsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_type == _AccountType.seller) _buildSellerRoles(),
        if (_type == _AccountType.buyer) _buildBuyerDocs(),
        if (_type == _AccountType.organisation) _buildOrgDocs(),
        SizedBox(height: 16.h),
        _noteTile(Icons.devices, ref.tr('oneDeviceNote')),
      ],
    );
  }

  Widget _idTypeButton(String label, _IdType type) {
    final selected = _idType == type;
    return GestureDetector(
      onTap: () => setState(() => _idType = type),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: selected ? _primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: _primaryGreen),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : _primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp)),
        ),
      ),
    );
  }

  Widget _planTile(String label, _Plan plan) {
    final selected = _plan == plan;
    return InkWell(
      onTap: () => setState(() => _plan = plan),
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color:
              selected ? _primaryGreen.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
              color: selected ? _primaryGreen : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? _primaryGreen : Colors.grey[400], size: 20),
            SizedBox(width: 10.w),
            Expanded(child: Text(label, style: TextStyle(fontSize: 13.sp))),
          ],
        ),
      ),
    );
  }

  Widget _docChip(String label) {
    bool uploaded = _docUploads[label] ?? false;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: GestureDetector(
        onTap: () => setState(() => _docUploads[label] = !uploaded),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color:
                uploaded ? _primaryGreen.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
                color: uploaded ? _primaryGreen : Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(uploaded ? Icons.check_circle : Icons.upload_file,
                  color: uploaded ? Colors.green : _primaryGreen, size: 18),
              SizedBox(width: 10.w),
              Expanded(child: Text(label, style: TextStyle(fontSize: 12.sp))),
              Text(ref.tr('uploadDoc'),
                  style: TextStyle(
                      fontSize: 11.sp,
                      color: _primaryGreen,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSellerRoles() {
    final roles = <(_SellerRole, String, IconData)>[
      (_SellerRole.farmer, ref.tr('roleFarmer'), Icons.agriculture),
      (_SellerRole.sarpanch, ref.tr('roleSarpanch'), Icons.how_to_vote),
      (_SellerRole.artisan, ref.tr('roleArtisan'), Icons.palette),
      (_SellerRole.craftsman, ref.tr('roleCraftsman'), Icons.handyman),
      (_SellerRole.msme, ref.tr('roleMsme'), Icons.factory),
      (_SellerRole.ngoHead, ref.tr('roleNgoHead'), Icons.volunteer_activism),
      (_SellerRole.shgFpo, ref.tr('roleShgFpo'), Icons.diversity_3),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ref.tr('sellerRolePicker'),
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: _primaryGreen)),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: roles.map((r) {
            final selected = _roles.contains(r.$1);
            return FilterChip(
              avatar: Icon(r.$3,
                  size: 16, color: selected ? Colors.white : _primaryGreen),
              label: Text(r.$2, style: TextStyle(fontSize: 11.sp)),
              selected: selected,
              selectedColor: _primaryGreen,
              backgroundColor: Colors.white,
              labelStyle:
                  TextStyle(color: selected ? Colors.white : Colors.grey[700]),
              checkmarkColor: Colors.white,
              onSelected: (value) => setState(() {
                value ? _roles.add(r.$1) : _roles.remove(r.$1);
                if (_roles.isEmpty) _roles.add(r.$1);
              }),
            );
          }).toList(),
        ),
        SizedBox(height: 14.h),
        Text(ref.tr('idType'),
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: _primaryGreen)),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
                child: _idTypeButton(ref.tr('idAadhaar'), _IdType.aadhaar)),
            SizedBox(width: 10.w),
            Expanded(child: _idTypeButton(ref.tr('idPan'), _IdType.pan)),
          ],
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _idController,
          keyboardType: TextInputType.number,
          maxLength: _idType == _IdType.aadhaar ? 12 : 10,
          decoration: _inputDecoration(
                  _idType == _IdType.aadhaar
                      ? ref.tr('idAadhaar')
                      : ref.tr('idPan'),
                  Icons.badge)
              .copyWith(counterText: ''),
          validator: (v) =>
              (v == null || v.length < (_idType == _IdType.aadhaar ? 12 : 10))
                  ? ref.tr('nationalIdInvalid')
                  : null,
        ),
        SizedBox(height: 14.h),
        TextFormField(
          controller: _bankController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(
              ref.tr('bankAccountNumber'), Icons.account_balance),
          validator: (v) =>
              v == null || v.length < 8 ? ref.tr('verifyBankFirst') : null,
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _ifscController,
          decoration: _inputDecoration(ref.tr('bankIfsc'), Icons.code),
          validator: (v) =>
              v == null || v.length < 6 ? ref.tr('verifyBankFirst') : null,
        ),
        SizedBox(height: 14.h),
        _noteTile(Icons.info_outline, ref.tr('sellerDocsNote')),
        SizedBox(height: 14.h),
        Text(ref.tr('subscriptionPlan'),
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: _primaryGreen)),
        SizedBox(height: 8.h),
        _planTile(ref.tr('planFreeTrial'), _Plan.freeTrial),
        _planTile(ref.tr('plan3Month'), _Plan.threeMonth),
        _planTile(ref.tr('plan1Year'), _Plan.oneYear),
        _planTile(ref.tr('planPayPerUse'), _Plan.payPerUse),
        SizedBox(height: 8.h),
        _noteTile(Icons.card_membership, ref.tr('freeTrialNote')),
      ],
    );
  }

  Widget _buildBuyerDocs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _idController,
          keyboardType: TextInputType.number,
          maxLength: 12,
          decoration: _inputDecoration(ref.tr('idAadhaar'), Icons.badge)
              .copyWith(counterText: ''),
          validator: (v) =>
              v == null || v.length != 12 ? ref.tr('nationalIdInvalid') : null,
        ),
        SizedBox(height: 12.h),
        // Penny-drop bank verification (refundable fee)
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: _primaryGreen, size: 20),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(ref.tr('pennyDropFee'),
                        style: TextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(ref.tr('pennyDropRefundNote'),
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pennyDropDone
                      ? null
                      : () => _showPennyDropDialog(context),
                  icon: Icon(
                      _pennyDropDone
                          ? Icons.check_circle
                          : Icons.currency_rupee,
                      color: _pennyDropDone ? Colors.green : _primaryGreen,
                      size: 18),
                  label: Text(
                      _pennyDropDone
                          ? ref.tr('bankVerified')
                          : ref.tr('pennyDropVerifyBank'),
                      style: TextStyle(fontSize: 12.sp)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        _noteTile(Icons.info_outline, ref.tr('buyerDocsNote')),
        SizedBox(height: 10.h),
        _noteTile(Icons.card_membership, ref.tr('freeTrialNote')),
      ],
    );
  }

  Widget _buildOrgDocs() {
    final orgTypes = <(_OrgType, String)>[
      (_OrgType.ngo, ref.tr('orgTypeNgo')),
      (_OrgType.shg, ref.tr('orgTypeShg')),
      (_OrgType.panchayat, ref.tr('orgTypePanchayat')),
      (_OrgType.fpo, ref.tr('orgTypeFpo')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ref.tr('orgRole'),
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: _primaryGreen)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: orgTypes.map((o) {
            final selected = _orgType == o.$1;
            return ChoiceChip(
              label: Text(o.$2, style: TextStyle(fontSize: 11.sp)),
              selected: selected,
              selectedColor: _primaryGreen,
              backgroundColor: Colors.white,
              labelStyle:
                  TextStyle(color: selected ? Colors.white : Colors.grey[700]),
              checkmarkColor: Colors.white,
              onSelected: (_) => setState(() => _orgType = o.$1),
            );
          }).toList(),
        ),
        SizedBox(height: 8.h),
        _noteTile(Icons.hub,
            '${ref.tr('orgTypeShg')} / ${ref.tr('orgTypeFpo')} = 1 ${ref.tr('sellerRole')}'),
        SizedBox(height: 14.h),
        Text(ref.tr('docsOrgTitle'),
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: _primaryGreen)),
        SizedBox(height: 8.h),
        _docChip(ref.tr('orgHeadAadhaar')),
        _docChip(ref.tr('orgHeadPhoto')),
        _docChip(ref.tr('orgSignedLetter')),
        _docChip(ref.tr('orgGovCert')),
      ],
    );
  }

  // ================= STEP 3: review & submit =================
  Widget _buildReviewStep() {
    final rows = <(String, String)>[
      (ref.tr('chooseAccountType'), _typeLabel),
      (ref.tr('sellerRolePicker'), _roleLabel),
      (ref.tr('fullLegalName'), _nameController.text),
      (ref.tr('mobileNumber'), _phoneController.text),
      (ref.tr('emailAddress'), _emailController.text),
      if (_type == _AccountType.organisation)
        (ref.tr('orgName'), _orgNameController.text),
      if (_type != _AccountType.organisation)
        (
          ref.tr('idType'),
          _idType == _IdType.aadhaar ? ref.tr('idAadhaar') : ref.tr('idPan')
        ),
      if (_type == _AccountType.seller)
        (ref.tr('subscriptionPlan'), _planLabel),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ref.tr('personalDetailsStep'),
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: _primaryGreen)),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: rows
                .map((r) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 130.w,
                            child: Text(r.$1,
                                style: TextStyle(
                                    fontSize: 12.sp, color: Colors.grey[600])),
                          ),
                          Expanded(
                            child: Text(r.$2,
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        SizedBox(height: 14.h),
        // Re-verification promise
        _noteTile(Icons.refresh, ref.tr('reVerifyNote')),
        SizedBox(height: 10.h),
        _noteTile(Icons.devices, ref.tr('oneDeviceNote')),
      ],
    );
  }

  String get _planLabel => switch (_plan) {
        _Plan.freeTrial => ref.tr('planFreeTrial'),
        _Plan.threeMonth => ref.tr('plan3Month'),
        _Plan.oneYear => ref.tr('plan1Year'),
        _Plan.payPerUse => ref.tr('planPayPerUse'),
      };

  String get _typeLabel => switch (_type) {
        _AccountType.buyer => ref.tr('buyerRole'),
        _AccountType.seller => ref.tr('sellerRole'),
        _AccountType.organisation => ref.tr('accountTypeOrganisation'),
      };

  String get _roleLabel {
    if (_type == _AccountType.seller) {
      return _roles
          .map((role) => switch (role) {
                _SellerRole.farmer => ref.tr('roleFarmer'),
                _SellerRole.sarpanch => ref.tr('roleSarpanch'),
                _SellerRole.artisan => ref.tr('roleArtisan'),
                _SellerRole.craftsman => ref.tr('roleCraftsman'),
                _SellerRole.msme => ref.tr('roleMsme'),
                _SellerRole.ngoHead => ref.tr('roleNgoHead'),
                _SellerRole.shgFpo => ref.tr('roleShgFpo'),
              })
          .join(' + ');
    }
    if (_type == _AccountType.organisation) {
      return switch (_orgType) {
        _OrgType.ngo => ref.tr('orgTypeNgo'),
        _OrgType.shg => ref.tr('orgTypeShg'),
        _OrgType.panchayat => ref.tr('orgTypePanchayat'),
        _OrgType.fpo => ref.tr('orgTypeFpo'),
      };
    }
    return _typeLabel;
  }

  // ================= Navigation & validation =================
  void _next() {
    // Step 0 → 1 always allowed (type picked inline).
    if (_step == 0) {
      setState(() => _step = 1);
      return;
    }
    if (_step == 1) {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _step = 2);
      return;
    }
    if (_step == 2) {
      if (!_formKey.currentState!.validate()) return;
      if (!_emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.tr('emailOtpVerify'))),
        );
        return;
      }
      if (_type == _AccountType.buyer && !_pennyDropDone) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.tr('pennyDropVerifyBank'))),
        );
        return;
      }
      if (_type == _AccountType.organisation) {
        final allUploaded = _docUploads.values.where((v) => v).length >= 4;
        if (!allUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ref.tr('docsOrgTitle'))),
          );
          return;
        }
      }
      setState(() => _step = 3);
      return;
    }
    if (_step == 3) {
      _submit(context);
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authProvider).user;
    if (!_emailVerified || user == null) return;
    setState(() => _isSubmitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      // Persist the role so the app can gate farm profile (farmers only),
      // device checks, and subscription state.
      await prefs.setString('ecosus.user.type', _type.name);
      await prefs.setString('ecosus.user.role', _roleLabel);
      if (_type == _AccountType.seller) {
        await prefs.setString('ecosus.user.plan', _planLabel);
      }
      await prefs.setString('ecosus.display_name.${user.uid}', _nameController.text.trim());
      await prefs.setString('ecosus.auth.user',
          '${user.uid}|${_phoneController.text}|${user.roleKey}');
      _draftTimer?.cancel();
      final draftKey = _draftKey;
      if (draftKey != null) await _secureStorage.delete(key: draftKey);

      if (!mounted || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.tr('accountCreated'))),
      );
      // Location consent is required by Weather Intelligence, so we ask for it
      // here — right after registration and just before the tutorial. The user
      // chooses between allow every time / only while using the app / ask every
      // time / deny, and denying never blocks any screen.
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationSelectionScreen(firstRegistration: true)));
      if (!mounted || !context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const OnboardingTutorialScreen()),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  void _showPennyDropDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(ref.tr('pennyDropFee'), style: TextStyle(fontSize: 16.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₹2 · ${ref.tr('pennyDropRefundNote')}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
            ),
            SizedBox(height: 12.h),
            const Icon(Icons.account_balance, color: _primaryGreen, size: 40),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(ref.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() => _pennyDropDone = true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ref.tr('bankVerified'))),
              );
            },
            child: Text(ref.tr('bankVerifiedSnackMessage'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
