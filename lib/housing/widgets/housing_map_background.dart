import 'package:flutter/material.dart';
import 'package:diplomka/housing/models/housing_item.dart';
import 'package:diplomka/housing/widgets/housing_location_map.dart';

/// Фон вкладки Housing — реальная карта OSM с метками объявлений.
class HousingMapBackground extends StatelessWidget {
  const HousingMapBackground({super.key, this.onMarkerTap});

  final void Function(HousingItem item)? onMarkerTap;

  @override
  Widget build(BuildContext context) {
    return HousingLocationMap(
      markers: HousingItem.nearbyList,
      expand: true,
      initialZoom: 12.5,
      showAddressLabel: false,
      interactive: true,
      onMarkerTap: onMarkerTap,
    );
  }
}
