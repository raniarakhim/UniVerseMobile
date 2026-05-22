import 'package:diplomka/core/services/saved_events_service.dart';
import 'package:diplomka/core/services/saved_housing_service.dart';
import 'package:diplomka/core/services/saved_jobs_service.dart';
import 'package:diplomka/events/models/event_item.dart';
import 'package:diplomka/housing/models/housing_item.dart';
import 'package:diplomka/job/models/job_item.dart';

/// Загрузка сохранённых id и подсчёт для профиля.
class SavedItemsRegistry {
  SavedItemsRegistry._();

  static Future<void> loadAll() async {
    await Future.wait([
      SavedEventsService.instance.load(),
      SavedJobsService.instance.load(),
      SavedHousingService.instance.load(),
    ]);
  }

  static int get totalCount =>
      savedEvents.length + savedJobs.length + savedHousing.length;

  static List<EventItem> get savedEvents => EventItem.sample
      .where(
        (e) => SavedEventsService.instance.isSavedWithDefault(
          e.id,
          defaultValue: e.isFavorite,
        ),
      )
      .toList();

  static List<JobItem> get savedJobs {
    final jobs = <JobItem>[];
    for (final id in SavedJobsService.instance.savedIdsOrdered) {
      final job = JobItem.bySaveId(id);
      if (job != null) jobs.add(job);
    }
    return jobs;
  }

  static List<HousingItem> get savedHousing {
    final items = <HousingItem>[];
    for (final id in SavedHousingService.instance.savedIdsOrdered) {
      final item = HousingItem.byId(id);
      if (item != null) items.add(item);
    }
    return items;
  }
}
