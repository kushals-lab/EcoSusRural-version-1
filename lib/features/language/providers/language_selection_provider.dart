import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/language_model.dart';

class LanguageSelectionState {
  final String searchQuery;
  final String selectedRegion; // 'All' or region name
  final LanguageModel? selectedLanguage;
  final bool isListeningVoice;

  LanguageSelectionState({
    this.searchQuery = '',
    this.selectedRegion = 'All',
    this.selectedLanguage,
    this.isListeningVoice = false,
  });

  LanguageSelectionState copyWith({
    String? searchQuery,
    String? selectedRegion,
    LanguageModel? selectedLanguage,
    bool? isListeningVoice,
  }) {
    return LanguageSelectionState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      isListeningVoice: isListeningVoice ?? this.isListeningVoice,
    );
  }
}

class LanguageSelectionNotifier extends StateNotifier<LanguageSelectionState> {
  LanguageSelectionNotifier() : super(LanguageSelectionState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setRegionFilter(String region) {
    state = state.copyWith(selectedRegion: region);
  }

  void selectLanguage(LanguageModel language) {
    state = state.copyWith(selectedLanguage: language);
  }

  void toggleVoiceListening(bool listening) {
    state = state.copyWith(isListeningVoice: listening);
  }
}

final languageSelectionProvider =
    StateNotifierProvider<LanguageSelectionNotifier, LanguageSelectionState>(
        (ref) => LanguageSelectionNotifier());