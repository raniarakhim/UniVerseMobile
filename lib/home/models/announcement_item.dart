class AnnouncementItem {
  const AnnouncementItem({
    required this.id,
    required this.title,
    required this.category,
    required this.meta,
    required this.homeDeadline,
    required this.typeLabel,
    required this.typeValue,
    required this.amountLabel,
    required this.amountValue,
    required this.deadlineDate,
    required this.organizer,
    required this.about,
    required this.requirements,
    required this.contactEmail,
    this.applyUrl,
  });

  final String id;
  final String title;
  final String category;
  final String meta;
  final String homeDeadline;
  final String typeLabel;
  final String typeValue;
  final String amountLabel;
  final String amountValue;
  final String deadlineDate;
  final String organizer;
  final String about;
  final List<String> requirements;
  final String contactEmail;
  final String? applyUrl;

  static const scholarship2026 = AnnouncementItem(
    id: 'sksu-scholarship-2026',
    title: 'Scholarship program open for applications',
    category: 'Academic',
    meta: 'SKSU · May 1, 2026',
    homeDeadline: 'Deadline: May 20, 2026',
    typeLabel: 'Type',
    typeValue: 'Academic',
    amountLabel: 'Amount',
    amountValue: '₸500,000',
    deadlineDate: 'May 20, 2026',
    organizer: 'SKSU',
    about:
        'The SKSU Scholarship Program 2026 supports outstanding students with financial assistance for their academic journey.',
    requirements: [
      'GPA 3.5 or higher',
      'Full-time enrolled student',
      'Recommendation letter required',
    ],
    contactEmail: 'scholarship@sksu.edu.kz',
    applyUrl: 'https://sksu.kz/scholarship',
  );

  static const erasmusExchange = AnnouncementItem(
    id: 'erasmus-exchange',
    title: 'Erasmus+ exchange applications now open',
    category: 'Exchange',
    meta: 'International Office · May 3, 2026',
    homeDeadline: 'Deadline: June 1, 2026',
    typeLabel: 'Type',
    typeValue: 'Exchange',
    amountLabel: 'Grant',
    amountValue: '€3,000',
    deadlineDate: 'June 1, 2026',
    organizer: 'Erasmus+',
    about:
        'Semester exchange opportunities at partner universities across the EU with financial support for selected students.',
    requirements: [
      'English level B2 or higher',
      '2nd year of study or higher',
      'Motivation letter required',
    ],
    contactEmail: 'erasmus@sksu.edu.kz',
    applyUrl: 'https://sksu.kz/erasmus',
  );

  static const carousel = [scholarship2026, erasmusExchange];

  static AnnouncementItem? byId(String id) {
    for (final item in carousel) {
      if (item.id == id) return item;
    }
    return null;
  }

  static List<AnnouncementItem> similarTo(AnnouncementItem current) {
    return carousel.where((a) => a.id != current.id).toList();
  }
}
