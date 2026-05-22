import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/core/widgets/home_detail_app_bar.dart';
import 'package:diplomka/home/announcement_details_page.dart';
import 'package:diplomka/home/models/announcement_item.dart';

class AnnouncementsListPage extends StatelessWidget {
  const AnnouncementsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            const HomeDetailAppBar(title: 'Announcements'),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  HomeTheme.horizontalPadding,
                  12,
                  HomeTheme.horizontalPadding,
                  24,
                ),
                itemCount: AnnouncementItem.carousel.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = AnnouncementItem.carousel[index];
                  return Material(
                    color: HomeTheme.primary,
                    borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnnouncementDetailsPage(
                              key: ValueKey(item.id),
                              item: item,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.category,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: HomeTheme.companyTint,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.homeDeadline,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: HomeTheme.placeholder,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
