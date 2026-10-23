import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/partner_plan.dart';
import '../providers/partner_provider.dart';

/// Cab & bike rider partner hub — choose per-ride commission OR a fixed-term
/// subscription (Rapido/Uber style monetisation model).
class RiderPartnerScreen extends ConsumerStatefulWidget {
  const RiderPartnerScreen({super.key});

  @override
  ConsumerState<RiderPartnerScreen> createState() => _RiderPartnerScreenState();
}

class _RiderPartnerScreenState extends ConsumerState<RiderPartnerScreen> {
  String _selectedPlanId = 'week';

  @override
  Widget build(BuildContext context) {
    final partnerState = ref.watch(riderPartnerProvider);
    final notifier = ref.read(riderPartnerProvider.notifier);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rider Partner Hub',
          style: TextStyle(color: Color(0xFF1B4D3E), fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildEarningsCard(partnerState),
                SizedBox(height: 16.h),
                _buildModeSelector(partnerState, notifier),
                SizedBox(height: 16.h),
                if (partnerState.mode == CommissionMode.subscription) ...[
                  _buildActivePlanBanner(partnerState),
                  SizedBox(height: 16.h),
                ],
                if (partnerState.mode == CommissionMode.perRide)
                  _buildPerRideModel(),
                if (partnerState.mode == CommissionMode.subscription)
                  _buildPlans(partnerState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsCard(RiderPartnerState state) {
    final subscription = state.mode == CommissionMode.subscription;
    final commission = (1240 * 10000 * kDefaultPerRideCommissionPercent / 100).round();
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4D3E),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your earnings snapshot',
            style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _stat('Trips', '${state.totalTrips}')),
              Expanded(child: _stat('Earned', '₹1,24,000')),
              Expanded(
                child: _stat(
                  'Commission paid',
                  subscription ? '₹0 (plan)' : '₹${(commission / 100).toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 2.h),
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 9.5.sp)),
      ],
    );
  }
  Widget _buildModeSelector(RiderPartnerState state, RiderPartnerNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How do you want to partner?',
          style: TextStyle(color: const Color(0xFF1B4D3E), fontSize: 15.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4.h),
        Text(
          'You choose — per ride commission, or a fixed-rate pass with ZERO commission.',
          style: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
        ),
        SizedBox(height: 10.h),
        ChoiceChip(
          selected: state.mode == CommissionMode.perRide,
          onSelected: (_) => notifier.revertToPerRide(),
          backgroundColor: Colors.grey[100],
          selectedColor: const Color(0xFF1B4D3E).withValues(alpha: 0.12),
          avatar: const Icon(Icons.percent, color: Color(0xFF1B4D3E), size: 18),
          label: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Per-ride commission · ${kDefaultPerRideCommissionPercent.toInt()}%',
                style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                'Pay only when you ride. No lock-in.',
                style: TextStyle(fontSize: 10.5.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        ChoiceChip(
          selected: state.mode == CommissionMode.subscription,
          onSelected: (_) => notifier.activatePlan(kSubscriptionPlans.first),
          backgroundColor: Colors.grey[100],
          selectedColor: const Color(0xFF1B4D3E).withValues(alpha: 0.12),
          avatar: const Icon(Icons.card_membership, color: Color(0xFF1B4D3E), size: 18),
          label: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subscription passes · 0% commission',
                style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                '1 day, 1 week, 1 month or 1 year — save up to 82%.',
                style: TextStyle(fontSize: 10.5.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildPerRideModel() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF4EA),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF1B4D3E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Per-ride commission model',
            style: TextStyle(color: const Color(0xFF1B4D3E), fontSize: 13.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6.h),
          Text(
            'For every ₹100 fare, we deduct ₹12 platform fee. Everything else is yours — paid instantly to EcoBharatPay after each trip.',
            style: TextStyle(fontSize: 11.5.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Estimated for 20 trips (₹100 avg)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.sp)),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  'Commission ≈ ${estimatedCommissionLabel(20)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1B4D3E)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlanBanner(RiderPartnerState state) {
    final plan = state.activePlan;
    if (plan == null) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4D3E),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(children: [
        const Icon(Icons.verified_user, color: Color(0xFFFFD166), size: 20),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${plan.title} ACTIVE · 0% commission',
                style: TextStyle(color: Colors.white, fontSize: 12.5.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2.h),
              Text(
                'Valid until ${_dateLabel(state.activeUntil)}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 10.5.sp),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  String _dateLabel(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return '${value.day}/${value.month}/${value.year}';
  }

  Widget _buildPlans(RiderPartnerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick your pass',
          style: TextStyle(color: const Color(0xFF1B4D3E), fontSize: 15.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        for (final plan in kSubscriptionPlans) ...[
          _planCard(plan, _selectedPlanId == plan.id),
          SizedBox(height: 10.h),
        ],
      ],
    );
  }

  Widget _planCard(PartnerPlan plan, bool selected) {
    return InkWell(
      onTap: () => setState(() => _selectedPlanId = plan.id),
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1B4D3E) : const Color(0xFFEDF4EA),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: selected ? const Color(0xFFFFD166) : const Color(0xFF1B4D3E)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.title,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF1B4D3E),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  plan.priceLabel,
                  style: TextStyle(
                    color: selected ? const Color(0xFFFFD166) : const Color(0xFF1B4D3E),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              '${plan.subtitle} · break-even in ~${plan.breakEvenTrips} trips',
              style: TextStyle(
                color: selected ? Colors.white.withValues(alpha: 0.85) : Colors.grey[700],
                fontSize: 10.5.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              children: [
                for (final benefit in plan.benefits)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '✓ $benefit',
                      style: TextStyle(
                        color: selected ? Colors.white : const Color(0xFF1B4D3E),
                        fontSize: 9.5.sp,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}