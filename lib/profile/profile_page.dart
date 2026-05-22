import 'package:flutter/material.dart';
import 'package:diplomka/core/models/app_user.dart';
import 'package:diplomka/core/services/user_profile_service.dart';
import 'package:diplomka/profile/basic_info_page.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/profile/my_applications_page.dart';
import 'package:diplomka/profile/notifications_page.dart';
import 'package:diplomka/profile/privacy_security_page.dart';
import 'package:diplomka/profile/saved_page.dart';
import 'package:diplomka/profile/settings_page.dart';
import 'package:diplomka/profile/widgets/profile_menu_row.dart';
import 'package:diplomka/core/services/saved_events_service.dart';
import 'package:diplomka/core/services/saved_housing_service.dart';
import 'package:diplomka/core/services/saved_items_registry.dart';
import 'package:diplomka/core/services/saved_jobs_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AppUser? _user;

  final _savedEvents = SavedEventsService.instance;
  final _savedJobs = SavedJobsService.instance;
  final _savedHousing = SavedHousingService.instance;

  @override
  void initState() {
    super.initState();
    _loadUser();
    for (final s in [_savedEvents, _savedJobs, _savedHousing]) {
      s.addListener(_onSavedChanged);
    }
  }

  @override
  void dispose() {
    for (final s in [_savedEvents, _savedJobs, _savedHousing]) {
      s.removeListener(_onSavedChanged);
    }
    super.dispose();
  }

  void _onSavedChanged() {
    if (mounted) setState(() {});
  }

  void _openSaved() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedPage()),
    );
  }

  Future<void> _loadUser() async {
    final user = await UserProfileService.instance.load();
    if (mounted) setState(() => _user = user);
  }

  Future<void> _openBasicInfo() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BasicInfoPage()),
    );
    await _loadUser();
  }

  void _openMyApplications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyApplicationsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
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
              _buildHeader(context),
              const SizedBox(height: 16),
              _userCard(context),
              const SizedBox(height: 16),
              _section(
                title: 'YOUR INTERESTS',
                children: [
                  ProfileMenuRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Basic Info',
                    onTap: _openBasicInfo,
                  ),
                  ProfileMenuRow(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifications',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsPage()),
                    ),
                  ),
                  ProfileMenuRow(
                    icon: Icons.lock_outline_rounded,
                    label: 'Pivacy and Security',
                    showDivider: false,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacySecurityPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _section(
                title: 'ACTIVITY',
                children: [
                  ProfileMenuRow(
                    icon: Icons.favorite_border_rounded,
                    label: 'Saved',
                    badge: SavedItemsRegistry.totalCount > 0
                        ? '${SavedItemsRegistry.totalCount}'
                        : null,
                    onTap: _openSaved,
                  ),
                  ProfileMenuRow(
                    icon: Icons.menu_book_outlined,
                    label: 'My Applications',
                    badge: '3',
                    onTap: _openMyApplications,
                  ),
                  ProfileMenuRow(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    showDivider: false,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _logoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 36 / 28,
              color: HomeTheme.profileTitle,
            ),
          ),
        ),
        Material(
          color: HomeTheme.surfaceBackground,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _openBasicInfo,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.edit_outlined, size: 24, color: HomeTheme.accent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _userCard(BuildContext context) {
    final name = _user?.fullName.isNotEmpty == true ? _user!.fullName : '...';
    final initials = _user?.initials ?? '?';
    final university = _user?.university.isNotEmpty == true ? _user!.university : 'SKSU';
    final yearTag = _user?.yearOfStudy.isNotEmpty == true ? _user!.yearOfStudy : 'Student';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HomeTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  color: HomeTheme.infoBox,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 26 / 20,
                        color: HomeTheme.surfaceBackground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _tag(yearTag),
                        const SizedBox(width: 6),
                        _tag(university),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, thickness: 0.3, color: HomeTheme.placeholder.withValues(alpha: 0.5)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: _stat('3', 'APPLIED')),
              _verticalDivider(),
              Expanded(
                child: GestureDetector(
                  onTap: _openSaved,
                  child: _stat('${SavedItemsRegistry.totalCount}', 'SAVED'),
                ),
              ),
              _verticalDivider(),
              Expanded(child: _stat('2', 'EVENTS')),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: _openMyApplications,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: HomeTheme.accentLight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'View my applications',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: HomeTheme.accentSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: HomeTheme.profileTitle,
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: HomeTheme.surfaceBackground,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: HomeTheme.placeholder.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 61,
      color: HomeTheme.placeholder.withValues(alpha: 0.5),
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: HomeTheme.tagMuted.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        Column(children: children),
      ],
    );
  }

  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: () => _confirmLogout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: HomeTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HomeTheme.cardRadius)),
        ),
        child: const Text(
          'Log out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log out')),
        ],
      ),
    );
    if (leave == true && context.mounted) {
      await UserProfileService.instance.logout(context);
    }
  }
}
