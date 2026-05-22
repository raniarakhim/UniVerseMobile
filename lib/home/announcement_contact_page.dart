import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/core/widgets/contact_action_row.dart';
import 'package:diplomka/core/widgets/home_detail_app_bar.dart';
import 'package:diplomka/home/models/announcement_item.dart';

class AnnouncementContactPage extends StatelessWidget {
  const AnnouncementContactPage({super.key, required this.item});

  final AnnouncementItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const HomeDetailAppBar(title: 'Contact'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  HomeTheme.horizontalPadding,
                  22,
                  HomeTheme.horizontalPadding,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32.5,
                          backgroundColor: HomeTheme.primary,
                          child: Text(
                            item.organizer.isNotEmpty ? item.organizer[0] : '?',
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
                                item.organizer,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: HomeTheme.primary,
                                ),
                              ),
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: HomeTheme.tagMuted.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, thickness: 1, color: HomeTheme.accentSurface),
                    const SizedBox(height: 16),
                    const Text(
                      'REACH OUT VIA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: HomeTheme.placeholder,
                      ),
                    ),
                    ContactActionRow(
                      icon: const Icon(Icons.mail_outline, size: 28, color: HomeTheme.primary),
                      title: 'Email',
                      subtitle: item.contactEmail,
                      actionLabel: 'Send',
                      onAction: () => _launch(
                        context,
                        Uri.parse('mailto:${item.contactEmail}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _launch(BuildContext context, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть приложение')),
        );
      }
    }
  }
}
