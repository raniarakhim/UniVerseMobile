import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сохранённые вакансии (общий список между Job Details и Saved).
class SavedJobsService extends ChangeNotifier {
  SavedJobsService._();

  static final SavedJobsService instance = SavedJobsService._();

  static const _prefsKey = 'saved_job_ids';

  final Set<String> _savedIds = {};
  bool _loaded = false;

  bool get isReady => _loaded;

  bool isSaved(String jobId) => _savedIds.contains(jobId);

  List<String> get savedIdsOrdered => _savedIds.toList();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _savedIds
      ..clear()
      ..addAll(prefs.getStringList(_prefsKey) ?? const []);
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(String jobId) async {
    if (_savedIds.contains(jobId)) {
      _savedIds.remove(jobId);
    } else {
      _savedIds.add(jobId);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> setSaved(String jobId, bool saved) async {
    if (saved) {
      _savedIds.add(jobId);
    } else {
      _savedIds.remove(jobId);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _savedIds.toList());
  }
}
