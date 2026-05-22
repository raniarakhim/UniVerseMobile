import 'package:flutter/material.dart';
import 'package:diplomka/home/announcement_details_page.dart';
import 'package:diplomka/home/announcements_list_page.dart';
import 'package:diplomka/events/models/event_item.dart';
import 'package:diplomka/job/job_details_page.dart';
import 'package:diplomka/events/event_details_page.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/housing/housing_details_page.dart';
import 'package:diplomka/housing/models/housing_item.dart';
import 'package:diplomka/home/models/announcement_item.dart';
import 'package:diplomka/job/jobs_page.dart';
import 'package:diplomka/job/models/job_item.dart';
import 'package:diplomka/housing/housing_page.dart';
import 'package:diplomka/profile/profile_page.dart';
import 'package:diplomka/events/events_page.dart';
import 'package:diplomka/core/widgets/home_bottom_nav.dart';
import 'package:diplomka/core/models/app_user.dart';
import 'package:diplomka/core/services/user_profile_service.dart';
import 'package:diplomka/core/navigation/home_shell.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;
  int _categoryIndex = 0;
  bool _showBackOnJobs = false;
  bool _showBackOnEvents = false;
  AppUser? _user;

  static const _categories = ['All', 'Announcements', 'Events', 'Jobs'];

  @override
  void initState() {
    super.initState();
    HomeShell.bind(
      switchTab: _switchTab,
      resetHomeCategory: _resetCategoryFilter,
      openJobsFromHome: _openJobsFromHome,
      openEventsFromHome: _openEventsFromHome,
      openHomeTab: _returnToHomeFromList,
    );
    _loadUser();
  }

  @override
  void dispose() {
    HomeShell.unbind(
      switchTab: _switchTab,
      resetHomeCategory: _resetCategoryFilter,
      openJobsFromHome: _openJobsFromHome,
      openEventsFromHome: _openEventsFromHome,
      openHomeTab: _returnToHomeFromList,
    );
    super.dispose();
  }

  void _resetCategoryFilter() {
    if (mounted) setState(() => _categoryIndex = 0);
  }

  void _switchTab(int index) {
    setState(() => _navIndex = index);
    if (index == 0) _loadUser();
  }

  void _openJobsFromHome() {
    setState(() {
      _showBackOnJobs = true;
      _showBackOnEvents = false;
      _navIndex = 1;
    });
  }

  void _openEventsFromHome() {
    setState(() {
      _showBackOnEvents = true;
      _showBackOnJobs = false;
      _navIndex = 3;
    });
  }

  void _returnToHomeFromList() {
    setState(() {
      _showBackOnJobs = false;
      _showBackOnEvents = false;
      _navIndex = 0;
      _categoryIndex = 0;
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _showBackOnJobs = false;
      _showBackOnEvents = false;
      _navIndex = index;
    });
    if (index == 0) _loadUser();
  }

  void _openAnnouncementsList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AnnouncementsListPage()),
    );
  }

  void _onCategoryChipTap(int index) {
    if (index == 0) {
      setState(() => _categoryIndex = 0);
      return;
    }
    switch (_categories[index]) {
      case 'Announcements':
        _openAnnouncementsList();
        break;
      case 'Events':
        HomeShell.openEventsFromHome();
        break;
      case 'Jobs':
        HomeShell.openJobsFromHome();
        break;
    }
  }

  Future<void> _loadUser() async {
    final user = await UserProfileService.instance.load();
    if (mounted) setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _buildHomeBody(),
          JobsPage(
            key: ValueKey('jobs-$_showBackOnJobs'),
            showBackButton: _showBackOnJobs,
            onBack: _returnToHomeFromList,
          ),
          const HousingPage(),
          EventsPage(
            key: ValueKey('events-$_showBackOnEvents'),
            showBackButton: _showBackOnEvents,
            onBack: _returnToHomeFromList,
          ),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _navIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildHomeBody() {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          HomeTheme.horizontalPadding,
          8,
          HomeTheme.horizontalPadding,
          100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: HomeTheme.sectionGap),
            _buildCategoryChips(),
            if (_showSection('Announcements')) ...[
              const SizedBox(height: HomeTheme.sectionGap),
              _SectionHeader(
                title: 'Announcements',
                onSeeAll: _openAnnouncementsList,
              ),
              const SizedBox(height: HomeTheme.sectionInnerGap),
              _buildAnnouncementsCarousel(),
            ],
            if (_showSection('Events')) ...[
              const SizedBox(height: HomeTheme.sectionGap),
              _SectionHeader(
                title: 'Events',
                onSeeAll: HomeShell.openEventsFromHome,
              ),
              const SizedBox(height: HomeTheme.sectionInnerGap),
              _EventsSection(
                onOpenEvent: (event) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EventDetailsPage(event: event)),
                  );
                },
              ),
            ],
            if (_showSection('Jobs')) ...[
              const SizedBox(height: HomeTheme.sectionGap),
              _SectionHeader(
                title: 'Jobs',
                onSeeAll: HomeShell.openJobsFromHome,
              ),
              const SizedBox(height: HomeTheme.sectionInnerGap),
              _JobCard(
                title: 'Frontend Developer',
                company: 'Kaspi Bank · Shymkent',
                tags: const ['Part-time', 'Remote'],
                salary: '₸250K',
                featured: true,
                dark: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JobDetailsPage(job: JobItem.frontendKaspi),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              _JobCard(
                title: 'Data Analyst Intern',
                company: 'Chocofamily · Shymkent',
                tags: const ['Full-time', 'Office'],
                salary: '₸550K',
                featured: true,
                dark: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JobDetailsPage(job: JobItem.dataAnalyst),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              _JobCard(
                title: 'UI/UX Designer',
                company: 'Kolesa Group · Remote',
                tags: const ['Part-time', 'Freelance'],
                salary: '₸330K',
                dark: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JobDetailsPage(job: JobItem.uxDesigner),
                    ),
                  );
                },
              ),
            ],
            if (_categoryIndex == 0) ...[
              const SizedBox(height: HomeTheme.sectionGap),
              _SectionHeader(
                title: 'Housing',
                onSeeAll: HomeShell.openHousingTab,
              ),
              const SizedBox(height: HomeTheme.sectionInnerGap),
              _HousingCard(
                title: 'Studio near SKSU',
                address: 'Al-Farabi St, Shymkent',
                price: '₸60,000 /mo',
                tags: const ['1 room', 'Wi-Fi', 'Furnished'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HousingDetailsPage(
                        key: ValueKey(HousingItem.studioSksu.id),
                        item: HousingItem.studioSksu,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _HousingCard(
                title: HousingItem.roomYufu.title,
                address: HousingItem.roomYufu.address,
                price: HousingItem.roomYufu.price,
                tags: HousingItem.roomYufu.amenities,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HousingDetailsPage(
                        key: ValueKey(HousingItem.roomYufu.id),
                        item: HousingItem.roomYufu,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _HousingCard(
                title: HousingItem.apartmentBaitursynov.title,
                address: HousingItem.apartmentBaitursynov.address,
                price: HousingItem.apartmentBaitursynov.price,
                tags: HousingItem.apartmentBaitursynov.amenities,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HousingDetailsPage(
                        key: ValueKey(HousingItem.apartmentBaitursynov.id),
                        item: HousingItem.apartmentBaitursynov,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _showSection(String name) {
    if (_categoryIndex == 0) return true;
    return _categories[_categoryIndex] == name;
  }

  Widget _buildHeader() {
    final name = _user?.fullName.isNotEmpty == true ? _user!.fullName : '...';
    final subtitle = _user?.homeSubtitle ?? '...';
    final initials = _user?.initials ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 31 / 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 0),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 15 / 12,
                  color: HomeTheme.placeholder,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HomeTheme.chipInactive,
            border: Border.all(color: HomeTheme.accentSurface, width: 1),
          ),
          alignment: Alignment.center,
          child: initials.isNotEmpty
              ? Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HomeTheme.accent,
                  ),
                )
              : const Icon(Icons.person, color: HomeTheme.accent, size: 28),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 5),
        itemBuilder: (context, index) {
          // Только «All» — фильтр на Home; остальные чипы открывают полный список.
          final selected = index == 0 && _categoryIndex == 0;
          return GestureDetector(
            onTap: () => _onCategoryChipTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? HomeTheme.accent : HomeTheme.chipInactive,
                borderRadius: BorderRadius.circular(HomeTheme.chipRadius),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 20 / 16,
                  color: selected ? Colors.white : HomeTheme.accent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementsCarousel() {
    return _HorizontalCarousel(
      height: 223,
      itemCount: AnnouncementItem.carousel.length,
      separator: 12,
      itemBuilder: (context, index) {
        final item = AnnouncementItem.carousel[index];
        return SizedBox(
          width: HomeTheme.contentWidth,
          child: _AnnouncementCard(
            item: item,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnnouncementDetailsPage(
                    key: ValueKey(item.id),
                    item: item,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Горизонтальная лента внутри вертикального скролла страницы.
class _HorizontalCarousel extends StatelessWidget {
  const _HorizontalCarousel({
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    this.separator = 12,
  });

  final double height;
  final int itemCount;
  final double separator;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        primary: false,
        clipBehavior: Clip.none,
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(width: separator),
        itemBuilder: itemBuilder,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 26 / 20,
            color: HomeTheme.primary,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 18 / 14,
                  color: HomeTheme.accentLight,
                ),
              ),
              Icon(Icons.arrow_forward, size: 24, color: HomeTheme.accentLight),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.item, this.onTap});

  final AnnouncementItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomeTheme.primary,
        borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 4, 14, 4),
            decoration: BoxDecoration(
              color: HomeTheme.badgeLight,
              borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_outlined, size: 18, color: HomeTheme.accent),
                const SizedBox(width: 6),
                Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: HomeTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 26 / 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.homeDeadline,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 20 / 16,
              color: HomeTheme.placeholder,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(child: _infoBox(item.typeLabel, item.typeValue)),
              const SizedBox(width: 8),
              Expanded(child: _infoBox(item.amountLabel, item.amountValue)),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: HomeTheme.infoBox,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 18 / 14,
              color: HomeTheme.placeholder,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 20 / 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventPanelData {
  const _EventPanelData({
    required this.featured,
    required this.compact,
  });

  final _FeaturedEventData featured;
  final List<_CompactEventData> compact;
}

class _FeaturedEventData {
  const _FeaturedEventData({
    required this.date,
    required this.title,
    required this.time,
    required this.tag,
  });

  final String date;
  final String title;
  final String time;
  final String tag;
}

class _CompactEventData {
  const _CompactEventData({
    required this.date,
    required this.title,
    required this.subtitle,
  });

  final String date;
  final String title;
  final String subtitle;
}

class _EventsSection extends StatelessWidget {
  const _EventsSection({required this.onOpenEvent});

  final void Function(EventItem event) onOpenEvent;

  static const _panels = [
    _EventPanelData(
      featured: _FeaturedEventData(
        date: 'MAY 12',
        title: 'Tech Career Fair',
        time: '10:00 AM',
        tag: 'Free',
      ),
      compact: [
        _CompactEventData(
          date: 'MAY 23',
          title: 'UI/UX Design Workshop',
          subtitle: '2:00 PM · Online · Zoom',
        ),
        _CompactEventData(
          date: 'MAY 28',
          title: 'Student Networking Evening',
          subtitle: '7:00 PM · ₸1,000',
        ),
      ],
    ),
    _EventPanelData(
      featured: _FeaturedEventData(
        date: 'JUN 3',
        title: 'Startup Pitch Day',
        time: '3:00 PM',
        tag: 'Free',
      ),
      compact: [
        _CompactEventData(
          date: 'JUN 10',
          title: 'Resume Review Session',
          subtitle: '11:00 AM · SKSU · Hall B',
        ),
        _CompactEventData(
          date: 'JUN 15',
          title: 'IT Internship Meetup',
          subtitle: '6:00 PM · ₸2,500',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _HorizontalCarousel(
      height: 196,
      itemCount: _panels.length,
      separator: 12,
      itemBuilder: (context, index) {
        final event = index == 0 ? EventItem.sample.first : EventItem.byId('design-workshop')!;
        return GestureDetector(
        onTap: () => onOpenEvent(event),
        child: SizedBox(
          width: HomeTheme.contentWidth,
          child: _EventPanel(data: _panels[index]),
        ),
      );
      },
    );
  }
}

class _EventPanel extends StatelessWidget {
  const _EventPanel({required this.data});

  final _EventPanelData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 170,
          child: _featuredEventCard(data.featured),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 184,
          child: Column(
            children: [
              Expanded(child: _smallEventCard(data.compact[0])),
              const SizedBox(height: 4),
              Expanded(child: _smallEventCard(data.compact[1])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _featuredEventCard(_FeaturedEventData event) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HomeTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EventsSectionDateBadge(text: event.date),
          const SizedBox(height: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                    color: HomeTheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                    color: HomeTheme.placeholder,
                  ),
                ),
              ],
            ),
          ),
          _EventsSectionPillTag(text: event.tag),
        ],
      ),
    );
  }

  Widget _smallEventCard(_CompactEventData event) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: HomeTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EventsSectionDateBadge(text: event.date, compact: true),
          const SizedBox(height: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                    color: HomeTheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  event.subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                    color: HomeTheme.placeholder,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsSectionDateBadge extends StatelessWidget {
  const _EventsSectionDateBadge({required this.text, this.compact = false});

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: HomeTheme.accentSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w500,
          height: 1.1,
          color: HomeTheme.accentLight,
        ),
      ),
    );
  }
}

class _EventsSectionPillTag extends StatelessWidget {
  const _EventsSectionPillTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: HomeTheme.accentSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: HomeTheme.accentLight,
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.title,
    required this.company,
    required this.tags,
    required this.salary,
    this.featured = false,
    this.dark = true,
    this.onTap,
  });

  final String title;
  final String company;
  final List<String> tags;
  final String salary;
  final bool featured;
  final bool dark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? HomeTheme.accent : HomeTheme.surfaceBackground;
    final titleColor = dark ? Colors.white : HomeTheme.accent;
    final companyColor = HomeTheme.companyTint;
    final salaryColor = dark ? Colors.white : HomeTheme.accent;

    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 23 / 18,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 20 / 16,
                        color: companyColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (featured) _featuredBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((t) => _jobTag(t)).toList(),
                ),
              ),
              Text(
                salary,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 20 / 16,
                  color: salaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
        child: card,
      ),
    );
  }

  Widget _featuredBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: HomeTheme.accentSurface,
        borderRadius: BorderRadius.circular(HomeTheme.tagRadius),
      ),
      child: const Text(
        '· Featured',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 18 / 14,
          color: HomeTheme.accent,
        ),
      ),
    );
  }

  Widget _jobTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: HomeTheme.accentSurface,
        borderRadius: BorderRadius.circular(HomeTheme.tagRadius),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 18 / 14,
          color: HomeTheme.accentLight,
        ),
      ),
    );
  }
}

class _HousingCard extends StatelessWidget {
  const _HousingCard({
    required this.title,
    required this.address,
    required this.price,
    required this.tags,
    this.onTap,
  });

  final String title;
  final String address;
  final String price;
  final List<String> tags;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomeTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 23 / 18,
                        color: HomeTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 20 / 16,
                        color: HomeTheme.placeholder,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 20 / 16,
                  color: HomeTheme.accentLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...tags.map(_housingTag),
              _availableTag(),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
        child: card,
      ),
    );
  }

  Widget _housingTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: HomeTheme.accentSurface,
        borderRadius: BorderRadius.circular(HomeTheme.tagRadius),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 18 / 14,
          color: HomeTheme.tagMuted,
        ),
      ),
    );
  }

  Widget _availableTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: HomeTheme.accentSurface,
        borderRadius: BorderRadius.circular(HomeTheme.tagRadius),
      ),
      child: const Text(
        '· Available',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 18 / 14,
          color: HomeTheme.accentLight,
        ),
      ),
    );
  }
}
