import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/home/models/announcement_item.dart';
import 'package:diplomka/core/widgets/home_detail_app_bar.dart';
import 'package:diplomka/home/announcement_contact_page.dart';

/// Экран деталей объявления (Figma: Announcement details).
class AnnouncementDetailsPage extends StatelessWidget {
  const AnnouncementDetailsPage({super.key, required this.item});

  final AnnouncementItem item;

  void _openContact(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AnnouncementContactPage(item: item)),
    );
  }

  void _openAnnouncement(BuildContext context, AnnouncementItem target) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AnnouncementDetailsPage(key: ValueKey(target.id), item: target),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final similar = AnnouncementItem.similarTo(item);

    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            const HomeDetailAppBar(title: 'Announcement'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  HomeTheme.horizontalPadding,
                  10,
                  HomeTheme.horizontalPadding,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._buildTopSection(item),
                    _infoGrid(item),
                    const SizedBox(height: HomeTheme.sectionGap),
                    _sectionTitle('About'),
                    const SizedBox(height: 12),
                    Text(
                      item.about,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 18 / 14,
                        color: HomeTheme.tagMuted,
                      ),
                    ),
                    const SizedBox(height: HomeTheme.sectionGap),
                    _sectionTitle('Requirements'),
                    const SizedBox(height: 8),
                    ...item.requirements.map(_requirementLine),
                    const SizedBox(height: HomeTheme.sectionGap),
                    _sectionTitle('Contact'),
                    const SizedBox(height: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openContact(context),
                        borderRadius: BorderRadius.circular(12),
                        child: _contactField(item.contactEmail),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => _openApplyUrl(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HomeTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Apply now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 20 / 16,
                          ),
                        ),
                      ),
                    ),
                    if (similar.isNotEmpty) ...[
                      const SizedBox(height: HomeTheme.sectionGap),
                      _sectionTitle('Similar projects'),
                      const SizedBox(height: 12),
                      ...similar.map(
                        (other) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _similarCard(context, other),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Верх по Figma: бейдж → заголовок → мета → разделитель.
  List<Widget> _buildTopSection(AnnouncementItem item) {
    return [
      _categoryBadge(item.category),
      const SizedBox(height: HomeTheme.sectionGap),
      Text(
        item.title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 26 / 20,
          color: HomeTheme.primary,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        item.meta,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 20 / 16,
          color: HomeTheme.tagMuted.withValues(alpha: 0.8),
        ),
      ),
      const SizedBox(height: HomeTheme.sectionGap),
      const Divider(height: 1, thickness: 1, color: HomeTheme.accentSurface),
      const SizedBox(height: HomeTheme.sectionGap),
    ];
  }

  Widget _categoryBadge(String label) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 14, 4),
      decoration: BoxDecoration(
        color: HomeTheme.chipInactive,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book_outlined, size: 18, color: HomeTheme.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 18 / 14,
              color: HomeTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoGrid(AnnouncementItem item) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _infoTile('DEADLINE', item.deadlineDate)),
            const SizedBox(width: 8),
            Expanded(
              child: _infoTile(
                'AMOUNT',
                item.amountValue,
                valueColor: HomeTheme.clearAction.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _infoTile('TYPE', item.typeValue)),
            const SizedBox(width: 8),
            Expanded(child: _infoTile('ORGANIZER', item.organizer)),
          ],
        ),
      ],
    );
  }

  Widget _infoTile(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: HomeTheme.surfaceBackground,
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 20 / 16,
              color: valueColor ?? HomeTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 20 / 16,
        color: HomeTheme.primary,
      ),
    );
  }

  Widget _requirementLine(String req) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '· ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 26 / 20,
              color: HomeTheme.accent,
            ),
          ),
          Expanded(
            child: Text(
              req,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 26 / 20,
                color: HomeTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openApplyUrl(BuildContext context) async {
    final url = item.applyUrl;
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ссылка на заявку пока не указана')),
      );
      return;
    }
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть ссылку')),
        );
      }
    }
  }

  Widget _contactField(String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: HomeTheme.accentSurface),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text(
            '@',
            style: TextStyle(
              fontSize: 14,
              height: 18 / 14,
              color: HomeTheme.placeholder,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              email,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 15 / 12,
                color: HomeTheme.placeholder,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _similarCard(BuildContext context, AnnouncementItem other) {
    return Material(
      color: HomeTheme.surfaceBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _openAnnouncement(context, other),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      other.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: HomeTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      other.meta,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: HomeTheme.tagMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                other.amountValue,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: HomeTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
