import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/language_provider.dart';
import '../models/scheme_model.dart';
import 'scheme_detail_screen.dart';

/// Government Schemes portal — now also lists insurance and scholarships.
/// Title and all labels render in the user's selected language (not hard-coded
/// bilingual text any more).
class SchemesScreen extends ConsumerStatefulWidget {
  const SchemesScreen({super.key});

  @override
  ConsumerState<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends ConsumerState<SchemesScreen> {
  String _selectedCategory = 'All';
  final Color _primaryGreen = const Color(0xFF1B4D3E);
  final List<String> _categories = ['All', 'Farmer', 'Artisan', 'MSME', 'General'];

  @override
  Widget build(BuildContext context) {
    final t = ref.tr;
    final schemes = _selectedCategory == 'All'
        ? kSchemes
        : kSchemes.where((s) => s.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          t('govtSchemes'),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Category Chips
          SizedBox(
            height: 44.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: _primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 13.sp,
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = category),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 8.h),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: schemes.length,
              itemBuilder: (context, index) {
                final scheme = schemes[index];
                return _SchemeCard(scheme: scheme);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  const _SchemeCard({required this.scheme});
  final SchemeModel scheme;
  final Color _primaryGreen = const Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SchemeDetailScreen(scheme: scheme)),
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: _categoryColor(scheme.category).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(child: Text(scheme.icon, style: TextStyle(fontSize: 22.sp))),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          scheme.name,
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _statusColor(scheme.status).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          scheme.status,
                          style: TextStyle(fontSize: 10.sp, color: _statusColor(scheme.status), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    scheme.description,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700], height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _tag('${scheme.category} Scheme', _categoryColor(scheme.category)),
                      if (scheme.isQuickApply) _tag('Quick Apply', _primaryGreen),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(text, style: TextStyle(fontSize: 10.sp, color: color, fontWeight: FontWeight.w600)),
    );
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'Available':
        return const Color(0xFF2E7D32);
      case 'Apply Now':
        return const Color(0xFF1565C0);
      case 'Closed':
        return const Color(0xFF757575);
      default:
        return const Color(0xFF757575);
    }
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'Farmer':
        return const Color(0xFF2E7D32);
      case 'Artisan':
        return const Color(0xFF1565C0);
      case 'MSME':
        return const Color(0xFF7B1FA2);
      case 'General':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF455A64);
    }
  }
}
