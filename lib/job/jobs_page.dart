import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/job/job_details_page.dart';
import 'package:diplomka/job/models/job_item.dart';
import 'package:diplomka/job/widgets/job_list_tile.dart';
import 'package:diplomka/core/widgets/home_filter_chips.dart';
import 'package:diplomka/core/services/user_profile_service.dart';
import 'package:diplomka/core/widgets/home_detail_app_bar.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({
    super.key,
    this.showBackButton = false,
    this.onBack,
  });

  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  static const _locations = ['Remote', 'Shymkent', 'Almaty', 'Astana', 'Taraz'];
  static const _types = ['All', 'Part-time', 'Full-time', 'Internship'];

  int _locationIndex = 0;
  int _typeIndex = 0;
  bool _searchExpanded = false;
  final _searchFocus = FocusNode();
  String _locationLine = 'Shymkent · May';

  @override
  void initState() {
    super.initState();
    _loadLocationLine();
  }

  Future<void> _loadLocationLine() async {
    final user = await UserProfileService.instance.load();
    if (!mounted) return;
    setState(() => _locationLine = user?.homeSubtitle ?? 'Shymkent · May');
  }

  void _toggleSearch() {
    setState(() => _searchExpanded = !_searchExpanded);
    if (_searchExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    } else {
      _searchFocus.unfocus();
    }
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  void _openJob(JobItem job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JobDetailsPage(job: job)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          HomeTheme.horizontalPadding,
          8,
          HomeTheme.horizontalPadding,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showBackButton) ...[
              HomeDetailAppBar(
                title: 'Jobs',
                onBack: widget.onBack,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              _locationLine,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 15 / 12,
                color: HomeTheme.tagMuted,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Find your job',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 31 / 24,
                color: HomeTheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              '234 open positions',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: HomeTheme.tagMuted,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: _searchExpanded
                    ? _searchField()
                    : _searchBar(),
              ),
            ),
            const SizedBox(height: 16),
            _locationChips(),
            const SizedBox(height: 8),
            _typeSwitcher(),
            const SizedBox(height: 16),
            const Text(
              'TOP PICK',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: HomeTheme.placeholder,
              ),
            ),
            const SizedBox(height: 8),
            _topPickCard(),
            const SizedBox(height: 16),
            const Text(
              'Jobs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: HomeTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...JobItem.allJobs.skip(1).map(
                  (job) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: JobListTile(job: job, onTap: () => _openJob(job)),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return GestureDetector(
      key: const ValueKey('jobs-search-collapsed'),
      onTap: _toggleSearch,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: HomeTheme.accentSurface),
          borderRadius: BorderRadius.circular(51),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, size: 20, color: HomeTheme.accent),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Job title, company',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: HomeTheme.tagMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return Container(
      key: const ValueKey('jobs-search-expanded'),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: HomeTheme.accent),
        borderRadius: BorderRadius.circular(51),
        color: HomeTheme.surfaceBackground,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: HomeTheme.accent),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              focusNode: _searchFocus,
              style: const TextStyle(fontSize: 14, color: HomeTheme.bodyText),
              decoration: const InputDecoration(
                hintText: 'Job title, company',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: HomeTheme.tagMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: _toggleSearch,
            child: const Icon(Icons.close, size: 20, color: HomeTheme.accent),
          ),
        ],
      ),
    );
  }

  Widget _locationChips() {
    return HomeFilterChips(
      labels: _locations,
      selectedIndex: _locationIndex,
      onSelected: (index) => setState(() => _locationIndex = index),
    );
  }

  Widget _typeSwitcher() {
    return HomeSegmentedFilter(
      labels: _types,
      selectedIndex: _typeIndex,
      onSelected: (index) => setState(() => _typeIndex = index),
    );
  }

  Widget _topPickCard() {
    const job = JobItem.frontendKaspi;
    return GestureDetector(
      onTap: () => _openJob(job),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: HomeTheme.primary,
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
                        job.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: HomeTheme.accentSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: HomeTheme.accentSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '· Featured',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: HomeTheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Wrap(
                  spacing: 6,
                  children: job.tags
                      .map(
                        (t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: HomeTheme.infoBox,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const Spacer(),
                Text(
                  job.salaryShort,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
