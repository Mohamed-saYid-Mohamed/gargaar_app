import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'translations.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, String>(
  (ref) => LanguageNotifier(),
);

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('en');

  void setLanguage(String lang) {
    state = lang;
  }

  /// Returns translated strings for current language
  Map<String, String> get strings => translations[state] ?? translations['en']!;
}
