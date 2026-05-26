import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';

/// Цена с периодом `/mo` под суммой (#A09DC5).
class HousingPriceLabel extends StatelessWidget {
  const HousingPriceLabel({
    super.key,
    required this.price,
    this.amountFontSize = 16,
    this.periodFontSize = 12,
    this.amountFontWeight = FontWeight.w700,
  });

  final String price;
  final double amountFontSize;
  final double periodFontSize;
  final FontWeight amountFontWeight;

  static const _periodColor = Color(0xFFA09DC5);
  static final _periodSuffix = RegExp(r'\s*/mo\s*$', caseSensitive: false);

  @override
  Widget build(BuildContext context) {
    final hasPeriod = _periodSuffix.hasMatch(price);
    final amount = hasPeriod ? price.replaceFirst(_periodSuffix, '').trim() : price;

    final amountStyle = TextStyle(
      fontSize: amountFontSize,
      fontWeight: amountFontWeight,
      color: HomeTheme.accentLight,
    );

    if (!hasPeriod) {
      return Text(amount, textAlign: TextAlign.right, style: amountStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(amount, textAlign: TextAlign.right, style: amountStyle),
        Text(
          '/mo',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: periodFontSize,
            fontWeight: FontWeight.w500,
            color: _periodColor,
          ),
        ),
      ],
    );
  }
}
