import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/housing/models/housing_item.dart';

class HousingListCard extends StatelessWidget {
  const HousingListCard({
    super.key,
    required this.item,
    this.highlighted = false,
    this.onTap,
  });

  final HousingItem item;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? HomeTheme.surfaceBackground : HomeTheme.pageBackground,
        border: Border.all(
          color: highlighted ? Colors.transparent : HomeTheme.chipInactive,
        ),
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
                      item.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: HomeTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.address,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: HomeTheme.placeholder,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.price,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: HomeTheme.accentLight,
                ),
              ),
            ],
          ),
          if (item.amenities.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: item.amenities.map(_tag).toList(),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
        child: card,
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: highlighted ? HomeTheme.accentSurface : HomeTheme.chipInactive,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: HomeTheme.tagMuted,
        ),
      ),
    );
  }
}
