import 'package:flutter/material.dart';

class NotificationItem {
  const NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.checked,
    this.logoColor,
    this.logoLetter,
    this.highlighted = false,
  });

  final String title;
  final String body;
  final String time;
  final bool checked;
  final Color? logoColor;
  final String? logoLetter;
  final bool highlighted;

  static const today = [
    NotificationItem(
      title: 'New job match!',
      body: 'Frontend Dev at Kaspi matches your profile. Check it out.',
      time: '2 min ago',
      checked: true,
      logoColor: Color(0xFFE31E24),
      logoLetter: 'K',
      highlighted: true,
    ),
    NotificationItem(
      title: 'Application received',
      body: 'Kolesa Group confirmed your UI/UX Designer application.',
      time: '1 h ago',
      checked: true,
      logoColor: Color(0xFF2563EB),
      logoLetter: 'k',
      highlighted: true,
    ),
    NotificationItem(
      title: 'Event reminder',
      body: 'Tech Career Fair starts tomorrow at 10:00 AM · Shymkent IT Hub',
      time: '3 h ago',
      checked: false,
      logoColor: Color(0xFF1E1B4B),
      logoLetter: 'IT',
    ),
  ];

  static const yesterday = [
    NotificationItem(
      title: 'New housing listed',
      body: 'Studio near SKSU · ₸60,000/mo matches your saved filters.',
      time: 'Yesterday',
      checked: false,
    ),
    NotificationItem(
      title: 'Scholarship deadline soon',
      body: 'SKSU Scholarship closes in 5 days · May 20, 2026.',
      time: 'Yesterday',
      checked: false,
    ),
    NotificationItem(
      title: 'Profile 75% complete',
      body: 'Add your resume to increase visibility to employers.',
      time: '3 days ago',
      checked: false,
    ),
  ];
}
