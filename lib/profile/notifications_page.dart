import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/profile/models/notification_item.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<NotificationItem> _today;
  late List<NotificationItem> _yesterday;

  @override
  void initState() {
    super.initState();
    _today = List.of(NotificationItem.today);
    _yesterday = List.of(NotificationItem.yesterday);
  }

  void _clearAll() {
    setState(() {
      _today = [];
      _yesterday = [];
    });
  }

  void _toggleToday(int index) {
    setState(() {
      final item = _today[index];
      _today[index] = NotificationItem(
        title: item.title,
        body: item.body,
        time: item.time,
        checked: !item.checked,
        logoColor: item.logoColor,
        logoLetter: item.logoLetter,
        highlighted: item.highlighted,
      );
    });
  }

  void _toggleYesterday(int index) {
    setState(() {
      final item = _yesterday[index];
      _yesterday[index] = NotificationItem(
        title: item.title,
        body: item.body,
        time: item.time,
        checked: !item.checked,
        logoColor: item.logoColor,
        logoLetter: item.logoLetter,
        highlighted: item.highlighted,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 12),
                children: [
                  if (_today.isNotEmpty) ...[
                    _sectionLabel('TODAY'),
                    ...List.generate(_today.length, (i) => _notificationTile(_today[i], () => _toggleToday(i))),
                    _sectionDivider(),
                  ],
                  if (_yesterday.isNotEmpty) ...[
                    _sectionLabel('YESTERDAY'),
                    ...List.generate(
                      _yesterday.length,
                      (i) => _notificationTile(_yesterday[i], () => _toggleYesterday(i)),
                    ),
                  ],
                  if (_today.isEmpty && _yesterday.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('No notifications', style: TextStyle(color: HomeTheme.tagMuted)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Material(
              color: HomeTheme.surfaceBackground,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.arrow_back_ios_new, size: 20, color: HomeTheme.primary),
                ),
              ),
            ),
            const Expanded(
              child: Text(
                'Notifications',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: HomeTheme.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: _clearAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Clear all',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: HomeTheme.clearAction),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: HomeTheme.tagMuted),
      ),
    );
  }

  Widget _sectionDivider() {
    return Divider(height: 24, thickness: 0.3, color: HomeTheme.placeholder.withValues(alpha: 0.5));
  }

  Widget _notificationTile(NotificationItem item, VoidCallback onToggle) {
    return Material(
      color: item.highlighted ? HomeTheme.surfaceBackground : Colors.white,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _checkbox(item.checked, onToggle),
              const SizedBox(width: 12),
              _avatar(item),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
                          ),
                        ),
                        Text(
                          item.time,
                          style: TextStyle(fontSize: 12, color: HomeTheme.tagMuted.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: TextStyle(fontSize: 12, height: 15 / 12, color: HomeTheme.tagMuted.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkbox(bool checked, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: checked ? HomeTheme.primary : Colors.transparent,
          border: Border.all(color: HomeTheme.primary, width: 1.5),
        ),
        child: checked ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
      ),
    );
  }

  Widget _avatar(NotificationItem item) {
    if (item.logoColor != null && item.logoLetter != null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: item.logoColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: HomeTheme.surfaceBackground),
        ),
        alignment: Alignment.center,
        child: Text(
          item.logoLetter!,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: HomeTheme.chipInactive,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
