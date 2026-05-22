import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';

/// Горизонтальные чипы фильтра (Jobs: локация).
class HomeFilterChips extends StatelessWidget {
  const HomeFilterChips({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 5),
        itemBuilder: (context, index) {
          final selected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? HomeTheme.accent : HomeTheme.chipInactive,
                borderRadius: BorderRadius.circular(HomeTheme.chipRadius),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 20 / 16,
                  color: selected ? Colors.white : HomeTheme.accent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Сегментированный переключатель (Jobs: тип занятости).
class HomeSegmentedFilter extends StatelessWidget {
  const HomeSegmentedFilter({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: HomeTheme.chipInactive,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? HomeTheme.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: selected ? HomeTheme.surfaceBackground : HomeTheme.accent,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
