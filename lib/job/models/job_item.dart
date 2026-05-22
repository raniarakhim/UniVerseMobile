import 'package:flutter/material.dart';

class JobItem {
  const JobItem({
    required this.title,
    required this.company,
    required this.location,
    required this.employmentType,
    required this.salary,
    required this.salaryShort,
    required this.salaryMonthly,
    required this.tags,
    this.workModes = const [],
    this.isTopPick = false,
    this.accentBarColor = const Color(0xFFC4B5FD),
    this.logoColor = 0xFF1E1B4B,
    this.logoLetter = 'K',
    this.about = '',
    this.requirements = const [],
    this.skills = const [],
    this.experience = '2+ yrs',
    this.schedule = 'Part-time',
    this.status = 'Open',
    this.companyMeta = '',
    this.contactEmail = '',
    this.contactPhone = '',
  });

  final String title;
  final String company;
  final String location;
  final String employmentType;
  final String salary;
  final String salaryShort;
  final String salaryMonthly;
  final List<String> tags;
  final List<String> workModes;
  final bool isTopPick;
  final Color accentBarColor;
  final int logoColor;
  final String logoLetter;
  final String about;
  final List<String> requirements;
  final List<String> skills;
  final String experience;
  final String schedule;
  final String status;
  final String companyMeta;
  final String contactEmail;
  final String contactPhone;

  String get summary => '$company · $employmentType · $salaryShort';

  String get listSubtitle {
    final parts = [company, location, employmentType].where((p) => p.isNotEmpty).toList();
    return parts.join(' · ');
  }

  String get detailSubtitle => '$company · $location';

  String get saveId => '$company|$title';

  static JobItem? bySaveId(String id) {
    for (final job in [...allJobs, ...detailsSimilar]) {
      if (job.saveId == id) return job;
    }
    return null;
  }

  static const frontendKaspi = JobItem(
    title: 'Frontend Developer',
    company: 'Kaspi Bank',
    location: 'Almaty',
    employmentType: 'Part-time',
    salary: '₸250,000',
    salaryShort: '₸250K',
    salaryMonthly: '₸250,000 /mo',
    tags: ['Remote', 'Part-time'],
    workModes: ['Part-time', 'Remote', 'React'],
    isTopPick: true,
    accentBarColor: Color(0xFF4C1D95),
    logoColor: 0xFF1E1B4B,
    logoLetter: 'K',
    experience: '2+ yrs',
    schedule: 'Part-time',
    status: 'Open',
    companyMeta: 'Fintech · 5,000+ employees · Almaty',
    about:
        "We are looking for a skilled Frontend Developer to join Kaspi Bank's product team. You will build and maintain high-performance web interfaces used by millions of Kazakhstanis every day. The role is part-time and fully remote.",
    requirements: [
      '2+ years of experience with React or Vue.js',
      'Strong knowledge of HTML5, CSS3, JavaScript (ES6+)',
      'Experience with REST APIs and version control (Git)',
      'Understanding of UI/UX principles and responsive design',
      'Kazakh or Russian language — intermediate or higher',
    ],
    skills: ['React.js', 'TypeScript', 'CSS / Tailwind', 'Git', 'REST API', 'Figma'],
    contactEmail: 'careers@kaspi.kz',
    contactPhone: '+7 727 258 8000',
  );

  static const uxDesigner = JobItem(
    title: 'UI/UX Designer',
    company: 'Kolesa Group',
    location: 'Remote',
    employmentType: 'Freelance',
    salary: '₸200,000',
    salaryShort: '₸200K',
    salaryMonthly: '₸200,000 /mo',
    tags: ['Freelance', 'Remote'],
    workModes: ['Freelance', 'Remote', 'Figma'],
    accentBarColor: Color(0xFF4C1D95),
    logoColor: 0xFF312E81,
    logoLetter: 'K',
    experience: '1+ yrs',
    schedule: 'Freelance',
    status: 'Open',
    companyMeta: 'Marketplace · 1,000+ employees · Remote-first',
    about:
        'Kolesa Group is looking for a UI/UX Designer to improve listing flows and mobile-first experiences across kolesa.kz products. You will work with product managers and engineers on user research, wireframes, and high-fidelity prototypes.',
    requirements: [
      'Portfolio with mobile and web case studies',
      'Proficiency in Figma and design systems',
      'Understanding of usability testing and user flows',
      'Ability to deliver assets for development handoff',
      'Kazakh or Russian — fluent communication',
    ],
    skills: ['Figma', 'UI Design', 'UX Research', 'Prototyping', 'Design Systems', 'Mobile UI'],
    contactEmail: 'jobs@kolesa.kz',
    contactPhone: '+7 727 300 5500',
  );

