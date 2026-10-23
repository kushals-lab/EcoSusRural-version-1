import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/language_provider.dart';
import '../../payments/screens/eco_bharat_pay_screen.dart';
import '../../payments/screens/payment_success_screen.dart';

class SellerPlanDef {
  final String key;
  final String name;
  final String priceLine;
  final String detailLine;
  final int listings;
  final String listingsNote;
  final String aiNote;
  final int expertSessions;
  final String weatherNote;
  final double checkoutAmount;
  const SellerPlanDef({
    required this.key, required this.name, required this.priceLine, required this.detailLine,
    required this.listings, required this.listingsNote, required this.aiNote,
    required this.expertSessions, required this.weatherNote, required this.checkoutAmount,
  });
  static const List<SellerPlanDef> all = [
    SellerPlanDef(key: 'Starter', name: 'Starter Plan', priceLine: 'Rs 4,000 / year',
      detailLine: '3 product listings for one year only + limited premium content + limited premium AI services',
      listings: 3, listingsNote: '3 product listings (valid for 1 year only)',
      aiNote: 'Limited AI use with a capped query allowance', expertSessions: 12,
      weatherNote: 'Limited weather data', checkoutAmount: 4000),
    SellerPlanDef(key: 'Premium', name: 'Premium Plan',
      priceLine: 'Rs 1,099 / 3 months or Rs 3,999 / year',
      detailLine: 'Best value - full premium content catalog + full weather telemetry & severe alerts',
      listings: 8, listingsNote: '8 product listings per year',
      aiNote: '2x Standard AI usage', expertSessions: 20,
      weatherNote: 'Full premium content + full weather telemetry & severe alerts', checkoutAmount: 3999),
    SellerPlanDef(key: 'Enterprise', name: 'Enterprise Plan', priceLine: 'Rs 1,00,000 / year',
      detailLine: 'Up to 30 people get access to multiple premium services + priority panel + dedicated account manager',
      listings: 999, listingsNote: 'Unlimited bulk listings',
      aiNote: 'Enterprise bulk token pool', expertSessions: 999,
      weatherNote: 'Enterprise telemetry + 30-seat admin dashboard', checkoutAmount: 100000),
    SellerPlanDef(key: 'Personalized', name: 'Personalized Plan', priceLine: 'Pay-per-service (dynamic)',
      detailLine: 'Select only the services you want to use - cost is added per service',
      listings: 0, listingsNote: 'Configurable count', aiNote: 'Configurable quota',
      expertSessions: 0, weatherNote: 'A la carte category add-ons available', checkoutAmount: 0),
  ];
  static SellerPlanDef byKey(String key) => all.firstWhere((p) => p.key == key, orElse: () => all[1]);
}

