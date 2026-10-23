import '../../dashboard/screens/main_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/farmer_profile_provider.dart';

class FarmerProfileScreen extends ConsumerWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(farmerProfileProvider);
    final profileNotifier = ref.read(farmerProfileProvider.notifier);
    const primaryGreen = Color(0xFF1B4D3E);

    // Common Indian crops for the selection grid
    final List<String> availableCrops = [
      'Wheat / गेहूं', 'Rice / चावल', 'Cotton / कपास', 'Sugarcane / गन्ना',
      'Maize / मक्का', 'Millet / बाजरा', 'Soybean / सोयाबीन', 'Pulses / दालें'
    ];

    // Common soil types
    final List<String> soilTypes = [
      'Unknown / पता नहीं', 'Alluvial / जलोढ़', 'Black / काली', 
      'Red / लाल', 'Laterite / लैटेराइट', 'Arid / शुष्क'
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        title: Text(
          'Setup Farm Profile',
          style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevent going back to OTP
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us about your farm',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: primaryGreen),
              ),
              SizedBox(height: 8.h),
              Text(
                'This helps our AI personalize your masterclasses and recommendations.',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              ),
              SizedBox(height: 32.h),

              // 1. Farmer Name
              TextField(
                onChanged: profileNotifier.updateName,
                decoration: InputDecoration(
                  labelText: 'Full Name / पूरा नाम',
                  prefixIcon: const Icon(Icons.person, color: primaryGreen),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: primaryGreen, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // 2. Land Size & Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: profileNotifier.updateLandSize,
                      decoration: InputDecoration(
                        labelText: 'Land Size / ज़मीन का आकार',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: primaryGreen, width: 2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: profileState.landUnit,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      items: ['Acres', 'Hectares', 'Bigha', 'Gunta'].map((String unit) {
                        return DropdownMenuItem(value: unit, child: Text(unit));
                      }).toList(),
                      onChanged: (val) => profileNotifier.updateLandUnit(val!),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // 3. Soil Type
              DropdownButtonFormField<String>(
                initialValue: profileState.soilType,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Soil Type / मिट्टी का प्रकार',
                  prefixIcon: const Icon(Icons.landscape, color: primaryGreen),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                items: soilTypes.map((String soil) {
                  return DropdownMenuItem(value: soil, child: Text(soil, style: TextStyle(fontSize: 14.sp)));
                }).toList(),
                onChanged: (val) => profileNotifier.updateSoilType(val!),
              ),
              SizedBox(height: 24.h),

              // 4. Primary Crops (Multi-Select Chips)
              Text(
                'Primary Crops / मुख्य फसलें',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: availableCrops.map((crop) {
                  final isSelected = profileState.selectedCrops.contains(crop);
                  return FilterChip(
                    label: Text(crop),
                    selected: isSelected,
                    selectedColor: primaryGreen.withValues(alpha: 0.2),
                    checkmarkColor: primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? primaryGreen : Colors.grey[800],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => profileNotifier.toggleCrop(crop),
                  );
                }).toList(),
              ),
              
              SizedBox(height: 48.h),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  minimumSize: Size(double.infinity, 54.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: (profileState.name.isEmpty || profileState.landSize.isEmpty)
                    ? null // Disable if name or size is empty
                    : () async {
                        bool success = await profileNotifier.submitProfile();
                        if (success && context.mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Profile created successfully!')),
  );
  
  // Launch the user into the Main Dashboard!
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
  );
}
                      },
                child: profileState.isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Complete Setup / पूरा करें',
                        style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}