  static const dataAnalyst = JobItem(
    title: 'Data Analyst Intern',
    company: 'Chocofamily',
    location: 'Shymkent',
    employmentType: 'Full-time',
    salary: '₸340,000',
    salaryShort: '₸340K',
    salaryMonthly: '₸340,000 /mo',
    tags: ['Full-time', 'Office'],
    workModes: ['Full-time', 'Office', 'SQL'],
    accentBarColor: Color(0xFFC4B5FD),
    logoColor: 0xFF5B21B6,
    logoLetter: 'C',
    experience: 'Intern',
    schedule: 'Full-time',
    status: 'Open',
    companyMeta: 'IT holding · 500+ employees · Shymkent',
    about:
        'Join Chocofamily as a Data Analyst Intern and support product teams with dashboards, ad-hoc reports, and data quality checks. Ideal for students or recent graduates who want hands-on experience with real business metrics.',
    requirements: [
      'Basic SQL and spreadsheet skills',
      'Familiarity with Python or R for analysis',
      'Attention to detail and clear written communication',
      'Interest in e-commerce or fintech data',
      'English — intermediate reading level',
    ],
    skills: ['SQL', 'Excel', 'Python', 'Tableau', 'Data Viz', 'A/B Testing'],
    contactEmail: 'hr@chocofamily.kz',
    contactPhone: '+7 727 244 4400',
  );

  static const mobileDev = JobItem(
    title: 'Mobile Developer',
    company: 'Sajda',
    location: 'Remote',
    employmentType: 'Internship',
    salary: '₸120,000',
    salaryShort: '₸120K',
    salaryMonthly: '₸120,000 /mo',
    tags: ['Internship', 'Remote'],
    workModes: ['Internship', 'Remote', 'Flutter'],
    accentBarColor: Color(0xFFC4B5FD),
    logoColor: 0xFF065F46,
    logoLetter: 'S',
    experience: '0–1 yrs',
    schedule: 'Internship',
    status: 'Open',
    companyMeta: 'Mobile app · Startup · Remote',
    about:
        'Sajda is hiring a Mobile Developer intern to help ship features for our Flutter app used by students across Kazakhstan. You will fix bugs, implement UI from Figma, and learn release practices with a senior mentor.',
    requirements: [
      'Dart/Flutter basics or strong mobile learning motivation',
      'Understanding of REST APIs and JSON',
      'Git workflow (branches, pull requests)',
      'Comfortable working in a small agile team',
      'Availability for at least 3 months',
    ],
    skills: ['Flutter', 'Dart', 'REST API', 'Git', 'Firebase', 'UI Implementation'],
    contactEmail: 'hello@sajda.app',
    contactPhone: '+7 701 555 7788',
  );

  static const contentManager = JobItem(
    title: 'Content Manager',
    company: 'UniVerse Media',
    location: 'Shymkent',
    employmentType: 'Part-time',
    salary: '₸180,000',
    salaryShort: '₸180K',
    salaryMonthly: '₸180,000 /mo',
    tags: ['Part-time', 'On-site'],
    workModes: ['Part-time', 'Shymkent', 'Social Media'],
    accentBarColor: Color(0xFFC4B5FD),
    logoColor: 0xFF27236B,
    logoLetter: 'U',
    experience: '1+ yrs',
    schedule: 'Part-time',
    status: 'Open',
    companyMeta: 'Student media · Shymkent · Hybrid',
    about:
        'UniVerse Media needs a Content Manager to plan posts, write short articles, and coordinate campus event coverage for our student platform. You will work with designers and moderators to keep feeds active and on-brand.',
    requirements: [
      'Strong writing in Kazakh and/or Russian',
      'Experience with Instagram, Telegram, or TikTok content',
      'Basic photo/video editing skills',
      'Organized, able to meet weekly deadlines',
      'Interest in student life and local events',
    ],
    skills: ['Copywriting', 'SMM', 'Canva', 'Content Calendar', 'SEO basics', 'Community'],
    contactEmail: 'media@universe.kz',
    contactPhone: '+7 775 220 3344',
  );

