import 'package:flutter/material.dart';

enum EventCategory { all, career, startup, design, free }

class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.month,
    required this.day,
    required this.sectionTitle,
    this.category = EventCategory.all,
    this.tags = const [],
    this.priceLabel,
    this.isFeatured = false,
    this.isFavorite = false,
    this.accentColor = const Color(0xFF4C1D95),
    this.time,
    this.dateLabel,
    this.organizerName = 'UniVerse Hub',
    this.contactEmail = 'events@universe.kz',
    this.contactPhone = '+7 775 000 1122',
  });

  final String id;
  final String title;
  final String subtitle;
  final String month;
  final int day;
  final String sectionTitle;
  final EventCategory category;
  final List<String> tags;
  final String? priceLabel;
  final bool isFeatured;
  final bool isFavorite;
  final Color accentColor;
  final String? time;
  final String? dateLabel;
  final String organizerName;
  final String contactEmail;
  final String contactPhone;

  String get dateBadge => dateLabel ?? '$month $day';

  EventItem withFavorite(bool value) {
    return EventItem(
      id: id,
      title: title,
      subtitle: subtitle,
      month: month,
      day: day,
      sectionTitle: sectionTitle,
      category: category,
      tags: tags,
      priceLabel: priceLabel,
      isFeatured: isFeatured,
      isFavorite: value,
      accentColor: accentColor,
      time: time,
      dateLabel: dateLabel,
      organizerName: organizerName,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
    );
  }

  static const sample = [
    EventItem(
      id: 'career-fair',
      title: 'Tech Career Fair 2026',
      subtitle: 'Shymkent IT Hub',
      month: 'MAY',
      day: 12,
      sectionTitle: 'Monday, May 12',
      category: EventCategory.career,
      tags: ['Free', '200 spots'],
      isFeatured: true,
      accentColor: Color(0xFF4C1D95),
      time: '10:00 AM',
      dateLabel: 'May 12, 2026',
    ),
    EventItem(
      id: 'pitch-night',
      title: 'Startup Pitch Night',
      subtitle: '6:00 PM · UniVerse Hub',
      month: 'MAY',
      day: 17,
      sectionTitle: 'Saturday, May 17',
      category: EventCategory.startup,
      tags: ['Startup', '₸500'],
      accentColor: Color(0xFF4C1D95),
    ),
    EventItem(
      id: 'design-workshop',
      title: 'UI/UX Design Workshop',
      subtitle: '2:00 PM · Online · Zoom',
      month: 'MAY',
      day: 23,
      sectionTitle: 'Friday, May 23',
      category: EventCategory.design,
      tags: ['Design', 'Free'],
      accentColor: Color(0xFFA78BFA),
      isFavorite: true,
    ),
    EventItem(
      id: 'networking',
      title: 'Student Networking Evening',
      subtitle: '7:00 PM · ₸1,000',
      month: 'MAY',
      day: 28,
      sectionTitle: 'Wednesday, May 28',
      category: EventCategory.career,
      tags: ['Networking'],
      accentColor: Color(0xFF4C1D95),
    ),
    EventItem(
      id: 'pitch-night-2',
      title: 'Startup Pitch Night',
      subtitle: '6:00 PM · UniVerse Hub',
      month: 'MAY',
      day: 17,
      sectionTitle: 'Saturday, May 17',
      category: EventCategory.startup,
      tags: ['Startup'],
      accentColor: Color(0xFF4C1D95),
    ),
    EventItem(
      id: 'workshop-june',
      title: 'Design Workshop',
      subtitle: '2:00 PM · Online · Zoom',
      month: 'JUNE',
      day: 1,
      sectionTitle: 'Monday, June 1',
      category: EventCategory.design,
      tags: ['Design'],
      accentColor: Color(0xFF4C1D95),
    ),
  ];

  static List<EventItem> filtered(EventCategory category) {
    if (category == EventCategory.all) return List.from(sample);
    return sample.where((e) => e.category == category).toList();
  }

  static List<EventItem> byMonth(String month) {
    return sample.where((e) => e.month == month).toList();
  }

  static EventItem? byId(String id) {
    for (final e in sample) {
      if (e.id == id) return e;
    }
    return null;
  }

  static List<EventItem> similarTo(EventItem current, {int limit = 2}) {
    return sample.where((e) => e.id != current.id).take(limit).toList();
  }

  static EventItem? matchTitle(String title) {
    final lower = title.toLowerCase();
    for (final e in sample) {
      if (e.title.toLowerCase() == lower ||
          e.title.toLowerCase().contains(lower) ||
          lower.contains(e.title.toLowerCase())) {
        return e;
      }
    }
    return null;
  }

  String get locationLine {
    final parts = subtitle.split('·').map((s) => s.trim()).toList();
    return parts.isNotEmpty ? parts.last : subtitle;
  }

  String get timeLine {
    if (time != null && time!.isNotEmpty) return time!;
    final parts = subtitle.split('·').map((s) => s.trim()).toList();
    return parts.isNotEmpty ? parts.first : subtitle;
  }

  String get priceLine {
    for (final tag in tags) {
      if (tag.contains('₸') || tag.toLowerCase() == 'free') return tag;
    }
    if (priceLabel != null) return priceLabel!;
    return 'Free';
  }

  String get aboutText {
    switch (category) {
      case EventCategory.design:
        return 'Hands-on session for students who want to improve UI/UX skills, portfolio quality, and design thinking.';
      case EventCategory.startup:
        return 'Meet founders, pitch your idea, and connect with mentors from the local startup ecosystem.';
      default:
        return 'Meet employers, explore internships, and network with professionals across tech industries in Shymkent.';
    }
  }

  String get shareMessage =>
      '$title\n${dateLabel ?? dateBadge} · $timeLine\n$locationLine';
}
