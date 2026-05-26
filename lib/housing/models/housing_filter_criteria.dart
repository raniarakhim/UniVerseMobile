import 'package:diplomka/housing/models/housing_item.dart';

/// Параметры фильтра Housing (возвращаются с экрана фильтра).
class HousingFilterCriteria {
  const HousingFilterCriteria({
    this.locationQuery = '',
    this.priceMin = 0,
    this.priceMax = 500000,
    this.pricePeriodIndex = 1,
    this.roomIndex = -1,
    this.requiredAmenities = const {},
    this.distanceIndex = -1,
  });

  /// Без активных ограничений (кроме диапазона цены по умолчанию).
  static const HousingFilterCriteria empty = HousingFilterCriteria(
    priceMin: 0,
    priceMax: 500000,
  );

  final String locationQuery;
  final double priceMin;
  final double priceMax;
  final int pricePeriodIndex;
  /// -1 = любое, 0 Studio, 1 = 1 room, 2 = 2–3 rooms
  final int roomIndex;
  final Set<String> requiredAmenities;
  final int distanceIndex;

  int? _parsePrice(HousingItem item) {
    final digits = item.price.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  bool _matchesRoom(HousingItem item) {
    if (roomIndex < 0) return true;
    final label = '${item.roomsLabel} ${item.title}'.toLowerCase();
    switch (roomIndex) {
      case 0:
        return label.contains('studio') || label.contains('loft');
      case 1:
        return label.contains('1 room') || label.contains('1-room');
      case 2:
        return label.contains('2 room') ||
            label.contains('2-room') ||
            label.contains('2-3') ||
            label.contains('apartment');
      default:
        return true;
    }
  }

  bool _matchesAmenity(String required, List<String> itemAmenities) {
    final r = required.toLowerCase();
    for (final a in itemAmenities) {
      final al = a.toLowerCase();
      if (al.contains(r) || r.contains(al)) return true;
      if (r.startsWith('bills') && al.contains('bill')) return true;
      if (r.startsWith('pet') && al.contains('pet')) return true;
    }
    return false;
  }

  bool _matchesLocation(HousingItem item) {
    final q = locationQuery.trim().toLowerCase();
    if (q.isEmpty) return true;
    final hay = '${item.address} ${item.mapAddress}'.toLowerCase();
    return hay.contains(q) || q.contains('shymkent') && hay.contains('shymkent');
  }

  bool matches(HousingItem item) {
    final price = _parsePrice(item);
    if (price != null && (price < priceMin || price > priceMax)) {
      return false;
    }
    if (!_matchesLocation(item)) return false;
    if (!_matchesRoom(item)) return false;
    for (final amenity in requiredAmenities) {
      if (!_matchesAmenity(amenity, item.amenities)) return false;
    }
    return true;
  }

  bool matchesSearch(HousingItem item, String searchQuery) {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return true;
    final hay =
        '${item.title} ${item.address} ${item.amenities.join(' ')} ${item.roomsLabel}'
            .toLowerCase();
    return hay.contains(q);
  }

  HousingFilterCriteria copyWith({
    String? locationQuery,
    double? priceMin,
    double? priceMax,
    int? pricePeriodIndex,
    int? roomIndex,
    Set<String>? requiredAmenities,
    int? distanceIndex,
  }) {
    return HousingFilterCriteria(
      locationQuery: locationQuery ?? this.locationQuery,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      pricePeriodIndex: pricePeriodIndex ?? this.pricePeriodIndex,
      roomIndex: roomIndex ?? this.roomIndex,
      requiredAmenities: requiredAmenities ?? this.requiredAmenities,
      distanceIndex: distanceIndex ?? this.distanceIndex,
    );
  }

  static HousingFilterCriteria fromFilterPageState({
    required String locationQuery,
    required double priceMin,
    required double priceMax,
    required int pricePeriodIndex,
    required int roomIndex,
    required Map<String, bool> amenities,
    required int distanceIndex,
  }) {
    return HousingFilterCriteria(
      locationQuery: locationQuery,
      priceMin: priceMin,
      priceMax: priceMax,
      pricePeriodIndex: pricePeriodIndex,
      roomIndex: roomIndex,
      requiredAmenities: amenities.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toSet(),
      distanceIndex: distanceIndex,
    );
  }
}
