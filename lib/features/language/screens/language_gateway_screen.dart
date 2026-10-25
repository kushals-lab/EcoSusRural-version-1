import '../../legal/screens/legal_agreement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/translation/translation_repository.dart';
import '../models/language_model.dart';
import '../providers/language_selection_provider.dart';

class LanguageGatewayScreen extends ConsumerWidget {
  /// When true (opened from Settings / Seller menu), picking a language
  /// applies it and pops back to where the user left off instead of forcing
  /// the onboarding forward into the Legal screen.
  final bool popAfterSelect;

  const LanguageGatewayScreen({super.key, this.popAfterSelect = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(languageSelectionProvider);
    final notifier = ref.read(languageSelectionProvider.notifier);

    // Use current active locale for screen labels so that once a language is
    // selected, the same language is used for the rest of the app's UI text.
    final langCode = ref.watch(languageProvider).code;

    // Filter languages based on search query and region filter.
    // The query is lowercased once (not 3x per language per build) and the
    // region predicate short-circuits first since it rejects the most items.
    final query = state.searchQuery.toLowerCase();
    final region = state.selectedRegion;
    final filteredLanguages = query.isEmpty && region == 'All'
        ? kSupportedLanguages
        : kSupportedLanguages.where((lang) {
            if (region != 'All' && lang.region != region) return false;
            if (query.isEmpty) return true;
            return lang.nativeName.toLowerCase().contains(query) ||
                lang.englishName.toLowerCase().contains(query) ||
                lang.code.toLowerCase().contains(query);
          }).toList();

    final t = ref.read(languageProvider.notifier).translate;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        title: Text(
          t('selectLanguage', langCode),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1B4D3E)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),

            // Search Bar + Voice Input Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: notifier.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: ref.tr('searchLanguage'),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF1B4D3E)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      // Voice-first AI Language Recognition trigger
                      notifier.toggleVoiceListening(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ref.tr('voiceFeeNote'))),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B4D3E),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        state.isListeningVoice ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 24.r,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // Regional Grouping Toggles
            SizedBox(
              height: 38.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: ['All', 'India', 'World'].map((region) {
                  final isSelected = state.selectedRegion == region;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: ChoiceChip(
                      label: Text(ref.tr(switch (region) {
                        'India' => 'indiaRegion',
                        'World' => 'worldRegion',
                        _ => 'allRegions',
                      })),
                      selected: isSelected,
                      selectedColor: const Color(0xFF1B4D3E),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF1B4D3E),
                        fontSize: 12.sp,
                      ),
                      onSelected: (_) => notifier.setRegionFilter(region),
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 12.h),

            // 60+ Touch-Friendly Language Grid Cards
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16.r),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  mainAxisExtent: (72.w * MediaQuery.textScalerOf(context).scale(1.0)).toDouble(),
                ),
                itemCount: filteredLanguages.length,
                itemBuilder: (context, index) {
                  final lang = filteredLanguages[index];
                  return InkWell(
                    onTap: () => _showConfirmationModal(context, ref, lang),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              lang.nativeName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1B4D3E),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Flexible(
                            child: Text(
                              lang.englishName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Interactive Confirmation Dialog displaying a sample sentence in the
  /// native script; the confirm button is rendered in the SELECTED language.
  void _showConfirmationModal(BuildContext context, WidgetRef ref, LanguageModel lang) {
    // Captured before the bottom-sheet builder shadows `context`.
    final parentContext = context;
    showModalBottomSheet(
      context: context,
      // Scrollable content: never overflows on short screens / desktop.
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(24.r),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lang.nativeName,
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1B4D3E)),
                ),
                SizedBox(height: 4.h),
                Text(
                  lang.englishName,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 8.h),
                Directionality(
                  // Urdu/Kashmiri/Sindhi/Arabic/Hebrew read right-to-left.
                  textDirection: _isRtl(lang.code) ? TextDirection.rtl : TextDirection.ltr,
                  child: Text(
                    lang.sampleSentence,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[800]),
                  ),
                ),
                SizedBox(height: 24.h),
                // Confirm button fully rendered in the user-selected language.
                FutureBuilder<void>(
                  future: TranslationRepository.instance.packFor(lang.code),
                  builder: (context, snap) {
                    final label = ref.read(languageProvider.notifier).translate(
                          'confirmContinue',
                          lang.code,
                        );
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4D3E),
                        minimumSize: Size(double.infinity, 48.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onPressed: snap.connectionState == ConnectionState.done
                          ? () async {
                              // Set active locale globally in Riverpod & storage
                              await ref.read(languageProvider.notifier).changeLanguage(lang.code);
                              if (context.mounted) {
                                Navigator.pop(context); // Close sheet
                              }
                              if (!parentContext.mounted) return;
                              if (popAfterSelect) {
                                // Opened from Settings / Seller menu: return to
                                // exactly where the user left off.
                                Navigator.pop(parentContext);
                              } else {
                                // Onboarding: navigates to the Legal Screen
                                Navigator.pushReplacement(
                                  parentContext,
                                  MaterialPageRoute(builder: (context) => const LegalAgreementScreen()),
                                );
                              }
                            }
                          : null,
                      child: Text(
                        label,
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static bool _isRtl(String code) =>
      const {'ur', 'ks', 'sd', 'ar', 'he', 'syr', 'pah'}.contains(code);
}