class SellerRegistrationScreen extends ConsumerStatefulWidget {
  const SellerRegistrationScreen({super.key});
  @override
  ConsumerState<SellerRegistrationScreen> createState() => _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends ConsumerState<SellerRegistrationScreen> {
  static const Color _primaryGreen = Color(0xFF1B4D3E);
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();
  final _orgController = TextEditingController();
  final _headController = TextEditingController();
  final _otpController = TextEditingController();
  final _captchaController = TextEditingController();
  final _employeeCountController = TextEditingController(text: '5');
  final _memberCountController = TextEditingController(text: '10');
  int _step = 0;
  bool _isOrganization = false;
  String _selectedPlan = 'Premium';
  String _selectedRole = 'Farmer';
  String _premiumDuration = 'yearly';
  String _captchaText = 'E4B7';
  bool _verificationComplete = false;
  bool _agreedTerms = false;
  bool _agreedGemini = false;
  Timer? _demoTimer;
  static const double _pricePerListing = 250.0;
  static const double _pricePerAiUnit = 50.0;
  static const double _pricePerExpertSession = 400.0;
  static const double _priceSoilLabAddon = 500.0;
  static const double _priceB2BDeskAddon = 800.0;
  static const double _priceGIAuthAddon = 300.0;
  int _personalizedListings = 0;
  int _personalizedAiUnits = 0;
  int _personalizedExpertSessions = 0;
  bool _personalizedSoilLab = false;
  bool _personalizedB2BDesk = false;
  bool _personalizedGIAuth = false;
  double get _personalizedTotal =>
      (_personalizedListings * _pricePerListing) + (_personalizedAiUnits * _pricePerAiUnit) +
      (_personalizedExpertSessions * _pricePerExpertSession) +
      (_personalizedSoilLab ? _priceSoilLabAddon : 0.0) + (_personalizedB2BDesk ? _priceB2BDeskAddon : 0.0) +
      (_personalizedGIAuth ? _priceGIAuthAddon : 0.0);
  double get _checkoutAmount {
    switch (_selectedPlan) {
      case 'Starter': return 4000.0;
      case 'Premium': return _premiumDuration == 'monthly' ? 1099.0 : 3999.0;
      case 'Enterprise': return 100000.0;
      case 'Personalized': return _personalizedTotal < 100.0 ? 100.0 : _personalizedTotal;
      default: return 0.0;
    }
  }
  String get _checkoutPlanName {
    switch (_selectedPlan) {
      case 'Starter': return 'Starter Plan (Rs 4,000 / year)';
      case 'Premium': return _premiumDuration == 'monthly' ? 'Premium Plan (Rs 1,099 / 3 months)' : 'Premium Plan (Rs 3,999 / year)';
      case 'Enterprise': return 'Enterprise Plan (Rs 1,00,000 / year)';
      case 'Personalized': return 'Personalized Plan (Pay-per-service)';
      default: return _selectedPlan;
    }
  }
  @override
  void initState() {
    super.initState();
    _demoTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _verificationComplete = true);
    });
  }
  @override
  void dispose() {
    _demoTimer?.cancel();
    _nameController.dispose(); _phoneController.dispose(); _emailController.dispose();
    _addressController.dispose(); _gstController.dispose(); _orgController.dispose();
    _headController.dispose(); _otpController.dispose(); _captchaController.dispose();
    _employeeCountController.dispose(); _memberCountController.dispose();
    super.dispose();
  }
  void _refreshCaptcha() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final seed = DateTime.now().microsecondsSinceEpoch;
    _captchaText = String.fromCharCodes(Iterable.generate(4, (index) => chars.codeUnitAt((seed >> (index * 3)) % chars.length)));
    _captchaController.clear();
    setState(() {});
  }
  void _incrementPersonalized(String key) {
    setState(() {
      switch (key) {
        case 'listings': _personalizedListings = (_personalizedListings + 1).clamp(0, 50); break;
        case 'ai': _personalizedAiUnits = (_personalizedAiUnits + 1).clamp(0, 50); break;
        case 'expert': _personalizedExpertSessions = (_personalizedExpertSessions + 1).clamp(0, 50); break;
      }
    });
  }
  void _decrementPersonalized(String key) {
    setState(() {
      switch (key) {
        case 'listings': _personalizedListings = (_personalizedListings - 1).clamp(0, 50); break;
        case 'ai': _personalizedAiUnits = (_personalizedAiUnits - 1).clamp(0, 50); break;
        case 'expert': _personalizedExpertSessions = (_personalizedExpertSessions - 1).clamp(0, 50); break;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final steps = [_buildTypeStep(), _buildProfileStep(), _buildVerificationStep(), _buildConfirmationStep()];
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 1,
        title: Text('Seller Registration', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
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
              if (_step > 0) Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                    side: const BorderSide(color: _primaryGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: () => setState(() => _step--),
                  child: Text(ref.tr('back'), style: const TextStyle(color: _primaryGreen)),
                ),
              ),
              if (_step > 0) SizedBox(width: 10.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: _handleNext,
                  child: Text(_step == steps.length - 1 ? 'Complete Registration' : ref.tr('next'),
                      style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _handleNext() async {
    if (_step == 1) {
      final valid = _formKey.currentState?.validate() ?? false;
      if (!valid) return;
      if (!_agreedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please agree to the Terms & Conditions to continue.')));
        return;
      }
      if (!_agreedGemini) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please acknowledge the Google Gemini AI consent to continue.')));
        return;
      }
    }
    if (_step == 2) {
      if (_otpController.text.trim().isEmpty || _captchaController.text.trim().toUpperCase() != _captchaText) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid OTP and matching captcha before continuing.')));
        return;
      }
    }
    if (_step < 3) { setState(() => _step++); return; }
    await _completeRegistration();
  }
  Future<void> _completeRegistration() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seller registration completed successfully.')));
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => EcoBharatPayScreen(
        amount: _checkoutAmount,
        purpose: _checkoutPlanName,
        referenceId: 'REG-${DateTime.now().millisecondsSinceEpoch}',
        successContext: PaymentSuccessContext(
          title: 'Subscription Activated - $_checkoutPlanName',
          subtitle: 'Your EcoSusRural seller subscription is active. You now have access to your plan benefits and category-specific services.',
          quotas: _buildQuotaSummary(),
        ),
      ),
    ));
  }
  List<SubscriptionQuotaSummary> _buildQuotaSummary() {
    switch (_selectedPlan) {
      case 'Starter':
        return const [
          SubscriptionQuotaSummary(label: 'Product Listings', value: '3 / year', fraction: 0.33, icon: Icons.inventory_2),
          SubscriptionQuotaSummary(label: 'AI Usage', value: 'Limited tokens', fraction: 0.25, icon: Icons.smart_toy),
          SubscriptionQuotaSummary(label: 'Expert Advice', value: '12 / year', fraction: 1.0, icon: Icons.support_agent),
        ];
      case 'Premium':
        return const [
          SubscriptionQuotaSummary(label: 'Product Listings', value: '8 / year', fraction: 0.5, icon: Icons.inventory_2),
          SubscriptionQuotaSummary(label: 'AI Usage', value: '2x standard', fraction: 0.6, icon: Icons.smart_toy),
          SubscriptionQuotaSummary(label: 'Expert Advice', value: '20 / year', fraction: 1.0, icon: Icons.support_agent),
        ];
      case 'Enterprise':
        return const [
          SubscriptionQuotaSummary(label: 'Seats', value: '30 members', fraction: 1.0, icon: Icons.groups),
          SubscriptionQuotaSummary(label: 'Product Listings', value: 'Unlimited', fraction: 1.0, icon: Icons.inventory_2),
          SubscriptionQuotaSummary(label: 'AI Usage', value: 'Enterprise pool', fraction: 1.0, icon: Icons.smart_toy),
        ];
      case 'Personalized':
        final listFrac = (_personalizedListings / 50).clamp(0.0, 1.0);
        final aiFrac = (_personalizedAiUnits / 50).clamp(0.0, 1.0);
        final expFrac = (_personalizedExpertSessions / 50).clamp(0.0, 1.0);
        return [
          SubscriptionQuotaSummary(label: 'Product Listings', value: '$_personalizedListings configured', fraction: listFrac, icon: Icons.inventory_2),
          SubscriptionQuotaSummary(label: 'AI Usage', value: '$_personalizedAiUnits units', fraction: aiFrac, icon: Icons.smart_toy),
          SubscriptionQuotaSummary(label: 'Expert Advice', value: '$_personalizedExpertSessions sessions', fraction: expFrac, icon: Icons.support_agent),
        ];
      default:
        return const [];
    }
  }
  Widget _buildTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account type', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        SizedBox(height: 16.h),
        _optionCard(icon: Icons.person, title: 'Individual Seller',
            subtitle: 'Farmer, artisan, or individual seller with PAN/GST if applicable.',
            selected: !_isOrganization, onTap: () => setState(() => _isOrganization = false)),
        SizedBox(height: 12.h),
        _optionCard(icon: Icons.groups, title: 'Organization / SHG / NGO / FPO',
            subtitle: 'Add head approval, employee tracking, and member count. Enterprise plan supports up to 30 members.',
            selected: _isOrganization, onTap: () => setState(() => _isOrganization = true)),
        SizedBox(height: 16.h),
        _infoBox(icon: Icons.lightbulb_outline,
            text: 'Every subscription plan (Starter, Premium, Enterprise, Personalized) is customizable for each seller category. Choose your role below to see category-specific services.',
            text2: 'Each category can configure Starter, Premium, Enterprise or Personalized with only the services they need.'),
        SizedBox(height: 12.h),
        _infoBox(icon: Icons.shield_outlined,
            text: 'Demo verification simulates email OTP, captcha, and a 5-10 minute review queue.',
            text2: ''),
      ],
    );
  }
  Widget _buildProfileStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_isOrganization ? 'Organization details' : 'Seller details',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        SizedBox(height: 16.h),
        if (_isOrganization) ...[
          _field('Organization name', _orgController, 'Enter your group or company name', Icons.business),
          SizedBox(height: 12.h),
          _field('Head of organization', _headController, 'Enter head/manager full name', Icons.badge_outlined),
          SizedBox(height: 12.h),
          _field('Member count (mandatory)', _memberCountController, 'Total members in the organization',
              Icons.groups_2_outlined, keyboardType: TextInputType.number),
          SizedBox(height: 12.h),
          _field('Employee count', _employeeCountController, 'Total employees',
              Icons.people_outline, keyboardType: TextInputType.number),
          SizedBox(height: 12.h),
        ] else ...[
          _field('Full name', _nameController, 'Enter your full name', Icons.person_outline),
          SizedBox(height: 12.h),
          if (_selectedRole == 'MSME') ...[
            _field('Employee count (MSME)', _employeeCountController, 'Number of employees',
                Icons.people_outline, keyboardType: TextInputType.number),
            SizedBox(height: 12.h),
          ],
        ],
        _field('Phone number', _phoneController, 'Enter mobile number', Icons.phone_android_outlined,
            keyboardType: TextInputType.phone),
        SizedBox(height: 12.h),
        _field('Email address', _emailController, 'Enter email address', Icons.email_outlined,
            keyboardType: TextInputType.emailAddress),
        SizedBox(height: 12.h),
        _field('Address', _addressController, 'Enter village / district / state', Icons.location_on_outlined),
        SizedBox(height: 12.h),
        _field('PAN / GST if applicable', _gstController, 'PAN or GST number', Icons.receipt_long_outlined),
        SizedBox(height: 16.h),
        Text('Business role', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: ['Farmer', 'MSME', 'Artisan', 'Exporter'].map((role) {
            final selected = _selectedRole == role;
            return ChoiceChip(
              label: Text(role),
              selected: selected,
              selectedColor: _primaryGreen,
              labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
              onSelected: (_) => setState(() => _selectedRole = role),
              avatar: Icon(
                role == 'Farmer' ? Icons.agriculture :
                    role == 'MSME' ? Icons.factory :
                    role == 'Artisan' ? Icons.handyman :
                    Icons.local_convenience_store,
                size: 15,
                color: selected ? Colors.white : _primaryGreen,
              ),
            );
          }).toList(),
        ),
        if (_selectedRole == 'MSME') ...[
          SizedBox(height: 8.h),
          _infoBox(icon: Icons.people_outline,
              text: 'MSME accounts require employee_count. Your value: ${_employeeCountController.text}.',
              text2: 'This is tracked as part of your seller profile and used for subscription eligibility.'),
        ] else if (_isOrganization) ...[
          SizedBox(height: 8.h),
          _infoBox(icon: Icons.groups_2_outlined,
              text: 'Organization accounts require member_count. Your value: ${_memberCountController.text}.',
              text2: 'Enterprise plan grants access for up to 30 members.'),
        ],
        SizedBox(height: 16.h),
        Text('Subscription plan (customizable for each category)',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: SellerPlanDef.all.map((plan) {
            final selected = _selectedPlan == plan.key;
            return ChoiceChip(
              label: Text(plan.name),
              selected: selected,
              selectedColor: _primaryGreen,
              labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
              onSelected: (_) => setState(() => _selectedPlan = plan.key),
            );
          }).toList(),
        ),
        _planDetailCard(),
        SizedBox(height: 12.h),
        if (_selectedPlan == 'Premium') ...[
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: _primaryGreen.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose duration',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Rs 1,099 / 3 months'),
                        selected: _premiumDuration == 'monthly',
                        selectedColor: _primaryGreen,
                        labelStyle: TextStyle(color: _premiumDuration == 'monthly' ? Colors.white : Colors.black87),
                        onSelected: (_) => setState(() => _premiumDuration = 'monthly'),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Rs 3,999 / year  (Best Value)'),
                        selected: _premiumDuration == 'yearly',
                        selectedColor: Colors.amber,
                        labelStyle: TextStyle(
                            color: _premiumDuration == 'yearly' ? Colors.black87 : Colors.black87),
                        onSelected: (_) => setState(() => _premiumDuration = 'yearly'),
                        avatar: const Icon(Icons.star, color: Colors.amber, size: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        if (_selectedPlan == 'Personalized') ...[
          _personalizedBuilder(),
          SizedBox(height: 12.h),
        ],
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: Checkbox(
                      value: _agreedTerms,
                      onChanged: (v) => setState(() => _agreedTerms = v ?? false),
                      activeColor: _primaryGreen,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('I agree to EcoSusRural Terms & Conditions',
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                        SizedBox(height: 4.h),
                        Text(
                            'By registering an account, selecting a subscription tier, or interacting with EcoSusRural AI, you acknowledge and agree that EcoSusRural utilizes Google Gemini models for its automated advisory, decision support, and content generation services ("EcoSusRural AI"). '
                            'You are bound by the Google Privacy Policy (https://policies.google.com/privacy) and Google Terms of Service (https://policies.google.com/terms) regarding data collection, processing, and usage. '
                            'Outputs provided by EcoSusRural AI serve as informational guidance only.',
                            style: TextStyle(fontSize: 10.sp, color: Colors.grey[600], height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: Checkbox(
                      value: _agreedGemini,
                      onChanged: (v) => setState(() => _agreedGemini = v ?? false),
                      activeColor: _primaryGreen,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                        'I acknowledge that EcoSusRural AI is powered by Google Gemini and my data is processed under Google Privacy Policy & Terms of Service for data collection.',
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey[700], height: 1.4)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _planDetailCard() {
    final plan = SellerPlanDef.byKey(_selectedPlan);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 4.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: _primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.arrow_circle_right, color: _primaryGreen, size: 16.r),
              SizedBox(width: 6.w),
              Text(plan.name, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
              const Spacer(),
              Text(plan.priceLine, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
          SizedBox(height: 8.h),
          Text(plan.detailLine, style: TextStyle(fontSize: 11.sp, color: Colors.grey[700])),
          SizedBox(height: 10.h),
          _planRow(Icons.inventory_2, 'Product listings', plan.listingsNote),
          _planRow(Icons.smart_toy, 'AI usage', plan.aiNote),
          _planRow(Icons.support_agent, 'Expert advice', '${plan.expertSessions} sessions / year'),
          _planRow(Icons.cloud, 'Weather & content', plan.weatherNote),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade800, size: 15.r),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                      'Plans are customizable for each category (Farmer, MSME, Artisan, Organization). Category-specific services (Soil Lab, B2B Desk, GI Registry, Org Console) activate automatically for the matching role.',
                      style: TextStyle(fontSize: 10.sp, color: Colors.amber.shade800, height: 1.4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _planRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(icon, color: _primaryGreen, size: 15.r),
          SizedBox(width: 8.w),
          Expanded(child: Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]))),
          Text(value, style: TextStyle(fontSize: 11.sp, color: Colors.black87, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
  Widget _personalizedBuilder() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
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
              Icon(Icons.build_outlined, color: _primaryGreen, size: 20.r),
              SizedBox(width: 8.w),
              Text('Personalized Plan - Pay-per-Service Builder',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
              const Spacer(),
              Text('Total: Rs ${_personalizedTotal.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold,
                      color: _personalizedTotal > 0 ? Colors.amber.shade800 : Colors.grey[600])),
            ],
          ),
          SizedBox(height: 12.h),
          Text('Counters (select the services you want to use):',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[700])),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(child: _counterTile('Product Listings', Icons.inventory_2, _personalizedListings, 'listings', _pricePerListing)),
              SizedBox(width: 8.w),
              Expanded(child: _counterTile('AI Units', Icons.smart_toy, _personalizedAiUnits, 'ai', _pricePerAiUnit)),
            ],
          ),
          SizedBox(height: 8.h),
          Expanded(
              child: _counterTile('Expert Sessions', Icons.support_agent, _personalizedExpertSessions, 'expert', _pricePerExpertSession)),
          SizedBox(height: 12.h),
          Text('Category add-ons (toggle on/off):',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[700])),
          SizedBox(height: 6.h),
          _addonToggle('Soil Lab Telemetry (Farmers only)', Icons.grass, _personalizedSoilLab,
              (v) => setState(() => _personalizedSoilLab = v), _priceSoilLabAddon),
          SizedBox(height: 6.h),
          _addonToggle('B2B Procurement Desk (MSMEs only)', Icons.factory, _personalizedB2BDesk,
              (v) => setState(() => _personalizedB2BDesk = v), _priceB2BDeskAddon),
          SizedBox(height: 6.h),
          _addonToggle('GI Authentication (Artisans only)', Icons.verified_user, _personalizedGIAuth,
              (v) => setState(() => _personalizedGIAuth = v), _priceGIAuthAddon),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: _primaryGreen.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: _primaryGreen.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance, color: _primaryGreen),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text('Real-time billing summary updates instantly as you adjust the counters above.',
                      style: TextStyle(fontSize: 10.sp, color: _primaryGreen, height: 1.4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _counterTile(String label, IconData icon, int value, String key, double unitPrice) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: _primaryGreen, size: 18.r),
          SizedBox(width: 8.w),
          Expanded(child: Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]))),
          IconButton(onPressed: () => _decrementPersonalized(key),
              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey), iconSize: 22),
          Text('$value',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold,
                  color: value > 0 ? _primaryGreen : Colors.grey[500])),
          IconButton(onPressed: () => _incrementPersonalized(key),
              icon: const Icon(Icons.add_circle_outline, color: Colors.green), iconSize: 22),
          SizedBox(width: 8.w),
          Text('Rs ${unitPrice.toStringAsFixed(0)} each',
              style: TextStyle(fontSize: 9.sp, color: Colors.grey[600])),
        ],
      ),
    );
  }
  Widget _addonToggle(String label, IconData icon, bool value, ValueChanged<bool> onChanged, double price) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: value ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: value ? Colors.green : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: value ? Colors.green : Colors.grey[600], size: 16.r),
            SizedBox(width: 8.w),
            Expanded(child: Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]))),
            Icon(value ? Icons.toggle_on : Icons.toggle_off, color: value ? Colors.green : Colors.grey, size: 22.r),
            SizedBox(width: 8.w),
            Text('Rs ${price.toStringAsFixed(0)}', style: TextStyle(
                fontSize: 11.sp, fontWeight: FontWeight.w600,
                color: value ? Colors.green : Colors.grey[600])),
          ],
        ),
      ),
    );
  }
  Widget _buildVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verification', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        SizedBox(height: 12.h),
        _infoBox(
          icon: Icons.email_outlined,
          text: 'We will send a one-time code to ${_emailController.text.trim().isEmpty ? 'your email' : _emailController.text.trim()}.',
          text2: 'Receive the OTP on your registered email and enter it below.',
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send_to_mobile),
                label: const Text('Send OTP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () { _refreshCaptcha(); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: const Text('Refresh Captcha'),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _field('OTP', _otpController, 'Enter the 6-digit code', Icons.lock_outline, keyboardType: TextInputType.number),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Captcha: $_captchaText',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, letterSpacing: 2, color: _primaryGreen),
                ),
              ),
              IconButton(
                onPressed: _refreshCaptcha,
                icon: const Icon(Icons.refresh, color: _primaryGreen),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _field('Captcha answer', _captchaController, 'Type the code above', Icons.check_circle_outline, keyboardType: TextInputType.text),
      ],
    );
  }
  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review in progress', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        SizedBox(height: 14.h),
        _infoBox(
          icon: Icons.pending_actions,
          text: 'Your approval is queued for manual verification. The demo wait time is approximately 5-10 minutes.',
          text2: 'After verification, your subscription payment will be processed via EcoBharatPay.',
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Verification status', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(height: 8.h),
              LinearProgressIndicator(
                value: _verificationComplete ? 1 : 0.65,
                minHeight: 8.h,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(_primaryGreen),
              ),
              SizedBox(height: 12.h),
              Text(
                _verificationComplete
                    ? 'Email verified and review check complete in demo mode.'
                    : 'Awaiting final KYC and document review (demo delay simulating 5-10 minutes).',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[700], height: 1.5),
              ),
              SizedBox(height: 12.h),
              if (_verificationComplete)
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Approval alert sent to the registered email address.',
                          style: TextStyle(fontSize: 12.sp, color: Colors.green.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        _infoBox(
          icon: Icons.receipt_long_outlined,
          text: 'Plan: ${SellerPlanDef.byKey(_selectedPlan).name} - $_checkoutPlanName',
          text2: 'Amount: Rs ${_checkoutAmount.toStringAsFixed(0)} via EcoBharatPay',
        ),
      ],
    );
  }
  Widget _optionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: selected ? _primaryGreen.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: selected ? _primaryGreen : Colors.grey.shade300, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? _primaryGreen : Colors.grey[600], size: 30.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 2.h),
                  Text(subtitle, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? _primaryGreen : Colors.grey[400]),
          ],
        ),
      ),
    );
  }
  Widget _field(String label, TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _primaryGreen),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
      ),
    );
  }
  Widget _infoBox({required IconData icon, required String text, String text2 = ''}) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: _primaryGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _primaryGreen.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _primaryGreen),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: TextStyle(fontSize: 12.sp, color: Colors.grey[800], height: 1.4)),
                if (text2.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(text2, style: TextStyle(fontSize: 10.sp, color: Colors.grey[600], height: 1.4)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
