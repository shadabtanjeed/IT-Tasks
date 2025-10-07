import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final scaleProvider = StateNotifierProvider<ScaleNotifier, double>((ref) {
  return ScaleNotifier();
});

class ScaleNotifier extends StateNotifier<double> {
  static const _key = 'ui_scale_factor';
  ScaleNotifier() : super(1.0) {
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getDouble(_key);
    if (v != null) state = v;
  }

  Future<void> setScale(double v) async {
    state = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble(_key, v);
  }
}
