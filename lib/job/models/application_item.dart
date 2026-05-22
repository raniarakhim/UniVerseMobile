import 'package:flutter/material.dart';

enum ApplicationStatus { underReview, interviewSet, notSelected }

class ApplicationItem {
  const ApplicationItem({
    required this.title,
    required this.company,
    required this.appliedLabel,
    required this.status,
    required this.logoColor,
    required this.logoLetter,
  });

  final String title;
  final String company;
  final String appliedLabel;
  final ApplicationStatus status;
  final Color logoColor;
  final String logoLetter;

  String get statusLabel => switch (status) {
        ApplicationStatus.underReview => 'Under review',
        ApplicationStatus.interviewSet => 'Interview set',
        ApplicationStatus.notSelected => 'Not selected',
      };

  IconData get statusIcon => switch (status) {
        ApplicationStatus.underReview => Icons.hourglass_top_rounded,
        ApplicationStatus.interviewSet => Icons.calendar_today_rounded,
        ApplicationStatus.notSelected => Icons.close_rounded,
      };

  static const sample = [
    ApplicationItem(
      title: 'Frontend Developer',
      company: 'Kaspi Bank',
      appliedLabel: 'Applied May 10',
      status: ApplicationStatus.underReview,
      logoColor: Color(0xFFE31E24),
      logoLetter: 'K',
    ),
    ApplicationItem(
      title: 'UI/UX Designer',
      company: 'Kolesa Group',
      appliedLabel: 'Applied May 12',
      status: ApplicationStatus.interviewSet,
      logoColor: Color(0xFF2563EB),
      logoLetter: 'k',
    ),
    ApplicationItem(
      title: 'Data Analyst Intern',
      company: 'Chocofamily',
      appliedLabel: 'Applied May 5',
      status: ApplicationStatus.notSelected,
      logoColor: Color(0xFF6B7280),
      logoLetter: 'C',
    ),
  ];
}
