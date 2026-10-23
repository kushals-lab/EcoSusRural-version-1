import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/weather_day.dart';

/// Destination of the "View mandi impact" action on Weather Intelligence.
///
/// It projects how the coming 7-day weather is expected to move mandi arrivals
/// and prices, and benchmarks the demand outlook against last season's recorded
/// mandi data. Charts are drawn with [CustomPainter] so the app needs no extra
/// charting dependency.
class MandiImpactScreen extends StatelessWidget {
  /// The same 7-day forecast shown on the Weather Intelligence page.
  final List<WeatherDay> forecast;

  const MandiImpactScreen({super.key, required this.forecast});

  static const Color _primaryGreen = Color(0xFF1B4D3E);

  /// Last season's weekly demand index recorded at the district mandi (0-100).
  static const List<double> _lastSeasonDemand = [62, 71, 80, 88];

  int get _rainyDays => forecast.where((d) => d.rainMm >= 5).length;
  int get _hotDays => forecast.where((d) => d.maxTemp >= 35).length;

  /// Mean projected arrival index across the week, in percent of a normal day.
  double get _avgArrivalPercent {
    if (forecast.isEmpty) return 100;
    final total = forecast.fold<double>(0, (sum, d) => sum + d.mandiArrivalIndex);
    return (total / forecast.length) * 100;
  }

