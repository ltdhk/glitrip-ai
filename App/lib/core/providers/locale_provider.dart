import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  //LocaleNotifier() : super(const Locale('zh')); // 默认中文
  LocaleNotifier() : super(const Locale('en')); // 默认英文
  void setLocale(Locale locale) {
    state = locale;
  }

  void toggleLocale() {
    if (state.languageCode == 'zh') {
      state = const Locale('en');
    } else {
      state = const Locale('zh');
    }
  }
}
