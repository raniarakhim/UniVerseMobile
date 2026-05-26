import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/events/event_details_page.dart';
import 'package:diplomka/events/models/event_item.dart';
import 'package:diplomka/events/widgets/event_ticket_preview.dart';

class EventRegisteredPage extends StatelessWidget {
  const EventRegisteredPage({
    super.key,
    required this.event,
    required this.attendeeName,
    required this.attendeeType,
    this.attendanceLabel,
  });

  final EventItem event;
  final String attendeeName;
  final String attendeeType;
  final String? attendanceLabel;

  static final _upcomingIds = ['pitch-night', 'design-workshop'];

  @override
  Widget build(BuildContext context) {
    final upcoming = _upcomingIds
        .map(EventItem.byId)
        .whereType<EventItem>()
        .where((e) => e.id != event.id)
        .take(2)
        .toList();

    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  children: [
                    _successIllustration(),
                    const SizedBox(height: 16),
                    const Text(
                      "You're registered!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 36 / 28,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'See you at the event. A confirmation has been sent to your email.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 18 / 14,
                        color: HomeTheme.tagMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    EventTicketPreview(
                      event: event,
                      attendeeName: attendeeName,
                      attendeeType: attendeeType,
                      attendanceLabel: attendanceLabel,
                      showQr: true,
                    ),
                    if (upcoming.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Other upcoming events',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (var i = 0; i < upcoming.length; i++) ...[
                            if (i > 0) const SizedBox(width: 4),
                            Expanded(
                              child: _miniCard(
                                context,
                                upcoming[i],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                    ),
                  ),
                  child: const Text(
                    'Back to Events',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _successIllustration() {
    return SizedBox(
      height: 187,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ..._decorDots(),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: HomeTheme.accentSurface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: Color(0xFF7C3AED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 38, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _decorDots() {
    final specs = [
      (0.05, 0.2, 6.0, const Color(0xFF7C3AED), 0.4),
      (0.9, 0.15, 5.0, const Color(0xFFC4B5FD), 0.6),
      (0.18, 0.05, 4.0, const Color(0xFFC4B5FD), 0.5),
      (0.75, 0.25, 4.0, HomeTheme.accentSurface, 0.8),
    ];
    return specs.map((s) {
      return Positioned(
        left: 319 * s.$1,
        top: 187 * s.$2,
        child: Opacity(
          opacity: s.$5,
          child: Container(
            width: s.$3,
            height: s.$3,
            decoration: BoxDecoration(color: s.$4, shape: BoxShape.circle),
          ),
        ),
      );
    }).toList();
  }

  Widget _miniCard(BuildContext context, EventItem item) {
    return Material(
      color: HomeTheme.surfaceBackground,
      borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailsPage(event: item)),
          );
        },
        borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.dateBadge,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFA78BFA),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: HomeTheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.locationLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