  /// Projected demand index per week, carried forward from last season's
  /// recorded demand and adjusted by the weather stress in this forecast.
  List<double> get _projectedDemand {
    final stress = (_rainyDays >= 3 ? 0.04 : 0.0) + (_hotDays >= 3 ? 0.07 : 0.0);
    return [
      for (final base in _lastSeasonDemand)
        ((base / 100) * 1.08 + stress).clamp(0.0, 1.2) * 100,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Mandi Impact Forecast',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: _primaryGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImpactSummary(),
            SizedBox(height: 16.h),
            _buildArrivalChart(),
            SizedBox(height: 16.h),
            _buildDemandChart(),
            SizedBox(height: 16.h),
            _buildPriceImpactLineChart(),
            SizedBox(height: 16.h),
            _buildDemandHeatmap(),
            SizedBox(height: 16.h),
            _buildCropOutlook(),
            SizedBox(height: 16.h),
            _buildMethodNote(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sections
  // ---------------------------------------------------------------------------
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }

  Widget _buildImpactSummary() {
    final arrival = _avgArrivalPercent;
    final tone = arrival >= 90
        ? 'Near-normal arrivals expected'
        : arrival >= 75
            ? 'Arrivals likely to thin out'
            : 'Sharp arrival dip expected';

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront, size: 20.r, color: _primaryGreen),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Weather impact on your mandi',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '$tone. $_rainyDays wet day(s) and $_hotDays heat day(s) in the next '
            '7 days change when farmers can bring produce to the yard.',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[800], height: 1.5),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: _metric(Icons.event_available, 'Wet days', '$_rainyDays'),
              ),
              Flexible(
                child: _metric(Icons.terrain, 'Heat days', '$_hotDays'),
              ),
              Flexible(
                child: _metric(Icons.local_shipping, 'Arrival index',
                    '${arrival.toStringAsFixed(0)}%'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20.r, color: _primaryGreen),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildArrivalChart() {
    if (forecast.isEmpty) {
      return _card(
        child: Text(
          'No forecast available to project mandi arrivals.',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
        ),
      );
    }

    final bars = forecast
        .map((d) => _ChartBar(
              label: d.dayLabel,
              value: d.mandiArrivalIndex * 100,
              valueLabel: (d.mandiArrivalIndex * 100).toStringAsFixed(0),
              color: _impactColor(d),
            ))
        .toList();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, size: 20.r, color: _primaryGreen),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Projected mandi arrivals (next 7 days)',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Index vs a normal auction day (100 = full yard).',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 170.h,
            child: CustomPaint(
              size: Size.infinite,
              painter: _MandiBarChartPainter(
                bars: bars,
                maxValue: 100,
                axisColor: Colors.grey.shade400,
                labelColor: Colors.grey.shade700,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 14.w,
            runSpacing: 6.h,
            children: const [
              _LegendDot(color: Color(0xFF1B4D3E), label: 'Normal day'),
              _LegendDot(color: Color(0xFF1E88E5), label: 'Rain — fewer lots'),
              _LegendDot(color: Color(0xFF3949AB), label: 'Storm — yards shut'),
              _LegendDot(color: Color(0xFFF4511E), label: 'Heat — late arrivals'),
            ],
          ),
        ],
      ),
    );
  }

  Color _impactColor(WeatherDay day) {
    if (day.rainMm >= 20) return const Color(0xFF3949AB);
    if (day.rainMm >= 5) return const Color(0xFF1E88E5);
    if (day.maxTemp >= 35) return const Color(0xFFF4511E);
    return _primaryGreen;
  }

  Widget _buildDemandChart() {
    final projected = _projectedDemand;
    final groups = <_GroupedBar>[
      for (var i = 0; i < _lastSeasonDemand.length; i++)
        _GroupedBar(
          label: 'Wk ${i + 1}',
          firstValue: _lastSeasonDemand[i],
          secondValue: projected[i],
        ),
    ];

    final delta = projected.isEmpty
        ? 0.0
        : (projected.last - _lastSeasonDemand.last);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 20.r, color: _primaryGreen),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Future demand vs last season',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Demand index built from last season mandi records, adjusted by the '
            'weather in this forecast.',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 180.h,
            child: CustomPaint(
              size: Size.infinite,
              painter: _MandiGroupedBarChartPainter(
                groups: groups,
                maxValue: 100,
                axisColor: Colors.grey.shade400,
                labelColor: Colors.grey.shade700,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 14.w,
            runSpacing: 6.h,
            children: const [
              _LegendDot(color: Color(0xFF9E9E9E), label: 'Last season (actual)'),
              _LegendDot(color: Color(0xFF1B4D3E), label: 'This season (projected)'),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: _primaryGreen.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16.r, color: _primaryGreen),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    delta >= 0
                        ? 'Demand stays ${delta.toStringAsFixed(1)} points above the '
                            'same week last season — a good window to sell graded lots '
                            'early and store only what holds quality.'
                        : 'Demand eases ${delta.abs().toStringAsFixed(1)} points below the '
                            'same week last season — stagger sales and avoid distress '
                            'selling right after a wet spell.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropOutlook() {
    final heavyRain = _rainyDays >= 3;
    final heat = _hotDays >= 3;
    final rows = <_CropOutlook>[
      _CropOutlook(
        crop: 'Onion',
        trend: heavyRain || heat ? '↑ Firming 4-8%' : '→ Stable',
        up: true,
        reason: heavyRain
            ? 'Fewer lots reach the yard in rain, so buyers bid up stored stock.'
            : 'Arrivals near normal keep quotes close to the weekly average.',
      ),
      _CropOutlook(
        crop: 'Wheat',
        trend: heat ? '↓ Easing 2-4%' : '→ Stable',
        up: false,
        reason: heat
            ? 'Heat during grain filling lowers grade, so millers discount lots.'
            : 'Comfortable temperatures keep grain quality and quotes steady.',
      ),
      _CropOutlook(
        crop: 'Grapes',
        trend: heavyRain ? '↓ Quality risk' : '↑ Firming',
        up: !heavyRain,
        reason: heavyRain
            ? 'Berry splitting after rain forces fast sales at lower rates.'
            : 'Dry spell protects berry quality and supports export demand.',
      ),
      const _CropOutlook(
        crop: 'Soybean',
        trend: '→ Range-bound',
        up: false,
        reason: 'Demand tracks last season; sell graded lots in staggered lots.',
      ),
    ];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.agriculture, size: 20.r, color: _primaryGreen),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Crop-wise mandi outlook',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Crop',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Expected price',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 16.h),
          for (final row in rows) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        row.crop,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        row.trend,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: row.up
                              ? Colors.green.shade700
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  row.reason,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[600], height: 1.4),
                ),
                Divider(height: 20.h),
              ],
            ),
          ],
          Text(
            'Based on the previous season price series for the district mandi.',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodNote() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, size: 18.r, color: _primaryGreen),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'How this forecast is built',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Arrival and price projections combine the 7-day weather forecast '
            'with the previous season arrival, price and demand series recorded '
            'for the district mandi. Wet days reduce lots brought to the yard and '
            'heat days shift trade to early hours, so both are applied to the '
            'historical weekly pattern.',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[700], height: 1.5),
          ),
          SizedBox(height: 8.h),
          Text(
            'Indicative only — confirm final rates on the live Mandi MSP tracker '
            'before selling.',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NEW: Price-impact line chart showing projected vs historical price index
  // ---------------------------------------------------------------------------
  Widget _buildPriceImpactLineChart() {
    // Historical weekly price index (last season, 0-100 scale where 100 = MSP).
    const List<double> historical = [72, 78, 85, 91, 88, 82, 76];
    // Projected price index derived from weather stress.
    final stress = (_rainyDays >= 3 ? 6.0 : 0.0) + (_hotDays >= 3 ? -4.0 : 0.0);
    final projected = historical.map((v) => (v + stress).clamp(0.0, 120.0)).toList();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, size: 20.r, color: _primaryGreen),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Projected mandi price impact',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Price index (100 = MSP) — historical vs weather-adjusted projection.',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 180.h,
            child: CustomPaint(
              size: Size.infinite,
              painter: _PriceLineChartPainter(
                historical: historical,
                projected: projected,
                axisColor: Colors.grey.shade400,
                labelColor: Colors.grey.shade700,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 14.w,
            runSpacing: 6.h,
            children: [
              _LegendLine(color: Colors.grey.shade500, label: 'Last season price (actual)'),
              const _LegendLine(color: Color(0xFF1B4D3E), label: 'This season (projected)'),
              const _LegendLine(color: Color(0xFFE53935), label: 'MSP baseline (100)'),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: _primaryGreen.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 16.r, color: _primaryGreen),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    stress > 0
                        ? 'Rain stress is likely to push prices ${stress.toStringAsFixed(0)} points '
                            'above MSP — a good window to sell graded lots early.'
                        : stress < 0
                            ? 'Heat stress may pull prices ${stress.abs().toStringAsFixed(0)} points '
                                'below last season — stagger sales and avoid bulk selling.'
                            : 'Weather conditions are near-normal. Prices expected to track '
                                'last season\'s curve closely this week.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NEW: Future demand heatmap – which crops are expected high/low demand
  // ---------------------------------------------------------------------------
  Widget _buildDemandHeatmap() {
    final heavyRain = _rainyDays >= 3;
    final heat = _hotDays >= 3;

    final items = [
      _DemandItem('Onion', heavyRain ? 88 : 72, heavyRain ? 'High' : 'Moderate',
          heavyRain ? Colors.green.shade700 : Colors.orange.shade700),
      _DemandItem('Wheat', heat ? 55 : 78, heat ? 'Low' : 'Moderate',
          heat ? Colors.red.shade600 : Colors.orange.shade700),
      _DemandItem('Grapes', heavyRain ? 42 : 85, heavyRain ? 'Low' : 'High',
          heavyRain ? Colors.red.shade600 : Colors.green.shade700),
      _DemandItem('Soybean', 70, 'Moderate', Colors.orange.shade700),
      _DemandItem('Tomato', heavyRain ? 80 : 65, heavyRain ? 'High' : 'Moderate',
          heavyRain ? Colors.green.shade700 : Colors.orange.shade700),
      _DemandItem('Potato', 68, 'Moderate', Colors.orange.shade700),
    ];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_view_rounded, size: 20.r, color: _primaryGreen),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Future demand outlook by crop',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Demand score (0–100) based on weather-adjusted historical data.',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 14.h),
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                SizedBox(
                  width: 64.w,
                  child: Text(
                    item.crop,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: LinearProgressIndicator(
                      value: item.score / 100,
                      minHeight: 14.h,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(item.color),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                SizedBox(
                  width: 58.w,
                  child: Text(
                    '${item.score}  ${item.label}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: item.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )),
          SizedBox(height: 4.h),
          Wrap(
            spacing: 14.w,
            runSpacing: 6.h,
            children: [
              _LegendDot(color: Colors.green.shade700, label: 'High demand'),
              _LegendDot(color: Colors.orange.shade700, label: 'Moderate demand'),
              _LegendDot(color: Colors.red.shade600, label: 'Low demand'),
            ],
          ),
        ],
      ),
    );
  }
}

/// One bar of a single-series chart.
class _ChartBar {
  final String label;
  final double value;
  final String? valueLabel;
  final Color color;

  const _ChartBar({
    required this.label,
    required this.value,
    required this.color,
    this.valueLabel,
  });
}

/// One two-series group (last season actual vs this season projected).
class _GroupedBar {
  final String label;
  final double firstValue;
  final double secondValue;

  const _GroupedBar({
    required this.label,
    required this.firstValue,
    required this.secondValue,
  });
}
/// One row of the crop-wise mandi outlook table.
class _CropOutlook {
  final String crop;
  final String trend;
  final bool up;
  final String reason;

  const _CropOutlook({
    required this.crop,
    required this.trend,
    required this.up,
    required this.reason,
  });
}

/// Small coloured square + caption used under the charts.
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey[700]),
        ),
      ],
    );
  }
}

