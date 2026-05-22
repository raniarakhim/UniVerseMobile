import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/housing/housing_details_page.dart';
import 'package:diplomka/housing/models/housing_item.dart';
import 'package:diplomka/housing/widgets/housing_list_card.dart';

class HousingResultsPage extends StatelessWidget {
  const HousingResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: HomeTheme.horizontalPadding),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${HousingItem.nearbyList.length}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: HomeTheme.accentLight,
                      ),
                    ),
                    const TextSpan(
                      text: ' places nearby',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: HomeTheme.accentLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: HomeTheme.horizontalPadding),
                itemCount: HousingItem.nearbyList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = HousingItem.nearbyList[index];
                  return HousingListCard(
                    item: item,
                    highlighted: index == 1,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HousingDetailsPage(
                            key: ValueKey(item.id),
                            item: item,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(HomeTheme.horizontalPadding),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                    ),
                  ),
                  child: const Text(
                    'Show on map',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
