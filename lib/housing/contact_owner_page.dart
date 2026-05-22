import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/housing/models/housing_item.dart';
import 'package:diplomka/core/widgets/home_detail_app_bar.dart';
import 'package:diplomka/core/widgets/contact_action_row.dart';

class ContactOwnerPage extends StatelessWidget {
  const ContactOwnerPage({super.key, required this.item});

  final HousingItem item;

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
            const HomeDetailAppBar(title: 'Contact owner'),
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
                    _ownerHeader(item),
                    const SizedBox(height: 16),
                    const Divider(height: 1, thickness: 1, color: HomeTheme.accentSurface),
                    const SizedBox(height: 16),
                    _propertySection(item),
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
                    ContactActionRow(
                      icon: _phoneIcon(),
                      title: 'Phone',
                      subtitle: item.ownerPhone,
                      actionLabel: 'Call',
                      onAction: () => _launch(context, Uri.parse('tel:${_digitsOnly(item.ownerPhone)}')),
                    ),
                    ContactActionRow(
                      icon: _whatsappIcon(),
                      title: 'WhatsApp',
                      subtitle: item.ownerPhone,
                      actionLabel: 'Open',
                      onAction: () => _launch(
                        context,
                        Uri.parse('https://wa.me/${_digitsOnly(item.ownerPhone)}'),
                      ),
                    ),
                    ContactActionRow(
                      icon: _telegramIcon(),
                      title: 'Telegram',
                      subtitle: item.ownerTelegram,
                      actionLabel: 'Open',
                      onAction: () => _launch(
                        context,
                        Uri.parse('https://t.me/${_telegramUsername(item.ownerTelegram)}'),
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

  Widget _ownerHeader(HousingItem item) {
    final initial = item.ownerName.isNotEmpty ? item.ownerName[0] : '?';
    return Row(
      children: [
        CircleAvatar(
          radius: 32.5,
          backgroundColor: HomeTheme.primary,
          child: Text(
            initial,
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
                item.ownerName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 31 / 24,
                  color: HomeTheme.primary,
                ),
              ),
              Text(
                item.ownerStatus,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 18 / 14,
                  color: HomeTheme.tagMuted.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _propertySection(HousingItem item) {
    final priceLabel = item.priceShort.isNotEmpty ? item.priceShort : item.price;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PROPERTY',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 20 / 16,
                  color: HomeTheme.placeholder,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 23 / 18,
                  color: HomeTheme.primary,
                ),
              ),
              Text(
                item.address,
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
          priceLabel,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 31 / 24,
            color: HomeTheme.accentLight,
          ),
        ),
      ],
    );
  }

  static Widget _phoneIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(color: HomeTheme.primary, shape: BoxShape.circle),
      child: const Icon(Icons.phone, color: Colors.white, size: 20),
    );
  }

  static Widget _whatsappIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF60D669), Color(0xFF1FAF38)],
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.chat, color: Colors.white, size: 22),
    );
  }

  static Widget _telegramIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2AABEE), Color(0xFF229ED9)],
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.send, color: Colors.white, size: 20),
    );
  }

  static String _digitsOnly(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  static String _telegramUsername(String handle) {
    return handle.replaceFirst('@', '');
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