  static const similarKolesa = JobItem(
    title: 'Frontend Developer',
    company: 'Kolesa Group',
    location: 'Remote',
    employmentType: 'Freelance',
    salary: '₸280,000',
    salaryShort: '₸280K',
    salaryMonthly: '₸280,000 /mo',
    tags: ['Freelance', 'Remote'],
    workModes: ['Freelance', 'Remote', 'Vue.js'],
    logoColor: 0xFF312E81,
    logoLetter: 'K',
    experience: '3+ yrs',
    schedule: 'Freelance',
    status: 'Open',
    companyMeta: 'Marketplace · Remote-first',
    about:
        'Build and optimize frontend modules for classifieds search, filters, and seller dashboards. Contract role with flexible hours and direct collaboration with the product squad.',
    requirements: [
      '3+ years with Vue.js or React',
      'Performance tuning and lazy-loading experience',
      'Unit tests and code review culture',
      'REST/GraphQL integration skills',
    ],
    skills: ['Vue.js', 'JavaScript', 'Webpack', 'Git', 'SCSS', 'Jest'],
    contactEmail: 'jobs@kolesa.kz',
    contactPhone: '+7 727 300 5500',
  );

  static const similarChoco = JobItem(
    title: 'Frontend Developer',
    company: 'Chocofamily',
    location: 'Shymkent',
    employmentType: 'Full-time',
    salary: '₸210,000',
    salaryShort: '₸210K',
    salaryMonthly: '₸210,000 /mo',
    tags: ['Full-time', 'Office'],
    workModes: ['Full-time', 'Office', 'React'],
    logoColor: 0xFF5B21B6,
    logoLetter: 'C',
    experience: '2+ yrs',
    schedule: 'Full-time',
    status: 'Open',
    companyMeta: 'IT holding · Shymkent',
    about:
        'Chocofamily is expanding the Shymkent engineering hub. You will maintain internal tools and customer-facing widgets used across the holding’s brands.',
    requirements: [
      '2+ years with React and TypeScript',
      'Experience with component libraries',
      'Cross-browser testing habits',
      'Team collaboration in Kazakh/Russian',
    ],
    skills: ['React', 'TypeScript', 'Redux', 'Git', 'CSS Modules', 'Storybook'],
    contactEmail: 'hr@chocofamily.kz',
    contactPhone: '+7 727 244 4400',
  );

  static bool _isSameRole(JobItem a, JobItem b) =>
      a.company == b.company && a.title == b.title && a.employmentType == b.employmentType;

  static List<JobItem> similarTo(JobItem current, {int limit = 4}) {
    final result = <JobItem>[];
    final seen = <String>{};

    void tryAdd(JobItem job) {
      if (_isSameRole(job, current)) return;
      final id = '${job.company}|${job.title}|${job.employmentType}';
      if (seen.add(id)) result.add(job);
    }

    for (final job in detailsSimilar) {
      tryAdd(job);
    }
    for (final job in allJobs) {
      tryAdd(job);
    }
    return result.take(limit).toList();
  }

  static List<JobItem> get allJobs => [
        frontendKaspi,
        uxDesigner,
        dataAnalyst,
        mobileDev,
        contentManager,
      ];

  static List<JobItem> get similarJobs => [
        uxDesigner,
        dataAnalyst,
        mobileDev,
      ];

  static List<JobItem> get detailsSimilar => [
        similarKolesa,
        similarChoco,
      ];
}
