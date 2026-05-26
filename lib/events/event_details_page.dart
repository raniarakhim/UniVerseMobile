import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/core/services/saved_events_service.dart';
import 'package:diplomka/core/widgets/home_detail_app_bar.dart';
import 'package:diplomka/events/event_register_page.dart';
import 'package:diplomka/events/models/event_item.dart';

class EventDetailsPage extends StatefulWidget {
  const EventDetailsPage({super.key, required this.event});

  final EventItem event;

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final _savedService = SavedEventsService.instance;

  @override
  void initState() {
    super.initState();
    _savedService.addListener(_onSavedChanged);
  }

  @override
  void dispose() {
    _savedService.removeListener(_onSavedChanged);
    super.dispose();
  }

  void _onSavedChanged() {
    if (mounted) setState(() {});
  }

  bool get _isSaved =>
      _savedService.isSavedWithDefault(widget.event.id, defaultValue: widget.event.isFavorite);

  void _toggleSave() => _savedService.toggle(
        widget.event.id,
        defaultValue: widget.event.isFavorite,
      );

  Future<void> _share() async {
    await Share.share(widget.event.shareMessage, subject: widget.event.title);
  }

  void _openEvent(EventItem event) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailsPage(key: ValueKey(event.id), event: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final similar = EventItem.similarTo(event);

    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            HomeDetailAppBar(
              title: 'Events',
              trailing: IconButton(
                onPressed: _share,
                icon: const Icon(Icons.ios_share, size: 32, color: HomeTheme.primary),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  HomeTheme.horizontalPadding,
                  13,
                  HomeTheme.horizontalPadding,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroBanner(event),
                    const SizedBox(height: 16),
                    _statRow(event),
                    const SizedBox(height: 16),
                    _sectionTitle('About'),
                    const SizedBox(height: 12),
                    Text(
                      event.aboutText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 18 / 14,
                        color: HomeTheme.tagMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Location'),
                    const SizedBox(height: 12),
                    _iconCard(
                      icon: Icons.location_on_outlined,
                      title: event.locationLine,
                      subtitle: 'Shymkent',
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Organizer'),
                    const SizedBox(height: 12),
                    _iconCard(
                      icon: Icons.school_outlined,
                      title: event.organizerName,
                      subtitle: 'Official organizer',
                    ),
                    if (similar.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _sectionTitle('Similar events'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (var i = 0; i < similar.length; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            Expanded(
                              child: _SimilarEventCard(
                                event: similar[i],
                                onTap: () => _openEvent(similar[i]),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: _toggleSave,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: HomeTheme.chipInactive,
                              foregroundColor: HomeTheme.primary,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                              ),
                            ),
                            icon: Icon(
                              _isSaved ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: HomeTheme.primary,
                            ),
                            label: Text(
                              _isSaved ? 'Saved' : 'Save',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventRegisterPage(event: event),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HomeTheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                                ),
                              ),
                              child: const Text(
                                'Register now',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroBanner(EventItem event) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: event.accentColor,
        borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 4, 14, 4),
            decoration: BoxDecoration(
              color: HomeTheme.accentLight,
              borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
            ),
            child: Text(
              event.dateLabel ?? '${event.month} ${event.day}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 31 / 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            event.locationLine,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 20 / 16,
              color: HomeTheme.companyTint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(EventItem event) {
    return Row(
      children: [
        Expanded(child: _statTile('TIME', event.timeLine)),
        const SizedBox(width: 8),
        Expanded(
          child: _statTile(
            'PRICE',
            event.priceLine,
            valueColor: event.accentColor.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: _statTile('SPOTS', event.tags.length > 1 ? '200' : '—')),
      ],
    );
  }

  Widget _statTile(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: HomeTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: HomeTheme.placeholder,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor ?? HomeTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: HomeTheme.primary,
      ),
    );
  }

  Widget _iconCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: HomeTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: HomeTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: HomeTheme.primary,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: HomeTheme.tagMuted.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      ),
    );
  }
}

class _SimilarEventCard extends StatelessWidget {
  const _SimilarEventCard({required this.event, required this.onTap});

  final EventItem event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeTheme.surfaceBackground,
      borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.dateBadge,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: HomeTheme.accentLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 23 / 18,
                  color: HomeTheme.primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                event.subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: HomeTheme.placeholder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
