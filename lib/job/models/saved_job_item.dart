import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/job/models/job_item.dart';

class SavedJobItem {
  const SavedJobItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.salaryLabel,
    required this.month,
    required this.day,
    required this.accentBar,
    this.categoryTag,
  });

  final String id;
  final String title;
  final String subtitle;
  final String salaryLabel;
  final String month;
  final int day;
  final Color accentBar;
  final String? categoryTag;

  factory SavedJobItem.fromJob(JobItem job) {
    return SavedJobItem(
      id: job.saveId,
      title: job.title,
      subtitle: job.listSubtitle,
      salaryLabel: job.salary,
      month: 'MAY',
      day: 17,
      accentBar: job.accentBarColor,
      categoryTag: job.tags.isNotEmpty ? job.tags.first : null,
    );
  }

  static const initialJobs = [
    SavedJobItem(
      id: 'kaspi',
      title: 'Frontend Developer',
      subtitle: 'Kaspi Bank · Part-time · Remote',
      salaryLabel: '₸250,000',
      month: 'MAY',
      day: 17,
      accentBar: HomeTheme.clearAction,
    ),
    SavedJobItem(
      id: 'kolesa',
      title: 'UI/UX Designer',
      subtitle: 'Kolesa Group · Freelance · Remote',
      salaryLabel: '₸200,000',
      categoryTag: 'Design',
      month: 'MAY',
      day: 23,
      accentBar: HomeTheme.accentLight,
    ),
    SavedJobItem(
      id: 'choco',
      title: 'Data Analyst Intern',
      subtitle: 'Chocofamily · Full-time · Office',
      salaryLabel: '₸180,000',
      month: 'MAY',
      day: 28,
      accentBar: HomeTheme.clearAction,
    ),
    SavedJobItem(
      id: 'jusan',
      title: 'Mobile Developer',
      subtitle: 'Jusan Bank · Full-time · Hybrid',
      salaryLabel: '₸350,000',
      month: 'MAY',
      day: 28,
      accentBar: HomeTheme.clearAction,
    ),
  ];
}
