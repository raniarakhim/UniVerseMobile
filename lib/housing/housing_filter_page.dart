import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/housing/models/housing_filter_criteria.dart';
import 'package:diplomka/core/widgets/donut_slider_thumb_shape.dart';
import 'package:diplomka/core/widgets/home_detail_app_bar.dart';

class HousingFilterPage extends StatefulWidget {
  const HousingFilterPage({super.key, this.initial});

  final HousingFilterCriteria? initial;

  @override
  State<HousingFilterPage> createState() => _HousingFilterPageState();
}

class _HousingFilterPageState extends State<HousingFilterPage> {
  late final TextEditingController _locationCtrl;

  late double _priceMin;
  late double _priceMax;
  late int _pricePeriod;
  late int _roomIndex;

  late final Map<String, bool> _amenities;

  late int _distanceIndex;

  static const _pricePeriods = ['Per hour', 'Per month', 'Per shift'];
  static const _rooms = ['Studio', '1 room', '2-3 rooms'];
  static const _distances = ['5 min', '10-15 min', '15-30 min', '40 min', 'Any'];

  @override
  void initState() {
    super.initState();
    final initial = widget.initial ?? HousingFilterCriteria.empty;
    _locationCtrl = TextEditingController(
      text: initial.locationQuery.isNotEmpty
          ? initial.locationQuery
          : 'Shymkent, Kazakhstan',
    );
    _priceMin = initial.priceMin > 0 ? initial.priceMin : 100000;
    _priceMax = initial.priceMax < 500000 ? initial.priceMax : 300000;
    _pricePeriod = initial.pricePeriodIndex >= 0 ? initial.pricePeriodIndex : 1;
    _roomIndex = initial.roomIndex >= 0 ? initial.roomIndex : 2;
    _distanceIndex = initial.distanceIndex >= 0 ? initial.distanceIndex : 1;
    _amenities = {
      'Wi-Fi': initial.requiredAmenities.contains('Wi-Fi'),
      'Furnished': initial.requiredAmenities.contains('Furnished'),
      'Parking': initial.requiredAmenities.contains('Parking'),
      'Bills included': initial.requiredAmenities.contains('Bills included'),
      'Pet friendly': initial.requiredAmenities.contains('Pet friendly'),
    };
    if (initial.requiredAmenities.isEmpty) {
      _amenities['Wi-Fi'] = true;
      _amenities['Parking'] = true;
      _amenities['Pet friendly'] = true;
    }
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  HousingFilterCriteria _buildCriteria() {
    return HousingFilterCriteria.fromFilterPageState(
      locationQuery: _locationCtrl.text,
      priceMin: _priceMin,
      priceMax: _priceMax,
      pricePeriodIndex: _pricePeriod,
      roomIndex: _roomIndex,
      amenities: _amenities,
      distanceIndex: _distanceIndex,
    );
  }

  void _onApply() {
    Navigator.pop(context, _buildCriteria());
  }

  void _onReset() {
    Navigator.pop(context, HousingFilterCriteria.empty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            const HomeDetailAppBar(title: 'Housing Filter'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  HomeTheme.horizontalPadding,
                  8,
                  HomeTheme.horizontalPadding,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Location'),
                    const SizedBox(height: 8),
                    _textField(_locationCtrl),
                    const SizedBox(height: 20),
                    _sectionTitle('Min price / Max price, ₸'),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: HomeTheme.accent,
                        inactiveTrackColor: HomeTheme.chipInactive,
                        trackHeight: 4,
                        overlayShape: SliderComponentShape.noOverlay,
                        rangeThumbShape: DonutRangeSliderThumbShape(
                          ringColor: HomeTheme.accent,
                        ),
                      ),
                      child: RangeSlider(
                        values: RangeValues(_priceMin, _priceMax),
                        min: 50000,
                        max: 500000,
                        divisions: 18,
                        onChanged: (v) => setState(() {
                          _priceMin = v.start;
                          _priceMax = v.end;
                        }),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(child: _priceBox('From', '₸${_priceMin.toInt()}')),
                        const SizedBox(width: 8),
                        Expanded(child: _priceBox('To', '₸${_priceMax.toInt()}')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: List.generate(_pricePeriods.length, (i) {
                        return _selectChip(_pricePeriods[i], _pricePeriod == i, () {
                          setState(() => _pricePeriod = i);
                        });
                      }),
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle('Rooms'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: List.generate(_rooms.length, (i) {
                        return _selectChip(_rooms[i], _roomIndex == i, () {
                          setState(() => _roomIndex = i);
                        });
                      }),
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle('Amenities'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: HomeTheme.accentSurface),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: _amenities.keys.map((key) {
                          final last = key == _amenities.keys.last;
                          return Column(
                            children: [
                              _amenityRow(key, _amenities[key]!),
                              if (!last)
                                const Divider(height: 1, color: HomeTheme.accentSurface),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle('Distance to University'),
                    const SizedBox(height: 8),
                    _dropdownField('Choose your dwelling'),
                    const SizedBox(height: 12),
                    ...List.generate(_distances.length, (i) {
                      return _distanceRow(_distances[i], _distanceIndex == i, () {
                        setState(() => _distanceIndex = i);
                      });
                    }),
                  ],
                ),
              ),
            ),
            _bottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Color(0xFF0F0E2A),
      ),
    );
  }

  Widget _textField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: HomeTheme.accentSurface),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: HomeTheme.accentSurface),
        ),
      ),
    );
  }

  Widget _dropdownField(String hint) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: HomeTheme.accentSurface),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(hint, style: const TextStyle(fontSize: 16, color: Color(0xFF78716C))),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down, color: HomeTheme.primary),
        ],
      ),
    );
  }

  Widget _priceBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.11),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: HomeTheme.tagMuted)),
          Text(
            value,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: Color(0xFF0F0E2A)),
          ),
        ],
      ),
    );
  }

  Widget _selectChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? HomeTheme.accent : Colors.transparent),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: selected
              ? null
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.check, size: 16, color: HomeTheme.accent),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: selected ? HomeTheme.accent : HomeTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _amenityRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: HomeTheme.accent)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: (v) => setState(() => _amenities[label] = v),
            activeThumbColor: Colors.white,
            activeTrackColor: HomeTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _distanceRow(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 0),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: HomeTheme.accent)),
            const Spacer(),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? HomeTheme.primary : Colors.transparent,
                border: Border.all(color: HomeTheme.primary, width: 1.5),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: _onReset,
                style: OutlinedButton.styleFrom(
                  backgroundColor: HomeTheme.chipInactive,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                  ),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HomeTheme.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
