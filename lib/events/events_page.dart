import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/events/event_details_page.dart';
import 'package:diplomka/events/event_register_page.dart';
import 'package:diplomka/events/models/event_item.dart';
import 'package:diplomka/core/services/saved_events_service.dart';
import 'package:diplomka/events/widgets/event_list_card.dart';
import 'package:diplomka/core/widgets/home_detail_app_bar.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({
    super.key,
    this.showBackButton = false,
    this.onBack,
  });

  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  static const _months = ['MAY', 'JUNE', 'JULY', 'AUGUST'];
  static const _categories = ['All', 'Career', 'Startup', 'Design', 'Free'];

  int _monthIndex = 0;
  int _categoryIndex = 0;
  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final _savedService = SavedEventsService.instance;

  @override
  void initState() {
    super.initState();
    _savedService.addListener(_onSavedChanged);
  }

  void _onSavedChanged() {
    if (mounted) setState(() {});
  }

  void _openSearch() {
    setState(() => _searchOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    setState(() => _searchOpen = false);
    _searchFocus.unfocus();
  }

  @override
  void dispose() {
    _savedService.removeListener(_onSavedChanged);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  EventCategory get _selectedCategory {
    switch (_categoryIndex) {
      case 1:
        return EventCategory.career;
      case 2:
        return EventCategory.startup;
      case 3:
        return EventCategory.design;
      case 4:
        return EventCategory.free;
      default:
        return EventCategory.all;
    }
  }

  List<EventItem> get _events {
    final month = _months[_monthIndex];
    var list = EventItem.sample.where((e) => e.month == month).toList();
    if (_selectedCategory != EventCategory.all) {
      list = list.where((e) => e.category == _selectedCategory).toList();
    }
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (e) =>
                e.title.toLowerCase().contains(q) ||
                e.subtitle.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  bool _isFavorite(EventItem e) =>
      _savedService.isSavedWithDefault(e.id, defaultValue: e.isFavorite);

  EventItem _withFavorite(EventItem e) =>
      EventItem(
        id: e.id,
        title: e.title,
        subtitle: e.subtitle,
        month: e.month,
        day: e.day,
        sectionTitle: e.sectionTitle,
        category: e.category,
        tags: e.tags,
        priceLabel: e.priceLabel,
        isFeatured: e.isFeatured,
        isFavorite: _isFavorite(e),
        accentColor: e.accentColor,
        time: e.time,
        dateLabel: e.dateLabel,
        organizerName: e.organizerName,
        contactEmail: e.contactEmail,
        contactPhone: e.contactPhone,
      );

  void _toggleFavorite(EventItem event) => _savedService.toggle(
        event.id,
        defaultValue: event.isFavorite,
      );

  void _openEvent(EventItem event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(event: event),
      ),
    );
  }

  void _openRegister(EventItem event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventRegisterPage(event: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<EventItem>>{};
    for (final e in _events) {
      grouped.putIfAbsent(e.sectionTitle, () => []).add(e);
    }

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          HomeTheme.horizontalPadding,
          8,
          HomeTheme.horizontalPadding,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showBackButton) ...[
              HomeDetailAppBar(
                title: 'Events',
                onBack: widget.onBack,
                trailing: _searchHeaderButton(),
              ),
              if (_searchOpen) ...[
                const SizedBox(height: 12),
                _searchField(),
              ],
              const SizedBox(height: 8),
            ] else
              _header(),
            const SizedBox(height: 12),
            _monthSwitcher(),
            const SizedBox(height: 12),
            _categoryChips(),
            const SizedBox(height: 12),
            ...grouped.entries.expand((entry) {
              return [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: HomeTheme.bodyText,
                  ),
                ),
                const SizedBox(height: 6),
                ...entry.value.map((raw) {
                  final event = _withFavorite(raw);
                  if (event.isFeatured) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: EventFeaturedCard(
                        event: event,
                        onFavoriteToggle: () => _toggleFavorite(raw),
                        onTap: () => _openRegister(event),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: EventCompactCard(
                      event: event,
                      onFavoriteToggle: () => _toggleFavorite(raw),
                      onTap: () => _openEvent(event),
                    ),
                  );
                }),
                const SizedBox(height: 4),
              ];
            }),
            if (_events.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No events for this filter',
                    style: TextStyle(color: HomeTheme.tagMuted),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Events',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 36 / 28,
                  color: HomeTheme.infoBox,
                ),
              ),
            ),
            _searchHeaderButton(),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: _searchOpen
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _searchField(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _searchHeaderButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: _searchOpen
          ? Material(
              key: const ValueKey('events-search-close'),
              color: HomeTheme.surfaceBackground,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _closeSearch,
                borderRadius: BorderRadius.circular(20),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.close, size: 24, color: HomeTheme.accent),
                ),
              ),
            )
          : Material(
              key: const ValueKey('events-search-open'),
              color: HomeTheme.surfaceBackground,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _openSearch,
                borderRadius: BorderRadius.circular(20),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.search, size: 24, color: HomeTheme.accent),
                ),
              ),
            ),
    );
  }

  Widget _searchField() {
    return TextField(
      key: const ValueKey('events-search-field'),
      controller: _searchCtrl,
      focusNode: _searchFocus,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search events...',
        filled: true,
        fillColor: HomeTheme.surfaceBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: HomeTheme.accentSurface),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: HomeTheme.accentSurface),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _monthSwitcher() {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: HomeTheme.inputBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: List.generate(_months.length, (i) {
          final selected = i == _monthIndex;
          final label = _months[i][0] + _months[i].substring(1).toLowerCase();
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _monthIndex = i),
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
                    color: selected ? Colors.white : HomeTheme.accent,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _categoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_categories.length, (i) {
          final selected = i == _categoryIndex;
          return Padding(
            padding: EdgeInsets.only(right: i < _categories.length - 1 ? 5 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _categoryIndex = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? HomeTheme.primary : HomeTheme.inputBackground,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  _categories[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : HomeTheme.primary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}