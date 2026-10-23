import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Full-screen confirmation shown immediately after the user taps "Set alert"
/// on the Weather Intelligence page.
class WeatherAlertSetScreen extends StatelessWidget {
  /// Village / district the alert is registered for.
  final String village;

  /// Short description of the conditions that will trigger the alert.
  final String triggerSummary;

  const WeatherAlertSetScreen({
    super.key,
    this.village = 'Nashik, Maharashtra',
    this.triggerSummary =
        'Heavy rain (≥5 mm), thunderstorm risk, or heat above 35°C',
  });

  static const Color _primaryGreen = Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Weather Alert',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: _primaryGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 24.h),
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.6, end: 1),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Container(
                    width: 120.r,
                    height: 120.r,
                    decoration: BoxDecoration(
                      color: _primaryGreen.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                      border: Border.all(color: _primaryGreen, width: 2),
                    ),
                    child: Icon(
                      Icons.alarm_on,
                      size: 56.r,
                      color: _primaryGreen,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green.shade600, size: 22.r),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      'Alarm set successfully',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: _primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                'Weather alerts are now active for $village.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What you will be alerted about',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _alertRow(
                      Icons.umbrella,
                      'Rain & thunderstorm',
                      'Ahead-of-time warning before spray or harvest windows close.',
                    ),
                    _alertRow(
                      Icons.thermostat,
                      'Heat & cold stress',
                      'When the forecast crosses your crop stress threshold.',
                    ),
                    _alertRow(
                      Icons.storefront,
                      'Mandi impact',
                      'Price and arrival swings expected from the coming weather.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notifications_active,
                        size: 18.r, color: Colors.amber.shade900),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Trigger: $triggerSummary. You can turn this alert off '
                        'any time from Weather Intelligence or Settings.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.amber.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.check, size: 18, color: Colors.white),
                label: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Alerts are generated from the same 7-day forecast shown on the '
                'Weather Intelligence page.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _alertRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.r, color: _primaryGreen),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}