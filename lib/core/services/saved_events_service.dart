import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Избранные события (список Events, детали, экран Saved).
class SavedEventsService extends ChangeNotifier {
  SavedEventsService._();

  static final SavedEventsService instance = SavedEventsService._();

  static const _savedKey = 'saved_event_ids';
  static const _removedKey = 'saved_event_removed_ids';

  final Set<String> _savedIds = {};
  final Set<String> _removedIds = {};
  bool _loaded = false;

  bool get isReady => _loaded;

  List<String> get savedIdsOrdered => _savedIds.toList();

  bool isSaved(String eventId) => _savedIds.contains(eventId);

  bool isSavedWithDefault(String eventId, {bool defaultValue = false}) {
    if (_removedIds.contains(eventId)) return false;
    if (_savedIds.contains(eventId)) return true;
    return defaultValue;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _savedIds
      ..clear()
      ..addAll(prefs.getStringList(_savedKey) ?? const []);
    _removedIds
      ..clear()
      ..addAll(prefs.getStringList(_removedKey) ?? const []);
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(String eventId, {bool defaultValue = false}) async {
    final currently = isSavedWithDefault(eventId, defaultValue: defaultValue);
    if (currently) {
      _savedIds.remove(eventId);
      _removedIds.add(eventId);
    } else {
      _savedIds.add(eventId);
      _removedIds.remove(eventId);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> setSaved(String eventId, bool saved, {bool defaultValue = false}) async {
    if (saved) {
      _savedIds.add(eventId);
      _removedIds.remove(eventId);
    } else {
      _savedIds.remove(eventId);
      if (defaultValue) _removedIds.add(eventId);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedKey, _savedIds.toList());
    await prefs.setStringList(_removedKey, _removedIds.toList());
  }
}