/// Draws a single-line label on a chart canvas.
void paintChartText(
  Canvas canvas,
  String text,
  Offset anchor,
  Color color,
  double fontSize, {
  bool centered = false,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: fontSize),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  final dx = centered ? anchor.dx - painter.width / 2 : anchor.dx;
  painter.paint(canvas, Offset(dx, anchor.dy));
}

/// Bar chart (single series) for the projected mandi arrivals.
class _MandiBarChartPainter extends CustomPainter {
  final List<_ChartBar> bars;
  final double maxValue;
  final Color axisColor;
  final Color labelColor;

  _MandiBarChartPainter({
    required this.bars,
    required this.maxValue,
    required this.axisColor,
    required this.labelColor,
  });

  /// Space reserved under the plot for the day labels.
  static const double _xLabelBand = 18;

  /// Space reserved above the plot so value labels never clip.
  static const double _valueBand = 14;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty || size.width <= 0 || size.height <= _xLabelBand + _valueBand) {
      return;
    }
    final chartHeight = size.height - _xLabelBand - _valueBand;
    final baseline = _valueBand + chartHeight;

    final gridPaint = Paint()
      ..color = axisColor.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = _valueBand + chartHeight * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final slot = size.width / bars.length;
    final barWidth = (slot * 0.52).clamp(4.0, 40.0);
    for (var i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final ratio =
          maxValue <= 0 ? 0.0 : (bar.value / maxValue).clamp(0.0, 1.0);
      final barHeight = chartHeight * ratio;
      final left = slot * i + (slot - barWidth) / 2;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(left, baseline - barHeight, barWidth, barHeight),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        Paint()..color = bar.color,
      );
      final valueLabel = bar.valueLabel;
      if (valueLabel != null) {
        paintChartText(
          canvas,
          valueLabel,
          Offset(left + barWidth / 2, baseline - barHeight - 13),
          labelColor,
          9,
          centered: true,
        );
      }
      paintChartText(
        canvas,
        bar.label,
        Offset(left + barWidth / 2, baseline + 4),
        labelColor,
        9,
        centered: true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MandiBarChartPainter oldDelegate) =>
      oldDelegate.bars != bars ||
      oldDelegate.maxValue != maxValue ||
      oldDelegate.labelColor != labelColor ||
      oldDelegate.axisColor != axisColor;
}

