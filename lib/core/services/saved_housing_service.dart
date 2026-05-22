import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сохранённое жильё (Housing Details ↔ Saved).
class SavedHousingService extends ChangeNotifier {
  SavedHousingService._();

  static final SavedHousingService instance = SavedHousingService._();

  static const _prefsKey = 'saved_housing_ids';

  final Set<String> _savedIds = {};
  bool _loaded = false;

  bool get isReady => _loaded;

  bool isSaved(String housingId) => _savedIds.contains(housingId);

  List<String> get savedIdsOrdered => _savedIds.toList();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _savedIds
      ..clear()
      ..addAll(prefs.getStringList(_prefsKey) ?? const []);
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(String housingId) async {
    if (_savedIds.contains(housingId)) {
      _savedIds.remove(housingId);
    } else {
      _savedIds.add(housingId);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> setSaved(String housingId, bool saved) async {
    if (saved) {
      _savedIds.add(housingId);
    } else {
      _savedIds.remove(housingId);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _savedIds.toList());
  }
}
