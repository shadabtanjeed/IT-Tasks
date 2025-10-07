import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  static const _key = 'is_dark_mode';
  ThemeNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getBool(_key);
    if (v != null) state = v;
  }

  Future<void> setDark(bool v) async {
    state = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_key, v);
  }
}