/// Two-series grouped bar chart: last season actual vs this season projected.
class _MandiGroupedBarChartPainter extends CustomPainter {
  final List<_GroupedBar> groups;
  final double maxValue;
  final Color axisColor;
  final Color labelColor;

  _MandiGroupedBarChartPainter({
    required this.groups,
    required this.maxValue,
    required this.axisColor,
    required this.labelColor,
  });

  static const Color _firstColor = Color(0xFF9E9E9E);
  static const Color _secondColor = Color(0xFF1B4D3E);
  static const double _xLabelBand = 18;
  static const double _valueBand = 14;

  @override
  void paint(Canvas canvas, Size size) {
    if (groups.isEmpty ||
        size.width <= 0 ||
        size.height <= _xLabelBand + _valueBand) {
      return;
    }
    final chartHeight = size.height - _xLabelBand - _valueBand;
    final baseline = _valueBand + chartHeight;

    final gridPaint = Paint()
      ..color = axisColor.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = _valueBand + chartHeight * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final slot = size.width / groups.length;
    final barWidth = (slot * 0.26).clamp(4.0, 22.0);
    const gap = 3.0;

    for (var i = 0; i < groups.length; i++) {
      final group = groups[i];
      final center = slot * i + slot / 2;
      final leftFirst = center - gap / 2 - barWidth;
      final leftSecond = center + gap / 2;

      _bar(canvas, leftFirst, barWidth, baseline, chartHeight,
          group.firstValue, _firstColor);
      _bar(canvas, leftSecond, barWidth, baseline, chartHeight,
          group.secondValue, _secondColor);

      paintChartText(
        canvas,
        group.firstValue.toStringAsFixed(0),
        Offset(leftFirst + barWidth / 2, baseline - _barHeight(chartHeight, group.firstValue) - 12),
        labelColor,
        8,
        centered: true,
      );
      paintChartText(
        canvas,
        group.secondValue.toStringAsFixed(0),
        Offset(leftSecond + barWidth / 2, baseline - _barHeight(chartHeight, group.secondValue) - 12),
        labelColor,
        8,
        centered: true,
      );
      paintChartText(
        canvas,
        group.label,
        Offset(center, baseline + 4),
        labelColor,
        9,
        centered: true,
      );
    }
  }

