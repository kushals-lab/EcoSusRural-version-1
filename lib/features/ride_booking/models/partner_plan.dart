/// Partner monetisation model for cab & bike riders (Rapido/Uber style).
///
/// A partner can choose EITHER a per-ride commission split OR a fixed-term
/// subscription with zero commission. This file models the plans and the math.
library partner_plan;

enum CommissionMode { perRide, subscription }

/// Per-ride commission percentage (of rider-paid fare).
const double kDefaultPerRideCommissionPercent = 12.0;

class PartnerPlan {
  final String id;
  final String title;
  final String subtitle;
  final int pricePaise;
  final Duration validity;
  final List<String> benefits;
  final double savingsPercent; // vs. per-ride commission over the term

  const PartnerPlan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pricePaise,
    required this.validity,
    required this.benefits,
    required this.savingsPercent,
  });

  String get priceLabel => '₹${(pricePaise / 100).toStringAsFixed(0)}';

  // Estimated trips to break even vs. per-ride commission.
  int get breakEvenTrips {
    const fareEstimatePaise = 10000; // ₹100 average fare per trip
    const commissionPerTrip = fareEstimatePaise * kDefaultPerRideCommissionPercent / 100;
    return (pricePaise / commissionPerTrip).ceil();
  }
}

/// The four subscription tiers a partner can buy.
const List<PartnerPlan> kSubscriptionPlans = [
  PartnerPlan(
    id: 'day',
    title: '1 Day Pass',
    subtitle: 'Perfect for festival / mandi days',
    pricePaise: 4900,
    validity: Duration(days: 1),
    benefits: ['Zero commission for 24 hours', 'Priority ride matching', 'Unlimited trips'],
    savingsPercent: 70,
  ),
  PartnerPlan(
    id: 'week',
    title: '1 Week Pass',
    subtitle: 'Most popular with part-timers',
    pricePaise: 27900,
    validity: Duration(days: 7),
    benefits: ['Zero commission for 7 days', 'Priority dispatch + QR toll pass', 'Weekly earnings report'],
    savingsPercent: 72,
  ),
  PartnerPlan(
    id: 'month',
    title: '1 Month Pass',
    subtitle: 'Best for full-time riders',
    pricePaise: 89900,
    validity: Duration(days: 30),
    benefits: ['Zero commission for 30 days', 'Free partner insurance', '4.9★ fast-track support line'],
    savingsPercent: 75,
  ),
  PartnerPlan(
    id: 'year',
    title: '1 Year Pro',
    subtitle: 'Serious partners & fleet owners',
    pricePaise: 799900,
    validity: Duration(days: 365),
    benefits: ['Zero commission for 1 year', 'Free insurance + helmet kit', 'Fuel cashback 2% flat', 'Dedicated fleet manager'],
    savingsPercent: 82,
  ),
];

/// Renders a per-ride model comparison for a given number of trips.
String estimatedCommissionLabel(int trips) {
  final commissionPaise = (trips * 10000 * kDefaultPerRideCommissionPercent / 100).round();
  return '₹${((commissionPaise / 100).toDouble().toStringAsFixed(0))}';
}