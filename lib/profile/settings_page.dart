import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/profile/privacy_security_page.dart';
import 'package:diplomka/core/widgets/home_detail_app_bar.dart';
import 'package:diplomka/core/services/auth_service.dart';
import 'package:diplomka/core/services/user_profile_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _push = true;
  bool _email = true;
  bool _jobAlerts = false;
  bool _eventReminders = true;
  bool _housingUpdates = false;
  bool _twoFactor = true;
  bool _showProfile = false;

  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            const HomeDetailAppBar(title: 'Settings'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section('NOTIFICATIONS', [
                      _toggleRow('Push notifications', _push, (v) => setState(() => _push = v)),
                      _toggleRow('Email notifications', _email, (v) => setState(() => _email = v)),
                      _toggleRow('New job alerts', _jobAlerts, (v) => setState(() => _jobAlerts = v)),
                      _toggleRow('Event reminders', _eventReminders, (v) => setState(() => _eventReminders = v)),
                      _toggleRow('Housing updates', _housingUpdates, (v) => setState(() => _housingUpdates = v), showDivider: false),
                    ]),
                    const SizedBox(height: 16),
                    _section('APPEARANCE', [
                      const Text(
                        'Language',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HomeTheme.bodyText),
                      ),
                      const SizedBox(height: 8),
                      _languageField(),
                    ]),
                    const SizedBox(height: 16),
                    _section('PRIVACY & SECURITY', [
                      _linkRow('Change password', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PrivacySecurityPage()),
                        );
                      }),
                      _toggleRow('Two-factor authentication', _twoFactor, (v) => setState(() => _twoFactor = v)),
                      _toggleRow(
                        'Show profile to employers',
                        _showProfile,
                        (v) => setState(() => _showProfile = v),
                        showDivider: false,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _section('ABOUT', [
                      _linkRow('Version', () {}),
                      _linkRow('Terms of Service', () {}),
                      _linkRow('Privacy Policy', () {}),
                      _linkRow('Delete account', _confirmDeleteAccount, destructive: true, showDivider: false),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: HomeTheme.tagMuted),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged, {bool showDivider = true}) {
    return Column(
      children: [
        SizedBox(
          height: 19,
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black)),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: HomeTheme.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: HomeTheme.accentSurface,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: HomeTheme.accentSurface.withValues(alpha: 0.7)),
          ),
      ],
    );
  }

  Widget _linkRow(String label, VoidCallback onTap, {bool destructive = false, bool showDivider = true}) {
    final color = destructive ? HomeTheme.error : Colors.black;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 24,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: destructive ? 16 : 13,
                      fontWeight: destructive ? FontWeight.w500 : FontWeight.w400,
                      color: color,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, size: 24, color: destructive ? HomeTheme.error : HomeTheme.tagMuted),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: HomeTheme.accentSurface.withValues(alpha: 0.7)),
          ),
      ],
    );
  }

  Widget _languageField() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: HomeTheme.accentSurface),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _language,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: HomeTheme.tagMuted),
          items: const [
            DropdownMenuItem(value: 'English', child: Text('English')),
            DropdownMenuItem(value: 'Қазақша', child: Text('Қазақша')),
            DropdownMenuItem(value: 'Русский', child: Text('Русский')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _language = v);
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: HomeTheme.error)),
          ),
        ],
      ),
    );
    if (delete != true || !mounted) return;
    try {
      await UserProfileService.instance.deleteAccount(context);
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