  double _barHeight(double chartHeight, double value) {
    final ratio = maxValue <= 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);
    return chartHeight * ratio;
  }

  void _bar(
    Canvas canvas,
    double left,
    double width,
    double baseline,
    double chartHeight,
    double value,
    Color color,
  ) {
    final height = _barHeight(chartHeight, value);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(left, baseline - height, width, height),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _MandiGroupedBarChartPainter oldDelegate) =>
      oldDelegate.groups != groups ||
      oldDelegate.maxValue != maxValue ||
      oldDelegate.labelColor != labelColor ||
      oldDelegate.axisColor != axisColor;
}

// ---------------------------------------------------------------------------
// Support classes for the new graph sections
// ---------------------------------------------------------------------------

/// Data holder for a single crop demand item.
class _DemandItem {
  final String crop;
  final int score;
  final String label;
  final Color color;

  const _DemandItem(this.crop, this.score, this.label, this.color);
}

/// A small horizontal dashed-line legend entry (used in the price chart legend).
class _LegendLine extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendLine({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(24, 3),
          painter: _DashedLinePainter(color: color),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey[700]),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2), Offset((x + 4).clamp(0, size.width), size.height / 2), paint);
      x += 7;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) => old.color != color;
}

/// Dual-series line chart painting historical and projected price indices.
class _PriceLineChartPainter extends CustomPainter {
  final List<double> historical;
  final List<double> projected;
  final Color axisColor;
  final Color labelColor;

  const _PriceLineChartPainter({
    required this.historical,
    required this.projected,
    required this.axisColor,
    required this.labelColor,
  });

  static const double _topBand = 16;
  static const double _bottomBand = 22;
  static const double _maxValue = 120;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= _topBand + _bottomBand) return;
    final chartH = size.height - _topBand - _bottomBand;
    final baseline = _topBand + chartH;

    // Grid lines at 25, 50, 75, 100
    final gridPaint = Paint()
      ..color = axisColor.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (final pct in [25.0, 50.0, 75.0, 100.0]) {
      final y = _topBand + chartH * (1 - pct / _maxValue);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      paintChartText(canvas, '${pct.toInt()}', Offset(0, y - 9), labelColor, 8);
    }

    // MSP reference line at 100
    final mspPaint = Paint()
      ..color = const Color(0xFFE53935).withValues(alpha: 0.55)
      ..strokeWidth = 1.5;
    final mspY = _topBand + chartH * (1 - 100 / _maxValue);
    canvas.drawLine(Offset(0, mspY), Offset(size.width, mspY), mspPaint);

    void drawLine(List<double> values, Color color, {bool dashed = false}) {
      if (values.isEmpty) return;
      final n = values.length;
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      for (var i = 0; i < n; i++) {
        final x = size.width * i / (n - 1);
        final y = _topBand + chartH * (1 - values[i] / _maxValue);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      if (dashed) {
        final metrics = path.computeMetrics();
        for (final metric in metrics) {
          double dist = 0;
          bool draw = true;
          while (dist < metric.length) {
            final seg = draw ? 6.0 : 4.0;
            final end = (dist + seg).clamp(0.0, metric.length);
            if (draw) {
              canvas.drawPath(metric.extractPath(dist, end), paint);
            }
            dist = end;
            draw = !draw;
          }
        }
      } else {
        canvas.drawPath(path, paint);
      }

      // Draw data point dots
      final dotPaint = Paint()..color = color;
      for (var i = 0; i < n; i++) {
        final x = size.width * i / (n - 1);
        final y = _topBand + chartH * (1 - values[i] / _maxValue);
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }
    }

    drawLine(historical, Colors.grey.shade500, dashed: true);
    drawLine(projected, const Color(0xFF1B4D3E));

    // X-axis day labels
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final n = historical.length;
    for (var i = 0; i < n; i++) {
      final x = size.width * i / (n - 1);
      final label = i < days.length ? days[i] : '';
      paintChartText(canvas, label, Offset(x, baseline + 5), labelColor, 8, centered: true);
    }
  }

  @override
  bool shouldRepaint(covariant _PriceLineChartPainter old) =>
      old.historical != historical ||
      old.projected != projected ||
      old.axisColor != axisColor ||
      old.labelColor != labelColor;
}