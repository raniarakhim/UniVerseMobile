import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/events/models/event_item.dart';

class EventTicketPreview extends StatelessWidget {
  const EventTicketPreview({
    super.key,
    required this.event,
    this.attendeeName = 'Aymakhan Balausa',
    this.attendeeType = 'Student',
    this.showQr = false,
  });

  final EventItem event;
  final String attendeeName;
  final String attendeeType;
  final bool showQr;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: _TicketPainter(),
          child: Container(
            width: constraints.maxWidth,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Column(
              children: [
                Text(
                  event.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.dateLabel ?? event.dateBadge} · ${event.time ?? ''} · ${event.subtitle}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: HomeTheme.placeholder,
                  ),
                ),
                const SizedBox(height: 8),
                CustomPaint(
                  size: Size(constraints.maxWidth - 40, 1),
                  painter: _DashedLinePainter(),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Attendee',
                            style: TextStyle(fontSize: 10, color: HomeTheme.placeholder),
                          ),
                          Text(
                            attendeeName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showQr)
                      Container(
                        width: 48,
                        height: 49,
                        decoration: BoxDecoration(
                          color: const Color(0xFF27236B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.qr_code_2, color: Colors.white, size: 32),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4C1D95),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'FREE · In person',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Type',
                            style: TextStyle(fontSize: 10, color: HomeTheme.placeholder),
                          ),
                          Text(
                            attendeeType,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TicketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    canvas.drawRRect(r, Paint()..color = HomeTheme.primary);
    const notchR = 8.0;
    final cy = size.height / 2;
    canvas.drawCircle(const Offset(0, 0).translate(0, cy), notchR, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(size.width, cy), notchR, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.5;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}