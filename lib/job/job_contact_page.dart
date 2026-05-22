import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/core/widgets/contact_action_row.dart';
import 'package:diplomka/core/widgets/home_detail_app_bar.dart';
import 'package:diplomka/job/models/job_item.dart';

class JobContactPage extends StatelessWidget {
  const JobContactPage({super.key, required this.job});

  final JobItem job;

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
                    _header(),
                    const SizedBox(height: 16),
                    const Divider(height: 1, thickness: 1, color: HomeTheme.accentSurface),
                    const SizedBox(height: 16),
                    const Text(
                      'REACH OUT VIA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 20 / 16,
                        color: HomeTheme.placeholder,
                      ),
                    ),
                    if (job.contactEmail.isNotEmpty)
                      ContactActionRow(
                        icon: const Icon(Icons.mail_outline, size: 28, color: HomeTheme.primary),
                        title: 'Email',
                        subtitle: job.contactEmail,
                        actionLabel: 'Send',
                        onAction: () => _launch(
                          context,
                          Uri.parse('mailto:${job.contactEmail}'),
                        ),
                      ),
                    if (job.contactPhone.isNotEmpty)
                      ContactActionRow(
                        icon: const Icon(Icons.phone_outlined, size: 28, color: HomeTheme.primary),
                        title: 'Phone',
                        subtitle: job.contactPhone,
                        actionLabel: 'Call',
                        onAction: () => _launch(
                          context,
                          Uri.parse('tel:${_digitsOnly(job.contactPhone)}'),
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

  Widget _header() {
    return Row(
      children: [
        CircleAvatar(
          radius: 32.5,
          backgroundColor: HomeTheme.primary,
          child: Text(
            job.logoLetter,
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
                job.company,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: HomeTheme.primary,
                ),
              ),
              Text(
                'HR · ${job.title}',
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
    );
  }

  static String _digitsOnly(String phone) =>
      phone.replaceAll(RegExp(r'[^\d+]'), '');

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
