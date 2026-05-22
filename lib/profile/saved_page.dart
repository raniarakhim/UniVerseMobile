import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/core/services/saved_events_service.dart';
import 'package:diplomka/core/services/saved_housing_service.dart';
import 'package:diplomka/core/services/saved_items_registry.dart';
import 'package:diplomka/core/services/saved_jobs_service.dart';
import 'package:diplomka/events/event_details_page.dart';
import 'package:diplomka/events/models/event_item.dart';
import 'package:diplomka/events/widgets/event_list_card.dart';
import 'package:diplomka/housing/housing_details_page.dart';
import 'package:diplomka/housing/models/housing_item.dart';
import 'package:diplomka/job/job_details_page.dart';
import 'package:diplomka/job/models/job_item.dart';
import 'package:diplomka/job/models/saved_job_item.dart';
import 'package:diplomka/core/widgets/home_detail_app_bar.dart';
import 'package:diplomka/housing/widgets/housing_list_card.dart';
import 'package:diplomka/job/widgets/saved_job_tile.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  int _tabIndex = 0;

  final _eventsService = SavedEventsService.instance;
  final _jobsService = SavedJobsService.instance;
  final _housingService = SavedHousingService.instance;

  @override
  void initState() {
    super.initState();
    for (final service in [_eventsService, _jobsService, _housingService]) {
      service.addListener(_onSavedChanged);
    }
  }

  @override
  void dispose() {
    for (final service in [_eventsService, _jobsService, _housingService]) {
      service.removeListener(_onSavedChanged);
    }
    super.dispose();
  }

  void _onSavedChanged() {
    if (mounted) setState(() {});
  }

  List<JobItem> get _jobs => SavedItemsRegistry.savedJobs;

  List<HousingItem> get _housing => SavedItemsRegistry.savedHousing;

  List<EventItem> get _events => SavedItemsRegistry.savedEvents;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            const HomeDetailAppBar(title: 'Saved'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _tabSwitcher(),
            ),
            Expanded(
              child: switch (_tabIndex) {
                0 => _jobsList(),
                1 => _housingList(),
                _ => _eventsList(),
              },
            ),
            if (_tabIndex == 0 && _jobs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Swipe left to remove from saved',
                  style: TextStyle(fontSize: 12, color: HomeTheme.tagMuted.withValues(alpha: 0.7)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tabSwitcher() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: HomeTheme.chipInactive,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(child: _tabButton('Jobs', 0)),
          Expanded(child: _tabButton('Housing', 1)),
          Expanded(child: _tabButton('Events', 2)),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? HomeTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? HomeTheme.surfaceBackground : HomeTheme.accent,
          ),
        ),
      ),
    );
  }

  Widget _jobsList() {
    final jobs = _jobs;
    if (jobs.isEmpty) {
      return _emptyState('No saved jobs', 'Tap Save on a job to add it here.');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: jobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final job = jobs[index];
        final tile = SavedJobItem.fromJob(job);
        return Dismissible(
          key: ValueKey(job.saveId),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _jobsService.setSaved(job.saveId, false),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: HomeTheme.error.withValues(alpha: 0.1),
            child: const Icon(Icons.delete_outline, color: HomeTheme.error),
          ),
          child: SavedJobTile(
            item: tile,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => JobDetailsPage(job: job)),
              );
            },
            onUnsave: () => _jobsService.setSaved(job.saveId, false),
          ),
        );
      },
    );
  }

  Widget _housingList() {
    final housing = _housing;
    if (housing.isEmpty) {
      return _emptyState('No saved housing', 'Tap Save on a listing to add it here.');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: housing.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = housing[index];
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _housingService.setSaved(item.id, false),
          child: HousingListCard(
            item: item,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HousingDetailsPage(
                    key: ValueKey(item.id),
                    item: item,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _eventsList() {
    final events = _events;
    if (events.isEmpty) {
      return _emptyState('No saved events', 'Tap Save on an event to add it here.');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final event = events[index];
        final isSaved = _eventsService.isSavedWithDefault(
          event.id,
          defaultValue: event.isFavorite,
        );
        return Dismissible(
          key: ValueKey(event.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _eventsService.setSaved(
            event.id,
            false,
            defaultValue: event.isFavorite,
          ),
          child: EventCompactCard(
            event: event.withFavorite(isSaved),
            onFavoriteToggle: () => _eventsService.toggle(
              event.id,
              defaultValue: event.isFavorite,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailsPage(event: event),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _emptyState(String title, String hint) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: HomeTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: HomeTheme.tagMuted),
            ),
          ],
        ),
      ),
    );
  }
}
